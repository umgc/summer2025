import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';
import 'dart:io';

class GamificationService {
  static final baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3000/api/gamification'
      : 'http://localhost:3000/api/gamification';
  static final session = SessionManager();

  static Future<Map<String, dynamic>> fetchXPProgress(int userId) async {
    final res = await session.get('$baseUrl/xp/progress/$userId');
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load XP progress');
  }

  static Future<List<dynamic>> fetchAchievements(int userId) async {
    final res = await session.get('$baseUrl/achievements/$userId');
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load achievements');
  }

  static Future<List<dynamic>> fetchAllAchievements(int userId) async {
    final res = await session.get('$baseUrl/achievements/all/$userId');
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load all achievements');
  }

}
