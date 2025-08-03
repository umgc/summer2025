import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart' as camera;
import '../emotion_bridge.dart';
import '../emotion_video_view.dart';
import 'jitsi_view_web.dart'; // Import the Jitsi view registration

class JitsiMeetingScreen extends StatefulWidget {
  final String roomId; // Pass the room ID for dynamic room URLs

  const JitsiMeetingScreen({super.key, required this.roomId});

  @override
  State<JitsiMeetingScreen> createState() => _JitsiMeetingScreenState();
}

class _JitsiMeetingScreenState extends State<JitsiMeetingScreen> {
  camera.CameraController? _cameraController;
  String? _emotion;
  String? _emoji;
  bool callStarted = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      registerJitsiView(); // Register Jitsi Web view for local and production URLs
    }
    _startEmotionDetection();
  }

  void _startEmotionDetection() {
    EmotionBridge.start((detectedEmotion, detectedEmoji) {
      setState(() {
        _emotion = detectedEmotion;
        _emoji = detectedEmoji;
      });
    });

    if (!kIsWeb) {
      _initMobileCamera(); // Initialize camera for mobile platforms
    }
  }

  Future<void> _initMobileCamera() async {
    final cameras = await camera.availableCameras();
    final frontCam = cameras.firstWhere(
          (cam) => cam.lensDirection == camera.CameraLensDirection.front,
    );

    _cameraController = camera.CameraController(
      frontCam,
      camera.ResolutionPreset.medium,
      enableAudio: true,
    );

    await _cameraController!.initialize();
    _cameraController!.startImageStream((image) {
      // Emotion detection logic handled inside EmotionBridge
    });
  }

  @override
  void dispose() {
    EmotionBridge.stop();
    _cameraController?.dispose();
    super.dispose();
  }

  // Start the call by updating state
  void _startCall() => setState(() => callStarted = true);

  // End the call and dispose of resources
  Future<void> _endCall() async {
    await _cameraController?.dispose();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = widget.roomId; // You can use dynamic room ID logic here
    final hasDetection = _emotion != null && _emoji != null;

    return Scaffold(
      appBar: AppBar(title: Text('Jitsi Meeting')),
      body: Stack(
        children: [
          // Render Jitsi Web view only if on the Web platform
          if (kIsWeb)
            const HtmlElementView(viewType: 'jitsi-view'),

          // Emotion panel for caregiver and patient
          if (hasDetection)
            Positioned(
              top: 20,
              right: 20,
              child: _EmotionPanel(
                label: "$roleLabel Emotion",
                emotion: _emotion!,
                emoji: _emoji!,
              ),
            ),

          // Emotion video for web
          if (kIsWeb) const EmotionVideoView(),

          // Camera preview for mobile platforms
          if (!kIsWeb && _cameraController != null)
            Offstage(
              offstage: true, // You can toggle this to show the camera
              child: camera.CameraPreview(_cameraController!),
            ),

          // Join/End call buttons
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width * 0.3,
            child: ElevatedButton.icon(
              icon: callStarted ? Icon(Icons.call_end) : Icon(Icons.call),
              label: callStarted ? Text("End Call") : Text("Join Call"),
              onPressed: callStarted ? _endCall : _startCall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionPanel extends StatelessWidget {
  final String label;
  final String emotion;
  final String emoji;

  const _EmotionPanel({
    required this.label,
    required this.emotion,
    required this.emoji,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "$label: $emotion $emoji",
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
