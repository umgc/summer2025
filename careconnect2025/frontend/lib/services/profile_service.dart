import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../services/auth_token_manager.dart';
// import '../config/api_constants.dart'; // Commented out until file exists

/// Enhanced profile service that uses separate patient/caregiver endpoints
/// and combines data with profile image endpoint as requested
class ProfileService {
  /// Get complete patient profile combining patient data and profile image
  static Future<Map<String, dynamic>?> getPatientProfile(int patientId) async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();

      // Get patient data from patient endpoint
      final patientResponse = await http
          .get(
            Uri.parse('${ApiConstants.patients}/$patientId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (patientResponse.statusCode != 200) {
        print('❌ Failed to get patient data: ${patientResponse.statusCode}');
        return null;
      }

      final patientData =
          jsonDecode(patientResponse.body) as Map<String, dynamic>;

      // Get profile image URL from profile endpoint
      String? profileImageUrl;
      try {
        profileImageUrl = await ApiService.getUserProfilePictureUrl(patientId);
      } catch (e) {
        print('⚠️ Failed to get profile image: $e');
        // Continue without profile image
      }

      // Combine the data
      return {
        ...patientData,
        'profileImageUrl': profileImageUrl,
        'profilePictureUrl': profileImageUrl, // For backward compatibility
      };
    } catch (e) {
      print('❌ Error getting patient profile: $e');
      return null;
    }
  }

  /// Get complete caregiver profile combining caregiver data and profile image
  static Future<Map<String, dynamic>?> getCaregiverProfile(
    int caregiverId,
  ) async {
    try {
      final headers = await AuthTokenManager.getAuthHeaders();

      // Get caregiver data from caregiver endpoint
      final caregiverResponse = await http
          .get(
            Uri.parse('${ApiConstants.caregivers}/$caregiverId'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      if (caregiverResponse.statusCode != 200) {
        print(
          '❌ Failed to get caregiver data: ${caregiverResponse.statusCode}',
        );
        return null;
      }

      final caregiverData =
          jsonDecode(caregiverResponse.body) as Map<String, dynamic>;

      // Get profile image URL from profile endpoint
      String? profileImageUrl;
      try {
        profileImageUrl = await ApiService.getUserProfilePictureUrl(
          caregiverId,
        );
      } catch (e) {
        print('⚠️ Failed to get profile image: $e');
        // Continue without profile image
      }

      // Combine the data
      return {
        ...caregiverData,
        'profileImageUrl': profileImageUrl,
        'profilePictureUrl': profileImageUrl, // For backward compatibility
      };
    } catch (e) {
      print('❌ Error getting caregiver profile: $e');
      return null;
    }
  }

  /// Get profile for the current user based on their role
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userSession = await AuthTokenManager.getUserSession();
      if (userSession == null) {
        print('❌ No user session found');
        return null;
      }

      final userRole = userSession['role'] as String?;

      if (userRole?.toUpperCase() == 'PATIENT') {
        final patientId = userSession['patientId'] as int?;
        if (patientId != null) {
          return await getPatientProfile(patientId);
        }
      } else if (userRole?.toUpperCase() == 'CAREGIVER' ||
          userRole?.toUpperCase() == 'FAMILY_LINK' ||
          userRole?.toUpperCase() == 'ADMIN') {
        final caregiverId = userSession['caregiverId'] as int?;
        if (caregiverId != null) {
          return await getCaregiverProfile(caregiverId);
        }
      }

      print('❌ Invalid user role or missing ID: $userRole');
      return null;
    } catch (e) {
      print('❌ Error getting current user profile: $e');
      return null;
    }
  }

  /// Get profile by user ID and role (for mixed scenarios)
  static Future<Map<String, dynamic>?> getProfileByUserIdAndRole(
    int userId,
    String role,
  ) async {
    try {
      if (role.toUpperCase() == 'PATIENT') {
        return await getPatientProfile(userId);
      } else if (role.toUpperCase() == 'CAREGIVER' ||
          role.toUpperCase() == 'FAMILY_LINK' ||
          role.toUpperCase() == 'ADMIN') {
        return await getCaregiverProfile(userId);
      }

      print('❌ Unsupported role: $role');
      return null;
    } catch (e) {
      print('❌ Error getting profile by user ID and role: $e');
      return null;
    }
  }
}
