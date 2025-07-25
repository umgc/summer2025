import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../widgets/incoming_call_popup.dart';
import '../widgets/hybrid_video_call_widget.dart';

/// Service to handle real-time call notifications for caregivers
class CallNotificationService {
  static io.Socket? _socket;
  static bool _isConnected = false;
  static String? _currentUserId;
  static String? _currentUserRole;
  static BuildContext? _context;

  // Stream controllers for call events
  static final StreamController<Map<String, dynamic>> _incomingCallController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  static Stream<Map<String, dynamic>> get incomingCallStream =>
      _incomingCallController.stream;
  static bool get isConnected => _isConnected;

  /// Initialize the real-time notification service
  static Future<bool> initialize({
    required String userId,
    required String userRole, // 'CAREGIVER' or 'PATIENT'
    required BuildContext context,
  }) async {
    try {
      _currentUserId = userId;
      _currentUserRole = userRole;
      _context = context;

      print('🔔 Initializing CallNotificationService for $userRole: $userId');

      // Connect to your backend WebSocket/Socket.IO server
      // For development: ws://localhost:8080
      // For production: replace with your actual backend URL
      const String websocketUrl = String.fromEnvironment(
        'WEBSOCKET_URL',
        defaultValue: 'ws://localhost:8080',
      );

      _socket = io.io(websocketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'query': {'userId': userId, 'userRole': userRole},
      });

      _socket!.connect();

      // Connection events
      _socket!.onConnect((_) {
        _isConnected = true;
        print('✅ CallNotificationService connected');

        // Join user-specific room for notifications
        _socket!.emit('join-user-room', {
          'userId': userId,
          'userRole': userRole,
        });
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        print('❌ CallNotificationService disconnected');
      });

      // Listen for incoming video call invitations
      _socket!.on('incoming-video-call', (data) {
        print('📞 Received incoming video call: $data');
        _handleIncomingCall(data);
      });

      // Listen for call status updates
      _socket!.on('call-ended', (data) {
        print('📞 Call ended: $data');
        // Handle call ended notification
      });

      _socket!.on('call-answered', (data) {
        print('📞 Call answered: $data');
        // Handle call answered notification
      });

      _socket!.on('call-declined', (data) {
        print('📞 Call declined: $data');
        // Handle call declined notification
      });

      return true;
    } catch (e) {
      print('❌ Error initializing CallNotificationService: $e');
      return false;
    }
  }

  /// Handle incoming call notification
  static void _handleIncomingCall(Map<String, dynamic> callData) {
    if (_context == null) return;

    // Extract call information
    final callId = callData['callId'] ?? '';
    final callerId = callData['callerId'] ?? '';
    final callerName = callData['callerName'] ?? 'Unknown Caller';
    final isVideoCall = callData['isVideoCall'] ?? true;
    final callerRole = callData['callerRole'] ?? 'PATIENT';

    print('📞 Processing incoming call from $callerName ($callerRole)');

    // Emit to stream for any listeners
    _incomingCallController.add(callData);

    // Show incoming call popup
    _showIncomingCallPopup(
      callId: callId,
      callerId: callerId,
      callerName: callerName,
      isVideoCall: isVideoCall,
      callerRole: callerRole,
    );
  }

  /// Show incoming call popup UI
  static void _showIncomingCallPopup({
    required String callId,
    required String callerId,
    required String callerName,
    required bool isVideoCall,
    required String callerRole,
  }) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      barrierDismissible: false,
      builder: (context) => IncomingCallPopup(
        callId: callId,
        callerId: callerId,
        callerName: callerName,
        isVideoCall: isVideoCall,
        callerRole: callerRole,
        onAccept: () => _acceptCall(
          callId: callId,
          callerId: callerId,
          callerName: callerName,
          isVideoCall: isVideoCall,
        ),
        onDecline: () => _declineCall(callId: callId),
      ),
    );
  }

  /// Accept incoming call
  static void _acceptCall({
    required String callId,
    required String callerId,
    required String callerName,
    required bool isVideoCall,
  }) {
    if (_context == null || _currentUserId == null) return;

    print('✅ Accepting call: $callId');

    // Notify backend that call was accepted
    _socket?.emit('accept-call', {
      'callId': callId,
      'acceptedBy': _currentUserId,
      'acceptedByRole': _currentUserRole,
    });

    // Close the incoming call popup
    Navigator.of(_context!).pop();

    // Navigate to video call screen
    Navigator.of(_context!).push(
      MaterialPageRoute(
        builder: (context) => HybridVideoCallWidget(
          userId: _currentUserId!,
          callId: callId,
          recipientId: callerId,
          isInitiator: false, // This user is joining the call
          isVideoEnabled: isVideoCall,
          isAudioEnabled: true,
          userName: _getCurrentUserName(),
          recipientName: callerName,
        ),
      ),
    );
  }

  /// Decline incoming call
  static void _declineCall({required String callId}) {
    print('❌ Declining call: $callId');

    // Notify backend that call was declined
    _socket?.emit('decline-call', {
      'callId': callId,
      'declinedBy': _currentUserId,
      'declinedByRole': _currentUserRole,
    });

    // Close the incoming call popup
    if (_context != null) {
      Navigator.of(_context!).pop();
    }
  }

  /// Send outgoing call notification
  static Future<bool> sendCallInvitation({
    required String recipientId,
    required String recipientRole, // 'CAREGIVER' or 'PATIENT'
    required String callId,
    required bool isVideoCall,
  }) async {
    if (!_isConnected || _socket == null) {
      print('❌ Cannot send call invitation - not connected');
      return false;
    }

    try {
      print('📤 Sending call invitation to $recipientRole: $recipientId');

      _socket!.emit('send-video-call-invitation', {
        'callId': callId,
        'callerId': _currentUserId,
        'callerName': _getCurrentUserName(),
        'callerRole': _currentUserRole,
        'recipientId': recipientId,
        'recipientRole': recipientRole,
        'isVideoCall': isVideoCall,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('❌ Error sending call invitation: $e');
      return false;
    }
  }

  /// Get current user name from context or default
  static String _getCurrentUserName() {
    // You can implement this to get the actual user name
    // For now, return a placeholder based on role
    return _currentUserRole == 'CAREGIVER' ? 'Caregiver' : 'Patient';
  }

  /// Dispose and cleanup
  static void dispose() {
    print('🧹 Disposing CallNotificationService');

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    _isConnected = false;
    _currentUserId = null;
    _currentUserRole = null;
    _context = null;

    if (!_incomingCallController.isClosed) {
      _incomingCallController.close();
    }
  }
}
