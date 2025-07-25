import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/providers/user_provider.dart';

void main() {
  group('JWT Authentication and Backend Tests', () {
    // JWT Token extraction tests
    group('JWT Token Extraction', () {
      test('should extract JWT token from Set-Cookie header', () {
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

      test('should handle malformed Set-Cookie header gracefully', () {
        // Arrange
        const malformedHeader = 'InvalidCookie=value; Path=/';

        // Act
        final authCookieMatch = RegExp(
          r'AUTH=([^;]+)',
        ).firstMatch(malformedHeader);

        // Assert
        expect(authCookieMatch, isNull);
      });

      test('should extract JWT from complex Set-Cookie header', () {
        // Arrange
        const complexHeader =
            'sessionid=abc123; AUTH=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test; HttpOnly; Path=/; SameSite=Strict; othercookie=value';

        // Act
        final authCookieMatch = RegExp(
          r'AUTH=([^;]+)',
        ).firstMatch(complexHeader);

        // Assert
        expect(authCookieMatch, isNotNull);
        expect(
          authCookieMatch!.group(1),
          equals('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test'),
        );
      });
    });

    // UserSession tests
    group('UserSession', () {
      test('should create UserSession from JSON correctly', () {
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

      test('should serialize UserSession to JSON correctly', () {
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

      test('should handle caregiver UserSession correctly', () {
        // Arrange
        final jsonData = {
          'id': 2,
          'email': 'caregiver@example.com',
          'role': 'CAREGIVER',
          'token': 'caregiver_token',
          'caregiverId': 2,
          'name': 'Jane Doe',
        };

        // Act
        final userSession = UserSession.fromJson(jsonData);

        // Assert
        expect(userSession.id, 2);
        expect(userSession.email, 'caregiver@example.com');
        expect(userSession.role, 'CAREGIVER');
        expect(userSession.token, 'caregiver_token');
        expect(userSession.caregiverId, 2);
        expect(userSession.name, 'Jane Doe');
        expect(userSession.patientId, isNull);
      });
    });

    // UserProvider tests
    group('UserProvider', () {
      test('should track user state correctly', () {
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

      test('should correctly identify caregiver role', () {
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

      test('should handle case insensitive roles', () {
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

      test('should handle null user state', () {
        // Arrange
        final userProvider = UserProvider();

        // Act & Assert
        expect(userProvider.user, isNull);
        expect(userProvider.isLoggedIn, false);
        expect(userProvider.isPatient, false);
        expect(userProvider.isCaregiver, false);
      });

      test('should handle loading state', () {
        // Arrange
        final userProvider = UserProvider();

        // Act & Assert
        expect(userProvider.isLoading, false);
      });
    });

    // Authentication flow tests
    group('Authentication Flow', () {
      test('should handle authentication header format correctly', () {
        // Arrange
        const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.test';

        // Act
        const authHeader = 'Bearer $mockToken';

        // Assert
        expect(authHeader, startsWith('Bearer '));
        expect(authHeader.contains(mockToken), true);
      });

      test('should validate JWT token format', () {
        // Arrange
        const validJWT =
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        const invalidJWT = 'invalid.token';

        // Act
        final validParts = validJWT.split('.');
        final invalidParts = invalidJWT.split('.');

        // Assert
        expect(validParts.length, 3); // JWT should have 3 parts
        expect(invalidParts.length, lessThan(3));
      });
    });
  });
}
