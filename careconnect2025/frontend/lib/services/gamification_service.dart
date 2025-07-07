import 'dart:convert';
import '../frontend/session_manager.dart';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Use localhost for web, otherwise fallback for emulator, etc.
  static final String _host = kIsWeb
      ? 'http://localhost:8080'
      : 'http://10.0.2.2:8080'; // Change if needed for emulator, or set to localhost for physical device

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