import 'package:focused_ai_ui/models/course.dart';
import 'package:focused_ai_ui/services/auth_service.dart';

import '../apis/moodle_api.dart';
import '../models/lms.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class MoodleService {
  final MoodleApi _api = MoodleApi();

  /* For API calls (other than login), use the following exception catch to reroute user to login screen
   *
   *  try {
        // API call
      } on SessionExpiredException {
        rethrow;
      } on Exception catch (e) {
        // Handle other errors
      }
   *  
   */

  Future<Map<String, dynamic>> login(String moodleUrl, String username, String password) async {
    print('MoodleService: Sending Moodle login request to backend...');
    try {
      final Map<String, dynamic>? backendResponse = await _api.moodleLogin(
        moodleUrl,
        username,
        password,
      );
      // backend returns id, role, token because we already know username and lms
      if (backendResponse != null && backendResponse.containsKey('token')) {
        final UserRole role = UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == backendResponse['role'],
          orElse: () => UserRole.unknown,
        );

        final User user = User(
          id: backendResponse['id'] as String,
          username: username,
          role: role,
          lmsType: LMS.moodle,
        );

        return {'user': user, 'token': backendResponse['token']};
      } else {
        throw Exception('Moodle login failed: Invalid response from backend');
      }
    } catch (e) {
      print('MoodleService: Error during Moodle login via backend: $e');
      rethrow; // Re-throw the exception for AuthService to catch
    }
  }

  Future<List<Course>> getCourses() async {
    try {
      // final response = await _api.listCourses();

      final response = await _api.protectedRequest('GET', '/moodle/courses') as List<dynamic>;

      return response.map((courseJson) {
        try {
          // Ensure courseJson is a Map<String, dynamic>
          final Map<String, dynamic> courseMap = courseJson as Map<String, dynamic>;
          return Course.fromJson(courseMap);
        } catch (e) {
          print('Failed to parse course: $courseJson');
          print('Parse error: $e');
          throw Exception('Invalid course data format: $e');
        }
      }).toList();
    } on SessionExpiredException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to get courses: ${e.toString()}');
    }
  }
}
