// This test suite verifies the responsive layout of the ContactScreen across different screen sizes.
// It also ensures the contact form functions correctly by testing text input, button tap, and the display of a success message.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deeptrainfront/screens/contact_screen.dart';

void main() {
  // Helper function to pump the widget for testing
  // Added a default height, making it explicit.
  Widget createContactScreen({
    required double screenWidth,
    double screenHeight = 800.0,
  }) {
    return MaterialApp(
      home: MediaQuery(
        // Set a sufficient height for the test cases where content might be scrolled.
        // 800 is often a good starting point for content that scrolls.
        data: MediaQueryData(size: Size(screenWidth, screenHeight)),
        child: const ContactScreen(),
      ),
    );
  }

  group('ContactScreen', () {
    testWidgets('renders mobile layout on small screens', (tester) async {
      await tester.pumpWidget(createContactScreen(screenWidth: 500));

      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Get in Touch with DeepTrain'), findsOneWidget);
      expect(
        find.text(
          'We’d love to hear from you. Fill out the form below, and our team will get back to you shortly.',
        ),
        findsOneWidget,
      );

      expect(find.widgetWithText(TextField, 'Your Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Your Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Your Message'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Send Message'),
        findsOneWidget,
      );

      expect(find.text('DeepTrain Headquarters'), findsNothing);
      expect(find.text('Email: support@deeptrain.ai'), findsNothing);
    });

    testWidgets('renders web layout on large screens', (tester) async {
      await tester.pumpWidget(createContactScreen(screenWidth: 1000));

      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Get in Touch with DeepTrain'), findsOneWidget);
      expect(
        find.text(
          'We’d love to hear from you. Fill out the form below, and our team will get back to you shortly.',
        ),
        findsOneWidget,
      );

      expect(find.widgetWithText(TextField, 'Your Name'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Your Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Your Message'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Send Message'),
        findsOneWidget,
      );

      expect(find.text('DeepTrain Headquarters'), findsOneWidget);
      expect(find.text('123 AI Learning Lane'), findsOneWidget);
      expect(find.text('Email: support@deeptrain.ai'), findsOneWidget);
      expect(find.text('Phone: +1 (555) 123-4567'), findsOneWidget);
      expect(find.text('Business Hours'), findsOneWidget);
    });

    testWidgets('form submission shows snackbar and clears fields', (
      tester,
    ) async {
      // Use a larger height for this test to ensure the button is visible
      await tester.pumpWidget(
        createContactScreen(screenWidth: 800, screenHeight: 1000),
      );

      final nameField = find.widgetWithText(TextField, 'Your Name');
      final emailField = find.widgetWithText(TextField, 'Your Email');
      final messageField = find.widgetWithText(TextField, 'Your Message');
      final sendButton = find.widgetWithText(ElevatedButton, 'Send Message');

      await tester.enterText(nameField, 'John Doe');
      await tester.enterText(emailField, 'john.doe@example.com');
      await tester.enterText(messageField, 'This is a test message.');

      expect(tester.widget<TextField>(nameField).controller!.text, 'John Doe');
      expect(
        tester.widget<TextField>(emailField).controller!.text,
        'john.doe@example.com',
      );
      expect(
        tester.widget<TextField>(messageField).controller!.text,
        'This is a test message.',
      );

      // Ensure the button is visible before tapping
      await tester.ensureVisible(sendButton);
      await tester.pumpAndSettle(); // Allow scrolling to complete

      await tester.tap(sendButton);
      await tester.pump(); // Pump to start the SnackBar animation
      await tester
          .pumpAndSettle(); // Pump until the SnackBar animation completes

      expect(
        find.text('Message sent! We will get back to you shortly.'),
        findsOneWidget,
      );

      expect(tester.widget<TextField>(nameField).controller!.text, '');
      expect(tester.widget<TextField>(emailField).controller!.text, '');
      expect(tester.widget<TextField>(messageField).controller!.text, '');
    });
  });
}
