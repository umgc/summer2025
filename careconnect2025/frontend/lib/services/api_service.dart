import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../config/env_constant.dart';
import 'auth_token_manager.dart';

class ApiConstants {
  static final String _host = getBackendBaseUrl();
  static final String auth = '$_host/v1/api/auth';
  static final String feed = '$_host/v1/api/feed';
  static final String users = '$_host/v1/api/users';
  static final String friends = '$_host/v1/api/friends';
  static final String analytics = '$_host/v1/api/analytics';
  static final String baseUrl = '$_host/v1/api/';
  static final String familyMembers = '$_host/v1/api/family-members';
  static final String patient = '$_host/v1/api/patient';
  static final String patients = '$_host/v1/api/patients';
  static final String caregivers = '$_host/v1/api/caregivers';
  static final String files = '$_host/v1/api/files';
  static final String connectionRequests = '$_host/v1/api/connection-requests';
  static final String subscriptions = '$_host/v1/api/subscriptions';
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

  static Future<http.Response> registerPatient(
    String firstName,
    String lastName,
    String email,
    String phone,
    String dob,
    String address,
    String relationship,
    int caregiverId,
  ) async {
    final headers = await AuthTokenManager.getAuthHeaders();

    // Debug: Check if JWT token is included
    print('🔍 registerPatient headers: $headers');
    final hasAuth = headers.containsKey('Authorization');
    print('🔍 Authorization header present: $hasAuth');
    if (hasAuth) {
      print('🔍 Auth header value: ${headers['Authorization']}');
    }

    return await _httpClient
        .post(
          Uri.parse('${ApiConstants.baseUrl}caregivers/$caregiverId/patients'),
          headers: headers,
          body: jsonEncode({
            'firstName': firstName,
            'lastName': lastName,
            'email': email,
            'phone': phone,
            'dob': dob,
            'address': address,
            'relationship': relationship,
            'caregiverId': caregiverId,
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

  // FAMILY
  // FAMILY
  static Future<List<Map<String, dynamic>>> getAccessiblePatients() async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();
      final response = await http
          .get(
            Uri.parse(
              '${ApiConstants.familyMembers}/patients',
            ), // Use ApiConstants.familyMembers
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (isAccessDenied(response)) {
        throw Exception('You do not have access to view patients');
      } else {
        throw Exception(handleErrorResponse(response));
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid response format from server');
      }
      rethrow;
    }
  }

  // Get specific patient data
  static Future<Map<String, dynamic>> getPatientData(int patientId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await http.get(
      Uri.parse(
        '${ApiConstants._host}/v1/api/family-members/patients/$patientId',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Access denied to patient data');
    } else {
      throw Exception('Failed to fetch patient data');
    }
  }

  // Check if family member has access to patient
  static Future<bool> hasAccessToPatient(int patientId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await http.get(
      Uri.parse(
        '${ApiConstants._host}/v1/api/family-members/patients/$patientId/access',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return false;
  }

  // Get patient dashboard (read-only)
  static Future<Map<String, dynamic>> getPatientDashboard(
    int patientId, {
    int days = 30,
  }) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await http.get(
      Uri.parse(
        '${ApiConstants._host}/v1/api/family-members/patients/$patientId/dashboard?days=$days',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Access denied to patient data');
    } else {
      throw Exception('Failed to fetch patient dashboard');
    }
  }

  // Get patient vitals (read-only)
  static Future<http.Response> getPatientVitals(
    int patientId, {
    int days = 7,
  }) async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();
      return await _httpClient
          .get(
            Uri.parse(
              '${ApiConstants.baseUrl}analytics/vitals?patientId=${patientId}&days=$days',
            ),
            headers: headers,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
          );
    } catch (e) {
      // Convert any errors to an error response
      return http.Response(jsonEncode({'error': e.toString()}), 500);
    }
  }

  static Future<Map<String, dynamic>> getPatientStatus(int patientId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final response = await http
        .get(
          Uri.parse(
            '${ApiConstants._host}/v1/api/family-members/patients/$patientId/status',
          ),
          headers: headers,
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => http.Response('{"error": "Request timeout"}', 408),
        );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 403) {
      throw Exception('Access denied to patient status');
    } else if (response.statusCode == 408) {
      throw Exception('Request timed out');
    } else {
      throw Exception('Failed to fetch patient status: ${response.statusCode}');
    }
  }

  // Add method to check if response indicates access denied
  static bool isAccessDenied(http.Response response) {
    return response.statusCode == 403;
  }

  // Add method to handle common error responses
  static String handleErrorResponse(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      return errorData['message'] ??
          errorData['error'] ??
          'Unknown error occurred';
    } catch (e) {
      return 'Failed with status code: ${response.statusCode}';
    }
  }

  static Future<http.Response> getFamilyMembers(int patientId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await http.get(
      Uri.parse(
        '${ApiConstants._host}/v1/api/patients/$patientId/family-members',
      ),
      headers: headers,
    );
  }

  static Future<http.Response> addFamilyMember(
    int patientId,
    Map<String, dynamic> familyMemberData,
  ) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    return await http.post(
      Uri.parse(
        '${ApiConstants._host}/v1/api/patients/$patientId/family-members',
      ),
      headers: headers,
      body: jsonEncode(familyMemberData),
    );
  }

  static Future<http.Response> submitMoodAndPainLog({
    required int moodValue,
    required int painValue,
    required String note,
    required DateTime timestamp,
  }) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse(
      '${ApiConstants._host}/v1/api/patients/mood-pain-log',
    );

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'moodValue': moodValue,
        'painValue': painValue,
        'note': note,
        'timestamp': timestamp.toIso8601String(),
      }),
    );
  }

  static Future<http.Response> registerPatientForCaregiver({
    required int caregiverId,
    required Map<String, dynamic> patientData,
  }) async {
    final headers = await AuthTokenManager.getAuthHeaders();

    print('🔍 registerPatientForCaregiver caregiverId: $caregiverId');
    print('🔍 patientData with structured address: ${jsonEncode(patientData)}');

    return await _httpClient
        .post(
          Uri.parse('${ApiConstants.baseUrl}caregivers/$caregiverId/patients'),
          headers: headers,
          body: jsonEncode(patientData),
        )
        .timeout(const Duration(seconds: 30));
  }

  // ========================
  // MESSAGING METHODS
  // ========================

  static Future<http.Response> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
  }) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final body = jsonEncode({
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });

    return await _httpClient
        .post(
          Uri.parse('${ApiConstants.baseUrl}messages/send'),
          headers: headers,
          body: body,
        )
        .timeout(const Duration(seconds: 15));
  }

  static Future<List<dynamic>> getConversation({
    required int user1,
    required int user2,
  }) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}messages/conversation?user1=$user1&user2=$user2',
    );

    final response = await _httpClient.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load conversation');
    }
  }

  static Future<List<dynamic>> getInbox(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final url = Uri.parse('${ApiConstants.baseUrl}messages/inbox/$userId');

    final response = await _httpClient.get(url, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load inbox');
    }
  }

  /// Get user profile picture URL based on role
  static Future<String?> getUserProfilePictureUrl(
    int userId, [
    String? role,
  ]) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    // Use the users endpoint to get files consistently
    final endpoint = 'users';

    try {
      final response = await _httpClient
          .get(
            Uri.parse(
              '${ApiConstants.files}/$endpoint/$userId?category=profilePicture',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          return data.first['fileUrl'];
        } else if (data is Map && data.containsKey('fileUrl')) {
          return data['fileUrl'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting profile picture URL: $e');
      return null;
    }
  }
}
