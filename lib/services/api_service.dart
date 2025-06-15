import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const baseUrl = 'http://localhost:3000/api/auth'; // change when deployed
  static final storage = FlutterSecureStorage();

  static Future<http.Response> register(String name, String email, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  static Future<http.Response> login(String email, String password) async {
    var client = http.Client();
    var response = await client.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      await storage.write(key: 'session', value: jsonEncode({'email': email}));
    }

    return response;
  }

  static Future<http.Response> getProfile() async {
    return await http.get(Uri.parse('$baseUrl/profile'));
  }

  static Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/logout'));
    await storage.delete(key: 'session');
  }
}
