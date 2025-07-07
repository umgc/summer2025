import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? _sessionCookie;

  /// Use this map for authenticated requests
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (_sessionCookie != null) 'cookie': _sessionCookie!,
  };

  /// Restore session cookie from local storage
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString('session_cookie');
    print("🔁 Restored cookie: $_sessionCookie");
  }

  /// Save session cookie after login response
  Future<void> updateCookies(http.Response response) async {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null && rawCookie.contains('SESSION=')) {
      _sessionCookie = rawCookie.split(';').firstWhere((c) => c.startsWith('SESSION='));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_cookie', _sessionCookie!);
      print("💾 Saved cookie: $_sessionCookie");
    } else {
      print("⚠️ No SESSION cookie found in response.");
    }
  }

  /// Standard GET request with session
  Future<http.Response> get(String url) {
    print('📤 GET $url with headers: $headers');
    return http.get(Uri.parse(url), headers: headers);
  }

  /// Standard POST request with session
  Future<http.Response> post(String url, {Object? body}) {
    print('📤 POST $url with headers: $headers');
    return http.post(Uri.parse(url), headers: headers, body: body);
  }

  /// Optional PUT method for updates
  Future<http.Response> put(String url, {Object? body}) {
    print('📤 PUT $url with headers: $headers');
    return http.put(Uri.parse(url), headers: headers, body: body);
  }

  /// Clear the session (logout or expired)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_cookie');
    _sessionCookie = null;
    print("🧹 Cleared session cookie");
  }
}
