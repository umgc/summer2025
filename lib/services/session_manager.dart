import 'package:http/http.dart' as http;

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  void updateCookies(http.Response response) {
    final rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      final cookies = rawCookie.split(';');
      headers['cookie'] = cookies[0];
    }
  }

  Future<http.Response> post(String url, {Object? body}) {
    return http.post(Uri.parse(url), headers: headers, body: body);
  }

  Future<http.Response> get(String url) {
    return http.get(Uri.parse(url), headers: headers);
  }

  void clear() {
    headers.remove('cookie');
  }
}
