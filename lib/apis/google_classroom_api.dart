import 'dart:convert' show json, jsonEncode;
import 'package:focused_ai_ui/constants/server_constants.dart';
import 'package:focused_ai_ui/services/auth_service.dart';
import 'package:http/http.dart' as http;

class GoogleClassroomApi {
  // Template for protected requests. Method is 'GET' or 'POST'. Endpoint will match request mapping in Spring Boot e.g. '/caila'.
  // For GET requests (no body needed)
  // final response = await _api.protectedRequest('GET', '/some/endpoint');

  // For POST requests with body
  // final response = await _api.protectedRequest('POST', '/some/endpoint', body: {'key': 'value'});
  Future<dynamic> protectedRequest(
    String method,
    String endpoint, {
    dynamic body,
  }) async {
    final uri = Uri.parse('${ServerConstants.serverUrl}$endpoint');
    try {
      final request = http.Request(method, uri);

      // Add headers
      request.headers.addAll(authService.authHeaders);

      // Only set body for non-GET requests and when body is not null
      if (body != null && method.toUpperCase() != 'GET') {
        request.body = jsonEncode(body);
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 401) {
        await authService.handleUnauthorized();
        throw SessionExpiredException();
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response body');
      }

      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  // Don't send or validate JWT with auth methods
  Future<Map<String, dynamic>?> googleLogin(
    String serverAuthCode,
    String userId,
    String email,
  ) async {
    print('GoogleApi: Logging in to Google...');

    final Uri uri = Uri.parse(
      '${ServerConstants.serverUrl}${ServerConstants.googleLoginEndpoint}',
    );

    try {
      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'serverAuthCode': serverAuthCode,
          'userId': userId,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        print(
          'BackendApi: Google login failed on backend: ${response.statusCode} - $errorMessage',
        );
        throw Exception(
          'Backend Google login failed: $errorMessage (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print(
        'BackendApi: Network or parsing error during Google backend call: $e',
      );
      rethrow;
    }
  }
}
