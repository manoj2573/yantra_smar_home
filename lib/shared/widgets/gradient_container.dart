// lib/shared/widgets/gradient_container.dart
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class GradientContainer extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientContainer({super.key, required this.child, this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.orangeTheme.gradient,
      ),
      child: child,
    );
  }
}
