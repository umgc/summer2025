export 'emotion_bridge_stub.dart' // Stub fallback
if (dart.library.html) 'emotion_bridge_web.dart'
if (dart.library.io) 'mobile_emotion_detector.dart';
