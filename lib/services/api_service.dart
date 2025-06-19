import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final _authBaseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api/auth'
      : 'http://localhost:3000/api/auth';

  static final _feedBaseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api'
      : 'http://localhost:3000/api';

  static final storage = FlutterSecureStorage();

  static Future<http.Response> register(String name, String email, String password) async {
    return await http.post(
      Uri.parse('$_authBaseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  static Future<http.Response> login(String email, String password, {String role = 'patient'}) async {
    final response = await http.post(
      Uri.parse('$_authBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    if (response.statusCode == 200) {
      await storage.write(key: 'session', value: jsonEncode({'email': email}));
    }

    return response;
  }

  static Future<http.Response> getProfile() async {
    return await http.get(Uri.parse('$_authBaseUrl/profile'));
  }

  static Future<void> logout() async {
    await http.post(Uri.parse('$_authBaseUrl/logout'));
    await storage.delete(key: 'session');
  }

  static Future<http.Response> getFeed(int userId) async {
    final url = Uri.parse('$_feedBaseUrl/feed/$userId');
    return await http.get(url, headers: {'Content-Type': 'application/json'});
  }
}
