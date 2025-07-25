import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Utility class for handling responsive behavior across different platforms
/// and screen sizes. This helps ensure the app renders well on web, iOS, and Android.
class ResponsiveUtils {
  /// Breakpoints for different device sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Determine if the current platform is mobile
  static bool get isMobile {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Determine if the current platform is web
  static bool get isWeb => kIsWeb;

  /// Determine if the current platform is iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  /// Determine if the current platform is Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid;
    } catch (e) {
      return false;
    }
  }

  /// Determine device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Determine orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get appropriate padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case DeviceType.tablet:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case DeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    }
  }

  /// Get appropriate font size based on device type
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return baseFontSize * 1.1;
      case DeviceType.desktop:
        return baseFontSize * 1.2;
    }
  }

  /// Get appropriate icon size based on device type
  static double getResponsiveIconSize(
    BuildContext context,
    double baseIconSize,
  ) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseIconSize;
      case DeviceType.tablet:
        return baseIconSize * 1.2;
      case DeviceType.desktop:
        return baseIconSize * 1.4;
    }
  }

  /// Get appropriate card elevation based on platform
  static double getCardElevation() {
    if (isWeb) return 2;
    if (isIOS) return 1;
    return 2; // Android and others
  }

  /// Get safe area padding that works across platforms
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Calculate a responsive width percentage
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  /// Calculate a responsive height percentage
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  /// Get appropriate border radius based on platform
  static double getBorderRadius() {
    if (isIOS) return 12;
    return 8; // Android, Web and others
  }

  /// Determine if the device should show desktop UI
  static bool shouldUseDesktopUI(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint;
  }
}

/// Enum representing different device types based on screen size
enum DeviceType { mobile, tablet, desktop }

/// A responsive widget that renders different widgets based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext, DeviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    return builder(context, deviceType);
  }
}
