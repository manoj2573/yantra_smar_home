// lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

enum AppThemeType { orange, blue, green, purple, dark }

class AppTheme {
  static AppColorScheme _currentColorScheme = AppColors.orangeTheme;
  static AppThemeType _currentThemeType = AppThemeType.orange;

  // Getters
  static AppColorScheme get colors => _currentColorScheme;
  static AppThemeType get currentThemeType => _currentThemeType;

  // Set theme
  static void setTheme(AppThemeType themeType) {
    _currentThemeType = themeType;
    switch (themeType) {
      case AppThemeType.orange:
        _currentColorScheme = AppColors.orangeTheme;
        break;
      case AppThemeType.blue:
        _currentColorScheme = AppColors.blueTheme;
        break;
      case AppThemeType.green:
        _currentColorScheme = AppColors.greenTheme;
        break;
      case AppThemeType.purple:
        _currentColorScheme = AppColors.purpleTheme;
        break;
      case AppThemeType.dark:
        _currentColorScheme = AppColors.darkTheme;
        break;
    }
  }

  // Light Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: _currentColorScheme.primary,
      onPrimary: _currentColorScheme.onPrimary,
      secondary: _currentColorScheme.secondary,
      onSecondary: _currentColorScheme.onSecondary,
      surface: _currentColorScheme.surface,
      onSurface: _currentColorScheme.onSurface,
      error: _currentColorScheme.error,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: Colors.transparent,
      foregroundColor: _currentColorScheme.onBackground,
      titleTextStyle: AppTextStyles.appBarTitle.withPrimaryColor(
        _currentColorScheme.onBackground,
      ),
      iconTheme: IconThemeData(color: _currentColorScheme.onBackground),
      actionsIconTheme: IconThemeData(color: _currentColorScheme.onBackground),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _currentThemeType == AppThemeType.dark
                ? Brightness.light
                : Brightness.dark,
        statusBarBrightness:
            _currentThemeType == AppThemeType.dark
                ? Brightness.dark
                : Brightness.light,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: AppDimensions.cardElevation,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLG),
      color: _currentColorScheme.cardBackground,
      shadowColor: _currentColorScheme.onSurface.withOpacity(0.1),
      margin: AppDimensions.paddingSM,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentColorScheme.primary,
        foregroundColor: _currentColorScheme.onPrimary,
        elevation: AppDimensions.cardElevation,
        padding: AppDimensions.paddingMD,
        minimumSize: Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMD,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _currentColorScheme.primary,
        side: BorderSide(color: _currentColorScheme.primary),
        padding: AppDimensions.paddingMD,
        minimumSize: Size(
          AppDimensions.buttonMinWidth,
          AppDimensions.buttonHeight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMD,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _currentColorScheme.primary,
        padding: AppDimensions.paddingMD,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMD,
        ),
        textStyle: AppTextStyles.buttonText,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _currentColorScheme.primary,
      foregroundColor: _currentColorScheme.onPrimary,
      elevation: AppDimensions.cardMaxElevation,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _currentColorScheme.primary;
        }
        return _currentColorScheme.onSurface.withOpacity(0.6);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _currentColorScheme.primary.withOpacity(0.3);
        }
        return _currentColorScheme.onSurface.withOpacity(0.2);
      }),
    ),

    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: _currentColorScheme.primary,
      inactiveTrackColor: _currentColorScheme.primary.withOpacity(0.3),
      thumbColor: _currentColorScheme.primary,
      overlayColor: _currentColorScheme.primary.withOpacity(0.2),
      trackHeight: AppDimensions.sliderTrackHeight,
      thumbShape: RoundSliderThumbShape(
        enabledThumbRadius: AppDimensions.sliderThumbRadius,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _currentColorScheme.surface,
      border: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: BorderSide(
          color: _currentColorScheme.onSurface.withOpacity(0.3),
          width: AppDimensions.inputFieldBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: BorderSide(
          color: _currentColorScheme.onSurface.withOpacity(0.3),
          width: AppDimensions.inputFieldBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: BorderSide(
          color: _currentColorScheme.primary,
          width: AppDimensions.inputFieldFocusedBorderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: BorderSide(
          color: _currentColorScheme.error,
          width: AppDimensions.inputFieldBorderWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppDimensions.borderRadiusMD,
        borderSide: BorderSide(
          color: _currentColorScheme.error,
          width: AppDimensions.inputFieldFocusedBorderWidth,
        ),
      ),
      contentPadding: AppDimensions.paddingMD,
      hintStyle: AppTextStyles.hintText.withOpacity(0.6),
      labelStyle: AppTextStyles.labelMedium,
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(_currentColorScheme.onPrimary),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _currentColorScheme.primary;
        }
        return Colors.transparent;
      }),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXS),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _currentColorScheme.primary;
        }
        return _currentColorScheme.onSurface.withOpacity(0.6);
      }),
    ),

    // Drawer Theme
    drawerTheme: DrawerThemeData(
      backgroundColor: _currentColorScheme.drawerBackground,
      elevation: AppDimensions.cardMaxElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppDimensions.radiusLG),
          bottomRight: Radius.circular(AppDimensions.radiusLG),
        ),
      ),
      width: AppDimensions.drawerWidth,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: AppDimensions.paddingMD,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMD),
      tileColor: _currentColorScheme.tileBackground,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: _currentColorScheme.divider,
      thickness: AppDimensions.dividerThickness,
      space: AppDimensions.md,
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: _currentColorScheme.onSurface,
      size: AppDimensions.iconMD,
    ),

    // Primary Icon Theme
    primaryIconTheme: IconThemeData(
      color: _currentColorScheme.primary,
      size: AppDimensions.iconMD,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _currentColorScheme.surface,
      selectedItemColor: _currentColorScheme.primary,
      unselectedItemColor: _currentColorScheme.onSurface.withOpacity(0.6),
      elevation: AppDimensions.cardMaxElevation,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: AppTextStyles.tabText,
      unselectedLabelStyle: AppTextStyles.tabText,
    ),

    // Tab Bar Theme
    tabBarTheme: TabBarThemeData(
      labelColor: _currentColorScheme.primary,
      unselectedLabelColor: _currentColorScheme.onSurface.withOpacity(0.6),
      labelStyle: AppTextStyles.tabText,
      unselectedLabelStyle: AppTextStyles.tabText,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: _currentColorScheme.primary, width: 2),
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: _currentColorScheme.secondary,
      selectedColor: _currentColorScheme.primary,
      deleteIconColor: _currentColorScheme.onSurface,
      labelStyle: AppTextStyles.labelMedium,
      padding: AppDimensions.paddingSM,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusXL),
    ),

    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _currentColorScheme.onSurface,
      contentTextStyle: AppTextStyles.bodyMedium.withPrimaryColor(
        _currentColorScheme.surface,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusMD),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: _currentColorScheme.surface,
      elevation: AppDimensions.cardMaxElevation,
      shape: RoundedRectangleBorder(borderRadius: AppDimensions.borderRadiusLG),
      titleTextStyle: AppTextStyles.h5.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      contentTextStyle: AppTextStyles.bodyMedium.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _currentColorScheme.primary,
      linearTrackColor: _currentColorScheme.primary.withOpacity(0.3),
      circularTrackColor: _currentColorScheme.primary.withOpacity(0.3),
    ),

    // Text Theme
    textTheme: TextTheme(
      headlineLarge: AppTextStyles.h1.withPrimaryColor(
        _currentColorScheme.onBackground,
      ),
      headlineMedium: AppTextStyles.h2.withPrimaryColor(
        _currentColorScheme.onBackground,
      ),
      headlineSmall: AppTextStyles.h3.withPrimaryColor(
        _currentColorScheme.onBackground,
      ),
      titleLarge: AppTextStyles.h4.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      titleMedium: AppTextStyles.h5.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      titleSmall: AppTextStyles.h6.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      bodyLarge: AppTextStyles.bodyLarge.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      bodyMedium: AppTextStyles.bodyMedium.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      bodySmall: AppTextStyles.bodySmall.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      labelLarge: AppTextStyles.labelLarge.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      labelMedium: AppTextStyles.labelMedium.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
      labelSmall: AppTextStyles.labelSmall.withPrimaryColor(
        _currentColorScheme.onSurface,
      ),
    ),
  );

  // Dark Theme Data (for dark theme)
  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkTheme.primary,
      onPrimary: AppColors.darkTheme.onPrimary,
      secondary: AppColors.darkTheme.secondary,
      onSecondary: AppColors.darkTheme.onSecondary,
      surface: AppColors.darkTheme.surface,
      onSurface: AppColors.darkTheme.onSurface,
      error: AppColors.darkTheme.error,
    ),
  );

  // Glassmorphism Decoration
  static BoxDecoration get glassMorphismDecoration => BoxDecoration(
    borderRadius: AppDimensions.borderRadiusLG,
    border: Border.all(color: _currentColorScheme.glassBorder, width: 1),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _currentColorScheme.glassBackground,
        _currentColorScheme.glassBackground.withOpacity(0.6),
      ],
    ),
  );

  // Device Card Decoration
  static BoxDecoration deviceCardDecoration(bool isOn) => BoxDecoration(
    borderRadius: AppDimensions.borderRadiusLG,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          isOn
              ? [
                _currentColorScheme.deviceOnPrimary,
                _currentColorScheme.deviceOnSecondary,
              ]
              : [
                _currentColorScheme.deviceOffPrimary,
                _currentColorScheme.deviceOffSecondary,
              ],
    ),
    boxShadow: [
      BoxShadow(
        color: _currentColorScheme.onSurface.withOpacity(0.1),
        blurRadius: AppDimensions.shadowBlurRadius,
        offset: AppDimensions.shadowOffset,
      ),
    ],
  );

  // Gradient Container Decoration
  static BoxDecoration get gradientDecoration =>
      BoxDecoration(gradient: _currentColorScheme.gradient);

  // Room Section Decoration
  static BoxDecoration get roomSectionDecoration => BoxDecoration(
    color: _currentColorScheme.surface,
    borderRadius: AppDimensions.borderRadiusLG,
    boxShadow: [
      BoxShadow(
        color: _currentColorScheme.onSurface.withOpacity(0.08),
        blurRadius: AppDimensions.shadowBlurRadius,
        offset: AppDimensions.shadowOffset,
      ),
    ],
  );
}
