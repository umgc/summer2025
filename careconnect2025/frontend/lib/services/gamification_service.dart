import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env_constant.dart';
import '../services/auth_token_manager.dart';

class ApiConstants {
  static final String _host = getBackendBaseUrl();
  static final String gamification = '$_host/api/gamification';
}

class GamificationService {
  static Future<Map<String, dynamic>> fetchXPProgress(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.gamification}/progress/$userId'),
      headers: headers,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Not authorized. Please log in again.");
    } else {
      print("Status: ${response.statusCode}, Body: '${response.body}'");
      throw Exception("Failed to load XP Progress");
    }
  }

  static Future<List<dynamic>> fetchAchievements(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final res = await http.get(
      Uri.parse('${ApiConstants.gamification}/achievements/$userId'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    if (res.statusCode == 401) {
      throw Exception("Not authorized. Please log in again.");
    }
    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? 'Failed to load achievements');
  }

  static Future<List<dynamic>> fetchAllAchievements(int userId) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    final res = await http.get(
      Uri.parse('${ApiConstants.gamification}/all-achievements'),
      headers: headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);

    if (res.statusCode == 401) {
      throw Exception("Not authorized. Please log in again.");
    }

    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? 'Failed to load all achievements');
  }
}
