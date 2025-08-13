import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'auth_token_manager.dart';
import 'api_service.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/env_constant.dart';

class MessagingService {
  // Send a notification/message to another user
  static Future<bool> sendMessage({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String message,
    required String messageType, // 'text', 'call_request', 'call_ended', etc.
    Map<String, dynamic>? data,
  }) async {
    try {
      if (_channel == null || !_isRegistered) {
        print('WebSocket not connected or user not registered.');
        return false;
      }
      final msg = {
        'recipientId': recipientId,
        'senderId': senderId,
        'senderName': senderName,
        'message': message,
        'messageType': messageType,
        'timestamp': DateTime.now().toIso8601String(),
        'data': data ?? {},
      };
      _channel!.sink.add(jsonEncode(msg));
      // Store message locally
      await _storeMessageLocally(senderId, recipientId, msg);
      print('✅ Message sent via WebSocket and stored locally');
      return true;
    } catch (e) {
      print('❌ Error sending WebSocket message: $e');
      return false;
    }
  }

  static WebSocketChannel? _channel;
  static bool _isRegistered = false;
  static String? _currentUserId;
  static Map<String, List<Map<String, dynamic>>> _localMessages = {};

  // Connect to WebSocket (no user registration yet)
  static Future<void> initialize() async {
    if (_channel != null) return; // Already connected
    try {
      final wsUrl = _getWebSocketUrl();
      print('Connecting to notification WebSocket: $wsUrl');
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isRegistered = false;

      // Listen for incoming messages with robust error handling
      _channel!.stream.listen(
        (message) {
          print('Received notification: $message');
          // Optionally handle incoming messages here
        },
        onError: (e, stackTrace) {
          print('WebSocket error: $e');
          if (stackTrace != null) {
            print('WebSocket error stack: $stackTrace');
          }
          _isRegistered = false;
          // Do not rethrow, app should continue running
        },
        onDone: () {
          print('WebSocket connection closed');
          _isRegistered = false;
        },
        cancelOnError: true,
      );

      // Catch any uncaught errors from the stream (for extra safety)
      _channel!.stream.handleError((error, stackTrace) {
        print('WebSocket stream uncaught error: $error');
        if (stackTrace != null) {
          print('WebSocket stream error stack: $stackTrace');
        }
        // Do not rethrow, app should continue running
      });

      // Load local messages from storage
      await _loadLocalMessages();
    } catch (e, stackTrace) {
      print('❌ Error initializing WebSocket messaging service: $e');
      print('Stack trace: $stackTrace');
      // Do not rethrow, app should continue running
    }
  }

  // Register user after login
  static Future<void> registerUser({required String userId}) async {
    if (_channel == null) await initialize();
    _currentUserId = userId;
    final registerMsg = 'REGISTER_USER:$userId';
    _channel!.sink.add(registerMsg);
    _isRegistered = true;
  }

  // Helper to get the WebSocket URL from backend base URL
  static String _getWebSocketUrl() {
    // Always use the correct WebSocket endpoint for notifications
    return getWebSocketNotificationUrl();
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
  static Future<bool> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      // Update local messages
      final participants = conversationId.split('_')..sort();
      final conversationKey = '${participants[0]}_${participants[1]}';

      if (_localMessages[conversationKey] != null) {
        for (final message in _localMessages[conversationKey]!) {
          message['read'] = true;
        }
        await _saveLocalMessages();
      }

      // Try to update backend
      try {
        final headers = await AuthTokenManager.getAuthHeaders();
        await http.patch(
          Uri.parse('${ApiConstants.baseUrl}messages/mark-read'),
          headers: {...headers, 'Content-Type': 'application/json'},
          body: jsonEncode({'conversationId': conversationId}),
        );
        return true;
      } catch (e) {
        print('Backend not available for marking messages as read: $e');
        return false;
      }
    } catch (e) {
      print('❌ Error marking messages as read: $e');
      return false;
    }
  }

  // Send video call invitation via WebSocket
  static Future<void> sendVideoCallInvitation({
    required String recipientId,
    required String callerId,
    required String callerName,
    required String callId,
    required bool isVideoCall,
  }) async {
    try {
      print(
        '📹 Sending ${isVideoCall ? 'video' : 'audio'} call invitation via WebSocket...',
      );
      await MessagingService.sendMessage(
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
    } catch (e) {
      print('❌ Error sending call invitation: $e');
    }
  }

  // Get platform-specific features availability
  static Map<String, bool> getPlatformFeatures() {
    return {
      'videoCall': true,
      'audioCall': true,
      'sms': !kIsWeb,
      'pushNotifications': true, // Now via WebSocket
      'backgroundMessages': true,
      'webNotifications': kIsWeb,
    };
  }

  // Send notification to a user via HTTP endpoint that triggers WebSocket delivery
  static Future<bool> sendHttpWebSocketNotification({
    required String userId,
    required String message,
    Map<String, String>? extraHeaders,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
        ...?extraHeaders,
      };
      final url =
          '${ApiConstants.baseUrl}notifications/ws/send-to-user/$userId';
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'message': message}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final resp = jsonDecode(response.body);
        print(
          '✅ WebSocket notification sent: \\${resp['message'] ?? response.body}',
        );
        return true;
      } else {
        print(
          '❌ Failed to send WebSocket notification: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error sending WebSocket notification: $e');
      return false;
    }
  }
}

// Import this to avoid circular dependency
