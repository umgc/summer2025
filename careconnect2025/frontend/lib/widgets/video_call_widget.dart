import 'package:flutter/material.dart';
import '../services/video_call_service.dart';
import '../config/theme/app_theme.dart';

class VideoCallWidget extends StatefulWidget {
  final String callId;
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;
  final bool isVideoCall;
  final bool isIncoming;

  const VideoCallWidget({
    super.key,
    required this.callId,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
    this.isVideoCall = true,
    this.isIncoming = false,
  });

  @override
  State<VideoCallWidget> createState() => _VideoCallWidgetState();
}

class _VideoCallWidgetState extends State<VideoCallWidget> {
  bool _isMicOn = true;
  bool _isCameraOn = true;
  bool _isCallConnected = false;
  bool _isCallEnded = false;
  DateTime? _callStartTime;

  @override
  void initState() {
    super.initState();
    if (!widget.isIncoming) {
      _joinCall();
    }
  }

  Future<void> _joinCall() async {
    try {
      final success = await VideoCallService.joinCall(
        widget.callId,
        widget.currentUserId,
      );

      if (success) {
        setState(() {
          _isCallConnected = true;
          _callStartTime = DateTime.now();
        });
      } else {
        _endCall('Failed to join call');
      }
    } catch (e) {
      print('Error joining call: $e');
      _endCall('Connection failed');
    }
  }

  Future<void> _endCall([String? reason]) async {
    if (_isCallEnded) return;

    setState(() => _isCallEnded = true);

    try {
      await VideoCallService.endCallStatic(widget.callId, widget.currentUserId);
    } catch (e) {
      print('Error ending call: $e');
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _toggleMic() {
    setState(() => _isMicOn = !_isMicOn);
    // In real implementation: await ZegoExpressEngine.instance.muteMicrophone(!_isMicOn);
  }

  void _toggleCamera() {
    if (!widget.isVideoCall) return;
    setState(() => _isCameraOn = !_isCameraOn);
    // In real implementation: await ZegoExpressEngine.instance.muteVideoOutput(!_isCameraOn);
  }

  String _getCallDuration() {
    if (_callStartTime == null) return '00:00';

    final duration = DateTime.now().difference(_callStartTime!);
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildVideoView() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? AppTheme.videoCallBackgroundDarkTheme
        : AppTheme.videoCallBackground;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Stack(
        children: [
          // Remote user video (main view)
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.isVideoCall && _isCallConnected
                ? Container(
                    // In real implementation, this would be the ZEGOCLOUD video view
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.3),
                          Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: Text(
                              widget.otherUserName.isNotEmpty
                                  ? widget.otherUserName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.videoCallText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.otherUserName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.videoCallText,
                            ),
                          ),
                          if (_isCallConnected) ...[
                            const SizedBox(height: 8),
                            Text(
                              _getCallDuration(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.videoCallTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            widget.otherUserName.isNotEmpty
                                ? widget.otherUserName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.videoCallText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          widget.otherUserName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.videoCallText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isCallConnected
                              ? _getCallDuration()
                              : widget.isIncoming
                              ? 'Incoming ${widget.isVideoCall ? 'video' : 'audio'} call'
                              : 'Calling...',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.videoCallTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Local user video (small preview in corner)
          if (widget.isVideoCall && _isCameraOn && _isCallConnected)
            Positioned(
              top: 50,
              right: 20,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.videoCallBackground.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.videoCallText, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    // In real implementation, this would be the local video preview
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.8),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.videoCallTextTertiary,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

          // Call status overlay
          if (!_isCallConnected && !widget.isIncoming)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.videoCallBackgroundDarkTheme.withOpacity(0.8)
                  : AppTheme.videoCallBackground.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.videoCallText),
                    SizedBox(height: 16),
                    Text(
                      'Connecting...',
                      style: TextStyle(
                        color: AppTheme.videoCallText,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          FloatingActionButton(
            heroTag: 'mic',
            onPressed: _toggleMic,
            backgroundColor: _isMicOn
                ? AppTheme.videoCallText
                : (Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.videoCallEndCallDarkTheme
                      : AppTheme.videoCallEndCall),
            child: Icon(
              _isMicOn ? Icons.mic : Icons.mic_off,
              color: _isMicOn
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.videoCallBackgroundDarkTheme
                        : AppTheme.videoCallBackground)
                  : AppTheme.videoCallText,
            ),
          ),

          // End call button
          FloatingActionButton(
            heroTag: 'endCall',
            onPressed: () => _endCall(),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.videoCallEndCallDarkTheme
                : AppTheme.videoCallEndCall,
            child: const Icon(Icons.call_end, color: AppTheme.videoCallText),
          ),

          // Camera toggle (video calls only)
          if (widget.isVideoCall)
            FloatingActionButton(
              heroTag: 'camera',
              onPressed: _toggleCamera,
              backgroundColor: _isCameraOn
                  ? AppTheme.videoCallText
                  : (Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.backgroundSecondaryDarkTheme
                        : Colors.grey[800]),
              child: Icon(
                _isCameraOn ? Icons.videocam : Icons.videocam_off,
                color: _isCameraOn
                    ? (Theme.of(context).brightness == Brightness.dark
                          ? AppTheme.videoCallBackgroundDarkTheme
                          : AppTheme.videoCallBackground)
                    : AppTheme.videoCallText,
              ),
            )
          else
            // Speaker toggle for audio calls
            FloatingActionButton(
              heroTag: 'speaker',
              onPressed: () {
                // Toggle speaker
              },
              backgroundColor: AppTheme.videoCallText,
              child: Icon(
                Icons.volume_up,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.videoCallBackgroundDarkTheme
                    : AppTheme.videoCallBackground,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIncomingCallControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Decline call
          FloatingActionButton(
            heroTag: 'decline',
            onPressed: () => _endCall('Call declined'),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.videoCallEndCallDarkTheme
                : AppTheme.videoCallEndCall,
            child: const Icon(Icons.call_end, color: AppTheme.videoCallText),
          ),

          // Accept call
          FloatingActionButton(
            heroTag: 'accept',
            onPressed: _joinCall,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.successDarkTheme
                : AppTheme.success,
            child: const Icon(Icons.call, color: AppTheme.videoCallText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use fallback UI for all platforms until Zego web compatibility is resolved
    return _buildFallbackUI();
  }

  // Fallback UI for development/testing when ZEGOCLOUD is not available
  Widget _buildFallbackUI() {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.videoCallBackgroundDarkTheme
          : AppTheme.videoCallBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildVideoView()),
            widget.isIncoming && !_isCallConnected
                ? _buildIncomingCallControls()
                : _buildCallControls(),
          ],
        ),
      ),
    );
  }
}
