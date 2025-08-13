import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:care_connect_app/config/utils/responsive_utils.dart';

void main() {
  group('Responsive Utils Tests', () {
    testWidgets('ResponsiveUtils.getDeviceType returns correct device type', (
      WidgetTester tester,
    ) async {
      // Build a simple widget for testing
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              // Test different device sizes
              final deviceType = ResponsiveUtils.getDeviceType(context);

              // Initial size is typically medium (tablet) in test environment
              expect(deviceType, equals(DeviceType.tablet));

              return const Text('Test');
            },
          ),
        ),
      );

      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final deviceType = ResponsiveUtils.getDeviceType(context);
              expect(deviceType, equals(DeviceType.mobile));
              return const Text('Test');
            },
          ),
        ),
      );

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final deviceType = ResponsiveUtils.getDeviceType(context);
              expect(deviceType, equals(DeviceType.desktop));
              return const Text('Test');
            },
          ),
        ),
      );
    });

    test('Platform detection methods should not throw errors', () {
      // These methods should not throw errors even when tested outside of a device
      expect(() => ResponsiveUtils.isMobile, returnsNormally);
      expect(() => ResponsiveUtils.isWeb, returnsNormally);
      expect(() => ResponsiveUtils.isIOS, returnsNormally);
      expect(() => ResponsiveUtils.isAndroid, returnsNormally);
    });

    testWidgets(
      'ResponsiveBuilder returns correct widget based on screen size',
      (WidgetTester tester) async {
        // Create widgets for different screen sizes
        final mobileWidget = Container(key: const Key('mobile'));
        final tabletWidget = Container(key: const Key('tablet'));
        final desktopWidget = Container(key: const Key('desktop'));

        // Helper function to build the responsive widget
        Widget buildResponsiveWidget() {
          return MaterialApp(
            home: ResponsiveBuilder(
              builder: (context, deviceType) {
                switch (deviceType) {
                  case DeviceType.mobile:
                    return mobileWidget;
                  case DeviceType.tablet:
                    return tabletWidget;
                  case DeviceType.desktop:
                    return desktopWidget;
                }
              },
            ),
          );
        }

        // Test mobile size
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpWidget(buildResponsiveWidget());
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('mobile')), findsOneWidget);

        // Test tablet size
        await tester.binding.setSurfaceSize(const Size(800, 1200));
        await tester.pumpWidget(buildResponsiveWidget());
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('tablet')), findsOneWidget);

        // Test desktop size
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(buildResponsiveWidget());
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('desktop')), findsOneWidget);
      },
    );
  });
}
