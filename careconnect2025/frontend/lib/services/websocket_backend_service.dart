import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:http/http.dart' as http;
import 'auth_token_manager.dart';

/// WebSocket service for real-time communication with Spring Boot backend
class CareConnectWebSocketService {
  static final CareConnectWebSocketService _instance =
      CareConnectWebSocketService._internal();
  static CareConnectWebSocketService get instance => _instance;

  CareConnectWebSocketService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isAuthenticated = false;
  String? _currentUserId;
  Timer? _heartbeatTimer;

  // Event stream controllers
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _callController =
      StreamController.broadcast();
  final StreamController<bool> _connectionController =
      StreamController.broadcast();

  // Public streams
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<Map<String, dynamic>> get callStream => _callController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;

  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      print('🔌 Connecting to WebSocket server...');

      // Connect to Spring Boot WebSocket endpoint
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/ws/careconnect'),
      );

      _isConnected = true;
      _connectionController.add(true);

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      // Authenticate after connection
      await _authenticate();

      // Start heartbeat
      _startHeartbeat();

      print('✅ WebSocket connected successfully');
    } catch (e) {
      print('❌ WebSocket connection failed: $e');
      _isConnected = false;
      _connectionController.add(false);
      rethrow;
    }
  }

  /// Authenticate with JWT token via WebSocket message
  Future<void> _authenticate() async {
    try {
      final token = await AuthTokenManager.getJwtToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      final userSession = await AuthTokenManager.getUserSession();
      if (userSession == null) {
        throw Exception('No current user session available');
      }

      _currentUserId = userSession['id']?.toString();
      if (_currentUserId == null) {
        throw Exception('User ID not found in session');
      }

      // Send authentication message
      final authMessage = {
        'type': 'authenticate',
        'token': token,
        'userId': _currentUserId,
      };

      _channel?.sink.add(jsonEncode(authMessage));
      print('🔑 Authentication message sent');

      // Wait for authentication confirmation
      await Future.delayed(const Duration(milliseconds: 500));
      _isAuthenticated = true;

      // Join user room after authentication
      await _joinUserRoom();
    } catch (e) {
      print('❌ WebSocket authentication failed: $e');
      _isAuthenticated = false;
      rethrow;
    }
  }

  /// Join user-specific room
  Future<void> _joinUserRoom() async {
    if (!_isAuthenticated || _currentUserId == null) return;

    final joinMessage = {'type': 'join-user-room', 'userId': _currentUserId};

    _channel?.sink.add(jsonEncode(joinMessage));
    print('🏠 Joined user room: $_currentUserId');
  }

  /// Send call invitation via WebSocket
  bool sendCallInvitation({
    required String recipientId,
    required String callType,
    required String callId,
  }) {
    if (!_isAuthenticated) {
      print('❌ Cannot send call invitation: Not authenticated');
      return false;
    }

    try {
      final callMessage = {
        'type': 'send-video-call-invitation',
        'recipientId': recipientId,
        'callType': callType,
        'callId': callId,
        'senderId': _currentUserId,
        'timestamp': DateTime.now().toIso8601String(),
      };

      _channel?.sink.add(jsonEncode(callMessage));
      print('📞 Call invitation sent to $recipientId');
      return true;
    } catch (e) {
      print('❌ Failed to send call invitation: $e');
      return false;
    }
  }

  /// Send SMS notification via REST API (not WebSocket)
  Future<bool> sendSMSNotification({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final token = await AuthTokenManager.getJwtToken();
      if (token == null) {
        print('❌ No authentication token for SMS');
        return false;
      }

      final response = await http.post(
        Uri.parse('http://localhost:8080/api/sms/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'phoneNumber': phoneNumber, 'message': message}),
      );

      if (response.statusCode == 200) {
        print('📱 SMS sent successfully to $phoneNumber');
        return true;
      } else {
        print('❌ SMS failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ SMS error: $e');
      return false;
    }
  }

  /// Handle incoming WebSocket messages
  void _handleMessage(dynamic data) {
    try {
      final message = jsonDecode(data.toString());
      print('📨 WebSocket message received: ${message['type']}');

      switch (message['type']) {
        case 'video-call-invitation':
          _callController.add(message);
          break;
        case 'authentication-success':
          _isAuthenticated = true;
          print('✅ WebSocket authentication confirmed');
          break;
        case 'authentication-failed':
          _isAuthenticated = false;
          print('❌ WebSocket authentication failed');
          break;
        default:
          _messageController.add(message);
      }
    } catch (e) {
      print('❌ Error handling WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(error) {
    print('❌ WebSocket error: $error');
    _isConnected = false;
    _isAuthenticated = false;
    _connectionController.add(false);
  }

  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    print('🔌 WebSocket disconnected');
    _isConnected = false;
    _isAuthenticated = false;
    _connectionController.add(false);
    _heartbeatTimer?.cancel();
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } else {
        timer.cancel();
      }
    });
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    await _channel?.sink.close(status.normalClosure);
    _isConnected = false;
    _isAuthenticated = false;
    _currentUserId = null;
    _connectionController.add(false);
    print('🔌 WebSocket disconnected');
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _callController.close();
    _connectionController.close();
  }
}
