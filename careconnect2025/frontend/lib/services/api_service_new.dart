import 'dart:convert';
import 'dart:io';
import '../config/env_constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'auth_token_manager.dart';

class ApiConstants {
  static final String _host = getBackendBaseUrl();
  static final String auth = '$_host/v1/api/auth';
  static final String feed = '$_host/v1/api/feed';
  static final String users = '$_host/v1/api/users';
  static final String friends = '$_host/v1/api/friends';
  static final String analytics = '$_host/v1/api/analytics';
  static final String baseUrl = '$_host/v1/api/';
}

class ApiService {
  static const storage = FlutterSecureStorage();

  // Performance optimization: Connection pooling
  static final http.Client _httpClient = http.Client();

  // Method to dispose of resources
  static void dispose() {
    _httpClient.close();
  }

  // ========================
  // AUTHENTICATION METHODS
  // ========================

  static Future<http.Response> register(
    String name,
    String email,
    String password,
  ) async {
    return await _httpClient
        .post(
          Uri.parse('${ApiConstants.auth}/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> login(
    String email,
    String password, {
    String role = 'patient',
  }) async {
    return await _httpClient
        .post(
          Uri.parse('${ApiConstants.auth}/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
            'role': role,
          }),
        )
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> logout() async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await _httpClient
        .post(Uri.parse('${ApiConstants.auth}/logout'), headers: headers)
        .timeout(const Duration(seconds: 30));

    // Clear all auth data
    await AuthTokenManager.clearAuthData();
    return response;
  }

  static Future<http.Response> requestPasswordReset(String email) async {
    return await _httpClient
        .post(
          Uri.parse('${ApiConstants.auth}/password/forgot'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email}),
        )
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    return await _httpClient
        .post(
          Uri.parse('${ApiConstants.auth}/password/reset'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'token': token, 'password': newPassword}),
        )
        .timeout(const Duration(seconds: 30));
  }

  // ========================
  // PROFILE METHODS
  // ========================

  static Future<http.Response> getProfile() async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await _httpClient
        .get(Uri.parse('${ApiConstants.auth}/profile'), headers: headers)
        .timeout(const Duration(seconds: 30));
  }

  // ========================
  // FEED METHODS
  // ========================

  static Future<http.Response> getAllPosts() async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await _httpClient
        .get(Uri.parse('${ApiConstants.feed}/all'), headers: headers)
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> getUserPosts(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await _httpClient
        .get(Uri.parse('${ApiConstants.feed}/user/$userId'), headers: headers)
        .timeout(const Duration(seconds: 30));
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

  // ========================
  // FRIEND METHODS
  // ========================

  static Future<http.Response> searchUsers(
    String query,
    int currentUserId,
  ) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse(
      '${ApiConstants.users}/search?query=$query&currentUserId=$currentUserId',
    );

    return await _httpClient
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> sendFriendRequest(
    int fromUserId,
    int toUserId,
  ) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/request');
    return await _httpClient
        .post(
          url,
          headers: headers,
          body: jsonEncode({'fromUserId': fromUserId, 'toUserId': toUserId}),
        )
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> getPendingFriendRequests(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/requests/$userId');
    return await _httpClient
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> acceptFriendRequest(int requestId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/accept');
    return await _httpClient
        .post(url, headers: headers, body: jsonEncode({'requestId': requestId}))
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> rejectFriendRequest(int requestId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/reject');
    return await _httpClient
        .post(url, headers: headers, body: jsonEncode({'requestId': requestId}))
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> getFriends(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.friends}/list/$userId');
    return await _httpClient
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 30));
  }

  // ========================
  // DASHBOARD METHODS
  // ========================

  static Future<http.Response> getCaregiverPatients(int caregiverId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await _httpClient
        .get(
          Uri.parse('${ApiConstants.baseUrl}caregivers/$caregiverId/patients'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));
  }

  static Future<http.Response> getPatientVitals(int patientId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await _httpClient
        .get(
          Uri.parse('${ApiConstants.baseUrl}patients/$patientId/vitals'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 30));
  }

  // ========================
  // UTILITY METHODS
  // ========================

  // Get auth headers with Authorization bearer token
  static Future<Map<String, String>> getAuthHeaders() async {
    return await AuthTokenManager.getAuthHeaders();
  }

  // Save JWT token from Set-Cookie header or response body
  static Future<void> saveJWTToken(String token) async {
    // This method is now deprecated - use AuthTokenManager.saveAuthData instead
    print(
      'Warning: saveJWTToken is deprecated. Use AuthTokenManager.saveAuthData instead.',
    );
  }

  // Clear auth cookie/token
  static Future<void> clearAuthCookie() async {
    await AuthTokenManager.clearAuthData();
  }
}
