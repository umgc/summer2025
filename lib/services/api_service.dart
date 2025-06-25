import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:care_connect_app/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
class ApiEndpoints {
  static final String _host = Platform.isAndroid ? 'http://10.0.2.2' : 'http://localhost';
  static final String auth = '$_host:3000/api/auth';
  static final String feed = '$_host:8080/api/feed';
  static final String users = '$_host:8080/users';
  static final String friends = '$_host:8080/friends';
}

class ApiService {
  static final storage = FlutterSecureStorage();

  static Future<http.Response> register(String name, String email, String password) async {
    return await http.post(
      Uri.parse('${ApiEndpoints.auth}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  static Future<http.Response> login(String email, String password, {String role = 'patient'}) async {
    final response = await http.post(
      Uri.parse('${ApiEndpoints.auth}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    if (response.statusCode == 200) {
      // ✅ Save session info to secure storage
      await storage.write(key: 'session', value: jsonEncode({'email': email}));

      // ✅ Extract and store session cookie manually
      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        final prefs = await SharedPreferences.getInstance();
        // Find the cookie starting with JSESSIONID= or SESSION=, etc.
        final sessionCookie = rawCookie.split(';').firstWhere(
              (c) => c.trim().startsWith('JSESSIONID='),
          orElse: () => '', // If not found
        );
        if (sessionCookie.isNotEmpty) {
          await prefs.setString('session_cookie', sessionCookie);
          print('💾 Saved session_cookie: $sessionCookie');
        } else {
          print('⚠️ No JSESSIONID found in cookie!');
        }
      }
    }
    return response;
  }

  static Future<http.Response> getProfile() async {
    return await http.get(Uri.parse('${ApiEndpoints.auth}/profile'));
  }

  static Future<void> logout() async {
    await http.post(Uri.parse('${ApiEndpoints.auth}/logout'));
    await storage.delete(key: 'session');
  }

  static Future<http.Response> getFeed(int userId) async {
    final url = Uri.parse('${ApiEndpoints.feed}/feed/$userId');
    return await http.get(url, headers: {'Content-Type': 'application/json'});
  }

  static Future<http.Response> getAllPosts() async {
    final session = SessionManager();
    await session.restoreSession();
    return session.get('${ApiEndpoints.feed}/all');
  }

  static Future<http.Response> getUserPosts(int userId) async {
    return await http.get(Uri.parse('${ApiEndpoints.feed}/user/$userId'));
  }

  static Future<http.Response> createPost(int userId, String content, [File? image]) async {
    final uri = Uri.parse('${ApiEndpoints.feed}/create');


    // 🔁 Restore session_cookie from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final session_cookie = prefs.getString('session_cookie') ?? '';
    print('💾 Saved session_cookie from prefs: $session_cookie');
    print('📤 [createPost] Using session_cookie: $session_cookie');

    final savedCookie = await prefs.getString('session_cookie');
    print('💾 Saved session_cookie from prefs: $savedCookie');

    var request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId.toString()
      ..fields['content'] = content
      ..headers['Cookie'] = session_cookie;

    // Optional: Attach image if present
    if (image != null) {
      final imageStream = http.ByteStream(image.openRead());
      final imageLength = await image.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: path.basename(image.path),
      );
      request.files.add(multipartFile);
    }

    // 🔄 Send request and wait for full response
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    // 🐞 Debug output
    print('📥 [createPost] Status: ${response.statusCode}');
    print('📥 [createPost] Body: ${response.body}');

    return response;
  }


  static Future<http.Response> searchUsers(String query) async {
    final url = Uri.parse('${ApiEndpoints.users}/search?query=$query');
    return await http.get(url);
  }

  static Future<http.Response> sendFriendRequest(int fromUserId, int toUserId) async {
    final url = Uri.parse('${ApiEndpoints.friends}/request');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fromUserId': fromUserId, 'toUserId': toUserId}),
    );
  }
}
