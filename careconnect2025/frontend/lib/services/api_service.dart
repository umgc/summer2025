import 'dart:convert';
import 'dart:io';
import 'package:care_connect_app/config/EnvConstant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:care_connect_app/services/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class ApiEndpoints {
  static final String _host = getBackendBaseUrl();
  static final String auth = '$_host/api/auth';
  static final String feed = '$_host/api/feed';
  static final String users = '$_host/api/users'; // ✅ Fixed here
  static final String friends = '$_host/api/friends';
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
      await storage.write(key: 'session', value: jsonEncode({'email': email}));

      final rawCookie = response.headers['set-cookie'];
      if (rawCookie != null) {
        final prefs = await SharedPreferences.getInstance();
        final sessionCookie = rawCookie.split(';').firstWhere(
              (c) => c.trim().startsWith('JSESSIONID=') || c.trim().startsWith('SESSION='),
          orElse: () => '',
        );
        if (sessionCookie.isNotEmpty) {
          await prefs.setString('session_cookie', sessionCookie);
          print('💾 Saved session_cookie: $sessionCookie');
        } else {
          print('⚠️ No session cookie found in login response');
        }
      }
    }

    return response;
  }

  static Future<void> logout() async {
    await http.post(Uri.parse('${ApiEndpoints.auth}/logout'));
    await storage.delete(key: 'session');
  }

  static Future<http.Response> getProfile() async {
    return await http.get(Uri.parse('${ApiEndpoints.auth}/profile'));
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
    final prefs = await SharedPreferences.getInstance();
    final session_cookie = prefs.getString('session_cookie') ?? '';

    var request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId.toString()
      ..fields['content'] = content
      ..headers['Cookie'] = session_cookie;

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

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // -------------------------------
  // 🤝 FRIEND FEATURES
  // -------------------------------

  static Future<http.Response> searchUsers(String query, int currentUserId) async {
    final prefs = await SharedPreferences.getInstance();
    final session_cookie = prefs.getString('session_cookie') ?? '';
    final url = Uri.parse('${ApiEndpoints.users}/search?query=$query&currentUserId=$currentUserId');

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': session_cookie,
      },
    );
  }

  static Future<http.Response> sendFriendRequest(int fromUserId, int toUserId) async {
    final url = Uri.parse('${ApiEndpoints.friends}/request');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fromUserId': fromUserId, 'toUserId': toUserId}),
    );
  }

  static Future<http.Response> getPendingFriendRequests(int userId) async {
    final url = Uri.parse('${ApiEndpoints.friends}/requests/$userId');
    return await http.get(url);
  }

  static Future<http.Response> acceptFriendRequest(int requestId) async {
    final url = Uri.parse('${ApiEndpoints.friends}/accept');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestId': requestId}),
    );
  }

  static Future<http.Response> rejectFriendRequest(int requestId) async {
    final url = Uri.parse('${ApiEndpoints.friends}/reject');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'requestId': requestId}),
    );
  }

  static Future<http.Response> getFriends(int userId) async {
    final url = Uri.parse('${ApiEndpoints.friends}/list/$userId');
    return await http.get(url);
  }
}
