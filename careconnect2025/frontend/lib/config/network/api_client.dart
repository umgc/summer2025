import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  final String _base = dotenv.env['API_URL'] ?? 'https://api.careconnect.dev';
  Future<Map<String, dynamic>> get(String path) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return {'endpoint': '$_base$path', 'data': 'dummy'}; // stub
  }

  Future<Map<String, dynamic>> post(String path, Map body) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return {'endpoint': '$_base$path', 'posted': body, 'data': 'dummy'};
  }
}
