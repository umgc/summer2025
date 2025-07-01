import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'package:care_connect_app/config/EnvConstant.dart';

class ApiEndpoints {
  static final String _host = getBackendBaseUrl();
  static final String auth = '$_host/api/auth';
}

class AuthService {
  // ✅ LOGIN
  static Future<Map<String, dynamic>> login(String email, String password, {required String role}) async {
    final session = SessionManager();

    final response = await session.post(
      '${ApiEndpoints.auth}/login',
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    session.updateCookies(response); // Store session cookie
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data; // Return full user object
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  static Future<String> register({
    required String name,
    required String email,
    required String password,
    String role = 'patient',
    required String verificationBaseUrl,
  }) async {
    final session = SessionManager();

    final response = await session.post(
      '${ApiEndpoints.auth}/register',
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'verificationBaseUrl': verificationBaseUrl,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("✅ Registration: $data");
      // If backend returns a string: just return it
      if (data is String) return data;
      // If backend returns JSON: extract a message
      return data['message'] ?? 'Registration successful! Please check your email to verify your account.';
    } else {
      // Try to extract error details
      throw Exception(data['error'] ?? data.toString() ?? 'Registration failed');
    }
  }


  // ✅ LOGOUT
  static Future<void> logout() async {
    final session = SessionManager();

    final response = await session.post('${ApiEndpoints.auth}/logout');

    if (response.statusCode == 200) {
      print("✅ Logout successful");
    } else {
      print("❌ Logout failed: ${response.statusCode} - ${response.body}");
    }
  }
}
