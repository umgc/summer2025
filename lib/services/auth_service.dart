import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'dart:io';
class AuthService {
  static final _baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api/auth'
      : 'http://localhost:3000/api/auth';

  static Future<Map<String, dynamic>> login(String email, String password, {required String role}) async {
    final session = SessionManager();
    final response = await session.post(
      '$_baseUrl/login',
      body: jsonEncode({
        'email': email,
        'password': password,
        'role': role, // <-- include this!
      }),
    );

    session.updateCookies(response); // ✅ Moved before checking status

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['user']; // ✅ return full user object
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'patient', // ✅ default role
  }) async {
    final session = SessionManager();
    final response = await session.post(
      '$_baseUrl/register',
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    if (response.statusCode == 201) {
      print("✅ Registration successful: ${response.body}");
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Registration failed');
    }
  }

  static Future<void> logout() async {
    final session = SessionManager();
    final response = await session.post('$_baseUrl/logout');

    if (response.statusCode == 200) {
      print("✅ Logout successful");
    } else {
      print("❌ Logout failed: ${response.statusCode} - ${response.body}");
    }
  }
}
