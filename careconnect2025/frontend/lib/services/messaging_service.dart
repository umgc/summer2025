import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'auth_token_manager.dart';
import 'api_service.dart';
import 'firebase_auth_service.dart';

class MessagingService {
  static const String _fcmUrl =
      'https://fcm.googleapis.com/v1/projects/careconnectptdemo/messages:send';

  static FirebaseMessaging? _messaging;
  static String? _currentUserToken;
  static Map<String, List<Map<String, dynamic>>> _localMessages = {};

  // Initialize messaging service with lazy loading
  static Future<void> initialize() async {
    // Return immediately if already initialized
    if (_messaging != null) return;

    try {
      // Initialize Firebase Cloud Messaging
      print('📱 Initializing Firebase Cloud Messaging...');

      // Firebase should already be initialized in main()
      _messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }

      // Get the token (with web-specific handling)
      if (kIsWeb) {
        // For web, we might need to provide VAPID key
        _currentUserToken = await _messaging!.getToken(
          vapidKey:
              'BKn4_bZ8g2g7Qf8WlFxl6c2GkGtRfXq8w5A6Ly4R9s8X7NdJ5Q3zP1mO6kH4L2cV8sY7wE1nU9rT3vI2bN0pM6Q', // Replace with your VAPID key
        );
      } else {
        _currentUserToken = await _messaging!.getToken();
      }
      print('FCM Token: $_currentUserToken');

      // Set up foreground message handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
            'Message also contained a notification: ${message.notification}',
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Load local messages from storage
      await _loadLocalMessages();
    } catch (e) {
      print('❌ Error initializing messaging service: $e');
    }
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }

  // Load local messages from SharedPreferences
  static Future<void> _loadLocalMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('local_messages');
      if (messagesJson != null) {
        final decoded = jsonDecode(messagesJson) as Map<String, dynamic>;
        _localMessages = decoded.map(
          (key, value) => MapEntry(key, List<Map<String, dynamic>>.from(value)),
        );
      }
    } catch (e) {
      print('Error loading local messages: $e');
    }
  }

  // Save local messages to SharedPreferences
  static Future<void> _saveLocalMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_messages', jsonEncode(_localMessages));
    } catch (e) {
      print('Error saving local messages: $e');
    }
  }

  // Get FCM token for current user
  static Future<String?> getFCMToken() async {
    try {
      if (_messaging == null) {
        await initialize();
      }
      return await _messaging!.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Get FCM access token using service account
  static Future<String?> _getAccessToken() async {
    try {
      return await FirebaseAuthService.getAccessToken();
    } catch (e) {
      print('❌ Error getting access token: $e');
      return null;
    }
  }

  // Send message between caregiver and patient
  static Future<bool> sendMessage({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String message,
    required String messageType, // 'text', 'call_request', 'call_ended'
    Map<String, dynamic>? data, // Additional data for the message
  }) async {
    try {
      final messageData = {
        'id': _generateMessageId(),
        'senderId': senderId,
        'senderName': senderName,
        'recipientId': recipientId,
        'message': message,
        'messageType': messageType,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };

      // Store message locally
      await _storeMessageLocally(senderId, recipientId, messageData);

      // Try to send FCM notification (will work when backend is ready)
      try {
        await _sendFCMNotification(recipientId, senderName, message);
      } catch (e) {
        print('FCM notification failed (backend not ready): $e');
        // Continue - message is stored locally
      }

      // Try to store in backend (will fail gracefully if backend not ready)
      try {
        await _storeMessageInDatabase(messageData);
      } catch (e) {
        print('Backend storage failed (backend not ready): $e');
        // Continue - message is stored locally
      }

      print('✅ Message sent successfully (stored locally)');
      return true;
    } catch (e) {
      print('❌ Error sending message: $e');
      return false;
    }
  }

  // Generate unique message ID
  static String _generateMessageId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString(8)}';
  }

  // Generate random string
  static String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Store message locally
  static Future<void> _storeMessageLocally(
    String senderId,
    String recipientId,
    Map<String, dynamic> messageData,
  ) async {
    try {
      // Create conversation key (consistent ordering)
      final participants = [senderId, recipientId]..sort();
      final conversationKey = '${participants[0]}_${participants[1]}';

      if (_localMessages[conversationKey] == null) {
        _localMessages[conversationKey] = [];
      }

      _localMessages[conversationKey]!.add(messageData);

      // Keep only last 100 messages per conversation
      if (_localMessages[conversationKey]!.length > 100) {
        _localMessages[conversationKey] = _localMessages[conversationKey]!
            .skip(_localMessages[conversationKey]!.length - 100)
            .toList();
      }

      await _saveLocalMessages();
    } catch (e) {
      print('Error storing message locally: $e');
    }
  }

  // Send FCM notification
  static Future<void> _sendFCMNotification(
    String recipientId,
    String senderName,
    String message,
  ) async {
    try {
      final accessToken = await _getAccessToken();
      if (accessToken == null) {
        print('⚠️ FCM notification skipped - no access token available');
        print(
          '   This is normal if Firebase service account is not configured',
        );
        return;
      }

      final recipientToken = await _getRecipientFCMToken(recipientId);
      if (recipientToken == null) return;

      final messageData = {
        'message': {
          'token': recipientToken,
          'notification': {
            'title': 'New Message from $senderName',
            'body': message,
          },
          'data': {
            'type': 'text',
            'senderId': recipientId,
            'senderName': senderName,
            'message': message,
            'timestamp': DateTime.now().toIso8601String(),
          },
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'careconnect_messages',
              'sound': 'default',
            },
          },
          'apns': {
            'payload': {
              'aps': {'sound': 'default', 'badge': 1},
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(messageData),
      );

      if (response.statusCode == 200) {
        print('✅ FCM notification sent successfully');
      } else {
        print('❌ Failed to send FCM notification: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending FCM notification: $e');
    }
  }

  // Get recipient's FCM token from backend
  static Future<String?> _getRecipientFCMToken(String userId) async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}users/$userId/fcm-token'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fcmToken'];
      }
      return null;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  // Store message in backend database
  static Future<void> _storeMessageInDatabase(
    Map<String, dynamic> messageData,
  ) async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}messages'),
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(messageData),
      );

      if (response.statusCode == 201) {
        print('✅ Message stored in database');
      } else {
        print('❌ Failed to store message: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error storing message: $e');
      // Don't throw - message is already stored locally
    }
  }

  // Get conversation messages between two users
  static Future<List<Map<String, dynamic>>> getConversation({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      // First try to get messages from local storage
      final participants = [userId1, userId2]..sort();
      final conversationKey = '${participants[0]}_${participants[1]}';

      List<Map<String, dynamic>> messages = [];

      if (_localMessages[conversationKey] != null) {
        messages = List<Map<String, dynamic>>.from(
          _localMessages[conversationKey]!,
        );
      }

      // Try to get messages from backend (will fail gracefully if not available)
      try {
        final headers = await AuthTokenManager.getAuthHeaders();
        final response = await http.get(
          Uri.parse(
            '${ApiConstants.baseUrl}messages/conversation?user1=$userId1&user2=$userId2&limit=$limit',
          ),
          headers: headers,
        );

        if (response.statusCode == 200) {
          final backendData = jsonDecode(response.body);
          final backendMessages = List<Map<String, dynamic>>.from(backendData);

          // Merge backend messages with local messages
          final allMessages = <String, Map<String, dynamic>>{};

          // Add backend messages
          for (final msg in backendMessages) {
            allMessages[msg['id'] ?? msg['timestamp']] = msg;
          }

          // Add local messages (will overwrite backend messages with same id)
          for (final msg in messages) {
            allMessages[msg['id'] ?? msg['timestamp']] = msg;
          }

          messages = allMessages.values.toList();
        }
      } catch (e) {
        print('Backend not available, using local messages only: $e');
      }

      // Sort by timestamp
      messages.sort((a, b) {
        final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
        final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
        return aTime.compareTo(bTime);
      });

      return messages.take(limit).toList();
    } catch (e) {
      print('❌ Error getting conversation: $e');
      return [];
    }
  }

  // Mark messages as read
  static Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      // Update local messages
      final participants = conversationId.split('_')..sort();
      final conversationKey = '${participants[0]}_${participants[1]}';

      if (_localMessages[conversationKey] != null) {
        for (final message in _localMessages[conversationKey]!) {
          if (message['recipientId'] == userId) {
            message['read'] = true;
          }
        }
        await _saveLocalMessages();
      }

      // Try to update backend
      try {
        final headers = await AuthTokenManager.getAuthHeaders();
        await http.patch(
          Uri.parse('${ApiConstants.baseUrl}messages/mark-read'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'conversationId': conversationId,
            'userId': userId,
          }),
        );
      } catch (e) {
        print('Backend not available for marking messages as read: $e');
      }
    } catch (e) {
      print('❌ Error marking messages as read: $e');
    }
  }

  // Send video call invitation via FCM (cross-platform)
  static Future<bool> sendVideoCallInvitation({
    required String recipientId,
    required String callerId,
    required String callerName,
    required String callId,
    required bool isVideoCall,
  }) async {
    try {
      print('📹 Sending ${isVideoCall ? 'video' : 'audio'} call invitation...');

      final success = await sendMessage(
        recipientId: recipientId,
        senderId: callerId,
        senderName: callerName,
        message: isVideoCall ? 'Incoming video call' : 'Incoming audio call',
        messageType: 'call_request',
        data: {
          'callId': callId,
          'callerId': callerId,
          'callerName': callerName,
          'isVideoCall': isVideoCall.toString(),
          'action': 'call_invitation',
        },
      );

      return success;
    } catch (e) {
      print('❌ Error sending call invitation: $e');
      return false;
    }
  }

  // Get platform-specific features availability
  static Map<String, bool> getPlatformFeatures() {
    return {
      'videoCall': true, // Available on all platforms with Zego
      'audioCall': true, // Available on all platforms with Zego
      'sms': !kIsWeb, // SMS only available on mobile platforms
      'pushNotifications': true, // FCM available on all platforms
      'backgroundMessages': true, // FCM handles background on all platforms
      'webNotifications': kIsWeb, // Web-specific notifications
    };
  }
}

// Import this to avoid circular dependency
