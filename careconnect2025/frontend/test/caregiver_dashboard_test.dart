import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/features/dashboard/presentation/pages/caregiver_dashboard.dart';
import 'package:care_connect_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('CaregiverDashboard', () {
    testWidgets('renders caregiver dashboard', (WidgetTester tester) async {
      // Create a mock user
      final mockUser = UserSession(
        id: 1,
        role: 'caregiver',
        token: 'mock_token',
        caregiverId: 1,
      );

      // Build the widget with provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the dashboard elements are present
      expect(find.text('Caregiver Dashboard'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Ask AI'), findsOneWidget);
    });

    testWidgets('handles API error gracefully', (WidgetTester tester) async {
      // Create a mock user
      final mockUser = UserSession(
        id: 1,
        role: 'caregiver',
        token: 'mock_token',
        caregiverId: 1,
      );

      // Build the widget with provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (context) => UserProvider()..setUser(mockUser),
            child: const CaregiverDashboard(),
          ),
        ),
      );

      // Wait for the widget to build and API call to complete
      await tester.pumpAndSettle();

      // In test environment, HTTP request will fail and show error state
      // Check if error text is displayed (which is expected behavior)
      final errorFinder = find.textContaining('Error');
      final failedFinder = find.textContaining('Failed to load patients');

      // Test passes if we can find error state (expected in test environment)
      expect(
        errorFinder.evaluate().length + failedFinder.evaluate().length,
        greaterThan(0),
      );
    });
  });
}
