import 'dart:io' show Platform;
import 'dart:developer' show log;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String getBackendBaseUrl() {
  if (kIsWeb) {
    // For web builds
    return dotenv.env['CC_BASE_URL_WEB']!;
  } else if (Platform.isAndroid) {
    // For Android emulator
    return dotenv.env['CC_BASE_URL_ANDROID']!;
  } else {
    // For Windows, Mac, iOS simulators, etc.
    return dotenv.env['CC_BASE_URL_OTHER']!;
  }
}

String getBackendToken() {
  final token =
      dotenv.env['CC_BACKEND_TOKEN'] ??
      Platform.environment['CC_BACKEND_TOKEN'];

  if (token == null || token.isEmpty || token == 'your_backend_token_here') {
    if (kDebugMode) {
      print('⚠️ Backend token not configured. Some API calls may fail.');
      return '';
    }
    throw Exception(
      'CC_BACKEND_TOKEN is not configured. Please set it in .env.local or environment variables.',
    );
  }

  if (kDebugMode) {
    print('✅ Backend token loaded successfully');
  }
  return token;
}

String getJWTSecret() {
  final secret = dotenv.env['JWT_SECRET'] ?? Platform.environment['JWT_SECRET'];

  if (secret == null ||
      secret.isEmpty ||
      secret == 'your_jwt_secret_key_here') {
    if (kDebugMode) {
      print('⚠️ JWT secret not configured. Token validation may fail.');
      return '';
    }
    throw Exception(
      'JWT_SECRET is not configured. Please set it in .env.local or environment variables.',
    );
  }

  // Validate JWT secret length (should be at least 32 characters for security)
  if (secret.length < 32) {
    throw Exception(
      'JWT_SECRET must be at least 32 characters long for security.',
    );
  }

  if (kDebugMode) {
    print('✅ JWT secret loaded successfully');
  }
  return secret;
}

String getDeepSeekUri() {
  final uri = dotenv.env['deepSeek_uri'];
  if (uri == null) {
    throw Exception('deepSeek_uri is not defined in .env');
  }
  return uri;
}

String getOpenAIKey() {
  // Try multiple environment sources for the API key
  final key =
      dotenv.env['OPENAI_API_KEY'] ??
      dotenv.env['openai_key'] ??
      Platform.environment['OPENAI_API_KEY'];

  if (key == null || key.isEmpty || key == 'your_openai_api_key_here') {
    if (kDebugMode) {
      print('⚠️ OpenAI API key not configured. AI features will be disabled.');
      return '';
    }
    throw Exception(
      'OPENAI_API_KEY is not configured. Please set it in .env.local or environment variables.',
    );
  }

  // Validate key format (OpenAI keys start with 'sk-')
  if (!key.startsWith('sk-')) {
    throw Exception(
      'Invalid OpenAI API key format. Key should start with "sk-".',
    );
  }

  if (kDebugMode) {
    print('✅ OpenAI API key loaded successfully');
  }
  return key;
}

String getDeepSeekKey() {
  // Try multiple environment sources for the API key
  final key =
      dotenv.env['DEEPSEEK_API_KEY'] ??
      dotenv.env['deepSeek_key']?.replaceFirst('Bearer ', '') ??
      Platform.environment['DEEPSEEK_API_KEY'];

  if (key == null || key.isEmpty || key == 'your_deepseek_api_key_here') {
    if (kDebugMode) {
      log(
        '⚠️ DeepSeek API key not configured. DeepSeek AI features will be disabled.',
      );
      return '';
    }
    throw Exception(
      'DEEPSEEK_API_KEY is not configured. Please set it in .env.local or environment variables.',
    );
  }

  // Validate key format (DeepSeek keys start with 'sk-')
  if (!key.startsWith('sk-')) {
    throw Exception(
      'Invalid DeepSeek API key format. Key should start with "sk-".',
    );
  }

  if (kDebugMode) {
    log('✅ DeepSeek API key loaded successfully');
  }
  return key;
}

String getGoogleClientId() {
  final clientId = dotenv.env['GOOGLE_CLIENT_ID'];
  if (clientId == null) {
    throw Exception('GOOGLE_CLIENT_ID is not defined in .env');
  }
  return clientId;
}

String getAppDomain() {
  return dotenv.env['APP_DOMAIN'] ?? 'localhost';
}

String getAppPort() {
  return dotenv.env['APP_PORT'] ?? '50030';
}

String getOAuthRedirectUri() {
  final domain = getAppDomain();
  final port = getAppPort();

  // For localhost, include port. For production domains, don't include port
  if (domain == 'localhost' || domain.startsWith('127.0.0.1')) {
    return 'http://$domain:$port/oauth2/callback/google';
  } else {
    return 'https://$domain/oauth2/callback/google';
  }
}

String getWebBaseUrl() {
  final domain = getAppDomain();
  final port = getAppPort();

  // For development/localhost
  if (domain == 'localhost' || domain.startsWith('127.0.0.1')) {
    return 'http://$domain:$port';
  }

  // For production
  return 'https://$domain';
}
