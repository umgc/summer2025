import 'package:focused_ai_ui/models/course.dart';
import 'package:focused_ai_ui/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../apis/google_classroom_api.dart';
import '../models/lms.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class GoogleClassroomService {
  final GoogleClassroomApi _api = GoogleClassroomApi();

  Future<Map<String, dynamic>?> login(
    String serverAuthCode,
    GoogleSignInAccount googleUser,
  ) async {
    print(
      'GoogleClassroomService: Sending serverAuthCode $serverAuthCode to backend to login user with ID: ${googleUser.id} ...',
    );
    try {
      final Map<String, dynamic>? backendResponse = await _api.googleLogin(
        serverAuthCode,
        googleUser.id,
        googleUser.email,
      );

      if (backendResponse != null && backendResponse.containsKey('jwt')) {
        final String appJwtToken = backendResponse['jwt'] as String;

        final String roleString = backendResponse['role'] as String;
        final UserRole role = UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleString.toLowerCase(),
          orElse: () => UserRole.unknown,
        );

        final User user = User(
          id: backendResponse['id'] as String,
          email: googleUser.email,
          role: role,
          lmsType: LMS.googleClassroom,
        );

        return {'user': user, 'jwt': appJwtToken};
      } else {
        throw Exception(
          'Google login failed: Invalid response format from backend.',
        );
      }
    } catch (e) {
      print(
        'GoogleClassroomService: Error during Google login via backend: $e',
      );
      rethrow;
    }
  }

  Future<List<Course>> getCourses() async {
    try {
      final response = await _api.protectedRequest('GET', '/google/courses');
      
      print('Google courses response: $response');
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
      throw Exception('Failed to get courses: $e');
    }
  }
}