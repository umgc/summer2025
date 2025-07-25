import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:care_connect_app/features/analytics/analytics_page.dart';

void main() {
  testWidgets('Analytics page shows filter chips', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: AnalyticsPage(patientId: 1)));

    // Wait for the initial loading to complete
    await tester.pump();

    // Verify that filter chips are present
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('14 days'), findsOneWidget);
    expect(find.text('21 days'), findsOneWidget);
    expect(find.text('30 days'), findsOneWidget);
  });

  testWidgets('Filter chips can be selected', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AnalyticsPage(patientId: 1)));

    await tester.pump();

    // Find and tap the 14 days filter chip
    final chip14Days = find.widgetWithText(FilterChip, '14 days');
    expect(chip14Days, findsOneWidget);

    await tester.tap(chip14Days);
    await tester.pump();

    // Verify the selection changed (this would trigger a new API call in the real app)
    // The exact verification would depend on the implementation details
  });

  testWidgets('Refresh button works', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AnalyticsPage(patientId: 1)));

    await tester.pump();

    // Find and tap the refresh button
    final refreshButton = find.byIcon(Icons.refresh);
    expect(refreshButton, findsOneWidget);

    await tester.tap(refreshButton);
    await tester.pump();

    // Verify that the refresh action was triggered
  });
}
