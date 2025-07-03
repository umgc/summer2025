// This file contains integration tests for the AuthService.
//
// These tests make network calls.
// They are designed to verify the end-to-end functionality of:
// - User sign-in with valid credentials (expecting a JWT).
// - User sign-in with invalid credentials (expecting an Exception).
// - User registration (expecting successful sign-up).
// - User confirmation (expecting successful confirmation).
//
// IMPORTANT: For these tests to pass reliably, you must ensure:
// - The Cognito client ID and region in AuthService are correct.
// - The 'signInUser' test uses valid, existing, and confirmed credentials.
// - The 'signUpUser' test uses a unique email for each run, or your backend
//   handles re-registration/cleanup appropriately.
// - The 'confirmUser' test uses an unconfirmed user and a valid confirmation code,
//   which can be challenging to automate without specific backend test support.

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:deeptrainfront/auth/auth_service.dart';

void main() {
  // These are now effectively Integration Tests, as AuthService makes real network calls.
  group('AuthService Integration Tests (Real Network Calls)', () {
    late AuthService authService;

    setUp(() {
      // Instantiate AuthService without passing a client.
      //  AuthService will use its own internal http.Client and Dio instance,
      authService = AuthService();
    });

    // Test case for successful sign-in
    // This test will now hit your actual backend.
    test(
      'signInUser returns JWT on successful authentication (real call)',
      () async {
        // Call the method under test with real credentials.
        final jwt = await authService.signInUser(
          email: 'nicolefpope@gmail.com',
          password: 'Ajax1991!',
        );

        // Assert the expected outcome
        // Expect a non-null string, as the actual JWT content will vary.
        expect(jwt, isNotNull);
        expect(jwt, isA<String>());
        print('Real JWT received: $jwt'); // Print JWT for debugging
      },
    );

    // Test case for failed authentication (e.g., wrong credentials)
    // This test will now hit your actual backend.
    test(
      'signInUser throws Exception on authentication failure (real call)',
      () async {
        // Verify that calling signInUser throws an Exception for invalid credentials.
        expect(
          () => authService.signInUser(
            email: 'wrong@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<Exception>()),
        );
      },
    );

    test('signUpUser handles successful registration (real call)', () async {
      final uniqueEmail =
          'test_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
      expectLater(
        () => authService.signUpUser(
          email: uniqueEmail,
          password: 'NewPassword1!',
          firstName: 'Test',
          lastName: 'User',
        ),
        returnsNormally, // Expect no exception to be thrown
      );
    });

    test('confirmUser handles successful confirmation (real call)', () async {
      expectLater(
        () => authService.confirmUser(
          'nicolefpope@gmail.com', // Pass email as first positional argument
          '123456!', // Pass code as second positional argument
        ),
        returnsNormally,
      );
    });
  });
}
