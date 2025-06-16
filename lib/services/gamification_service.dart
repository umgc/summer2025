import 'dart:convert';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

class GamificationService {
  static const baseUrl = 'http://10.0.2.2:3000/api/gamification';
  static final session = SessionManager(); // ✅ Reuse your session-aware client

  static Future<Map<String, dynamic>> fetchXPProgress(int userId) async {
    final res = await session.get('$baseUrl/xp/progress/$userId'); // ✅ Use session.get
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load XP progress');
  }

  static Future<List<dynamic>> fetchAchievements(int userId) async {
    final res = await session.get('$baseUrl/achievements/$userId'); // ✅ Use session.get
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load achievements');
  }
}
