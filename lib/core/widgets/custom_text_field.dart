// lib/core/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_dimensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.colors.surface,
        border: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: BorderSide(
            color: AppTheme.colors.onSurface.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: BorderSide(
            color: AppTheme.colors.onSurface.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.borderRadiusMD,
          borderSide: BorderSide(color: AppTheme.colors.error, width: 2),
        ),
      ),
    );
  }
}
