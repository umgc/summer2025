// emotion_bridge_web.dart

import 'dart:html' as html;
import 'dart:js' as js;

class EmotionBridge {
  static Function(String emotion, String emoji)? _callback;

  static void start(void Function(String emotion, String emoji)? onUpdate) {
    _callback = onUpdate;

    final startFn = js.context['startEmotionDetection'];
    startFn?.apply([]);

    html.window.onMessage.listen((html.MessageEvent event) {
      final data = event.data;
      if (data is Map && data.containsKey('emotion') && data.containsKey('emoji')) {
        final emotion = data['emotion'] as String;
        final emoji = data['emoji'] as String;
        _callback?.call(emotion, emoji);
      }
    });
  }

  static void stop() {
    final stopFn = js.context['stopEmotionDetection'];
    stopFn?.apply([]);
  }
}
