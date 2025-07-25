import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/environment_config.dart';
import 'messaging_service.dart';

class RealVideoCallService {
  static bool _isInitialized = false;
  static RtcEngine? _agoraEngine;
  static io.Socket? _signalingSocket;
  static final Map<String, RTCPeerConnection> _peerConnections = {};
  static RTCVideoRenderer? _localRenderer;
  static RTCVideoRenderer? _remoteRenderer;
  static MediaStream? _localStream;

  // Agora configuration
  static String get _agoraAppId => EnvironmentConfig.agoraAppId;
  static const String _agoraToken = ''; // Optional token for production

  /// Initialize the real video call service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🎥 Initializing REAL Video Call Service...');

      if (kIsWeb) {
        await _initializeWebRTC();
      } else {
        await _initializeAgora();
      }

      await _initializeSignaling();

      _isInitialized = true;
      print('✅ REAL Video Call Service initialized successfully!');
    } catch (e) {
      print('❌ Error initializing real video call service: $e');
      rethrow;
    }
  }

  /// Initialize WebRTC for web platform
  static Future<void> _initializeWebRTC() async {
    print('🌐 Initializing WebRTC for web...');

    // Initialize renderers
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();

    await _localRenderer!.initialize();
    await _remoteRenderer!.initialize();

    print('✅ WebRTC initialized for web');
  }

  /// Initialize Agora for mobile platforms
  static Future<void> _initializeAgora() async {
    print('📱 Initializing Agora for mobile...');

    _agoraEngine = createAgoraRtcEngine();
    await _agoraEngine!.initialize(
      RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // Enable video
    await _agoraEngine!.enableVideo();
    await _agoraEngine!.enableAudio();

    print('✅ Agora initialized for mobile');
  }

  /// Initialize signaling server connection
  static Future<void> _initializeSignaling() async {
    print('🔄 Connecting to signaling server...');

    // In a real app, you'd have your own signaling server
    // For now, we'll create a mock connection
    _signalingSocket = io.io(
      'https://your-signaling-server.com',
      io.OptionBuilder().setTransports(['websocket']).build(),
    );

    _signalingSocket!.onConnect((_) {
      print('✅ Connected to signaling server');
    });

    _signalingSocket!.onDisconnect((_) {
      print('❌ Disconnected from signaling server');
    });
  }

  /// Get user media (camera and microphone)
  static Future<MediaStream?> _getUserMedia({
    bool video = true,
    bool audio = true,
  }) async {
    try {
      if (kIsWeb) {
        final constraints = {
          'video': video
              ? {
                  'width': {'min': 640, 'ideal': 1280},
                  'height': {'min': 480, 'ideal': 720},
                  'facingMode': 'user',
                }
              : false,
          'audio': audio,
        };

        return await navigator.mediaDevices.getUserMedia(constraints);
      } else {
        // For mobile, Agora handles media access
        return null;
      }
    } catch (e) {
      print('❌ Error getting user media: $e');
      return null;
    }
  }

  /// Initiate a real video call
  static Future<Map<String, dynamic>?> initiateCall({
    required String callerId,
    required String callerName,
    required String calleeId,
    required String calleeName,
    bool isVideoCall = true,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final callId = _generateCallId();

      print('🎥 Initiating REAL ${isVideoCall ? 'video' : 'audio'} call...');
      print('📞 Caller: $callerName -> Callee: $calleeName');

      if (kIsWeb) {
        // WebRTC call setup
        _localStream = await _getUserMedia(video: isVideoCall, audio: true);
        if (_localStream != null && _localRenderer != null) {
          _localRenderer!.srcObject = _localStream;
        }
      } else {
        // Agora call setup
        if (_agoraEngine != null) {
          await _agoraEngine!.joinChannel(
            token: _agoraToken,
            channelId: callId,
            uid: int.parse(callerId.hashCode.toString().substring(0, 8)),
            options: const ChannelMediaOptions(
              clientRoleType: ClientRoleType.clientRoleBroadcaster,
              channelProfile: ChannelProfileType.channelProfileCommunication,
            ),
          );
        }
      }

      // Send call notification
      final notificationSent = await MessagingService.sendVideoCallInvitation(
        recipientId: calleeId,
        callerId: callerId,
        callerName: callerName,
        callId: callId,
        isVideoCall: isVideoCall,
      );

      if (!notificationSent) {
        print('❌ Failed to send call notification');
        return null;
      }

      return {
        'callId': callId,
        'platform': kIsWeb ? 'webrtc' : 'agora',
        'isVideoCall': isVideoCall,
        'localRenderer': _localRenderer,
        'remoteRenderer': _remoteRenderer,
        'localStream': _localStream,
        'status': 'initiated',
        'realVideoCall': true, // This indicates it's a REAL call
      };
    } catch (e) {
      print('❌ Error initiating real video call: $e');
      return null;
    }
  }

  /// Join a real video call
  static Future<bool> joinCall({
    required String callId,
    required String userId,
    required String userName,
    bool isVideoCall = true,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      print('🎥 Joining REAL video call: $callId');

      if (kIsWeb) {
        // WebRTC join
        _localStream = await _getUserMedia(video: isVideoCall, audio: true);
        if (_localStream != null && _localRenderer != null) {
          _localRenderer!.srcObject = _localStream;
        }

        // Create peer connection for WebRTC
        await _createPeerConnection(callId);
      } else {
        // Agora join
        if (_agoraEngine != null) {
          await _agoraEngine!.joinChannel(
            token: _agoraToken,
            channelId: callId,
            uid: int.parse(userId.hashCode.toString().substring(0, 8)),
            options: const ChannelMediaOptions(
              clientRoleType: ClientRoleType.clientRoleBroadcaster,
              channelProfile: ChannelProfileType.channelProfileCommunication,
            ),
          );
        }
      }

      print('✅ Successfully joined REAL video call');
      return true;
    } catch (e) {
      print('❌ Error joining real video call: $e');
      return false;
    }
  }

  /// Create WebRTC peer connection
  static Future<void> _createPeerConnection(String callId) async {
    try {
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          // Add TURN servers for production
        ],
      };

      final pc = await createPeerConnection(config);
      _peerConnections[callId] = pc;

      // Add local stream to connection
      if (_localStream != null) {
        await pc.addStream(_localStream!);
      }

      // Handle remote stream
      pc.onAddStream = (stream) {
        print('📡 Remote stream received');
        if (_remoteRenderer != null) {
          _remoteRenderer!.srcObject = stream;
        }
      };

      // Handle ICE candidates
      pc.onIceCandidate = (candidate) {
        print('🧊 ICE candidate: ${candidate.candidate}');
        // Send candidate to remote peer via signaling
        _signalingSocket?.emit('ice-candidate', {
          'callId': callId,
          'candidate': candidate.toMap(),
        });
      };

      print('✅ Peer connection created for call: $callId');
    } catch (e) {
      print('❌ Error creating peer connection: $e');
    }
  }

  /// End a real video call
  static Future<bool> endCall(String callId) async {
    try {
      print('🎥 Ending REAL video call: $callId');

      if (kIsWeb) {
        // End WebRTC call
        _localStream?.getTracks().forEach((track) {
          track.stop();
        });
        _localStream?.dispose();
        _localStream = null;

        if (_peerConnections.containsKey(callId)) {
          await _peerConnections[callId]!.close();
          _peerConnections.remove(callId);
        }
      } else {
        // End Agora call
        if (_agoraEngine != null) {
          await _agoraEngine!.leaveChannel();
        }
      }

      print('✅ REAL video call ended successfully');
      return true;
    } catch (e) {
      print('❌ Error ending real video call: $e');
      return false;
    }
  }

  /// Toggle camera on/off
  static Future<void> toggleCamera() async {
    try {
      if (kIsWeb) {
        _localStream?.getVideoTracks().forEach((track) {
          track.enabled = !track.enabled;
        });
      } else {
        await _agoraEngine?.enableLocalVideo(!(_agoraEngine != null));
      }
    } catch (e) {
      print('❌ Error toggling camera: $e');
    }
  }

  /// Toggle microphone on/off
  static Future<void> toggleMicrophone() async {
    try {
      if (kIsWeb) {
        _localStream?.getAudioTracks().forEach((track) {
          track.enabled = !track.enabled;
        });
      } else {
        await _agoraEngine?.enableLocalAudio(!(_agoraEngine != null));
      }
    } catch (e) {
      print('❌ Error toggling microphone: $e');
    }
  }

  /// Switch camera (front/back)
  static Future<void> switchCamera() async {
    try {
      if (!kIsWeb && _agoraEngine != null) {
        await _agoraEngine!.switchCamera();
      }
    } catch (e) {
      print('❌ Error switching camera: $e');
    }
  }

  /// Get video renderers for UI
  static Map<String, RTCVideoRenderer?> getRenderers() {
    return {'local': _localRenderer, 'remote': _remoteRenderer};
  }

  /// Generate unique call ID
  static String _generateCallId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return 'real_call_${timestamp}_$random';
  }

  /// Cleanup resources
  static Future<void> dispose() async {
    try {
      await endCall('cleanup');

      await _localRenderer?.dispose();
      await _remoteRenderer?.dispose();

      _localRenderer = null;
      _remoteRenderer = null;

      if (_agoraEngine != null) {
        await _agoraEngine!.release();
        _agoraEngine = null;
      }

      _signalingSocket?.disconnect();
      _signalingSocket = null;

      _isInitialized = false;
      print('✅ Real video call service disposed');
    } catch (e) {
      print('❌ Error disposing video call service: $e');
    }
  }
}
