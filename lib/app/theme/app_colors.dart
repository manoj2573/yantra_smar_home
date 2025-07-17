// lib/app/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Orange Theme (Default - your current theme)
  static const orangeTheme = AppColorScheme(
    primary: Color(0xFFD88129),
    primaryDark: Color(0xFFBF6B1F),
    secondary: Color(0xFFFFE29E),
    accent: Color(0xFFF4B942),
    background: Color(0xFFF6F6F6),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    success: Color(0xFFA5D6A7),
    warning: Color(0xFFFFB74D),
    error: Color(0xFFF7505F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2C2C2C),
    onBackground: Color(0xFF2C2C2C),
    onSurface: Color(0xFF2C2C2C),
    divider: Color(0xFF789CAC),
    drawerBackground: Color(0xFFF0C87E),
    tileBackground: Color(0xFFFFECB3),
    gradient: LinearGradient(
      colors: [Color(0xFFFFE29E), Color(0xFFD88129)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Blue Theme
  static const blueTheme = AppColorScheme(
    primary: Color(0xFF1976D2),
    primaryDark: Color(0xFF1565C0),
    secondary: Color(0xFFBBDEFB),
    accent: Color(0xFF42A5F5),
    background: Color(0xFFF3F8FF),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2C2C2C),
    onBackground: Color(0xFF2C2C2C),
    onSurface: Color(0xFF2C2C2C),
    divider: Color(0xFF90CAF9),
    drawerBackground: Color(0xFFE3F2FD),
    tileBackground: Color(0xFFE1F5FE),
    gradient: LinearGradient(
      colors: [Color(0xFFBBDEFB), Color(0xFF1976D2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Green Theme
  static const greenTheme = AppColorScheme(
    primary: Color(0xFF388E3C),
    primaryDark: Color(0xFF2E7D32),
    secondary: Color(0xFFC8E6C9),
    accent: Color(0xFF66BB6A),
    background: Color(0xFFF1F8E9),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2C2C2C),
    onBackground: Color(0xFF2C2C2C),
    onSurface: Color(0xFF2C2C2C),
    divider: Color(0xFFA5D6A7),
    drawerBackground: Color(0xFFE8F5E8),
    tileBackground: Color(0xFFE0F2F1),
    gradient: LinearGradient(
      colors: [Color(0xFFC8E6C9), Color(0xFF388E3C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Purple Theme
  static const purpleTheme = AppColorScheme(
    primary: Color(0xFF7B1FA2),
    primaryDark: Color(0xFF6A1B9A),
    secondary: Color(0xFFE1BEE7),
    accent: Color(0xFFAB47BC),
    background: Color(0xFFF8F4FF),
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFF2C2C2C),
    onBackground: Color(0xFF2C2C2C),
    onSurface: Color(0xFF2C2C2C),
    divider: Color(0xFFCE93D8),
    drawerBackground: Color(0xFFF3E5F5),
    tileBackground: Color(0xFFEDE7F6),
    gradient: LinearGradient(
      colors: [Color(0xFFE1BEE7), Color(0xFF7B1FA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Dark Theme
  static const darkTheme = AppColorScheme(
    primary: Color(0xFFFF9800),
    primaryDark: Color(0xFFF57C00),
    secondary: Color(0xFF37474F),
    accent: Color(0xFFFFB74D),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    cardBackground: Color(0xFF2C2C2C),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFFFFFFFF),
    onBackground: Color(0xFFFFFFFF),
    onSurface: Color(0xFFFFFFFF),
    divider: Color(0xFF424242),
    drawerBackground: Color(0xFF1E1E1E),
    tileBackground: Color(0xFF2C2C2C),
    gradient: LinearGradient(
      colors: [Color(0xFF37474F), Color(0xFF121212)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // Status Colors (consistent across all themes)
  static const deviceOnColor = Color(0xFF4CAF50);
  static const deviceOffColor = Color(0xFF9E9E9E);
  static const onlineColor = Color(0xFF4CAF50);
  static const offlineColor = Color(0xFFF44336);
  static const learningColor = Color(0xFF2196F3);
  static const scheduleActiveColor = Color(0xFF8BC34A);
  static const timerActiveColor = Color(0xFFFF5722);
}

class AppColorScheme {
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color success;
  final Color warning;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final Color divider;
  final Color drawerBackground;
  final Color tileBackground;
  final Gradient gradient;

  const AppColorScheme({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.success,
    required this.warning,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.divider,
    required this.drawerBackground,
    required this.tileBackground,
    required this.gradient,
  });
}

// Theme Extensions
extension AppColorSchemeExtension on AppColorScheme {
  // Device state colors with opacity variations
  Color get deviceOnPrimary => primary.withOpacity(0.8);
  Color get deviceOnSecondary => success.withOpacity(0.3);
  Color get deviceOffPrimary => onSurface.withOpacity(0.3);
  Color get deviceOffSecondary => surface;

  // Glassmorphism colors
  Color get glassBackground => surface.withOpacity(0.8);
  Color get glassBorder => onSurface.withOpacity(0.1);

  // Elevation colors
  Color get elevation1 => surface;
  Color get elevation2 =>
      Color.alphaBlend(onSurface.withOpacity(0.05), surface);
  Color get elevation3 =>
      Color.alphaBlend(onSurface.withOpacity(0.08), surface);

  // Shimmer colors
  Color get shimmerBase => onSurface.withOpacity(0.1);
  Color get shimmerHighlight => onSurface.withOpacity(0.3);
}
