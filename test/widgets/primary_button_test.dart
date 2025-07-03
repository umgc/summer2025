// This file contains widget tests for the PrimaryButton.
//
// These tests verify:
// - That the PrimaryButton renders correctly with its label when not in a loading state.
// - That the PrimaryButton's onPressed callback is triggered when tapped and not loading.
// - That the PrimaryButton correctly displays a CircularProgressIndicator and is disabled
//   when the isLoading property is set to true.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deeptrainfront/shared/widgets/buttons/primary_button.dart';

void main() {
  group('PrimaryButton Widget Tests', () {
    // Helper function to wrap the PrimaryButton in a basic MaterialApp
    // This provides the necessary widget tree context for the button to render.
    Widget createButtonUnderTest({
      required String label,
      required VoidCallback onPressed,
      bool isLoading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: PrimaryButton(
              label: label,
              onPressed: onPressed,
              isLoading: isLoading,
            ),
          ),
        ),
      );
    }

    // Test 1: Verify PrimaryButton renders with the correct label when not loading
    testWidgets('PrimaryButton displays label and is enabled when not loading', (
      WidgetTester tester,
    ) async {
      // Arrange: Set up a flag to check if onPressed is called
      bool buttonTapped = false;
      await tester.pumpWidget(
        createButtonUnderTest(
          label: 'Click Me',
          onPressed: () {
            buttonTapped = true;
          },
          isLoading: false,
        ),
      );
      await tester
          .pumpAndSettle(); // Ensure the widget tree is built and settled

      // Assert 1: Find the button by its label
      expect(find.text('Click Me'), findsOneWidget);

      // Assert 2: Verify the button is an ElevatedButton (implicitly enabled if onPressed is not null)
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Act: Tap the button
      await tester.tap(find.text('Click Me'));
      await tester
          .pumpAndSettle(); // Allow any potential animations/callbacks to complete

      // Assert 3: Verify that the onPressed callback was triggered
      expect(buttonTapped, isTrue);
    });

    // Test 2: Verify PrimaryButton displays a loading indicator and is disabled when loading
    testWidgets(
      'PrimaryButton displays loading indicator and is disabled when loading',
      (WidgetTester tester) async {
        // Arrange: Set up a flag to ensure onPressed is NOT called
        bool buttonTapped = false;
        await tester.pumpWidget(
          createButtonUnderTest(
            label: 'Loading...',
            onPressed: () {
              buttonTapped = true; // This should NOT be called
            },
            isLoading: true, // Set to loading state
          ),
        );
        // NICOLE EDITS: Use pump() instead of pumpAndSettle() because CircularProgressIndicator is a continuous animation.
        // We only need one pump to render the indicator.
        await tester.pump();

        // Assert 1: Verify the CircularProgressIndicator is present
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Assert 2: Verify the label text is NOT present (replaced by indicator)
        expect(find.text('Loading...'), findsNothing);

        // Assert 3: Verify the ElevatedButton is disabled (onPressed is null)
        final buttonFinder = find.byType(ElevatedButton);
        final ElevatedButton button = tester.widget(buttonFinder);
        expect(button.onPressed, isNull);

        // Act: Try to tap the button (it should do nothing)
        await tester.tap(buttonFinder);
        await tester
            .pump(); // Just pump once after tap, no settling needed for disabled button

        // Assert 4: Verify that the onPressed callback was NOT triggered
        expect(buttonTapped, isFalse);
      },
    );
  });
}
