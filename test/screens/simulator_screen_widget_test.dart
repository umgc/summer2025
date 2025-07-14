// two tests fail

// This file contains a simple widget test for the SimulatorScreen.
//
// The test verifies:
// - That the SimulatorScreen renders without errors.
// - The presence of the AppBar title "Simulator".
// - The presence of key text elements like "Simulation Status: ACTIVE" and "Incoming Event:".
// - The presence of the "Load Simulation" button.
// - The presence of the "Trainee response" TextField.
// - The presence of the "Submit Response" button.
// - That tapping the "Load Simulation" button displays a SnackBar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deeptrainfront/screens/simulator_screen.dart'; // Import your SimulatorScreen

void main() {
  group('SimulatorScreen Widget Tests', () {
    // Helper function to pump the SimulatorScreen
    Widget createWidgetUnderTest() {
      return const MaterialApp(home: SimulatorScreen());
    }

    testWidgets('SimulatorScreen renders correctly with all main elements', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Ensure all widgets are built and settled

      // Verify AppBar title
      expect(find.text('Simulator'), findsOneWidget);

      // Verify main status and event texts
      expect(find.text('Simulation Status: ACTIVE'), findsOneWidget);
      expect(find.text('Incoming Event:'), findsOneWidget);

      // Verify "Load Simulation" button using a more robust finder
      final loadSimulationButtonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ElevatedButton &&
            find
                .descendant(
                  of: find.byWidget(widget),
                  matching: find.text('Load Simulation'),
                )
                .evaluate()
                .isNotEmpty,
        description: 'ElevatedButton containing "Load Simulation" text',
      );
      expect(loadSimulationButtonFinder, findsOneWidget);
      expect(
        find.byIcon(Icons.play_arrow),
        findsOneWidget,
      ); // Verify icon is present

      // Verify "Trainee response" TextField
      expect(
        find.widgetWithText(TextField, 'Trainee response'),
        findsOneWidget,
      );
      expect(
        find.byType(TextField),
        findsOneWidget,
      ); // More general check for the TextField

      // Verify "Submit Response" button using a more robust finder
      // NICOLE EDITS: Applied the robust find.byWidgetPredicate strategy for "Submit Response" button
      final submitResponseButtonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ElevatedButton &&
            find
                .descendant(
                  of: find.byWidget(widget),
                  matching: find.text('Submit Response'),
                )
                .evaluate()
                .isNotEmpty,
        description: 'ElevatedButton containing "Submit Response" text',
      );
      expect(submitResponseButtonFinder, findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget); // Verify icon is present
    });

    testWidgets('Tapping "Load Simulation" button shows a SnackBar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Tap the "Load Simulation" button using the robust finder
      final loadSimulationButtonFinder = find.byWidgetPredicate(
        (widget) =>
            widget is ElevatedButton &&
            find
                .descendant(
                  of: find.byWidget(widget),
                  matching: find.text('Load Simulation'),
                )
                .evaluate()
                .isNotEmpty,
        description: 'ElevatedButton containing "Load Simulation" text',
      );
      await tester.tap(loadSimulationButtonFinder);
      await tester.pump(); // Pump to allow the SnackBar to appear

      // Verify that the SnackBar is displayed
      expect(find.text('Load Simulation button'), findsOneWidget);
    });
  });
}
