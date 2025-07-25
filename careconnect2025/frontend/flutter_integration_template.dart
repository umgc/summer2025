// CareConnect Flutter Integration Template
// Copy this code into your Flutter project and customize as needed

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:async';

// ===========================
// 1. API SERVICE CLASS
// ===========================

class CareConnectApiService {
  static const String baseUrl = 'http://localhost:8080/api'; // Change for production
  String? _authToken;
  
  // Singleton pattern
  static final CareConnectApiService _instance = CareConnectApiService._internal();
  factory CareConnectApiService() => _instance;
  CareConnectApiService._internal();
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  String? get authToken => _authToken;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  // Authentication
  Future<ApiResponse<LoginResponse>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final loginResponse = LoginResponse.fromJson(data['data']);
        setAuthToken(loginResponse.token);
        return ApiResponse.success(loginResponse);
      } else {
        return ApiResponse.error(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // AI Chat
  Future<ApiResponse<AIChatSession>> startAIChat(String message, {String provider = 'openai'}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai-chat/start'),
        headers: _headers,
        body: json.encode({
          'provider': provider,
          'contextType': 'general_health',
          'initialMessage': message,
        }),
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(AIChatSession.fromJson(data['data']));
      } else {
        return ApiResponse.error(data['message'] ?? 'Failed to start AI chat');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  Future<ApiResponse<ChatMessage>> continueAIChat(String sessionId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai-chat/continue'),
        headers: _headers,
        body: json.encode({
          'sessionId': sessionId,
          'message': message,
        }),
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(ChatMessage.fromJson(data['data']['message']));
      } else {
        return ApiResponse.error(data['message'] ?? 'Failed to continue chat');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  // WebSocket Operations
  Future<ApiResponse<bool>> sendCallInvitation({
    required String recipientId,
    required String senderName,
    required String callId,
    bool isVideoCall = true,
    String callType = 'general',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/websocket/call-invitation'),
        headers: _headers,
        body: json.encode({
          'recipientId': recipientId,
          'senderId': 'current-user-id', // Replace with actual current user ID
          'senderName': senderName,
          'callId': callId,
          'isVideoCall': isVideoCall,
          'callType': callType,
        }),
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error(data['message'] ?? 'Failed to send call invitation');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  Future<ApiResponse<bool>> sendSMSNotification({
    required String recipientId,
    required String senderName,
    required String message,
    String messageType = 'general',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/websocket/sms-notification'),
        headers: _headers,
        body: json.encode({
          'recipientId': recipientId,
          'senderId': 'current-user-id', // Replace with actual current user ID
          'senderName': senderName,
          'message': message,
          'messageType': messageType,
        }),
      );
      
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return ApiResponse.success(true);
      } else {
        return ApiResponse.error(data['message'] ?? 'Failed to send SMS notification');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
}

// ===========================
// 2. WEBSOCKET SERVICE CLASS
// ===========================

class CareConnectWebSocketService {
  WebSocketChannel? _callChannel;
  WebSocketChannel? _healthChannel;
  String? _token;
  
  // Stream controllers for different message types
  final StreamController<CallInvitation> _callInvitationController = 
      StreamController<CallInvitation>.broadcast();
  final StreamController<SMSNotification> _smsNotificationController = 
      StreamController<SMSNotification>.broadcast();
  final StreamController<MedicationReminder> _medicationReminderController = 
      StreamController<MedicationReminder>.broadcast();
  final StreamController<bool> _connectionStatusController = 
      StreamController<bool>.broadcast();
  
  // Public streams
  Stream<CallInvitation> get callInvitations => _callInvitationController.stream;
  Stream<SMSNotification> get smsNotifications => _smsNotificationController.stream;
  Stream<MedicationReminder> get medicationReminders => _medicationReminderController.stream;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  
  // Singleton pattern
  static final CareConnectWebSocketService _instance = CareConnectWebSocketService._internal();
  factory CareConnectWebSocketService() => _instance;
  CareConnectWebSocketService._internal();
  
  void initialize(String token) {
    _token = token;
  }
  
  void connectToCallService() {
    if (_token == null) {
      print('Error: No authentication token provided');
      return;
    }
    
    try {
      final uri = Uri.parse('ws://localhost:8080/ws/calls?token=$_token');
      _callChannel = WebSocketChannel.connect(uri);
      
      _callChannel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _handleCallMessage(data);
          _connectionStatusController.add(true);
        },
        onError: (error) {
          print('Call WebSocket Error: $error');
          _connectionStatusController.add(false);
          _reconnectCallService();
        },
        onDone: () {
          print('Call WebSocket Connection Closed');
          _connectionStatusController.add(false);
          _reconnectCallService();
        },
      );
      
      print('Connected to Call WebSocket service');
    } catch (e) {
      print('Failed to connect to Call WebSocket: $e');
      _connectionStatusController.add(false);
    }
  }
  
  void connectToHealthService() {
    if (_token == null) {
      print('Error: No authentication token provided');
      return;
    }
    
    try {
      final uri = Uri.parse('ws://localhost:8080/ws/careconnect?token=$_token');
      _healthChannel = WebSocketChannel.connect(uri);
      
      _healthChannel!.stream.listen(
        (message) {
          final data = json.decode(message);
          _handleHealthMessage(data);
        },
        onError: (error) {
          print('Health WebSocket Error: $error');
          _reconnectHealthService();
        },
        onDone: () {
          print('Health WebSocket Connection Closed');
          _reconnectHealthService();
        },
      );
      
      print('Connected to Health WebSocket service');
    } catch (e) {
      print('Failed to connect to Health WebSocket: $e');
    }
  }
  
  void _handleCallMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final data = message['data'];
    final timestamp = message['timestamp'];
    
    print('Received call message: $type');
    
    switch (type) {
      case 'call_invitation':
        final invitation = CallInvitation.fromJson(data, timestamp);
        _callInvitationController.add(invitation);
        break;
      case 'sms_notification':
        final sms = SMSNotification.fromJson(data, timestamp);
        _smsNotificationController.add(sms);
        break;
      default:
        print('Unknown call message type: $type');
    }
  }
  
  void _handleHealthMessage(Map<String, dynamic> message) {
    final type = message['type'];
    final data = message['data'];
    final timestamp = message['timestamp'];
    
    print('Received health message: $type');
    
    switch (type) {
      case 'medication_reminder':
        final reminder = MedicationReminder.fromJson(data, timestamp);
        _medicationReminderController.add(reminder);
        break;
      case 'vital_signs_alert':
        // Handle vital signs alert
        print('Vital signs alert: ${data['alertMessage']}');
        break;
      case 'emergency_alert':
        // Handle emergency alert
        print('Emergency alert: ${data['alertMessage']}');
        break;
      default:
        print('Unknown health message type: $type');
    }
  }
  
  void respondToCall(String callId, String response) {
    if (_callChannel == null) {
      print('Error: Call channel not connected');
      return;
    }
    
    final message = {
      'type': 'call_response',
      'data': {
        'callId': callId,
        'response': response, // 'accept' or 'decline'
        'userId': 'current-user-id', // Replace with actual user ID
      }
    };
    
    _callChannel!.sink.add(json.encode(message));
    print('Sent call response: $response for call $callId');
  }
  
  void _reconnectCallService() {
    print('Attempting to reconnect to call service...');
    Future.delayed(Duration(seconds: 5), () {
      connectToCallService();
    });
  }
  
  void _reconnectHealthService() {
    print('Attempting to reconnect to health service...');
    Future.delayed(Duration(seconds: 5), () {
      connectToHealthService();
    });
  }
  
  void disconnect() {
    _callChannel?.sink.close();
    _healthChannel?.sink.close();
    _connectionStatusController.add(false);
    print('WebSocket connections closed');
  }
  
  void dispose() {
    disconnect();
    _callInvitationController.close();
    _smsNotificationController.close();
    _medicationReminderController.close();
    _connectionStatusController.close();
  }
}

// ===========================
// 3. DATA MODELS
// ===========================

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  
  ApiResponse.success(this.data) : success = true, error = null;
  ApiResponse.error(this.error) : success = false, data = null;
}

class LoginResponse {
  final String token;
  final String refreshToken;
  final User user;
  final int expiresIn;
  
  LoginResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });
  
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'],
      refreshToken: json['refreshToken'],
      user: User.fromJson(json['user']),
      expiresIn: json['expiresIn'],
    );
  }
}

class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? phoneNumber;
  final bool isActive;
  
  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.phoneNumber,
    required this.isActive,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      isActive: json['isActive'],
    );
  }
}

class AIChatSession {
  final String sessionId;
  final String provider;
  final String contextType;
  final List<ChatMessage> messages;
  
  AIChatSession({
    required this.sessionId,
    required this.provider,
    required this.contextType,
    required this.messages,
  });
  
  factory AIChatSession.fromJson(Map<String, dynamic> json) {
    return AIChatSession(
      sessionId: json['sessionId'],
      provider: json['provider'],
      contextType: json['contextType'],
      messages: (json['messages'] as List)
          .map((msg) => ChatMessage.fromJson(msg))
          .toList(),
    );
  }
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
  
  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      role: json['role'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class CallInvitation {
  final String senderId;
  final String senderName;
  final String callId;
  final bool isVideoCall;
  final String callType;
  final String message;
  final DateTime timestamp;
  
  CallInvitation({
    required this.senderId,
    required this.senderName,
    required this.callId,
    required this.isVideoCall,
    required this.callType,
    required this.message,
    required this.timestamp,
  });
  
  factory CallInvitation.fromJson(Map<String, dynamic> json, String timestampStr) {
    return CallInvitation(
      senderId: json['senderId'],
      senderName: json['senderName'],
      callId: json['callId'],
      isVideoCall: json['isVideoCall'],
      callType: json['callType'],
      message: json['message'],
      timestamp: DateTime.parse(timestampStr),
    );
  }
}

class SMSNotification {
  final String senderId;
  final String senderName;
  final String message;
  final String messageType;
  final DateTime timestamp;
  
  SMSNotification({
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.messageType,
    required this.timestamp,
  });
  
  factory SMSNotification.fromJson(Map<String, dynamic> json, String timestampStr) {
    return SMSNotification(
      senderId: json['senderId'],
      senderName: json['senderName'],
      message: json['message'],
      messageType: json['messageType'],
      timestamp: DateTime.parse(timestampStr),
    );
  }
}

class MedicationReminder {
  final String medicationName;
  final String reminderTime;
  final String dosage;
  final String message;
  final DateTime timestamp;
  
  MedicationReminder({
    required this.medicationName,
    required this.reminderTime,
    required this.dosage,
    required this.message,
    required this.timestamp,
  });
  
  factory MedicationReminder.fromJson(Map<String, dynamic> json, String timestampStr) {
    return MedicationReminder(
      medicationName: json['medicationName'],
      reminderTime: json['reminderTime'],
      dosage: json['dosage'],
      message: json['message'],
      timestamp: DateTime.parse(timestampStr),
    );
  }
}

// ===========================
// 4. USAGE EXAMPLE WIDGET
// ===========================

/*
Usage Example in your Flutter app:

class CareConnectHomePage extends StatefulWidget {
  @override
  _CareConnectHomePageState createState() => _CareConnectHomePageState();
}

class _CareConnectHomePageState extends State<CareConnectHomePage> {
  final CareConnectApiService _apiService = CareConnectApiService();
  final CareConnectWebSocketService _wsService = CareConnectWebSocketService();
  
  StreamSubscription<CallInvitation>? _callSubscription;
  StreamSubscription<SMSNotification>? _smsSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }
  
  void _initializeServices() {
    // Initialize WebSocket service with token (after login)
    // _wsService.initialize(authToken);
    // _wsService.connectToCallService();
    // _wsService.connectToHealthService();
    
    // Listen to incoming calls
    _callSubscription = _wsService.callInvitations.listen((invitation) {
      _showCallInvitationDialog(invitation);
    });
    
    // Listen to SMS notifications
    _smsSubscription = _wsService.smsNotifications.listen((sms) {
      _showSMSNotification(sms);
    });
    
    // Listen to connection status
    _connectionSubscription = _wsService.connectionStatus.listen((isConnected) {
      print('WebSocket connection status: $isConnected');
    });
  }
  
  void _showCallInvitationDialog(CallInvitation invitation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incoming Call'),
        content: Text('${invitation.senderName} is calling you'),
        actions: [
          TextButton(
            onPressed: () {
              _wsService.respondToCall(invitation.callId, 'decline');
              Navigator.of(context).pop();
            },
            child: Text('Decline'),
          ),
          TextButton(
            onPressed: () {
              _wsService.respondToCall(invitation.callId, 'accept');
              Navigator.of(context).pop();
              // Navigate to call screen
            },
            child: Text('Accept'),
          ),
        ],
      ),
    );
  }
  
  void _showSMSNotification(SMSNotification sms) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${sms.senderName}: ${sms.message}'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to SMS details
          },
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _callSubscription?.cancel();
    _smsSubscription?.cancel();
    _connectionSubscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CareConnect')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _testLogin,
              child: Text('Test Login'),
            ),
            ElevatedButton(
              onPressed: _testAIChat,
              child: Text('Test AI Chat'),
            ),
            ElevatedButton(
              onPressed: _testSendCall,
              child: Text('Test Send Call'),
            ),
          ],
        ),
      ),
    );
  }
  
  void _testLogin() async {
    final result = await _apiService.login('test@example.com', 'password');
    if (result.success) {
      print('Login successful: ${result.data?.user.firstName}');
      // Initialize WebSocket with token
      _wsService.initialize(result.data!.token);
      _wsService.connectToCallService();
      _wsService.connectToHealthService();
    } else {
      print('Login failed: ${result.error}');
    }
  }
  
  void _testAIChat() async {
    final result = await _apiService.startAIChat('I have a headache');
    if (result.success) {
      print('AI Chat started: ${result.data?.sessionId}');
    } else {
      print('AI Chat failed: ${result.error}');
    }
  }
  
  void _testSendCall() async {
    final result = await _apiService.sendCallInvitation(
      recipientId: 'test-user-123',
      senderName: 'Test User',
      callId: 'call-${DateTime.now().millisecondsSinceEpoch}',
    );
    if (result.success) {
      print('Call invitation sent successfully');
    } else {
      print('Failed to send call: ${result.error}');
    }
  }
}
*/
