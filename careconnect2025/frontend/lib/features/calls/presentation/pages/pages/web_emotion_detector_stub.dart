import 'package:flutter/material.dart';

class WebEmotionDetector extends StatelessWidget {
  final Function(String emoji, String label) onEmotionDetected;

  const WebEmotionDetector({super.key, required this.onEmotionDetected});

  @override
  Widget build(BuildContext context) {
    // Simulated web emotion detection UI
    Future.delayed(const Duration(seconds: 2), () {
      onEmotionDetected("🙂", "Neutral");
    });

    return Column(
      children: const [
        Icon(Icons.face, size: 64),
        Text("Web Emotion Detected", style: TextStyle(fontSize: 20)),
      ],
    );
  }
}
