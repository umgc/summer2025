// This test verifies that the AboutScreen renders correctly,
// displays all essential text content, and handles responsive layouts.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deeptrainfront/screens/about_screen.dart';

void main() {
  group('AboutScreen Widget Tests', () {
    testWidgets('AboutScreen renders correctly and displays key texts', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AboutScreen()));

      expect(find.text('About'), findsOneWidget);
      expect(find.text('About DeepTrain'), findsOneWidget);
      expect(
        find.text('Empowering Professionals with AI-Driven Learning'),
        findsOneWidget,
      );
      expect(find.text('Our Mission'), findsOneWidget);
      expect(
        find.textContaining(
          'DeepTrain\'s mission is to deliver the future of learning',
        ),
        findsOneWidget,
      );
      expect(find.text('Our Values'), findsOneWidget);
      expect(find.text('Innovation'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/images/DeepTrainHero.webp',
        ),
        findsOneWidget,
      );
    });

    testWidgets('AboutScreen renders mobile layout correctly', (
      WidgetTester tester,
    ) async {
      // Set a mobile screen size for the test environment.
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      await tester.pumpWidget(const MaterialApp(home: AboutScreen()));

      // The layout changes based on `isMobile = MediaQuery.of(context).size.width < 600;`
      // In mobile layout, the image and description are in a Column.
      // We can check for the specific Column that holds the image and description.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Column && // This is the main Column for mobile layout
              widget.children.any(
                (child) => child is Image,
              ) && // Contains the image
              widget.children.any(
                (child) =>
                    child is Text &&
                    child.data != null &&
                    child.data!.contains('Founded in 2025'),
              ), // Contains the description text
        ),
        findsOneWidget,
      );

      // Reset the screen size after the test
      addTearDown(() {
        tester.binding.window.clearAllTestValues();
      });
    });
  });
}
