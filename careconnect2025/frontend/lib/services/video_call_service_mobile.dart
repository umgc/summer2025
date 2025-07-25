// Mobile-specific video call service using Agora
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallService {
  static const String agoraAppId = '6dd0e8e31625434e8dd185bcb075cd79';

  RtcEngine? _engine;
  bool _isInCall = false;
  String? _currentCallId;
  String? _currentUserId;
  int? _remoteUid;

  Function(int uid)? _onRemoteStreamReceived;
  Function()? _onCallEnded;

  bool get isInCall => _isInCall;
  String? get currentCallId => _currentCallId;
  int? get remoteUid => _remoteUid;

  /// Initialize Agora for mobile
  Future<void> initialize({
    required String userId,
    Function(int uid)? onRemoteStreamReceived,
    Function()? onCallEnded,
  }) async {
    _currentUserId = userId;
    _onRemoteStreamReceived = onRemoteStreamReceived;
    _onCallEnded = onCallEnded;

    // Create RTC engine
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      const RtcEngineContext(
        appId: agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    // Set up event handlers
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Local user joined channel: ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          print('Remote user joined: $uid');
          _remoteUid = uid;
          _onRemoteStreamReceived?.call(uid);
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
              print('Remote user left: $uid');
              _remoteUid = null;
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print('Left channel');
          _isInCall = false;
          _currentCallId = null;
          _remoteUid = null;
          _onCallEnded?.call();
        },
      ),
    );

    await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine!.enableVideo();
    await _engine!.enableAudio();

    print('Agora service initialized for mobile platform');
  }

  /// Start Agora call
  Future<Widget> startCall({
    required String callId,
    required String recipientId,
    bool isVideoEnabled = true,
    bool isAudioEnabled = true,
  }) async {
    if (_engine == null) {
      throw Exception('Engine not initialized');
    }

    if (_isInCall) {
      throw Exception('Already in a call');
    }

    _isInCall = true;
    _currentCallId = callId;

    try {
      await _engine!.joinChannel(
        token: '',
        channelId: callId,
        uid: 0,
        options: const ChannelMediaOptions(),
      );

      await _engine!.enableLocalVideo(isVideoEnabled);
      await _engine!.enableLocalAudio(isAudioEnabled);

      // Return a video call widget
      return Stack(
        children: [
          // Remote video (full screen)
          getRemoteVideoView(),
          // Local video (small overlay)
          Positioned(
            top: 40,
            right: 20,
            width: 120,
            height: 160,
            child: getLocalVideoView(),
          ),
        ],
      );
    } catch (e) {
      _isInCall = false;
      _currentCallId = null;
      print('Error starting Agora call: $e');
      rethrow;
    }
  }

  /// Join Agora call (instance method)
  Future<Widget> joinCallInstance({
    required String callId,
    bool isVideoEnabled = true,
    bool isAudioEnabled = true,
  }) async {
    return startCall(
      callId: callId,
      recipientId: '',
      isVideoEnabled: isVideoEnabled,
      isAudioEnabled: isAudioEnabled,
    );
  }

  /// End Agora call
  Future<void> endCall() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
      }
    } catch (e) {
      print('Error ending Agora call: $e');
    } finally {
      _isInCall = false;
      _currentCallId = null;
      _remoteUid = null;
      _onCallEnded?.call();
    }
  }

  /// Toggle video
  Future<void> toggleVideo(bool enabled) async {
    if (_engine != null) {
      await _engine!.enableLocalVideo(enabled);
    }
  }

  /// Toggle audio
  Future<void> toggleAudio(bool enabled) async {
    if (_engine != null) {
      await _engine!.enableLocalAudio(enabled);
    }
  }

  /// Get local video view
  Widget getLocalVideoView() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  /// Get remote video view
  Widget getRemoteVideoView() {
    if (_remoteUid == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Waiting for remote user...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: _currentCallId),
      ),
    );
  }

  /// Get call controls widget
  Widget getCallControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: "video",
            onPressed: () async {
              // Toggle video state (implement logic if needed)
              await toggleVideo(true);
            },
            child: const Icon(Icons.videocam),
          ),
          FloatingActionButton(
            heroTag: "audio",
            onPressed: () async {
              // Toggle audio state (implement logic if needed)
              await toggleAudio(true);
            },
            child: const Icon(Icons.mic),
          ),
          FloatingActionButton(
            heroTag: "end",
            backgroundColor: Colors.red,
            onPressed: () async {
              await endCall();
            },
            child: const Icon(Icons.call_end),
          ),
        ],
      ),
    );
  }

  /// Dispose service
  Future<void> dispose() async {
    await endCall();
    await _engine?.release();
    _engine = null;
  }

  // Static methods to match the interface expected by the app
  static final VideoCallService _staticInstance = VideoCallService();

  static Future<bool> initializeService() async {
    try {
      // Initialize the service if needed
      print('Mobile VideoCallService initialized');
      return true;
    } catch (e) {
      print('Error initializing mobile video service: $e');
      return false;
    }
  }

  static Future<bool> checkUserAvailability(String userId) async {
    // For mobile, we assume user is available if not in a call
    return !_staticInstance._isInCall;
  }

  static Future<Map<String, dynamic>> initiateCall({
    required String recipientId,
    required String callerId,
    bool isVideoCall = true,
  }) async {
    try {
      final callId = 'call_${DateTime.now().millisecondsSinceEpoch}';

      // Initialize the static instance for the call
      await _staticInstance.initialize(
        userId: callerId,
        onRemoteStreamReceived: (uid) {
          print('Remote user joined: $uid');
        },
        onCallEnded: () {
          print('Call ended');
        },
      );

      return {
        'success': true,
        'callId': callId,
        'callerId': callerId,
        'recipientId': recipientId,
        'isVideoCall': isVideoCall,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<bool> joinCall(String callId, String userId) async {
    try {
      await _staticInstance.initialize(
        userId: userId,
        onRemoteStreamReceived: (uid) {
          print('Remote user joined: $uid');
        },
        onCallEnded: () {
          print('Call ended');
        },
      );

      // Start the call (which will join the channel)
      await _staticInstance.startCall(
        callId: callId,
        recipientId: 'unknown', // We don't have recipient info here
        isVideoEnabled: true,
        isAudioEnabled: true,
      );

      return true;
    } catch (e) {
      print('Error joining call: $e');
      return false;
    }
  }

  static Future<void> endCallStatic(String callId, String userId) async {
    try {
      await _staticInstance.endCall();
      await _staticInstance.dispose();
    } catch (e) {
      print('Error ending call: $e');
    }
  }
}
