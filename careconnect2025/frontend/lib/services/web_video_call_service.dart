// Web-specific video call service using WebRTC
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class WebVideoCallService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  io.Socket? _socket;

  bool _isInCall = false;
  String? _currentCallId;
  String? _currentUserId;

  Function(MediaStream)? _onRemoteStreamReceived;
  Function()? _onCallEnded;

  // WebRTC renderers
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;

  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;

  /// Initialize WebRTC for web
  Future<void> initialize({
    required String userId,
    Function(MediaStream)? onRemoteStreamReceived,
    Function()? onCallEnded,
  }) async {
    _currentUserId = userId;
    _onRemoteStreamReceived = onRemoteStreamReceived;
    _onCallEnded = onCallEnded;

    try {
      // Initialize socket connection for signaling
      _socket = io.io('ws://localhost:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket!.connect();

      _socket!.on('connect', (_) {
        print('Connected to signaling server');
      });

      _socket!.on('offer', (data) async {
        await _handleOffer(data);
      });

      _socket!.on('answer', (data) async {
        await _handleAnswer(data);
      });

      _socket!.on('ice-candidate', (data) async {
        await _handleIceCandidate(data);
      });

      print('WebRTC service initialized for web platform');
    } catch (e) {
      print('Error initializing WebRTC: $e');
      throw Exception('Failed to initialize WebRTC video service: $e');
    }
  }

  /// Initialize video renderers for WebRTC
  Future<void> _initializeRenderers() async {
    _localRenderer = RTCVideoRenderer();
    _remoteRenderer = RTCVideoRenderer();
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  /// Start WebRTC call
  Future<Widget> startCall({
    required String callId,
    required String recipientId,
    bool isVideoEnabled = true,
    bool isAudioEnabled = true,
  }) async {
    if (_isInCall) {
      throw Exception('Already in a call');
    }

    _isInCall = true;
    _currentCallId = callId;

    try {
      await _initializeRenderers();

      // Create peer connection
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });

      // Get local media stream
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': isVideoEnabled,
        'audio': isAudioEnabled,
      });

      // Set local video
      _localRenderer.srcObject = _localStream;

      // Add local stream to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      // Handle remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
          _onRemoteStreamReceived?.call(_remoteStream!);
        }
      };

      // Handle ICE candidates
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _socket!.emit('ice-candidate', {
          'callId': callId,
          'candidate': candidate.toMap(),
        });
      };

      // Create and send offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _socket!.emit('offer', {
        'callId': callId,
        'recipientId': recipientId,
        'offer': offer.toMap(),
      });

      return _buildWebRTCVideoWidget();
    } catch (e) {
      _isInCall = false;
      _currentCallId = null;
      print('Error starting WebRTC call: $e');
      rethrow;
    }
  }

  /// Join WebRTC call
  Future<Widget> joinCall({
    required String callId,
    bool isVideoEnabled = true,
    bool isAudioEnabled = true,
  }) async {
    if (_isInCall) {
      throw Exception('Already in a call');
    }

    _isInCall = true;
    _currentCallId = callId;

    try {
      await _initializeRenderers();

      // Similar to start call but as a receiver
      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ],
      });

      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': isVideoEnabled,
        'audio': isAudioEnabled,
      });

      _localRenderer.srcObject = _localStream;

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteRenderer.srcObject = _remoteStream;
          _onRemoteStreamReceived?.call(_remoteStream!);
        }
      };

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        _socket!.emit('ice-candidate', {
          'callId': callId,
          'candidate': candidate.toMap(),
        });
      };

      // Join the call room
      _socket!.emit('join-call', {'callId': callId});

      return _buildWebRTCVideoWidget();
    } catch (e) {
      _isInCall = false;
      _currentCallId = null;
      print('Error joining WebRTC call: $e');
      rethrow;
    }
  }

  /// Build WebRTC video widget
  Widget _buildWebRTCVideoWidget() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Local video
                Expanded(
                  child: _localStream != null
                      ? RTCVideoView(_localRenderer)
                      : Container(color: Colors.black),
                ),
                // Remote video
                Expanded(
                  child: _remoteStream != null
                      ? RTCVideoView(_remoteRenderer)
                      : Container(
                          color: Colors.grey,
                          child: const Center(
                            child: Text(
                              'Waiting for remote stream...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          // Call controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  onPressed: _toggleMute,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.mic),
                ),
                FloatingActionButton(
                  onPressed: _toggleCamera,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.videocam),
                ),
                FloatingActionButton(
                  onPressed: endCall,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Handle WebRTC offer
  Future<void> _handleOffer(dynamic data) async {
    try {
      RTCSessionDescription offer = RTCSessionDescription(
        data['offer']['sdp'],
        data['offer']['type'],
      );

      await _peerConnection!.setRemoteDescription(offer);

      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _socket!.emit('answer', {
        'callId': data['callId'],
        'answer': answer.toMap(),
      });
    } catch (e) {
      print('Error handling offer: $e');
    }
  }

  /// Handle WebRTC answer
  Future<void> _handleAnswer(dynamic data) async {
    try {
      RTCSessionDescription answer = RTCSessionDescription(
        data['answer']['sdp'],
        data['answer']['type'],
      );

      await _peerConnection!.setRemoteDescription(answer);
    } catch (e) {
      print('Error handling answer: $e');
    }
  }

  /// Handle ICE candidate
  Future<void> _handleIceCandidate(dynamic data) async {
    try {
      RTCIceCandidate candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );

      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      print('Error handling ICE candidate: $e');
    }
  }

  /// Toggle microphone mute
  void _toggleMute() {
    _localStream?.getAudioTracks().forEach((track) {
      track.enabled = !track.enabled;
    });
  }

  /// Toggle camera on/off
  void _toggleCamera() {
    _localStream?.getVideoTracks().forEach((track) {
      track.enabled = !track.enabled;
    });
  }

  /// End WebRTC call
  Future<void> endCall() async {
    try {
      // Close peer connection
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }

      // Stop local stream
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) => track.stop());
        _localStream = null;
      }

      // Stop remote stream
      if (_remoteStream != null) {
        _remoteStream!.getTracks().forEach((track) => track.stop());
        _remoteStream = null;
      }

      // Dispose renderers
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();

      // Disconnect socket
      _socket?.emit('end-call', {'callId': _currentCallId});
    } catch (e) {
      print('Error ending WebRTC call: $e');
    } finally {
      _isInCall = false;
      _currentCallId = null;
      _onCallEnded?.call();
    }
  }

  /// Get call controls (empty for web as controls are built into video widget)
  Widget getCallControls() {
    return Container();
  }

  /// Dispose service
  Future<void> dispose() async {
    await endCall();
    _socket?.disconnect();
    _socket?.dispose();
  }
}
