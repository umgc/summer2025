import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_theme.dart';
import '../utils/responsive_utils.dart';

/// A utility class for accessing consistent colors throughout the application
/// This helps maintain a unified color scheme and allows for easy updates
/// Now with platform-specific color adjustments for better rendering across web, iOS, and Android
class ColorUtils {
  // Primary theme colors
  static Color get primary => AppTheme.primary;
  static Color get primaryDark => AppTheme.primaryDark;
  static Color get primaryLight => AppTheme.primaryLight;
  static Color get accent => AppTheme.accent;

  // Status colors
  static Color get success => AppTheme.success;
  static Color get warning => AppTheme.warning;
  static Color get error => AppTheme.error;
  static Color get info => AppTheme.info;

  // Text colors
  static Color get textPrimary => AppTheme.textPrimary;
  static Color get textSecondary => AppTheme.textSecondary;
  static Color get textLight => AppTheme.textLight;

  // Background colors
  static Color get backgroundPrimary => AppTheme.backgroundPrimary;
  static Color get backgroundSecondary => AppTheme.backgroundSecondary;
  static Color get cardBackground => AppTheme.cardBackground;

  // Helper methods for creating color variations
  static Color getSuccessWithOpacity(double opacity) =>
      AppTheme.success.withOpacity(opacity);
  static Color getSuccessLight() =>
      const Color(0xFFE8F5E9); // green.shade50 equivalent
  static Color getSuccessLighter() =>
      const Color(0xFFC8E6C9); // green.shade100 equivalent

  static Color getWarningWithOpacity(double opacity) =>
      AppTheme.warning.withOpacity(opacity);
  static Color getWarningLight() =>
      const Color(0xFFFFF8E1); // amber.shade50 equivalent
  static Color getWarningLighter() =>
      const Color(0xFFFFECB3); // amber.shade100 equivalent

  static Color getErrorWithOpacity(double opacity) =>
      AppTheme.error.withOpacity(opacity);
  static Color getErrorLight() =>
      const Color(0xFFFFEBEE); // red.shade50 equivalent
  static Color getErrorLighter() =>
      const Color(0xFFFFCDD2); // red.shade100 equivalent

  static Color getInfoWithOpacity(double opacity) =>
      AppTheme.info.withOpacity(opacity);
  static Color getInfoLight() =>
      const Color(0xFFE3F2FD); // blue.shade50 equivalent
  static Color getInfoLighter() =>
      const Color(0xFFBBDEFB); // blue.shade100 equivalent

  static Color getPrimaryWithOpacity(double opacity) =>
      AppTheme.primary.withOpacity(opacity);
  static Color getPrimaryLight() => AppTheme.primaryLight;
  static Color getPrimaryLighter() =>
      const Color(0xFFE3F2FD); // blue.shade50 equivalent

  // Consistent gradient generators
  static LinearGradient getPrimaryGradient() => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppTheme.primary, AppTheme.primaryDark],
  );

  static LinearGradient getSuccessGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [getSuccessLight(), getSuccessLighter()],
  );

  static LinearGradient getInfoGradient() => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [getInfoLight(), getInfoLighter()],
  );

  // Chart colors - using more accessible blue tones instead of green
  static Color getChartPrimary() => AppTheme.primary;
  static Color getChartSecondary() => AppTheme.info;
  static Color getChartTertiary() => const Color(0xFF5C6BC0); // indigo.shade400
  static Color getChartQuaternary() => const Color(0xFF26A69A); // teal.shade500

  // Platform-specific color utilities
  static Color getCardBackgroundForPlatform(BuildContext context) {
    // iOS uses slightly off-white for cards
    if (ResponsiveUtils.isIOS) {
      return const Color(0xFFF8F8F8);
    }
    // Android and Web use pure white
    return AppTheme.cardBackground;
  }

  // Get elevated button color with platform-specific adjustments
  static Color getElevatedButtonColor(BuildContext context) {
    if (kIsWeb) {
      // Web uses slightly darker primary for better contrast
      return AppTheme.primaryDark;
    }
    return AppTheme.primary;
  }

  // Get shadow color based on platform
  static Color getShadowColor(BuildContext context) {
    if (ResponsiveUtils.isIOS) {
      return Colors.black.withOpacity(0.1); // iOS uses lighter shadows
    } else if (ResponsiveUtils.isAndroid) {
      return Colors.black.withOpacity(0.2); // Android uses medium shadows
    }
    return Colors.black.withOpacity(0.15); // Web uses medium-light shadows
  }
}
