import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class ApiEndpoints {
  static final String _host = Platform.isAndroid ? 'http://10.0.2.2' : 'http://localhost';
  static final String auth = '$_host:8080/api/auth';
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

  // ✅ REGISTER
  static Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'patient',
  }) async {
    final session = SessionManager();

    final response = await session.post(
      '${ApiEndpoints.auth}/register',
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      print("✅ Registration: $data");
    } else {
      throw Exception(data['error'] ?? 'Registration failed');
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
