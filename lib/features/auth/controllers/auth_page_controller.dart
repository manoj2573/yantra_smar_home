// lib/features/auth/controllers/auth_page_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/controllers/auth_controller.dart';

class AuthPageController extends GetxController {
  static AuthPageController get to => Get.find();

  final AuthController _authController = AuthController.to;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoginMode = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    clearForm();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _authController.clearError();
  }

  Future<void> submitForm() async {
    if (!_validateForm()) return;

    if (isLoginMode.value) {
      await _authController.signIn(
        emailController.text.trim(),
        passwordController.text,
      );
    } else {
      await _authController.signUp(
        emailController.text.trim(),
        passwordController.text,
      );
    }
  }

  Future<void> forgotPassword() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _authController.resetPassword(emailController.text.trim());

    if (_authController.error.value.isEmpty) {
      Get.snackbar(
        'Success',
        'Password reset email sent!',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool _validateForm() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty) {
      Get.snackbar('Error', 'Email is required');
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email');
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar('Error', 'Password is required');
      return false;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return false;
    }

    if (!isLoginMode.value && password != confirmPassword) {
      Get.snackbar('Error', 'Passwords do not match');
      return false;
    }

    return true;
  }

  // Getters for reactive properties
  bool get isLoading => _authController.isLoading.value;
  String get error => _authController.error.value;
}
