/*// Import necessary packages for web.
import 'dart:html' as html;

class EmotionBridge {
  // Callback function type
  static Function(String detectedEmotion, String emoji)? _callback;

  // Start emotion detection on the web
  static void start(Function(String detectedEmotion, String emoji) callback) {
    _callback = callback;

    // Get access to video stream from the webcam
    html.window.navigator.mediaDevices?.getUserMedia({'video': true}).then((stream) {
      final videoElement = html.VideoElement()
        ..srcObject = stream
        ..autoplay = true
        ..width = 640
        ..height = 480;

      // Start the emotion detection logic
      videoElement.onPlay.listen((_) {
        // Here, you would implement the logic for detecting faces and emotions in the video stream.
        // For simplicity, let's assume we detect a "Happy" face.

        // Simulate the emotion detection result
        _detectEmotionAndTriggerCallback();
      });

      // Attach the video element to the DOM for display
      html.document.body?.append(videoElement);
    });
  }

  // Stop emotion detection on the web
  static void stop() {
    // Stop any video stream and cleanup resources.
    html.document.body?.querySelector('video')?.remove();
    _callback = null;
  }

  // Simulated method to detect emotions (replace with actual face detection logic)
  static void _detectEmotionAndTriggerCallback() {
    // Simulate detecting a happy emotion.
    if (_callback != null) {
      _callback!("Happy", "😄");
    }
  }
}
*/
// utils/emotion_bridge_web.dart


import 'dart:async' as html;
import 'dart:html' as html;
import 'dart:js' as js;

class EmotionBridge {
  static Function(String emotion, String emoji)? _callback;
  static html.StreamSubscription<html.MessageEvent>? _subscription;

  static void start(Function(String emotion, String emoji) callback) {
    _callback = callback;

    // Start JS emotion detection using dart:js
    final startFn = js.context['startEmotionDetection'];
    if (startFn != null) {
      startFn.apply([]);
    } else {
      print("⚠️ startEmotionDetection not found in JS context");
    }

    // Cancel previous listener
    _subscription?.cancel();

    // Listen for postMessage events from emotion.js
    _subscription = html.window.onMessage.listen((html.MessageEvent event) {
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
    if (stopFn != null) {
      stopFn.apply([]);
    } else {
      print("⚠️ stopEmotionDetection not found in JS context");
    }

    _subscription?.cancel();
    _subscription = null;
    _callback = null;
  }
}
