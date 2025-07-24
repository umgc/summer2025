// lib/features/calls/presentation/pages/emotion_detector_stub.dart
import 'package:flutter/material.dart';

class EmotionDetector extends StatelessWidget {
  final void Function(String, String) onEmotionDetected;

  const EmotionDetector({super.key, required this.onEmotionDetected});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Emotion detection is not supported on this platform."));
  }
}
