import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import 'package:flutter/foundation.dart';

/// Service to handle Firebase authentication using service account
class FirebaseAuthService {
  // Use environment variable for service account path with fallback
  static String? get _serviceAccountPath {
    const String envPath = String.fromEnvironment(
      'FIREBASE_SERVICE_ACCOUNT_PATH',
    );
    if (envPath.isNotEmpty) {
      return envPath;
    }

    // Fallback to default path (optional)
    const String fallbackPath = String.fromEnvironment(
      'FIREBASE_SERVICE_ACCOUNT_PATH_FALLBACK',
      defaultValue: '',
    );

    return fallbackPath.isNotEmpty ? fallbackPath : null;
  }

  static Map<String, dynamic>? _serviceAccount;
  static String? _cachedAccessToken;
  static DateTime? _tokenExpiry;

  /// Load service account from JSON file
  static Future<Map<String, dynamic>?> _loadServiceAccount() async {
    if (_serviceAccount != null) return _serviceAccount;

    try {
      final serviceAccountPath = _serviceAccountPath;

      // Check if service account path is configured
      if (serviceAccountPath == null || serviceAccountPath.isEmpty) {
        print(
          '⚠️ Firebase service account path not configured via environment variables',
        );
        print('   Set FIREBASE_SERVICE_ACCOUNT_PATH environment variable');
        return null;
      }

      if (!kIsWeb) {
        final file = File(serviceAccountPath);

        // Check if file exists before attempting to read
        if (await file.exists()) {
          try {
            final contents = await file.readAsString();
            final parsed = jsonDecode(contents);

            // Validate required fields in service account
            if (parsed is Map<String, dynamic> &&
                parsed.containsKey('client_email') &&
                parsed.containsKey('private_key')) {
              _serviceAccount = parsed;
              print(
                '✅ Firebase service account loaded successfully from: $serviceAccountPath',
              );
              return _serviceAccount;
            } else {
              print(
                '❌ Invalid service account format - missing required fields',
              );
              return null;
            }
          } catch (e) {
            print('❌ Error reading or parsing service account file: $e');
            return null;
          }
        } else {
          print('⚠️ Service account file not found at: $serviceAccountPath');
          print(
            '💡 FCM messaging will use limited functionality without service account',
          );
          print('   To enable full FCM features:');
          print(
            '   1. Download Firebase service account JSON from Firebase Console',
          );
          print('   2. Set FIREBASE_SERVICE_ACCOUNT_PATH environment variable');
          return null;
        }
      } else {
        print('⚠️ Service account loading not supported on web platform');
        print('💡 Web FCM messaging will use client-side tokens only');
        return null;
      }
    } catch (e) {
      print('❌ Unexpected error loading service account: $e');
      return null;
    }
  }

  /// Get Firebase access token using service account
  static Future<String?> getAccessToken() async {
    // Return cached token if still valid
    if (_cachedAccessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _cachedAccessToken;
    }

    try {
      final serviceAccount = await _loadServiceAccount();
      if (serviceAccount == null) {
        print('⚠️ Service account unavailable - FCM admin features disabled');
        print('💡 App will continue with limited messaging functionality');
        return null;
      }

      // Create JWT for Firebase authentication
      final header = {'alg': 'RS256', 'typ': 'JWT'};

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final exp = now + 3600; // 1 hour expiry

      final payload = {
        'iss': serviceAccount['client_email'],
        'scope': 'https://www.googleapis.com/auth/firebase.messaging',
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': now,
        'exp': exp,
      };

      // Create and sign JWT
      final jwt = await _createSignedJWT(
        header,
        payload,
        serviceAccount['private_key'],
      );
      if (jwt == null) {
        print('❌ Failed to create signed JWT - messaging features limited');
        return null;
      }

      // Exchange JWT for access token
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
          'assertion': jwt,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _cachedAccessToken = data['access_token'];
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: data['expires_in'] - 60),
        ); // 60s buffer

        print('✅ Firebase access token obtained successfully');
        return _cachedAccessToken;
      } else {
        print(
          '❌ Failed to get access token: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error getting Firebase access token: $e');
      return null;
    }
  }

  /// Create signed JWT token using RSA private key
  static Future<String?> _createSignedJWT(
    Map<String, dynamic> header,
    Map<String, dynamic> payload,
    String privateKeyPem,
  ) async {
    try {
      // Encode header and payload
      final headerEncoded = _base64UrlEncode(utf8.encode(jsonEncode(header)));
      final payloadEncoded = _base64UrlEncode(utf8.encode(jsonEncode(payload)));

      final message = '$headerEncoded.$payloadEncoded';

      // Parse RSA private key
      final rsaPrivateKey = _parseRSAPrivateKey(privateKeyPem);
      if (rsaPrivateKey == null) {
        print('❌ Failed to parse RSA private key');
        return null;
      }

      // Sign the message
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201');
      signer.init(true, PrivateKeyParameter<RSAPrivateKey>(rsaPrivateKey));

      final signature = signer.generateSignature(utf8.encode(message));
      final signatureEncoded = _base64UrlEncode(signature.bytes);

      return '$message.$signatureEncoded';
    } catch (e) {
      print('❌ Error creating signed JWT: $e');
      return null;
    }
  }

  /// Parse RSA private key from PEM format
  static RSAPrivateKey? _parseRSAPrivateKey(String privateKeyPem) {
    try {
      // For now, return null - in production, you would need proper ASN.1 parsing
      // This requires the asn1lib package: https://pub.dev/packages/asn1lib
      print('⚠️ RSA private key parsing requires asn1lib package');
      return null;
    } catch (e) {
      print('❌ Error parsing RSA private key: $e');
      return null;
    }
  }

  /// Base64 URL encode
  static String _base64UrlEncode(List<int> bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  /// Send FCM message using access token
  static Future<bool> sendFCMMessage({
    required String recipientToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('❌ Failed to get access token for FCM');
        return false;
      }

      final message = {
        'message': {
          'token': recipientToken,
          'notification': {'title': title, 'body': body},
          if (data != null) 'data': data,
        },
      };

      final response = await http.post(
        Uri.parse(
          'https://fcm.googleapis.com/v1/projects/careconnectptdemo/messages:send',
        ),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ FCM message sent successfully');
        return true;
      } else {
        print(
          '❌ Failed to send FCM message: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Error sending FCM message: $e');
      return false;
    }
  }
}
