// lib/core/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_dimensions.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonType type;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget buttonChild =
        isLoading
            ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  type == ButtonType.primary
                      ? AppTheme.colors.onPrimary
                      : AppTheme.colors.primary,
                ),
              ),
            )
            : icon != null
            ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [Icon(icon), const SizedBox(width: 8), child],
            )
            : child;

    Widget button = switch (type) {
      ButtonType.primary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.primary,
          foregroundColor: AppTheme.colors.onPrimary,
          padding: padding ?? AppDimensions.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMD,
          ),
          elevation: 2,
        ),
        child: buttonChild,
      ),
      ButtonType.secondary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.colors.secondary,
          foregroundColor: AppTheme.colors.onSecondary,
          padding: padding ?? AppDimensions.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMD,
          ),
          elevation: 1,
        ),
        child: buttonChild,
      ),
      ButtonType.outline => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.colors.primary,
          side: BorderSide(color: AppTheme.colors.primary),
          padding: padding ?? AppDimensions.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMD,
          ),
        ),
        child: buttonChild,
      ),
      ButtonType.text => TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.colors.primary,
          padding: padding ?? AppDimensions.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.borderRadiusMD,
          ),
        ),
        child: buttonChild,
      ),
    };

    return isExpanded
        ? SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeight,
          child: button,
        )
        : button;
  }
}
