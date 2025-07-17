// lib/app/theme/app_dimensions.dart
import 'package:flutter/material.dart';

class AppDimensions {
  // Spacing System (8pt grid)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal Padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(
    horizontal: xs,
  );
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(
    horizontal: xl,
  );

  // Vertical Padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(
    vertical: xs,
  );
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(
    vertical: xl,
  );

  // Page Padding
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(md, lg, md, md);
  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets pagePaddingVertical = EdgeInsets.symmetric(
    vertical: lg,
  );

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 50.0;

  // Border Radius Objects
  static const BorderRadius borderRadiusXS = BorderRadius.all(
    Radius.circular(radiusXS),
  );
  static const BorderRadius borderRadiusSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );
  static const BorderRadius borderRadiusMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );
  static const BorderRadius borderRadiusLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );
  static const BorderRadius borderRadiusXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );
  static const BorderRadius borderRadiusXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );
  static const BorderRadius borderRadiusCircular = BorderRadius.all(
    Radius.circular(radiusCircular),
  );

  // Component Specific Dimensions
  static const double appBarHeight = 56.0;
  static const double tabBarHeight = 48.0;
  static const double bottomNavBarHeight = 60.0;
  static const double floatingActionButtonSize = 56.0;
  static const double drawerWidth = 280.0;

  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double cardMaxElevation = 8.0;
  static const double cardMinHeight = 120.0;
  static const double deviceCardHeight = 140.0;
  static const double deviceCardWidth = 120.0;
  static const double roomCardHeight = 160.0;

  // Button Dimensions
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 120.0;
  static const double iconButtonSize = 40.0;
  static const double fabSize = 56.0;
  static const double miniActionButtonSize = 40.0;

  // Input Field Dimensions
  static const double inputFieldHeight = 56.0;
  static const double inputFieldBorderWidth = 1.0;
  static const double inputFieldFocusedBorderWidth = 2.0;

  // Icon Sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 40.0;
  static const double iconXXL = 48.0;
  static const double iconXXXL = 64.0;

  // Device Icon Sizes
  static const double deviceIconSmall = 32.0;
  static const double deviceIconMedium = 48.0;
  static const double deviceIconLarge = 64.0;
  static const double deviceIconXL = 80.0;

  // Avatar Sizes
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 80.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double thickDividerThickness = 2.0;

  // Shadow & Blur
  static const double shadowBlurRadius = 8.0;
  static const double shadowSpreadRadius = 0.0;
  static const Offset shadowOffset = Offset(0, 2);
  static const double glassMorphismBlur = 10.0;

  // Animation Durations
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  static const Duration animationDurationXSlow = Duration(milliseconds: 800);

  // Grid Dimensions
  static const double gridSpacing = 12.0;
  static const double gridAspectRatio = 1.0;
  static const int gridCrossAxisCount = 2;
  static const int tabletGridCrossAxisCount = 3;
  static const int desktopGridCrossAxisCount = 4;

  // Slider Dimensions
  static const double sliderHeight = 40.0;
  static const double sliderThumbRadius = 12.0;
  static const double sliderTrackHeight = 4.0;

  // Timer & Progress Dimensions
  static const double progressIndicatorSize = 20.0;
  static const double progressIndicatorStrokeWidth = 3.0;
  static const double timerProgressSize = 120.0;
  static const double timerProgressStrokeWidth = 8.0;

  // IR Remote Button Dimensions
  static const double irButtonSize = 60.0;
  static const double irButtonSmallSize = 45.0;
  static const double irButtonLargeSize = 80.0;
  static const double irButtonSpacing = 8.0;

  // Curtain Control Button Dimensions
  static const double curtainButtonHeight = 80.0;
  static const double curtainButtonWidth = 120.0;

  // Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // Safe Area
  static const double statusBarHeight = 24.0;
  static const double navigationBarHeight = 56.0;
}

// Responsive Extensions
extension ResponsiveDimensions on BuildContext {
  bool get isMobile =>
      MediaQuery.of(this).size.width < AppDimensions.mobileBreakpoint;
  bool get isTablet =>
      MediaQuery.of(this).size.width >= AppDimensions.mobileBreakpoint &&
      MediaQuery.of(this).size.width < AppDimensions.desktopBreakpoint;
  bool get isDesktop =>
      MediaQuery.of(this).size.width >= AppDimensions.desktopBreakpoint;

  int get gridCrossAxisCount {
    if (isDesktop) return AppDimensions.desktopGridCrossAxisCount;
    if (isTablet) return AppDimensions.tabletGridCrossAxisCount;
    return AppDimensions.gridCrossAxisCount;
  }

  double get deviceCardSize {
    if (isDesktop) return AppDimensions.deviceCardWidth * 1.2;
    if (isTablet) return AppDimensions.deviceCardWidth * 1.1;
    return AppDimensions.deviceCardWidth;
  }
}
