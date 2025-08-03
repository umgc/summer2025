import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'video_call_service_base.dart';
import '../config/env_constant.dart';
import 'webrtc_signaling.dart';

class GenericWebRTCService implements VideoCallServiceBase {
  static String get _signalingServerUrl => getWebRTCSignalingServerUrl();
  WebRTCSignaling? _signaling;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  // String? _currentCallId;

  @override
  Future<void> initializeService() async {
    // No-op for now, could pre-connect signaling if needed
  }

  @override
  Future<bool> checkUserAvailability(String userId) async {
    // For demo, always return true. In production, query signaling server for user presence.
    return true;
  }

  @override
  Future<Map<String, dynamic>> initiateCall({
    required String callId,
    required String callerId,
    required String recipientId,
    required bool isVideoCall,
  }) async {
    try {
      _signaling = WebRTCSignaling(_signalingServerUrl);

      // Get user media
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': isVideoCall,
      });

      // Create peer connection
      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      };
      _peerConnection = await createPeerConnection(config);
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      if (_signaling != null) {
        // Listen for ICE candidates
        _peerConnection!.onIceCandidate = (candidate) async {
          await _signaling!.sendSignal(
            userId: recipientId,
            message: 'ice-candidate:${candidate.toMap()}',
          );
        };

        // Listen for remote stream
        _peerConnection!.onTrack = (event) {
          if (event.streams.isNotEmpty) {
            _remoteStream = event.streams[0];
          }
        };

        // Create offer
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);

        // Send offer to recipient
        await _signaling!.sendSignal(
          userId: recipientId,
          message: 'offer:${offer.toMap()}',
        );
      } else {
        print('[WebRTC] Running in local-only mode: signaling unavailable.');
      }

      return {
        'success': true,
        'callId': callId,
        // Optionally return local/remote stream for UI
        'signaling': _signaling != null,
      };
    } catch (e) {
      print('[WebRTC] Error in initiateCall: $e');
      return {'success': false, 'callId': callId, 'error': e.toString()};
    }
  }

  // Add getters for local/remote stream if needed for UI
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
}
