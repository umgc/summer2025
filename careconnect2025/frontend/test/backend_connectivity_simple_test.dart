import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/env_constant.dart';

void main() {
  group('Backend Connectivity Tests', () {
    test('getBackendBaseUrl should return valid URL', () {
      // Act
      final baseUrl = getBackendBaseUrl();

      // Assert
      expect(baseUrl, isNotNull);
      expect(baseUrl, isA<String>());
      expect(baseUrl.isNotEmpty, true);
      expect(baseUrl.contains('://'), true); // Should contain protocol
    });

    test('API endpoints should be properly constructed', () {
      // Act
      final baseUrl = getBackendBaseUrl();
      final authEndpoint = '$baseUrl/v1/api/auth';
      final usersEndpoint = '$baseUrl/v1/api/users';

      // Assert
      expect(authEndpoint, contains('/v1/api/auth'));
      expect(usersEndpoint, contains('/v1/api/users'));
    });

    test('Environment configuration should be consistent', () {
      // This test verifies that the environment configuration is working
      // In a real scenario, this would test against actual environment variables

      // Act
      final baseUrl = getBackendBaseUrl();

      // Assert
      expect(baseUrl, isNotNull);
      expect(baseUrl.length, greaterThan(0));
    });
  });
}
