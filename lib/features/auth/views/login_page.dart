// lib/features/auth/views/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/auth_page_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthPageController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.colors.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Obx(
                  () => Text(
                    controller.isLoginMode.value
                        ? 'Welcome Back'
                        : 'Create Account',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart Home Automation',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 48),

                // Form
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Email field
                        CustomTextField(
                          controller: controller.emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        Obx(
                          () => CustomTextField(
                            controller: controller.passwordController,
                            label: 'Password',
                            icon: Icons.lock_outlined,
                            obscureText: controller.obscurePassword.value,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.obscurePassword.value
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                          ),
                        ),

                        // Confirm password (only for signup)
                        Obx(
                          () =>
                              !controller.isLoginMode.value
                                  ? Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      CustomTextField(
                                        controller:
                                            controller
                                                .confirmPasswordController,
                                        label: 'Confirm Password',
                                        icon: Icons.lock_outlined,
                                        obscureText:
                                            controller
                                                .obscureConfirmPassword
                                                .value,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            controller
                                                    .obscureConfirmPassword
                                                    .value
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                          ),
                                          onPressed:
                                              controller
                                                  .toggleConfirmPasswordVisibility,
                                        ),
                                      ),
                                    ],
                                  )
                                  : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 24),

                        // Submit button
                        Obx(
                          () => CustomButton(
                            onPressed:
                                controller.isLoading
                                    ? null
                                    : controller.submitForm,
                            isLoading: controller.isLoading,
                            child: Text(
                              controller.isLoginMode.value
                                  ? 'Sign In'
                                  : 'Sign Up',
                            ),
                          ),
                        ),

                        // Forgot password (only for login)
                        Obx(
                          () =>
                              controller.isLoginMode.value
                                  ? TextButton(
                                    onPressed: controller.forgotPassword,
                                    child: const Text('Forgot Password?'),
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Toggle auth mode
                Obx(
                  () => TextButton(
                    onPressed: controller.toggleAuthMode,
                    child: Text(
                      controller.isLoginMode.value
                          ? "Don't have an account? Sign Up"
                          : "Already have an account? Sign In",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // Error message
                Obx(
                  () =>
                      controller.error.isNotEmpty
                          ? Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              controller.error,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
