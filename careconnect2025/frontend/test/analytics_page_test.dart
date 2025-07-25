import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:care_connect_app/features/analytics/analytics_page.dart';

void main() {
  testWidgets('Analytics page renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: AnalyticsPage(patientId: 1)));

    // Verify that the analytics page shows loading initially
    expect(find.text('Patient Analytics'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Analytics page shows export buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AnalyticsPage(patientId: 1)));

    // Verify that export buttons are present
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
  });
}
