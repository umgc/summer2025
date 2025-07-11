import 'package:focused_ai_ui/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../apis/google_classroom_api.dart';
import '../models/lms.dart';
import '../models/user.dart';
import '../models/user_role.dart';

class GoogleClassroomService {
  final GoogleClassroomApi _api = GoogleClassroomApi();

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

  /// Handles the Google login process by sending the ID Token to the backend.
  Future<Map<String, dynamic>?> login(
    String serverAuthCode,
    GoogleSignInAccount googleUser,
  ) async {
    print(
      'GoogleClassroomService: Sending serverAuthCode $serverAuthCode to backend to login user with ID: ${googleUser.id} ...',
    );
    try {
      // Send Google ID Token to server for verification and JWT
      // backend returns id, role, token because we already know email and lms
      final Map<String, dynamic>? backendResponse = await _api.googleLogin(
        serverAuthCode,
        googleUser.id,
        googleUser.email,
      );

      if (backendResponse != null && backendResponse.containsKey('token')) {
        final String appJwtToken =
            backendResponse['token'] as String; // The JWT from your backend

        // Extract and convert role string to UserRole enum
        final String roleString = backendResponse['role'] as String;
        final UserRole role = UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleString.toLowerCase(),
          orElse: () => UserRole.unknown,
        );

        // Construct the User object.
        final User user = User(
          id: backendResponse['id'] as String,
          email: googleUser.email,
          role: role,
          lmsType: LMS.googleClassroom,
        );

        // Return a Map containing both the User object and the JWT token.
        return {'user': user, 'token': appJwtToken};
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

  Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _api.protectedRequest('GET', '/google/courses');
      return (response as List).cast<Map<String, dynamic>>();
    } on SessionExpiredException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to get courses: $e');
    }
  }
}
