/*
// Tests for AdminDashboardScreen widget, covering layout rendering for mobile and web,
// drawer functionality, and interactions with the account popup menu items
// including dialog displays and navigation.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:deeptrainfront/screens/admin_dashboard.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  late MockGoRouter mockRouter;

  setUp(() {
    mockRouter = MockGoRouter();
    registerFallbackValue(Uri.parse('/'));
    registerFallbackValue(const Offset(0, 0));
  });

  Widget createAdminDashboardScreen({required double screenWidth}) {
    return Provider<GoRouter>.value(
      value: mockRouter,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: Size(screenWidth, 800)),
          child: const AdminDashboardScreen(),
        ),
      ),
    );
  }

  group('AdminDashboardScreen', () {
    testWidgets('renders web layout on large screens', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 1000));

      expect(find.text('DeepTrain Dashboard'), findsOneWidget);
      expect(find.text('Scenario Builder'), findsOneWidget);
      expect(find.text('Simulator'), findsOneWidget);
      expect(find.text('KPI Dashboard'), findsOneWidget);
      expect(find.text('Tasks Completed'), findsOneWidget);
      expect(find.text('Upcoming Tasks'), findsOneWidget);
      expect(find.byType(Card), findsAtLeastNWidgets(4));
      expect(find.text('Scenarios'), findsOneWidget);
    });

    testWidgets('renders mobile layout on small screens', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 500));

      expect(find.text('DeepTrain Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.text('Tasks Completed'), findsOneWidget);
      expect(find.text('Upcoming Tasks'), findsOneWidget);
      expect(find.byType(Card), findsAtLeastNWidgets(4));
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('Scenario Builder'), findsNothing);
      expect(find.text('Simulator'), findsNothing);
      expect(find.text('KPI Dashboard'), findsNothing);
    });

    testWidgets('drawer opens and navigates in mobile layout', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 500));

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Scenario Builder'), findsOneWidget);
      expect(find.text('Simulator'), findsOneWidget);
      expect(find.text('KPI Dashboard'), findsOneWidget);

      when(() => mockRouter.push('/builder')).thenAnswer((_) async {});
      await tester.tap(find.text('Scenario Builder'));
      await tester.pumpAndSettle();
      verify(() => mockRouter.push('/builder')).called(1);
    });

    testWidgets('account details dialog appears when tapped', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 1000));

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Account Details'));
      await tester.pumpAndSettle();

      expect(find.text('Account Details'), findsOneWidget);
      expect(
        find.text('Email: user@example.com\nRole: Trainee'),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Account Details'), findsNothing);
    });

    testWidgets('change password dialog appears when tapped', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 1000));

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Change Password'), findsNothing);
    });

    testWidgets('notifications dialog appears and switch toggles', (
      tester,
    ) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 1000));

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Enable Notifications'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);

      SwitchListTile switchTile = tester.widget(find.byType(SwitchListTile));
      expect(switchTile.value, isTrue);

      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();

      switchTile = tester.widget(find.byType(SwitchListTile));
      expect(switchTile.value, isFalse);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Notifications'), findsNothing);
    });

    testWidgets('privacy & terms dialog appears when tapped', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 1000));

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy & Terms'));
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Terms'), findsOneWidget);
      expect(
        find.text(
          'By using this app you agree to our Privacy Policy and Terms of Service.',
        ),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Privacy & Terms'), findsNothing);
    });

    testWidgets('logout navigates to root path', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 1000));

      await tester.tap(find.byIcon(Icons.account_circle));
      await tester.pumpAndSettle();

      when(() => mockRouter.pop('/')).thenAnswer((_) async {});
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.pop('/')).called(1);
    });

    testWidgets('web layout navigation works correctly', (tester) async {
      await tester.pumpWidget(createAdminDashboardScreen(screenWidth: 1000));

      when(() => mockRouter.push('/scenario')).thenAnswer((_) async {});
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ListTile &&
              (widget.title as Text).data == 'Scenario Builder',
        ),
      );
      await tester.pumpAndSettle();
      verify(() => mockRouter.push('/scenario')).called(1);

      when(() => mockRouter.push('/simulator')).thenAnswer((_) async {});
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ListTile && (widget.title as Text).data == 'Simulator',
        ),
      );
      await tester.pumpAndSettle();
      verify(() => mockRouter.push('/simulator')).called(1);

      when(() => mockRouter.push('/kpi')).thenAnswer((_) async {});
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is ListTile &&
              (widget.title as Text).data == 'KPI Dashboard',
        ),
      );
      await tester.pumpAndSettle();
      verify(() => mockRouter.push('/kpi')).called(1);
    });
  });
}
*/
