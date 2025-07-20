import 'package:focused_ai_ui/models/course.dart';
import 'package:focused_ai_ui/services/auth_service.dart';

import '../apis/moodle_api.dart';
import '../models/lms.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class MoodleService {
  final MoodleApi _api = MoodleApi();

  Future<Map<String, dynamic>> login(String moodleUrl, String username, String password) async {
    print('MoodleService: Sending Moodle login request to backend...');
    try {
      final Map<String, dynamic>? backendResponse = await _api.moodleLogin(
        moodleUrl,
        username,
        password,
      );
      
      if (backendResponse != null && backendResponse.containsKey('jwt')) {
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

        return {'user': user, 'jwt': backendResponse['jwt']};
      } else {
        throw Exception('Moodle login failed: Invalid response from backend');
      }
    } catch (e) {
      print('MoodleService: Error during Moodle login via backend: $e');
      rethrow;
    }
  }

  Future<List<Course>> getCourses() async {
    try {
      final response = await _api.protectedRequest('GET', '/moodle/courses');
      
      print('Raw response: $response');
      print('Response type: ${response.runtimeType}');
      
      if (response is Map<String, dynamic> && response.containsKey('courses')) {
        final coursesList = response['courses'] as List<dynamic>;
        return coursesList.map((courseJson) {
          try {
            final Map<String, dynamic> courseMap = courseJson as Map<String, dynamic>;
            print('Parsing course: $courseMap');
            return Course.fromJson(courseMap);
          } catch (e) {
            print('Failed to parse course: $courseJson');
            print('Parse error: $e');
            throw Exception('Invalid course data format: $e');
          }
        }).toList();
      } else {
        throw Exception('Unexpected response format: expected CourseList wrapper');
      }
    } on SessionExpiredException {
      rethrow;
    } catch (e) {
      print('Full error details: $e');
      throw Exception('Failed to get courses: ${e.toString()}');
    }
  }
}