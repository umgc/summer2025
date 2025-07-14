// there is 1 error need to come back

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:deeptrainfront/screens/trainee_dashboard_screen.dart'; /

// We need to mock the VoiceAssistantLottie widget as it likely contains Lottie animations
// that prevent pumpAndSettle from completing. Use a simple placeholder.

class MockVoiceAssistantLottie extends StatelessWidget {
  const MockVoiceAssistantLottie({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 80,
      height: 80,
      child: Text('Mock Voice Assistant'),
    );
  }
}

void main() {
  group('TraineeDashboardScreen Web Layout Test', () {
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
                builder: (context, state) => const TraineeDashboardScreen(),
              ),
              // Add placeholder routes for navigation targets
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
      // Replace pumpAndSettle() with pumpMultipleTimes() to avoid timeout issues
      // and ensure widgets have time to render without waiting indefinitely for animations.
      await pumpMultipleTimes(tester);

      // Verify AppBar elements for web layout
      expect(find.text('DeepTrain Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsOneWidget);
      expect(
        find.byIcon(Icons.menu),
        findsNothing,
      ); // Menu icon should not be present on web

      // Verify sidebar navigation items for web layout
      expect(find.text('Simulator'), findsOneWidget);
      expect(find.text('KPI Dashboard'), findsOneWidget);

      // Verify main content cards
      expect(find.text('Tasks Completed'), findsOneWidget);
      expect(find.text('255'), findsOneWidget);
      expect(find.text('Upcoming Tasks'), findsOneWidget);
      expect(find.text('67'), findsOneWidget);
      expect(
        find.byType(LineChart),
        findsOneWidget,
      ); // Verify LineChart presence
      expect(find.text('Scenarios'), findsOneWidget);
      expect(find.text('Scenario 1'), findsOneWidget);
      expect(find.text('Scenario 2'), findsOneWidget);

      // Verify Lottie animation (if it's not mocked out for testing)
      // Since Lottie animations can cause timeouts, if you encounter issues,
      // you might need to mock LottieBuilder or its asset loading mechanism.
      expect(find.byType(LottieBuilder), findsOneWidget);
    });
  });
}
