// This file contains simplified widget tests for the RegisterScreen.
//
// These tests focus on the following aspects of the RegisterScreen's UI and local behavior:
// - Correct rendering of all form fields, labels, and buttons.
// - Ability to enter text into the First Name, Last Name, Email, and Password fields.
// - Functionality to toggle password visibility.
// - Correct navigation to the '/login' route when the "Sign In" link is tapped.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';
import 'package:deeptrainfront/auth/register_screen.dart';

// Mock NavigatorObserver to capture navigation events
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('RegisterScreen Widget Tests (Simplified)', () {
    late MockNavigatorObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigatorObserver();
    });

    // Helper function to pump the RegisterScreen with necessary GoRouter setup
    Widget createWidgetUnderTest() {
      return MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              // Pass a null authService, as we are not testing its interactions directly
              builder: (context, state) =>
                  const RegisterScreen(authService: null),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const Text('Login Screen Mock'),
            ),
            // The /confirm route is still needed if the screen attempts to go there,
            // even if we don't test the success path in this simplified version.
            GoRoute(
              path: '/confirm',
              builder: (context, state) => const Text('Confirm Screen Mock'),
            ),
          ],
          observers: [
            mockObserver,
          ], // Attach the observer to capture navigation
        ),
      );
    }

    // Helper to find TextField by hintText
    Finder findTextFieldByHint(String hintText) {
      return find.byWidgetPredicate(
        (widget) =>
            widget is TextField && widget.decoration?.hintText == hintText,
      );
    }

    // Test 1: RegisterScreen renders all fields and buttons
    testWidgets('RegisterScreen renders all fields and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Create your DeepTrain account'), findsOneWidget);
      expect(findTextFieldByHint('First Name'), findsOneWidget);
      expect(findTextFieldByHint('Last Name'), findsOneWidget);
      expect(findTextFieldByHint('Email'), findsOneWidget);
      expect(findTextFieldByHint('Password'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.textContaining("Already have an account?"), findsOneWidget);
      expect(find.text("Sign In"), findsOneWidget);
      expect(
        find.text(
          "By signing up, you agree to DeepTrain's Terms of Service and Privacy Policy",
        ),
        findsOneWidget,
      );
    });

    // Test 2: User can type into text fields
    testWidgets('User can enter text into input fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(findTextFieldByHint('First Name'), 'John');
      await tester.enterText(findTextFieldByHint('Last Name'), 'Doe');
      await tester.enterText(
        findTextFieldByHint('Email'),
        'john.doe@example.com',
      );
      await tester.enterText(findTextFieldByHint('Password'), 'Password123!');

      expect(find.text('John'), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      final passwordField = tester.widget<TextField>(
        findTextFieldByHint('Password'),
      );
      expect(passwordField.controller!.text, 'Password123!');
    });

    // Test 3: Toggle password visibility
    testWidgets('Password visibility can be toggled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        tester.widget<TextField>(findTextFieldByHint('Password')).obscureText,
        isTrue,
      );
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(
        tester.widget<TextField>(findTextFieldByHint('Password')).obscureText,
        isFalse,
      );
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(
        tester.widget<TextField>(findTextFieldByHint('Password')).obscureText,
        isTrue,
      );
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    // Test 4: Tapping 'Sign In' navigates to /login
    testWidgets('Tapping "Sign In" navigates to /login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen Mock'), findsOneWidget);
      // The presence of 'Login Screen Mock' verifies navigation.
    });
  });
}
