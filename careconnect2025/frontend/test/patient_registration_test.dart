import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/onboarding/presentation/pages/patient_registration.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('PatientRegistrationPage', () {
    testWidgets('renders patient registration form', (
      WidgetTester tester,
    ) async {
      // Create a mock user
      final mockUser = UserSession(
        id: 1,
        role: 'caregiver',
        token: 'mock_token',
        email: 'testcaregiver@sample.com',
        caregiverId: 1,
      );

      // Build the widget with provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const PatientRegistrationPage(),
          ),
        ),
      );

      // Verify that the form elements are present
      expect(find.text('Register New Patient'), findsAtLeast(1));
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Relationship to Patient'), findsOneWidget);
      expect(find.text('Register Patient'), findsOneWidget);
    });

    testWidgets('validates required fields', (WidgetTester tester) async {
      // Create a mock user
      final mockUser = UserSession(
        id: 1,
        role: 'caregiver',
        token: 'mock_token',
        email: 'testmeemail@sample.com',
        caregiverId: 1,
      );

      // Build the widget with provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const PatientRegistrationPage(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Scroll to make the button visible
      await tester.ensureVisible(find.text('Register Patient'));

      // Tap the register button without filling the form
      await tester.tap(find.text('Register Patient'));
      await tester.pumpAndSettle();

      // Verify that validation errors are shown
      expect(find.text('Please enter first name'), findsOneWidget);
      expect(find.text('Please enter last name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your phone number'), findsOneWidget);
      expect(find.text('Please select date of birth'), findsOneWidget);
      expect(find.text('Please enter your address'), findsOneWidget);
      expect(
        find.text('Please enter your relationship to the patient'),
        findsOneWidget,
      );
    });
  });
}
