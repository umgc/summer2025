// Web-specific video call service using WebRTC
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../config/env_constant.dart';
import 'webrtc_signaling.dart';

class WebVideoCallService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  bool _isInCall = false;
  String? _currentCallId;
  String? _currentUserId;
  Function(MediaStream)? _onRemoteStreamReceived;
  Function()? _onCallEnded;
  late RTCVideoRenderer _localRenderer;
  late RTCVideoRenderer _remoteRenderer;
  late WebRTCSignaling _signaling;
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
    _signaling = WebRTCSignaling(getWebRTCSignalingServerUrl());
    print('WebRTC service initialized for web platform (HTTP signaling)');
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
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
        await _signaling.sendSignal(
          userId: recipientId,
          message: 'ice-candidate:${candidate.toMap()}',
        );
      };

      // Create and send offer
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      await _signaling.sendSignal(
        userId: recipientId,
        message: 'offer:${offer.toMap()}',
      );

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

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
        // Use recipientId for outgoing ICE candidates in joinCall
        await _signaling.sendSignal(
          userId: recipientId,
          message: 'ice-candidate:${candidate.toMap()}',
        );
      };

      // Notify caller/host via HTTP-based notification if needed (optional)
      // await _signaling.sendSignal(userId: <callerId>, message: 'Joined video call');

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

      // Stop and disable local stream tracks (especially video)
      if (_localStream != null) {
        for (var track in _localStream!.getTracks()) {
          try {
            track.stop();
            track.enabled = false;
          } catch (_) {}
        }
        _localStream = null;
      }

      // Stop and disable remote stream tracks
      if (_remoteStream != null) {
        for (var track in _remoteStream!.getTracks()) {
          try {
            track.stop();
            track.enabled = false;
          } catch (_) {}
        }
        _remoteStream = null;
      }

      // Dispose renderers
      await _localRenderer.dispose();
      await _remoteRenderer.dispose();

      // Disconnect socket
      // Notify other party via HTTP-based notification
      if (_currentCallId != null && _currentUserId != null) {
        await _signaling.sendSignal(
          userId: _currentUserId!,
          message: 'call-ended',
        );
      }
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
  }
}
