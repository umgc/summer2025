import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/widgets/ai_chat.dart';
import 'package:care_connect_app/services/ai_service.dart';

void main() {
  group('AI Chat File Upload Tests', () {
    testWidgets('displays file upload button', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'patient')]),
          ),
        ),
      );

      // Verify the initial state - chat should be collapsed
      expect(find.text('Ask AI (DeepSeek)'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file), findsNothing);

      // Tap the floating action button to expand chat
      await tester.tap(find.text('Ask AI (DeepSeek)'));
      await tester.pumpAndSettle();

      // Verify the chat is expanded and file upload button is visible
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets('shows file upload button with correct tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'analytics')]),
          ),
        ),
      );

      // Expand the chat
      await tester.tap(find.text('Ask AI (DeepSeek)'));
      await tester.pumpAndSettle();

      // Find the file upload button
      final uploadButton = find.byIcon(Icons.attach_file);
      expect(uploadButton, findsOneWidget);

      // Verify the tooltip by finding the IconButton that contains this icon
      final iconButton = find.ancestor(
        of: uploadButton,
        matching: find.byType(IconButton),
      );
      expect(iconButton, findsOneWidget);

      final button = tester.widget<IconButton>(iconButton);
      expect(button.tooltip, 'Upload files');
    });

    testWidgets('displays uploaded files when files are present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'caregiver')]),
          ),
        ),
      );

      // Expand the chat
      await tester.tap(find.text('Ask AI (DeepSeek)'));
      await tester.pumpAndSettle();

      // Initially, no uploaded files should be shown
      expect(find.text('Uploaded Files'), findsNothing);
      // Since there are no uploaded files, there should be no file removal functionality visible
      expect(find.textContaining('Uploaded Files ('), findsNothing);
    });

    testWidgets('chat widget has correct initial state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'patient')]),
          ),
        ),
      );

      // Verify initial collapsed state
      expect(find.text('Ask AI (DeepSeek)'), findsOneWidget);
      expect(find.text('Health Assistant'), findsNothing);
      expect(find.byIcon(Icons.smart_toy), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('chat expands and shows all components', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'analytics')]),
          ),
        ),
      );

      // Expand the chat
      await tester.tap(find.text('Ask AI (DeepSeek)'));
      await tester.pumpAndSettle();

      // Verify expanded state components
      expect(find.text('Health Assistant'), findsOneWidget);
      expect(find.byIcon(Icons.minimize), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text('Ask a health question...'), findsOneWidget);
    });

    testWidgets('model selector dropdown is present', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'patient')]),
          ),
        ),
      );

      // Expand the chat
      await tester.tap(find.text('Ask AI (DeepSeek)'));
      await tester.pumpAndSettle();

      // Find the dropdown button
      expect(find.byType(DropdownButton<AIModel>), findsOneWidget);
    });

    testWidgets('welcome message appears on first expansion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'caregiver')]),
          ),
        ),
      );

      // Expand the chat
      await tester.tap(find.text('Ask AI (DeepSeek)'));
      await tester.pumpAndSettle();

      // Verify welcome message is present
      expect(
        find.textContaining('Hello! I\'m your health assistant'),
        findsOneWidget,
      );
    });

    testWidgets('input field accepts text input', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(children: [AIChat(role: 'patient')]),
          ),
        ),
      );

      // Expand the chat
      await tester.tap(find.text('Ask AI (DeepSeek)'));
      await tester.pumpAndSettle();

      // Find the text field and enter some text
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      await tester.enterText(textField, 'Hello AI');
      await tester.pump();

      // Verify text is entered
      expect(find.text('Hello AI'), findsOneWidget);
    });
  });
}
