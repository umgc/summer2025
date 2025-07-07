import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:care_connect_app/providers/user_provider.dart';

class MockUserProvider extends Mock implements UserProvider {}

void main() {
  group('UserProvider Name Display', () {
    testWidgets('Consumer displays user name correctly', (
      WidgetTester tester,
    ) async {
      final mockUserProvider = MockUserProvider();
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'PATIENT',
        token: 'test_token',
        name: 'John Doe',
        patientId: 1,
      );

      when(mockUserProvider.user).thenReturn(mockUser);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<UserProvider>.value(
              value: mockUserProvider,
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final userName = userProvider.user?.name ?? 'Patient';
                  return Text(userName);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify user name is displayed
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('Consumer displays fallback name when user is null', (
      WidgetTester tester,
    ) async {
      final mockUserProvider = MockUserProvider();

      when(mockUserProvider.user).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<UserProvider>.value(
              value: mockUserProvider,
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final userName = userProvider.user?.name ?? 'Patient';
                  return Text(userName);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify fallback name is displayed
      expect(find.text('Patient'), findsOneWidget);
    });

    testWidgets('Consumer displays fallback name when user has no name', (
      WidgetTester tester,
    ) async {
      final mockUserProvider = MockUserProvider();
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'PATIENT',
        token: 'test_token',
        name: null, // No name provided
        patientId: 1,
      );

      when(mockUserProvider.user).thenReturn(mockUser);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<UserProvider>.value(
              value: mockUserProvider,
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final userName = userProvider.user?.name ?? 'Patient';
                  return Text(userName);
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify fallback name is displayed
      expect(find.text('Patient'), findsOneWidget);
    });

    testWidgets('Consumer handles complex name logic like patient dashboard', (
      WidgetTester tester,
    ) async {
      final mockUserProvider = MockUserProvider();
      final mockUser = UserSession(
        id: 1,
        email: 'test@example.com',
        role: 'PATIENT',
        token: 'test_token',
        name: null, // No name in user
        patientId: 1,
      );

      when(mockUserProvider.user).thenReturn(mockUser);

      // Mock patient data (like from API)
      final patientData = {'firstName': 'Jane', 'lastName': 'Smith'};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<UserProvider>.value(
              value: mockUserProvider,
              child: Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  final user = userProvider.user;
                  final patientName =
                      user?.name ??
                      (patientData['firstName'] != null &&
                              patientData['lastName'] != null
                          ? '${patientData['firstName']} ${patientData['lastName']}'
                          : 'Patient');

                  return Column(
                    children: [
                      Text(patientName),
                      const Text('Patient'), // Role text
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the correct name from patient data is displayed
      expect(find.text('Jane Smith'), findsOneWidget);

      // Verify role text is also displayed
      expect(find.text('Patient'), findsOneWidget);
    });
  });
}
