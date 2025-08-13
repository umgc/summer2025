import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env_constant.dart';
import '../models/notification_settings.dart';
import '../services/auth_token_manager.dart';

class NotificationSettingsService {
  /// Get notification settings for a user
  static Future<NotificationSettings?> getNotificationSettings(
    int userId,
  ) async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();
      final url = Uri.parse(
        '${getBackendBaseUrl()}/v1/api/notification-settings/$userId',
      );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return NotificationSettings.fromJson(json);
      } else if (response.statusCode == 404) {
        // Settings don't exist yet, return default settings
        return NotificationSettings(
          userId: userId,
          gamification: true,
          emergency: true,
          videoCall: true,
          audioCall: true,
          sms: true,
          significantVitals: true,
        );
      } else {
        print('Failed to get notification settings: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting notification settings: $e');
      return null;
    }
  }

  /// Create or update notification settings
  static Future<NotificationSettings?> saveNotificationSettings(
    NotificationSettings settings,
  ) async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();
      final url = Uri.parse(
        '${getBackendBaseUrl()}/v1/api/notification-settings',
      );

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(settings.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return NotificationSettings.fromJson(json);
      } else {
        print('Failed to save notification settings: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error saving notification settings: $e');
      return null;
    }
  }
}
