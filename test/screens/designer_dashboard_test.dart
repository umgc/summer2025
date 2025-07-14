// This test suite verifies the basic rendering of the `DesignerDashboardScreen` for the web layout.
// It checks for the presence of key AppBar elements, sidebar navigation items, and primary content cards,
// ensuring the UI components are correctly displayed for wider screens.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:deeptrainfront/screens/designer_dashboard.dart';
import 'package:lottie/lottie.dart';

void main() {
  group('DesignerDashboardScreen Web Layout Test', () {
    Future<void> pumpMultipleTimes(
      WidgetTester tester, {
      int pumps = 3,
      Duration duration = const Duration(milliseconds: 100),
    }) async {
      for (int i = 0; i < pumps; i++) {
        await tester.pump(duration);
      }
    }

    testWidgets('Web layout renders correctly', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      addTearDown(() {
        tester.binding.window.clearPhysicalSizeTestValue();
        tester.binding.window.clearDevicePixelRatioTestValue();
      });

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DesignerDashboardScreen(),
              ),
              GoRoute(
                path: '/scenario',
                builder: (context, state) => const Placeholder(),
              ),
              GoRoute(
                path: '/simulator',
                builder: (context, state) => const Placeholder(),
              ),
              GoRoute(
                path: '/kpi',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
        ),
      );
      // Replaced pumpAndSettle() with pumpMultipleTimes() to avoid timeout issues
      await pumpMultipleTimes(tester);

      expect(find.text('DeepTrain Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsNothing);

      expect(find.text('Scenario Builder'), findsOneWidget);
      expect(find.text('Simulator'), findsOneWidget);
      expect(find.text('KPI Dashboard'), findsOneWidget);

      expect(find.text('Tasks Completed'), findsOneWidget);
      expect(find.text('255'), findsOneWidget);
      expect(find.text('Upcoming Tasks'), findsOneWidget);
      expect(find.text('67'), findsOneWidget);
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('Scenario 1'), findsOneWidget);
      expect(find.byType(LottieBuilder), findsOneWidget);
    });
  });
}
