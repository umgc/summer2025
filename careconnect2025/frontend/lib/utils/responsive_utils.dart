import 'package:flutter/material.dart';

/// ResponsiveUtils provides centralized methods and constants for responsive design
/// throughout the application. This ensures consistent behavior across all screens.
class ResponsiveUtils {
  /// Screen width breakpoints
  static const double mobileBreakpoint = 600; // Max width for mobile view
  static const double tabletBreakpoint = 900; // Max width for tablet view
  static const double desktopBreakpoint = 1200; // Min width for desktop view
  static const double largeDesktopBreakpoint =
      1440; // Min width for large desktop view

  /// Maximum content width for large screens
  static const double maxContentWidth = 1400;

  /// Get the current device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceType.desktop;
    } else {
      return DeviceType.largeDesktop;
    }
  }

  /// Calculate horizontal margin based on screen width
  static double getHorizontalMargin(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return 16.0; // Standard margin for mobile
    } else if (width < tabletBreakpoint) {
      return width * 0.05; // 5% margin for tablet
    } else if (width < largeDesktopBreakpoint) {
      return width * 0.08; // 8% margin for desktop
    } else {
      // For very large screens, center the content
      return (width - maxContentWidth) / 2 > 0
          ? (width - maxContentWidth) / 2
          : width * 0.1;
    }
  }

  /// Calculate card width based on screen size
  static double getCardWidth(
    BuildContext context, {
    double defaultWidth = 400,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return MediaQuery.of(context).size.width * 0.85;
      case DeviceType.tablet:
        return defaultWidth;
      case DeviceType.desktop:
        return defaultWidth;
      case DeviceType.largeDesktop:
        return defaultWidth;
    }
  }

  /// Get number of grid columns based on screen width
  static int getGridColumnCount(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
      case DeviceType.largeDesktop:
        return 4;
    }
  }

  /// Get responsive page padding
  static EdgeInsets getPagePadding(BuildContext context) {
    final horizontalMargin = getHorizontalMargin(context);
    final deviceType = getDeviceType(context);

    double verticalPadding = 16.0;
    if (deviceType == DeviceType.desktop ||
        deviceType == DeviceType.largeDesktop) {
      verticalPadding = 24.0;
    }

    return EdgeInsets.symmetric(
      horizontal: horizontalMargin,
      vertical: verticalPadding,
    );
  }

  /// Determine if a responsive container should be constrained
  static bool shouldConstrainWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > desktopBreakpoint;
  }

  /// Get constrained width container
  static Widget constrainedWidthContainer({
    required BuildContext context,
    required Widget child,
  }) {
    if (shouldConstrainWidth(context)) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: child,
        ),
      );
    } else {
      return child;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    double baseFontSize = 14.0,
    double scaleFactor = 0.2,
  }) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return baseFontSize;
      case DeviceType.tablet:
        return baseFontSize * (1 + scaleFactor * 0.5);
      case DeviceType.desktop:
        return baseFontSize * (1 + scaleFactor);
      case DeviceType.largeDesktop:
        return baseFontSize * (1 + scaleFactor * 1.5);
    }
  }
}

/// Enum representing device types for responsive design
enum DeviceType { mobile, tablet, desktop, largeDesktop }

/// Extension on BuildContext to easily access responsive utilities
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  double get horizontalMargin => ResponsiveUtils.getHorizontalMargin(this);
  int get gridColumns => ResponsiveUtils.getGridColumnCount(this);
  EdgeInsets get responsivePadding => ResponsiveUtils.getPagePadding(this);
  bool get shouldConstrainWidth => ResponsiveUtils.shouldConstrainWidth(this);

  // Screen size checks for quick conditional logic
  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isLargeDesktop => deviceType == DeviceType.largeDesktop;

  // Helper for determining if we're on a mobile-sized device
  bool get isMobileOrTablet => isMobile || isTablet;

  // Helper for determining if we're on a desktop-sized device
  bool get isDesktopOrLarger => isDesktop || isLargeDesktop;

  // Responsive value selection based on device type
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? mobile;
    }
  }

  Widget responsiveContainer({required Widget child}) {
    return ResponsiveUtils.constrainedWidthContainer(
      context: this,
      child: child,
    );
  }

  double responsiveFontSize({double base = 14.0, double scaleFactor = 0.2}) {
    return ResponsiveUtils.getResponsiveFontSize(
      this,
      baseFontSize: base,
      scaleFactor: scaleFactor,
    );
  }
}
