import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/theme/app_theme.dart';

class RealVideoCallWidget extends StatefulWidget {
  final String callId;
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;
  final bool isVideoCall;

  const RealVideoCallWidget({
    super.key,
    required this.callId,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
    this.isVideoCall = true,
  });

  @override
  State<RealVideoCallWidget> createState() => _RealVideoCallWidgetState();
}

class _RealVideoCallWidgetState extends State<RealVideoCallWidget> {
  late RtcEngine _engine;
  bool _isInitialized = false;
  String _callStatus = 'Connecting...';
  int? _remoteUid;
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    print('🎥 Requesting camera and microphone permissions...');

    // Request permissions
    Map<Permission, PermissionStatus> permissions = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    bool allGranted = permissions.values.every((status) => status.isGranted);

    if (allGranted) {
      print('✅ Permissions granted, initializing Agora...');
      await _initializeAgora();
    } else {
      print('❌ Permissions denied');
      setState(() {
        _callStatus = 'Permissions required for video call';
      });
    }
  }

  Future<void> _initializeAgora() async {
    try {
      print('🚀 Initializing Agora RTC Engine...');
      print('📱 App ID: 6dd0e8e31625434e8dd185bcb075cd79');
      print('🎬 Channel: ${widget.callId}');

      // Create Agora RTC Engine
      _engine = createAgoraRtcEngine();
      await _engine.initialize(
        const RtcEngineContext(appId: "6dd0e8e31625434e8dd185bcb075cd79"),
      );

      // Set up event handlers
      _engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print('✅ Joined channel successfully');
            setState(() {
              _localUserJoined = true;
              _callStatus = widget.isVideoCall
                  ? 'Video call connected'
                  : 'Audio call connected';
            });
          },
          onUserJoined: (RtcConnection connection, int uid, int elapsed) {
            print('👥 User joined: $uid');
            setState(() {
              _remoteUid = uid;
              _callStatus = '${widget.otherUserName} joined the call';
            });
          },
          onUserOffline:
              (
                RtcConnection connection,
                int uid,
                UserOfflineReasonType reason,
              ) {
                print('👋 User left: $uid');
                setState(() {
                  _remoteUid = null;
                  _callStatus = '${widget.otherUserName} left the call';
                });
              },
        ),
      );

      // Enable video if this is a video call
      if (widget.isVideoCall) {
        await _engine.enableVideo();
        await _engine.startPreview();
      }

      // Join the channel
      await _engine.joinChannel(
        token: "", // Empty string for no token
        channelId: widget.callId,
        uid: 0, // Let Agora assign a UID
        options: const ChannelMediaOptions(),
      );

      setState(() {
        _isInitialized = true;
        _callStatus = 'Connected to ${widget.callId}';
      });

      print('✅ Agora RTC Engine initialized successfully!');
    } catch (e) {
      print('❌ Failed to initialize Agora: $e');
      setState(() {
        _callStatus = 'Failed to connect: $e';
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _engine.leaveChannel();
      _engine.release();
    }
    super.dispose();
  }

  // Render video views
  Widget _renderVideo() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppTheme.videoCallBackgroundDarkTheme
        : AppTheme.videoCallBackground;

    if (!widget.isVideoCall) {
      // Audio only call - show user info
      return Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person,
                size: 100,
                color: AppTheme.videoCallText,
              ),
              const SizedBox(height: 20),
              Text(
                widget.otherUserName,
                style: const TextStyle(
                  color: AppTheme.videoCallText,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _callStatus,
                style: const TextStyle(
                  color: AppTheme.videoCallTextSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Video call - show video views
    return Stack(
      children: [
        // Remote video (full screen)
        Expanded(
          child: _remoteUid != null
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: _engine,
                    canvas: VideoCanvas(uid: _remoteUid),
                    connection: RtcConnection(channelId: widget.callId),
                  ),
                )
              : Container(
                  color: backgroundColor,
                  child: const Center(
                    child: Text(
                      'Waiting for other user...',
                      style: TextStyle(
                        color: AppTheme.videoCallText,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
        ),
        // Local video (small overlay)
        if (_localUserJoined)
          Positioned(
            top: 20,
            right: 20,
            width: 120,
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: _engine,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Toggle camera on/off
  void _toggleCamera() async {
    await _engine.enableLocalVideo(!_localUserJoined);
    setState(() {
      _localUserJoined = !_localUserJoined;
    });
  }

  // Toggle microphone on/off
  void _toggleMicrophone() async {
    await _engine.muteLocalAudioStream(!_localUserJoined);
  }

  // End the call
  void _endCall() async {
    await _engine.leaveChannel();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppTheme.videoCallBackgroundDarkTheme
        : AppTheme.videoCallBackground;

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.videoCallText,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _callStatus,
                style: const TextStyle(
                  color: AppTheme.videoCallText,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Using Agora App ID: 6dd0e8e31625434e8dd185bcb075cd79',
                style: TextStyle(
                  color: AppTheme.videoCallTextSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode
                      ? AppTheme.errorDarkTheme
                      : AppTheme.error,
                  foregroundColor: AppTheme.videoCallText,
                ),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      );
    }

    // Real Agora video call interface
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Video views
              Center(child: _renderVideo()),
              // Control buttons
              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      onPressed: _toggleCamera,
                      backgroundColor: AppTheme.videoCallText,
                      child: const Icon(
                        Icons.videocam,
                        color: AppTheme.videoCallBackground,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: _toggleMicrophone,
                      backgroundColor: AppTheme.videoCallText,
                      child: const Icon(
                        Icons.mic,
                        color: AppTheme.videoCallBackground,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: _endCall,
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.videoCallEndCallDarkTheme
                          : AppTheme.videoCallEndCall,
                      child: const Icon(
                        Icons.call_end,
                        color: AppTheme.videoCallText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
