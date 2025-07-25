import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/services/role_validator.dart';
import 'package:care_connect_app/services/enhanced_auth_service.dart';
import 'package:care_connect_app/providers/user_provider.dart';

void main() {
  group('Role Validation Tests', () {
    test('Caregiver login should accept CAREGIVER role', () {
      final userSession = UserSession(
        id: 1,
        email: 'caregiver@test.com',
        role: 'CAREGIVER',
        token: 'test-token',
        name: 'Test Caregiver',
      );

      final result = RoleValidator.validateUserRole(
        expectedRole: 'caregiver',
        userSession: userSession,
      );

      expect(result.isValid, true);
    });

    test('Caregiver login should accept FAMILY_LINK role', () {
      final userSession = UserSession(
        id: 1,
        email: 'familylink@test.com',
        role: 'FAMILY_LINK',
        token: 'test-token',
        name: 'Test Family Link',
      );

      final result = RoleValidator.validateUserRole(
        expectedRole: 'caregiver',
        userSession: userSession,
      );

      expect(result.isValid, true);
    });

    test('Caregiver login should reject PATIENT role', () {
      final userSession = UserSession(
        id: 1,
        email: 'patient@test.com',
        role: 'PATIENT',
        token: 'test-token',
        name: 'Test Patient',
      );

      final result = RoleValidator.validateUserRole(
        expectedRole: 'caregiver',
        userSession: userSession,
      );

      expect(result.isValid, false);
      expect(result.errorMessage, contains('Patient Login'));
    });

    test('Patient login should accept PATIENT role', () {
      final userSession = UserSession(
        id: 1,
        email: 'patient@test.com',
        role: 'PATIENT',
        token: 'test-token',
        name: 'Test Patient',
      );

      final result = RoleValidator.validateUserRole(
        expectedRole: 'patient',
        userSession: userSession,
      );

      expect(result.isValid, true);
    });

    test('Patient login should accept FAMILY_MEMBER role', () {
      final userSession = UserSession(
        id: 1,
        email: 'family@test.com',
        role: 'FAMILY_MEMBER',
        token: 'test-token',
        name: 'Test Family Member',
      );

      final result = RoleValidator.validateUserRole(
        expectedRole: 'patient',
        userSession: userSession,
      );

      expect(result.isValid, true);
    });

    test('Patient login should reject CAREGIVER role', () {
      final userSession = UserSession(
        id: 1,
        email: 'caregiver@test.com',
        role: 'CAREGIVER',
        token: 'test-token',
        name: 'Test Caregiver',
      );

      final result = RoleValidator.validateUserRole(
        expectedRole: 'patient',
        userSession: userSession,
      );

      expect(result.isValid, false);
      expect(result.errorMessage, contains('Caregiver Login'));
    });

    test('Should return correct login route for different roles', () {
      expect(
        RoleValidator.getCorrectLoginRoute('CAREGIVER'),
        '/login/caregiver',
      );
      expect(
        RoleValidator.getCorrectLoginRoute('FAMILY_LINK'),
        '/login/caregiver',
      );
      expect(RoleValidator.getCorrectLoginRoute('ADMIN'), '/login/caregiver');
      expect(RoleValidator.getCorrectLoginRoute('PATIENT'), '/login/patient');
      expect(
        RoleValidator.getCorrectLoginRoute('FAMILY_MEMBER'),
        '/login/patient',
      );
    });

    test('Should return proper display names for roles', () {
      expect(RoleValidator.getRoleDisplayName('CAREGIVER'), 'Caregiver');
      expect(
        RoleValidator.getRoleDisplayName('FAMILY_LINK'),
        'Family Link Caregiver',
      );
      expect(RoleValidator.getRoleDisplayName('ADMIN'), 'Administrator');
      expect(RoleValidator.getRoleDisplayName('PATIENT'), 'Patient');
      expect(
        RoleValidator.getRoleDisplayName('FAMILY_MEMBER'),
        'Family Member',
      );
    });
  });

  group('Enhanced Auth Service Tests', () {
    test('AuthResult should create success result correctly', () {
      final userSession = UserSession(
        id: 1,
        email: 'test@test.com',
        role: 'PATIENT',
        token: 'test-token',
        name: 'Test User',
      );

      final result = AuthResult.success(userSession: userSession);

      expect(result.isSuccess, true);
      expect(result.userSession, userSession);
      expect(result.errorMessage, null);
    });

    test('AuthResult should create role validation failure correctly', () {
      final result = AuthResult.roleValidationFailure(
        message: 'Test error message',
        actualRole: 'PATIENT',
        expectedRole: 'CAREGIVER',
        correctLoginRoute: '/login/patient',
      );

      expect(result.isSuccess, false);
      expect(result.errorType, AuthErrorType.roleValidation);
      expect(result.actualRole, 'PATIENT');
      expect(result.expectedRole, 'CAREGIVER');
      expect(result.correctLoginRoute, '/login/patient');
    });

    test('AuthResult should create authentication failure correctly', () {
      final result = AuthResult.authenticationFailure(message: 'Login failed');

      expect(result.isSuccess, false);
      expect(result.errorType, AuthErrorType.authentication);
      expect(result.errorMessage, 'Login failed');
    });
  });
}
