import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:camera/camera.dart';
import 'animation_controller.dart';

class WebEmotionDetector extends StatefulWidget {
  const WebEmotionDetector({super.key, required this.onEmotionDetected});

  final void Function(String emoji, String label) onEmotionDetected;

  @override
  State<WebEmotionDetector> createState() => _WebEmotionDetectorState();
}

class _WebEmotionDetectorState extends State<WebEmotionDetector> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  String _emotion = "Neutral";
  String _emoji = "😐";

  late EmotionAnimationController anim;

  @override
  void initState() {
    super.initState();

    anim = EmotionAnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Listen for emotion detection messages from JavaScript
    html.window.onMessage.listen((event) {
      final data = event.data;
      if (data is Map && data['emotion'] != null && data['emoji'] != null) {
        setState(() {
          _emotion = data['emotion'].toString().capitalize();
          _emoji = data['emoji'];
        });
        widget.onEmotionDetected(_emoji, _emotion);  // Notify parent widget of detected emotion
      }
    });

    // Initialize the camera after a short delay
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _initCamera();
    });
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    anim.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        AnimatedBuilder(
          animation: anim.controller,
          builder: (context, child) {
            return Container(
              width: anim.size.value,
              height: anim.size.value,
              decoration: BoxDecoration(
                color: anim.color.value,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CameraPreview(_controller!),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text("Detected Emotion: $_emotion $_emoji",
            style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}

extension Capitalize on String {
  String capitalize() => isEmpty ? "" : "${this[0].toUpperCase()}${substring(1)}";
}
