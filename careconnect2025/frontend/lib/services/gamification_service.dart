import 'dart:convert';
import 'dart:io';
import 'package:care_connect_app/config/EnvConstant.dart';

import 'session_manager.dart';

class ApiEndpoints {
  static final String _host = getBackendBaseUrl();
  static final String gamification = '$_host/api/gamification';
}

class GamificationService {
  static final session = SessionManager();

  static Future<Map<String, dynamic>> fetchXPProgress(int userId) async {
    await session.restoreSession(); // Ensure cookie is restored

    final response = await session.get('${ApiEndpoints.gamification}/progress/$userId');

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return jsonDecode(response.body);
    } else {
      print("🚫 Status: ${response.statusCode}, Body: '${response.body}'");
      throw Exception("Failed to load XP Progress");
    }
  }

  static Future<List<dynamic>> fetchAchievements(int userId) async {
    final res = await session.get('${ApiEndpoints.gamification}/achievements/$userId');
    if (res.statusCode == 200) return jsonDecode(res.body);

    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? 'Failed to load achievements');
  }

  static Future<List<dynamic>> fetchAllAchievements(int userId) async {
    final res = await session.get('${ApiEndpoints.gamification}/all-achievements');
    if (res.statusCode == 200) return jsonDecode(res.body);

    final error = jsonDecode(res.body);
    throw Exception(error['error'] ?? 'Failed to load all achievements');
  }
}
