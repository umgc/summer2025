import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/providers/user_provider.dart';

void main() {
  group('JWT Authentication Tests', () {
    test('JWT token should be extractable from Set-Cookie header', () {
      // Arrange
      const setCookieHeader =
          'AUTH=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c; HttpOnly; Path=/; SameSite=Strict';

      // Act
      final authCookieMatch = RegExp(
        r'AUTH=([^;]+)',
      ).firstMatch(setCookieHeader);

      // Assert
      expect(authCookieMatch, isNotNull);
      expect(authCookieMatch!.group(1), isNotNull);
      expect(authCookieMatch.group(1)!.length, greaterThan(20));
    });

    test('UserSession should be created from JSON correctly', () {
      // Arrange
      final jsonData = {
        'id': 1,
        'email': 'test@example.com',
        'role': 'PATIENT',
        'token': 'mock_token',
        'patientId': 1,
      };

      // Act
      final userSession = UserSession.fromJson(jsonData);

      // Assert
      expect(userSession.id, 1);
      expect(userSession.email, 'test@example.com');
      expect(userSession.role, 'PATIENT');
      expect(userSession.token, 'mock_token');
      expect(userSession.patientId, 1);
    });

    test('UserSession should serialize to JSON correctly', () {
      // Arrange
      final userSession = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'PATIENT',
        token: 'mock_token',
        patientId: 1,
      );

      // Act
      final json = userSession.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['email'], 'test@example.com');
      expect(json['role'], 'PATIENT');
      expect(json['token'], 'mock_token');
      expect(json['patientId'], 1);
    });

    test('UserProvider should track user state correctly', () {
      // Arrange
      final userProvider = UserProvider();
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'PATIENT',
        token: 'mock_token',
        patientId: 1,
      );

      // Act
      userProvider.setUser(mockUser);

      // Assert
      expect(userProvider.user, isNotNull);
      expect(userProvider.isLoggedIn, true);
      expect(userProvider.isPatient, true);
      expect(userProvider.isCaregiver, false);
    });

    test('UserProvider should correctly identify caregiver role', () {
      // Arrange
      final userProvider = UserProvider();
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'CAREGIVER',
        token: 'mock_token',
        caregiverId: 1,
      );

      // Act
      userProvider.setUser(mockUser);

      // Assert
      expect(userProvider.user, isNotNull);
      expect(userProvider.isLoggedIn, true);
      expect(userProvider.isPatient, false);
      expect(userProvider.isCaregiver, true);
    });

    test('UserProvider should handle case insensitive roles', () {
      // Arrange
      final userProvider = UserProvider();
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'patient', // lowercase
        token: 'mock_token',
        patientId: 1,
      );

      // Act
      userProvider.setUser(mockUser);

      // Assert
      expect(userProvider.isPatient, true);
      expect(userProvider.isCaregiver, false);
    });

    test('UserProvider should handle null user state', () {
      // Arrange
      final userProvider = UserProvider();

      // Act & Assert
      expect(userProvider.user, isNull);
      expect(userProvider.isLoggedIn, false);
      expect(userProvider.isPatient, false);
      expect(userProvider.isCaregiver, false);
    });
  });
}
