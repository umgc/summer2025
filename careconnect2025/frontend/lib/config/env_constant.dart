import 'dart:developer';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String getBackendBaseUrl() {
  if (kIsWeb) {
    // For web builds
    log('Running on Web: ${dotenv.env['CC_BASE_URL_WEB']!}');
    return dotenv.env['CC_BASE_URL_WEB']!;
  } else if (Platform.isAndroid) {
    // For Android emulator
    log('Running on Android: ${dotenv.env['CC_BASE_URL_ANDROID']!}');
    return dotenv.env['CC_BASE_URL_ANDROID']!;
  } else {
    // For Windows, Mac, iOS simulators, etc.
    log('Running on OTHER: ${dotenv.env['CC_BASE_URL_OTHER']!}');
    return dotenv.env['CC_BASE_URL_OTHER']!;
  }
}

String getBackendToken() {
  final token = dotenv.env['CC_BACKEND_TOKEN'];
  if (token == null) {
    throw Exception('CC_BACKEND_TOKEN is not defined in .env');
  }
  return token;
}

String getDeepSeekUri() {
  final uri = dotenv.env['deepSeek_uri'];
  if (uri == null) {
    throw Exception('deepSeek_uri is not defined in .env');
  }
  return uri;
}

String getDeepSeekKey() {
  final key = dotenv.env['deepSeek_key'];
  if (key == null) {
    throw Exception('deepSeek_key is not defined in .env');
  }
  return key;
}
