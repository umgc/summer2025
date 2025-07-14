import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deeptrainfront/screens/features_screen.dart';
import 'package:deeptrainfront/auth/register_screen.dart';

void main() {
  group('FeaturesScreen Web Layout Test', () {
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
        MaterialApp(
          home: const FeaturesScreen(),
          routes: {
            '/register': (context) =>
                const RegisterScreen(), // Provide a route for RegisterScreen
          },
        ),
      );
      await pumpMultipleTimes(tester);

      // Verify AppBar
      expect(find.text('Features'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Verify main header and subtitle
      expect(find.text('DeepTrain Features'), findsOneWidget);
      expect(
        find.textContaining('Explore the cutting-edge capabilities'),
        findsOneWidget,
      );

      // Verify Feature Cards
      expect(find.text('AI-Driven Personalization'), findsOneWidget);
      expect(find.byIcon(Icons.psychology), findsOneWidget);

      expect(find.text('Real-Time Progress Tracking'), findsOneWidget);
      expect(find.byIcon(Icons.show_chart), findsOneWidget);

      expect(find.text('Team Collaboration'), findsOneWidget);
      expect(find.byIcon(Icons.group), findsOneWidget);

      expect(find.text('Interactive Scenario Simulation'), findsOneWidget);
      expect(find.byIcon(Icons.extension), findsOneWidget);

      expect(find.text('Certifications & Badges'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsOneWidget);

      expect(find.text('Enterprise-Grade Security'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);

      // Verify Call to Action section
      expect(
        find.text("Ready to unlock your team's potential?"),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(ElevatedButton, "Get Started Now"),
        findsOneWidget,
      );
    });
  });
}
