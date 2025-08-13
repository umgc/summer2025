import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/ai_chat_improved.dart';
import 'package:care_connect_app/services/ai_service.dart';

void main() {
  group('AI Chat Widget Tests', () {
    testWidgets('Modal AI Chat should show header text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'patient', isModal: true)),
        ),
      );

      await tester.pumpAndSettle();

      // Since we're using isModal: true, it should show the header title
      expect(find.text('Health Assistant'), findsOneWidget);

      // Should find the model dropdown
      expect(find.byType(DropdownButton<AIModel>), findsOneWidget);
    });

    testWidgets('Modal AI Chat should show health assistant elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AIChat(role: 'caregiver', isModal: true)),
        ),
      );

      await tester.pumpAndSettle();

      // Should show a welcome message since this is a modal view
      expect(
        find.textContaining("Welcome to the Caregiver Assistant"),
        findsOneWidget,
      );

      // Should show input field
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
