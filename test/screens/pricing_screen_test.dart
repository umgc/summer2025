import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:deeptrainfront/screens/pricing_screen.dart'; // Adjust path if necessary

// Mock classes for GoRouter and its dependencies if needed, or simply provide placeholder routes.
// For simple rendering tests, providing routes that go to Placeholder is sufficient.

void main() {
  group('PricingScreen Web Layout Test', () {
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
                builder: (context, state) => const PricingScreen(),
              ),
              // Add placeholder routes for navigation targets
              GoRoute(
                path: '/contact',
                builder: (context, state) => const Placeholder(),
              ),
              GoRoute(
                path: '/signUp',
                builder: (context, state) => const Placeholder(),
              ),
            ],
          ),
        ),
      );
      await pumpMultipleTimes(tester);

      // Verify AppBar
      expect(find.text('Pricing'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify main header and subtitle
      expect(find.text('Choose the Right Plan for Your Team'), findsOneWidget);
      expect(
        find.textContaining(
          "Whether you're a solo learner or a growing organization,",
        ),
        findsOneWidget,
      );

      // Verify Pricing Cards
      expect(find.text('Starter'), findsOneWidget);
      expect(find.text('\$19/mo'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Get Started'),
        findsNWidgets(3),
      ); // Three 'Get Started' buttons

      expect(find.text('Professional'), findsOneWidget);
      expect(find.text('\$49/mo'), findsOneWidget);

      expect(find.text('Enterprise'), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);

      // Verify Call to Action section
      expect(
        find.text("Questions about pricing or custom solutions?"),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, "Contact Sales"),
        findsOneWidget,
      );
    });
  });
}
