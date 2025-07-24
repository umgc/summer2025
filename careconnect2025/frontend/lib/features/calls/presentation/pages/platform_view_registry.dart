// platform_view_registry.dart
import 'emotion_bridge_web.dart';

void registerEmotionView() {
  // Register emotion view logic for web
  EmotionBridge.start((detectedEmotion, emoji) {
    // You can handle the detected emotion and emoji here, like updating the UI.
    print('Detected Emotion: $detectedEmotion, Emoji: $emoji');
  });
}
