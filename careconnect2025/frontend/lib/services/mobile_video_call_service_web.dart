// Stub for mobile video call service when running on web
// This prevents Agora imports from being loaded on web platform
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MobileVideoCallService {
  final bool _isInCall = false;
  String? _currentCallId;

  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;

  /// Initialize (stub for web)
  Future<void> initialize({
    required String userId,
    Function(MediaStream)? onRemoteStreamReceived,
    Function()? onCallEnded,
  }) async {
    throw UnsupportedError(
      'Mobile video calling not supported on web platform',
    );
  }

  /// Start call (stub for web)
  Future<Widget> startCall({
    required String callId,
    required String recipientId,
    bool isVideoEnabled = true,
    bool isAudioEnabled = true,
  }) async {
    throw UnsupportedError(
      'Mobile video calling not supported on web platform',
    );
  }

  /// Join call (stub for web)
  Future<Widget> joinCall({
    required String callId,
    bool isVideoEnabled = true,
    bool isAudioEnabled = true,
  }) async {
    throw UnsupportedError(
      'Mobile video calling not supported on web platform',
    );
  }

  /// End call (stub for web)
  Future<void> endCall() async {
    // No-op for web
  }

  /// Get call controls (stub for web)
  Widget getCallControls() {
    return Container();
  }

  /// Dispose service (stub for web)
  Future<void> dispose() async {
    // No-op for web
  }
}
