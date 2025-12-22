import 'package:flutter/material.dart';

/// Central utility class for managing app-wide styles, colors, and constants
class AppStyles {
  // ============================================================================
  // COLOR PALETTE - Following the Promise wireframe (Purple/White/Dark theme)
  // ============================================================================

  // Primary Purple Colors
  static const Color primaryPurple = Color(0xFF7C3AED); // Vibrant Purple
  static const Color primaryPurpleLight = Color(0xFFA78BFA); // Light Purple
  static const Color primaryPurpleDark = Color(0xFF5B21B6); // Dark Purple

  // Secondary Colors
  static const Color accentPurple = Color(0xFFEC4899); // Pink accent
  static const Color accentBlue = Color(0xFF3B82F6); // Blue accent

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearWhite = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFE5E7EB);
  static const Color mediumGray = Color(0xFF9CA3AF);
  static const Color darkGray = Color(0xFF4B5563);
  static const Color darkBackground = Color(0xFF1F2937);

  // System Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF0EA5E9);

  // Additional Colors
  static const Color accentPink = Color(0xFFEC4899); // Pink accent (alias)
  static const Color dangerRed = Color(
    0xFFDC2626,
  ); // Darker red for critical actions

  // ============================================================================
  // TEXT STYLES - Using Inter font family
  // ============================================================================

  static const String fontFamily = 'Inter';

  // Heading Styles
  static const TextStyle headingXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: primaryPurpleDark,
    letterSpacing: -0.5,
  );

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: primaryPurpleDark,
    letterSpacing: -0.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: primaryPurpleDark,
    letterSpacing: -0.2,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryPurpleDark,
    letterSpacing: -0.1,
  );

  // Body Styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: darkGray,
    letterSpacing: 0,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: darkGray,
    letterSpacing: 0,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: mediumGray,
    letterSpacing: 0.5,
  );

  // Label Styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryPurple,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: primaryPurple,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: mediumGray,
    letterSpacing: 0.5,
  );

  // Error Text Style
  static const TextStyle errorText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: errorRed,
    letterSpacing: 0,
  );

  // ============================================================================
  // SPACING & PADDING CONSTANTS
  // ============================================================================

  // Standard Padding Values
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double paddingXXLarge = 48.0;

  // Standard Edge Insets
  static const EdgeInsets edgeInsetXSmall = EdgeInsets.all(paddingXSmall);
  static const EdgeInsets edgeInsetSmall = EdgeInsets.all(paddingSmall);
  static const EdgeInsets edgeInsetMedium = EdgeInsets.all(paddingMedium);
  static const EdgeInsets edgeInsetLarge = EdgeInsets.all(paddingLarge);
  static const EdgeInsets edgeInsetXLarge = EdgeInsets.all(paddingXLarge);

  // Symmetric Edge Insets (Horizontal/Vertical)
  static const EdgeInsets edgeInsetSymmetricHLarge = EdgeInsets.symmetric(
    horizontal: paddingLarge,
  );
  static const EdgeInsets edgeInsetSymmetricHMedium = EdgeInsets.symmetric(
    horizontal: paddingMedium,
  );
  static const EdgeInsets edgeInsetSymmetricVLarge = EdgeInsets.symmetric(
    vertical: paddingLarge,
  );
  static const EdgeInsets edgeInsetSymmetricVMedium = EdgeInsets.symmetric(
    vertical: paddingMedium,
  );

  // ============================================================================
  // BORDER RADIUS CONSTANTS
  // ============================================================================

  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;

  static const BorderRadius borderRadiusSmallAll = BorderRadius.all(
    Radius.circular(borderRadiusSmall),
  );
  static const BorderRadius borderRadiusMediumAll = BorderRadius.all(
    Radius.circular(borderRadiusMedium),
  );
  static const BorderRadius borderRadiusLargeAll = BorderRadius.all(
    Radius.circular(borderRadiusLarge),
  );
  static const BorderRadius borderRadiusXLargeAll = BorderRadius.all(
    Radius.circular(borderRadiusXLarge),
  );

  // ============================================================================
  // BOX SHADOW CONSTANTS
  // ============================================================================

  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color.fromARGB(25, 0, 0, 0),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color.fromARGB(40, 0, 0, 0),
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color.fromARGB(50, 0, 0, 0),
      offset: Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
  ];

  // ============================================================================
  // DURATION CONSTANTS
  // ============================================================================

  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 400);
  static const Duration animationDurationLong = Duration(milliseconds: 600);

  // ============================================================================
  // ICON SIZE CONSTANTS
  // ============================================================================

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // ============================================================================
  // BUTTON SIZE CONSTANTS
  // ============================================================================

  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  // ============================================================================
  // INPUT FIELD STYLE CONSTANTS
  // ============================================================================

  static const double inputFieldHeight = 48.0;
  static const double inputFieldBorderWidth = 1.5;

  // ============================================================================
  // CARD STYLE CONSTANTS
  // ============================================================================

  static const double cardElevation = 2.0;
  static const double cardBorderWidth = 1.0;

  // ============================================================================
  // UTILITY METHODS FOR RESPONSIVE DESIGN
  // ============================================================================

  /// Get padding value based on screen width for responsive design
  static double getResponsivePadding(double screenWidth) {
    if (screenWidth < 600) {
      return paddingMedium;
    } else if (screenWidth < 900) {
      return paddingLarge;
    } else {
      return paddingXLarge;
    }
  }

  /// Get font size based on screen width for responsive design
  static double getResponsiveFontSize(double baseSize, double screenWidth) {
    if (screenWidth < 600) {
      return baseSize * 0.9;
    } else if (screenWidth < 900) {
      return baseSize;
    } else {
      return baseSize * 1.1;
    }
  }

  /// Build theme data for the app
  static ThemeData buildAppTheme({required bool isDarkMode}) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,

      scaffoldBackgroundColor: isDarkMode ? darkBackground : white,

      canvasColor: isDarkMode ? darkBackground : white,

      cardColor: isDarkMode ? darkGray : white,

      dialogBackgroundColor: isDarkMode ? darkGray : white,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryPurple,
        secondary: accentPurple,
        tertiary: accentBlue,
        surface: isDarkMode ? darkBackground : white,
        surfaceContainerHighest: isDarkMode ? darkGray : nearWhite,
        error: errorRed,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? primaryPurpleDark : primaryPurple,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDarkMode ? darkBackground : white,
        selectedItemColor: primaryPurple,
        unselectedItemColor: mediumGray,
        elevation: 8.0,
        type: BottomNavigationBarType.fixed,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? darkGray : nearWhite,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: 12,
        ),

        border: OutlineInputBorder(
          borderRadius: borderRadiusSmallAll,
          borderSide: const BorderSide(
            color: lightGray,
            width: inputFieldBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadiusSmallAll,
          borderSide: const BorderSide(
            color: lightGray,
            width: inputFieldBorderWidth,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: borderRadiusSmallAll,
          borderSide: BorderSide(
            color: primaryPurple,
            width: inputFieldBorderWidth,
          ),
        ),

        labelStyle: TextStyle(color: isDarkMode ? nearWhite : mediumGray),

        hintStyle: TextStyle(color: isDarkMode ? mediumGray : mediumGray),

        floatingLabelStyle: TextStyle(
          color: isDarkMode ? primaryPurpleLight : primaryPurple,
        ),
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primaryPurple,
        selectionColor: primaryPurpleLight.withOpacity(0.3),
        selectionHandleColor: primaryPurple,
      ),

      cardTheme: CardThemeData(
        color: isDarkMode ? darkGray : white,
        elevation: cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadiusMediumAll,
          side: const BorderSide(color: lightGray, width: cardBorderWidth),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: headingXLarge.copyWith(
          color: isDarkMode ? white : primaryPurpleDark,
        ),
        displayMedium: headingLarge.copyWith(
          color: isDarkMode ? white : primaryPurpleDark,
        ),
        displaySmall: headingMedium.copyWith(
          color: isDarkMode ? white : primaryPurpleDark,
        ),
        headlineMedium: headingSmall.copyWith(
          color: isDarkMode ? white : primaryPurpleDark,
        ),

        titleLarge: bodyLarge.copyWith(
          color: isDarkMode ? nearWhite : darkGray,
        ),
        titleMedium: bodyMedium.copyWith(
          color: isDarkMode ? nearWhite : darkGray,
        ),
        titleSmall: bodySmall.copyWith(
          color: isDarkMode ? mediumGray : mediumGray,
        ),

        bodyLarge: bodyLarge.copyWith(color: isDarkMode ? nearWhite : darkGray),
        bodyMedium: bodyMedium.copyWith(
          color: isDarkMode ? nearWhite : darkGray,
        ),
        bodySmall: bodySmall.copyWith(
          color: isDarkMode ? mediumGray : mediumGray,
        ),

        labelLarge: labelLarge.copyWith(
          color: isDarkMode ? primaryPurpleLight : primaryPurple,
        ),
        labelMedium: labelMedium.copyWith(
          color: isDarkMode ? primaryPurpleLight : primaryPurple,
        ),
      ),
    );
  }
}
