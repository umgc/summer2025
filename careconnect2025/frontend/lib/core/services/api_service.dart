import 'dart:convert';
import 'dart:io';
import '../../config/env_constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/auth_token_manager.dart';
import 'package:path/path.dart' as path;

class ApiConstants {
  static final String _host = getBackendBaseUrl();
  static final String auth = '$_host/v1/api/auth';
  static final String feed = '$_host/v1/api/feed';
  static final String users = '$_host/v1/api/users';
  static final String friends = '$_host/v1/api/friends';
}

class ApiService {
  static const storage = FlutterSecureStorage();

  static Future<http.Response> register(
    String name,
    String email,
    String password,
  ) async {
    return await http.post(
      Uri.parse('${ApiConstants.auth}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
  }

  static Future<http.Response> login(
    String email,
    String password, {
    String role = 'patient',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'role': role}),
    );

    // Note: JWT token will be extracted from response body and saved by AuthService.login()
    // No session cookie handling needed here
    return response;
  }

  static Future<http.Response> logout() async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.auth}/logout'),
      headers: headers,
    );

    // Clear JWT token after logout
    await AuthTokenManager.clearAuthData();
    return response;
  }

  static Future<http.Response> getProfile() async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await http.get(
      Uri.parse('${ApiConstants.auth}/profile'),
      headers: headers,
    );
  }

  static Future<http.Response> getAllPosts() async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await http.get(
      Uri.parse('${ApiConstants.feed}/all'),
      headers: headers,
    );
  }

  static Future<http.Response> getUserPosts(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await http.get(
      Uri.parse('${ApiConstants.feed}/user/$userId'),
      headers: headers,
    );
  }

  static Future<http.Response> createPost(
    int userId,
    String content, [
    File? image,
  ]) async {
    final uri = Uri.parse('${ApiConstants.feed}/create');
    final headers = await AuthTokenManager.getAuthHeaders();

    var request = http.MultipartRequest('POST', uri)
      ..fields['userId'] = userId.toString()
      ..fields['content'] = content;

    // Add auth headers to multipart request
    request.headers.addAll(headers);

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

  static Future<http.Response> searchUsers(
    String query,
    int currentUserId,
  ) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse(
      '${ApiConstants.users}/search?query=$query&currentUserId=$currentUserId',
    );

    return await http.get(url, headers: headers);
  }

  static Future<http.Response> sendFriendRequest(
    int fromUserId,
    int toUserId,
  ) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/request');
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode({'fromUserId': fromUserId, 'toUserId': toUserId}),
    );
  }

  static Future<http.Response> getPendingFriendRequests(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/requests/$userId');
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> acceptFriendRequest(int requestId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/accept');
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode({'requestId': requestId}),
    );
  }

  static Future<http.Response> rejectFriendRequest(int requestId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/reject');
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode({'requestId': requestId}),
    );
  }

  static Future<http.Response> getFriends(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/list/$userId');
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> resetUserPassword({
    required String username,
    required String resetToken,
    required String newPassword,
  }) async {
    return await http.post(
      Uri.parse('${ApiConstants.users}/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'resetToken': resetToken,
        'newPassword': newPassword,
      }),
    );
  }
}
