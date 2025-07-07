import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

String getBackendBaseUrl() {
  if (kIsWeb) {
    // For web builds
    return 'http://localhost:8080';
  } else if (Platform.isAndroid) {
    // For Android emulator
    return 'http://10.0.2.2:8080';
  } else {
    // For Windows, Mac, iOS simulators, etc.
    return 'http://localhost:8080';
  }
}
