import 'package:flutter/material.dart';

/// Centralized theme configuration for the CareConnect app
/// This ensures consistent colors, typography, and component styles across the app
class AppTheme {
  // Light Theme Colors
  // Main app colors
  static const Color primaryDark = Color(0xFF14366E); // UX provided blue
  static const Color primary = Color(0xFF14366E); // UX provided blue
  static const Color primaryLight = Color(
    0xFF325694,
  ); // Lighter shade of UX blue
  static const Color accent = Color(0xFF325694); // Lighter shade of UX blue

  // Status colors
  static const Color success = Color(0xFF43A047); // green.shade600
  static const Color warning = Color(0xFFFFA000); // amber.shade700
  static const Color error = Color(0xFFE53935); // red.shade600
  static const Color info = Color(0xFF325694); // lighter shade of our UX blue

  // Text colors
  static const Color textPrimary = Color(0xFF212121); // grey.shade900
  static const Color textSecondary = Color(0xFF757575); // grey.shade600
  static const Color textLight = Color(0xFFFFFFFF); // white

  // Background colors
  static const Color backgroundPrimary = Color(0xFFFFFFFF); // white
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // grey.shade100
  static const Color cardBackground = Color(0xFFFFFFFF); // white

  // Border colors
  static const Color borderColor = Color(0xFFE0E0E0); // grey.shade300

  // Dark Theme Colors
  // Main app colors
  static const Color primaryDarkThemeDark = Color(
    0xFF5C80BE,
  ); // Lighter version of UX blue for dark theme
  static const Color primaryDarkTheme = Color(
    0xFF2D5196,
  ); // Medium version of UX blue for dark theme
  static const Color primaryDarkThemeLight = Color(
    0xFF5C80BE,
  ); // Lighter shade for dark theme
  static const Color accentDarkTheme = Color(
    0xFF5C80BE,
  ); // Accent for dark theme

  // Status colors - slightly lighter for dark theme
  static const Color successDarkTheme = Color(0xFF66BB6A); // green.shade400
  static const Color warningDarkTheme = Color(0xFFFFB74D); // amber.shade300
  static const Color errorDarkTheme = Color(0xFFEF5350); // red.shade400
  static const Color infoDarkTheme = Color(
    0xFF5C80BE,
  ); // lighter shade of our UX blue for dark theme

  // Text colors for dark theme
  static const Color textPrimaryDarkTheme = Color(0xFFF5F5F5); // grey.shade100
  static const Color textSecondaryDarkTheme = Color(
    0xFFBDBDBD,
  ); // grey.shade400
  static const Color textDarkThemeDark = Color(0xFF000000); // black

  // Background colors for dark theme
  static const Color backgroundPrimaryDarkTheme = Color(
    0xFF121212,
  ); // Material dark background
  static const Color backgroundSecondaryDarkTheme = Color(
    0xFF1E1E1E,
  ); // Slightly lighter
  static const Color cardBackgroundDarkTheme = Color(
    0xFF242424,
  ); // Card background

  // Border colors for dark theme
  static const Color borderColorDarkTheme = Color(0xFF424242); // grey.shade800

  // Typography styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textLight,
  );

  // Button styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primary, // UX-specified color #14366E
    foregroundColor: textLight,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: buttonText,
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: primary, // UX-specified color #14366E
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: primary, width: 1.5),
    ),
    textStyle: buttonText,
  );

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primary, // UX-specified color #14366E
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  );

  static ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: error,
    foregroundColor: textLight,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: buttonText,
  );

  // Card styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: borderColor),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Input decoration
  static InputDecoration inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Generate theme data for MaterialApp
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        error: error,
        background: backgroundPrimary,
        surface: cardBackground,
        onPrimary: textLight,
        onSecondary: textLight,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onError: textLight,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: primary, // Using our UX blue color
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: cardBackground,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      textButtonTheme: TextButtonThemeData(style: textButtonStyle),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        fillColor: backgroundPrimary,
        filled: true,
      ),
      textTheme: const TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ),
      dividerTheme: const DividerThemeData(thickness: 1, color: borderColor),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textSecondary.withOpacity(0.3);
          }
          return primary;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundPrimary,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
      ),
      useMaterial3: true,
    );
  }

  // Generate dark theme data for MaterialApp
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: primaryDarkTheme,
      colorScheme: const ColorScheme.dark(
        primary: primaryDarkTheme,
        secondary: accentDarkTheme,
        error: errorDarkTheme,
        background: backgroundPrimaryDarkTheme,
        surface: cardBackgroundDarkTheme,
        onPrimary: textDarkThemeDark,
        onSecondary: textDarkThemeDark,
        onBackground: textPrimaryDarkTheme,
        onSurface: textPrimaryDarkTheme,
        onError: textDarkThemeDark,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: backgroundPrimaryDarkTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkTheme, // Using our primary dark theme color
        foregroundColor: textDarkThemeDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDarkThemeDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textDarkThemeDark),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: cardBackgroundDarkTheme,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDarkTheme,
          foregroundColor: textDarkThemeDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDarkThemeLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColorDarkTheme),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryDarkThemeLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        fillColor: backgroundSecondaryDarkTheme,
        filled: true,
        labelStyle: const TextStyle(color: textSecondaryDarkTheme),
        hintStyle: const TextStyle(color: textSecondaryDarkTheme),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryDarkTheme,
        ),
        displayMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryDarkTheme,
        ),
        displaySmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimaryDarkTheme,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimaryDarkTheme),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimaryDarkTheme),
        bodySmall: TextStyle(fontSize: 12, color: textSecondaryDarkTheme),
      ),
      dividerTheme: const DividerThemeData(
        thickness: 1,
        color: borderColorDarkTheme,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return textSecondaryDarkTheme.withOpacity(0.3);
          }
          return primaryDarkTheme;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      iconTheme: const IconThemeData(color: textPrimaryDarkTheme),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundPrimaryDarkTheme,
        selectedItemColor: primaryDarkThemeLight,
        unselectedItemColor: textSecondaryDarkTheme,
      ),
      dialogBackgroundColor: cardBackgroundDarkTheme,
      useMaterial3: true,
    );
  }
}
