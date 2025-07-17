// lib/app/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  // Font family - using Google Fonts for consistency
  static String get fontFamily => GoogleFonts.poppins().fontFamily ?? 'Poppins';

  // Heading Styles
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle get h4 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get h5 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static TextStyle get h6 => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.5,
  );

  // Body Text Styles
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
    height: 1.7,
  );

  // Label Styles
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.5,
  );

  // App-Specific Styles
  static TextStyle get appBarTitle => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.2,
  );

  static TextStyle get deviceName => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static TextStyle get deviceStatus => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
    height: 1.2,
  );

  static TextStyle get roomTitle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle get cardTitle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static TextStyle get cardSubtitle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle get buttonText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get tabText => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.8,
    height: 1.2,
  );

  static TextStyle get drawerItemText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.3,
  );

  static TextStyle get inputText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle get hintText => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle get timerText => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextStyle get scheduleText => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static TextStyle get irButtonText => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // Status Text Styles
  static TextStyle get onlineStatus => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle get offlineStatus => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Notification Styles
  static TextStyle get notificationTitle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.3,
  );

  static TextStyle get notificationBody => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
    height: 1.4,
  );

  static TextStyle get notificationTime => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
    height: 1.3,
  );
}

// Text Style Extensions for Color Theming
extension AppTextStylesExtension on TextStyle {
  TextStyle withPrimaryColor(Color color) => copyWith(color: color);
  TextStyle withSecondaryColor(Color color) => copyWith(color: color);
  TextStyle withSuccessColor(Color color) => copyWith(color: color);
  TextStyle withWarningColor(Color color) => copyWith(color: color);
  TextStyle withErrorColor(Color color) => copyWith(color: color);
  TextStyle withOpacity(double opacity) =>
      copyWith(color: color?.withOpacity(opacity));
}
