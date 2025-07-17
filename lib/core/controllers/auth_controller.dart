// lib/core/controllers/auth_controller.dart
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (event) {
          case AuthChangeEvent.signedIn:
            _logger.i('User signed in: ${user?.email}');
            Get.offAllNamed('/dashboard');
            break;
          case AuthChangeEvent.signedOut:
            _logger.i('User signed out');
            Get.offAllNamed('/login');
            break;
          default:
            break;
        }
      });
    });

    // Check initial auth state safely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_supabaseService.isAuthenticated) {
        Get.offAllNamed('/dashboard');
      } else {
        Get.offAllNamed('/login');
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _supabaseService.signInWithEmail(email, password);

      if (response.user != null) {
        _logger.i('Sign in successful');
      }
    } catch (e) {
      _logger.e('Sign in error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _supabaseService.signUpWithEmail(email, password);

      if (response.user != null) {
        _logger.i('Sign up successful');
      }
    } catch (e) {
      _logger.e('Sign up error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      _logger.i('Sign out successful');
    } catch (e) {
      _logger.e('Sign out error: $e');
      error.value = e.toString();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _supabaseService.resetPassword(email);
      _logger.i('Password reset email sent');
    } catch (e) {
      _logger.e('Password reset error: $e');
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void clearError() {
    error.value = '';
  }
}
