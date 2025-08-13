import '../providers/user_provider.dart';

/// Role validation utility for login authentication
class RoleValidator {
  /// Validates if the user's actual role matches the expected role from the login form
  static RoleValidationResult validateUserRole({
    required String expectedRole,
    required UserSession userSession,
  }) {
    final actualRole = userSession.role.toUpperCase();
    final expectedRoleUpper = expectedRole.toUpperCase();

    // Handle role mappings and validations
    switch (expectedRoleUpper) {
      case 'CAREGIVER':
        if (_isCaregiverRole(actualRole)) {
          return RoleValidationResult.success();
        }
        return RoleValidationResult.failure(
          actualRole: actualRole,
          expectedRole: expectedRoleUpper,
          message: _getCaregiverErrorMessage(actualRole),
        );

      case 'PATIENT':
        if (_isPatientRole(actualRole)) {
          return RoleValidationResult.success();
        }
        return RoleValidationResult.failure(
          actualRole: actualRole,
          expectedRole: expectedRoleUpper,
          message: _getPatientErrorMessage(actualRole),
        );

      default:
        // For any other roles, do exact match
        if (actualRole == expectedRoleUpper) {
          return RoleValidationResult.success();
        }
        return RoleValidationResult.failure(
          actualRole: actualRole,
          expectedRole: expectedRoleUpper,
          message:
              'Role mismatch. Please use the correct login page for your account type.',
        );
    }
  }

  /// Check if the role is a caregiver-type role
  static bool _isCaregiverRole(String role) {
    return role == 'CAREGIVER' || role == 'FAMILY_LINK' || role == 'ADMIN';
  }

  /// Check if the role is a patient-type role
  static bool _isPatientRole(String role) {
    return role == 'PATIENT' || role == 'FAMILY_MEMBER';
  }

  /// Get error message for caregiver login with wrong role
  static String _getCaregiverErrorMessage(String actualRole) {
    switch (actualRole) {
      case 'PATIENT':
        return 'This account is registered as a Patient. Please use the Patient Login to access your account.';
      case 'FAMILY_MEMBER':
        return 'This account is registered as a Family Member. Please use the Patient Login to access your account.';
      default:
        return 'This account cannot access the Caregiver portal. Please use the appropriate login page for your account type.';
    }
  }

  /// Get error message for patient login with wrong role
  static String _getPatientErrorMessage(String actualRole) {
    switch (actualRole) {
      case 'CAREGIVER':
        return 'This account is registered as a Caregiver. Please use the Caregiver Login to access your account.';
      case 'FAMILY_LINK':
        return 'This account is registered as a Family Link Caregiver. Please use the Caregiver Login to access your account.';
      case 'ADMIN':
        return 'This account is registered as an Admin. Please use the Caregiver Login to access your account.';
      default:
        return 'This account cannot access the Patient portal. Please use the appropriate login page for your account type.';
    }
  }

  /// Get the correct login route for a given role
  static String getCorrectLoginRoute(String role) {
    final roleUpper = role.toUpperCase();

    if (_isCaregiverRole(roleUpper)) {
      return '/login/caregiver';
    } else if (_isPatientRole(roleUpper)) {
      return '/login/patient';
    }

    // Default to patient login for unknown roles
    return '/login/patient';
  }

  /// Get user-friendly role display name
  static String getRoleDisplayName(String role) {
    switch (role.toUpperCase()) {
      case 'CAREGIVER':
        return 'Caregiver';
      case 'FAMILY_LINK':
        return 'Family Link Caregiver';
      case 'ADMIN':
        return 'Administrator';
      case 'PATIENT':
        return 'Patient';
      case 'FAMILY_MEMBER':
        return 'Family Member';
      default:
        return role;
    }
  }
}

/// Result of role validation
class RoleValidationResult {
  final bool isValid;
  final String? actualRole;
  final String? expectedRole;
  final String? errorMessage;

  RoleValidationResult._({
    required this.isValid,
    this.actualRole,
    this.expectedRole,
    this.errorMessage,
  });

  factory RoleValidationResult.success() {
    return RoleValidationResult._(isValid: true);
  }

  factory RoleValidationResult.failure({
    required String actualRole,
    required String expectedRole,
    required String message,
  }) {
    return RoleValidationResult._(
      isValid: false,
      actualRole: actualRole,
      expectedRole: expectedRole,
      errorMessage: message,
    );
  }
}
