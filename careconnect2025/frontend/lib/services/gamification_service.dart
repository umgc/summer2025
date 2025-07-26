import 'dart:convert';
// import 'dart:io';
import '../config/env_constant.dart';

import '../services/session_manager.dart';

class ApiConstants {
  static final String _host = getBackendBaseUrl();
  static final String gamification = '$_host/api/gamification';
}

class GamificationService {
  static final session = SessionManager();

  static Future<Map<String, dynamic>> fetchXPProgress(int userId) async {
    await session.restoreSession(); // Ensure cookie is restored

    final response = await session.get(
      '${ApiConstants.gamification}/progress/$userId',
    );

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      print("Status: ${response.statusCode}, Body: '${response.body}'");
      throw Exception("Failed to load XP Progress");
    }
  }

  static Future<List<dynamic>> fetchAchievements(int userId) async {
    final res = await session.get(
      '${ApiConstants.gamification}/achievements/$userId',
    );
    if (res.statusCode == 200) return jsonDecode(res.body);

    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? 'Failed to load achievements');
  }

  static Future<List<dynamic>> fetchAllAchievements(int userId) async {
    final res = await session.get(
      '${ApiConstants.gamification}/all-achievements',
    );
    if (res.statusCode == 200) return jsonDecode(res.body);

    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? 'Failed to load all achievements');
  }

  static Future<void> addXP(int userId, int amount) async {
    final headers = await AuthTokenManager.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final response = await http.post(
      Uri.parse('${ApiConstants.gamification}/award-xp'),
      headers: headers,
      body: jsonEncode({
        'userId': userId,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to award XP: ${response.body}');
    }
  }
}
