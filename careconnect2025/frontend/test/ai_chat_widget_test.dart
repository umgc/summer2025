import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/ai_chat.dart';

void main() {
  group('AI Chat Widget Tests', () {
    testWidgets('AI Chat should show correct button text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'patient')),
        ),
      );

      // Should show "Ask AI" text on the button
      expect(find.textContaining('Ask AI'), findsOneWidget);

      // Should show model indicator
      expect(find.textContaining('DeepSeek'), findsOneWidget);
    });

    testWidgets('AI Chat should show smart toy icon when collapsed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'caregiver')),
        ),
      );

      // Should show smart toy icon
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);

      // Should show settings icon hint
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
