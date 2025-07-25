import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/providers/user_provider.dart';

void main() {
  group('JWT Token Handling Tests', () {
    test('UserSession should extract token from login response', () {
      // Simulate the login response you provided
      final loginResponse = {
        "id": 2,
        "email": "jane.doe23@example.com",
        "role": "PATIENT",
        "token":
            "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjYXJlY29ubmVjdCIsInN1YiI6ImphbmUuZG9lMjNAZXhhbXBsZS5jb20iLCJyb2xlIjoiUEFUSUVOVCIsImlhdCI6MTc1MTY4NjU4OCwiZXhwIjoxNzUxNjg3NDg4fQ.gExhTny88bbfLCaeAqO-jK1XTs-Cw6h4rZXhZbKY-ag",
        "patientId": 1,
        "caregiverId": null,
        "name": "Jane Doe",
        "status": "ACTIVE",
      };

      // Act
      final userSession = UserSession.fromJson(loginResponse);

      // Assert
      expect(userSession.id, 2);
      expect(userSession.email, 'jane.doe23@example.com');
      expect(userSession.role, 'PATIENT');
      expect(userSession.token, startsWith('eyJhbGciOiJIUzI1NiJ9'));
      expect(userSession.patientId, 1);
      expect(userSession.caregiverId, null);
      expect(userSession.name, 'Jane Doe');
    });

    test('JWT token should be valid format', () {
      const token =
          "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjYXJlY29ubmVjdCIsInN1YiI6ImphbmUuZG9lMjNAZXhhbXBsZS5jb20iLCJyb2xlIjoiUEFUSUVOVCIsImlhdCI6MTc1MTY4NjU4OCwiZXhwIjoxNzUxNjg3NDg4fQ.gExhTny88bbfLCaeAqO-jK1XTs-Cw6h4rZXhZbKY-ag";

      // JWT should have 3 parts separated by dots
      final parts = token.split('.');
      expect(parts.length, 3);
      expect(parts[0], isNotEmpty); // Header
      expect(parts[1], isNotEmpty); // Payload
      expect(parts[2], isNotEmpty); // Signature
    });

    test('Authorization header should be formatted correctly', () {
      const token =
          "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjYXJlY29ubmVjdCIsInN1YiI6ImphbmUuZG9lMjNAZXhhbXBsZS5jb20iLCJyb2xlIjoiUEFUSUVOVCIsImlhdCI6MTc1MTY4NjU4OCwiZXhwIjoxNzUxNjg3NDg4fQ.gExhTny88bbfLCaeAqO-jK1XTs-Cw6h4rZXhZbKY-ag";

      const authHeader = 'Bearer $token';

      expect(authHeader, startsWith('Bearer '));
      expect(authHeader.substring(7), equals(token));
    });
  });
}
