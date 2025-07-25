import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCSignalingService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static final Map<String, StreamController> _eventControllers = {};

  // Signaling server URL (you can use socket.io test server or deploy your own)
  static const String signalingServerUrl =
      'https://socket.io-chat-e9jt.herokuapp.com';

  // Initialize signaling connection
  static Future<bool> initialize() async {
    try {
      print('🔗 Connecting to signaling server...');

      _socket = IO.io(signalingServerUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket!.connect();

      // Setup event listeners
      _socket!.onConnect((_) {
        _isConnected = true;
        print('✅ Connected to signaling server');
      });

      _socket!.onDisconnect((_) {
        _isConnected = false;
        print('❌ Disconnected from signaling server');
      });

      // WebRTC signaling events
      _socket!.on('offer', (data) => _emitEvent('offer', data));
      _socket!.on('answer', (data) => _emitEvent('answer', data));
      _socket!.on('ice-candidate', (data) => _emitEvent('ice-candidate', data));
      _socket!.on('user-joined', (data) => _emitEvent('user-joined', data));
      _socket!.on('user-left', (data) => _emitEvent('user-left', data));
      _socket!.on('call-ended', (data) => _emitEvent('call-ended', data));

      // Wait for connection
      await Future.delayed(const Duration(seconds: 2));
      return _isConnected;
    } catch (e) {
      print('❌ Error initializing signaling: $e');
      return false;
    }
  }

  // Join a call room
  static void joinRoom(String roomId, String userId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join', {'room': roomId, 'userId': userId});
      print('📞 Joined room: $roomId as user: $userId');
    }
  }

  // Leave a call room
  static void leaveRoom(String roomId, String userId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave', {'room': roomId, 'userId': userId});
      print('📞 Left room: $roomId');
    }
  }

  // Send offer to peer
  static void sendOffer(
    String roomId,
    String targetUserId,
    Map<String, dynamic> offer,
  ) {
    if (_socket != null && _isConnected) {
      _socket!.emit('offer', {
        'room': roomId,
        'targetUserId': targetUserId,
        'offer': offer,
      });
      print('📤 Sent offer to $targetUserId');
    }
  }

  // Send answer to peer
  static void sendAnswer(
    String roomId,
    String targetUserId,
    Map<String, dynamic> answer,
  ) {
    if (_socket != null && _isConnected) {
      _socket!.emit('answer', {
        'room': roomId,
        'targetUserId': targetUserId,
        'answer': answer,
      });
      print('📤 Sent answer to $targetUserId');
    }
  }

  // Send ICE candidate
  static void sendIceCandidate(
    String roomId,
    String targetUserId,
    Map<String, dynamic> candidate,
  ) {
    if (_socket != null && _isConnected) {
      _socket!.emit('ice-candidate', {
        'room': roomId,
        'targetUserId': targetUserId,
        'candidate': candidate,
      });
      print('📤 Sent ICE candidate to $targetUserId');
    }
  }

  // End call
  static void endCall(String roomId, String userId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('end-call', {'room': roomId, 'userId': userId});
      print('📞 Ended call in room: $roomId');
    }
  }

  // Listen to signaling events
  static Stream<T> on<T>(String event) {
    if (!_eventControllers.containsKey(event)) {
      _eventControllers[event] = StreamController<T>.broadcast();
    }
    return _eventControllers[event]!.stream as Stream<T>;
  }

  // Emit event to listeners
  static void _emitEvent(String event, dynamic data) {
    if (_eventControllers.containsKey(event)) {
      _eventControllers[event]!.add(data);
    }
  }

  // Check connection status
  static bool get isConnected => _isConnected;

  // Cleanup
  static void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;

    // Close all stream controllers
    for (var controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();

    print('🧹 WebRTC signaling service disposed');
  }
}
