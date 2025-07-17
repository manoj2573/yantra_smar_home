// lib/features/auth/views/signup_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yantra_smart_home_automation/features/auth/controllers/auth_page_controller.dart';
import 'login_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the same LoginPage but force it into signup mode
    final controller = Get.find<AuthPageController>();
    controller.isLoginMode.value = false;

    return const LoginPage();
  }
}
