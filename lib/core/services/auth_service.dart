// lib/core/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'supabase_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final _logger = Logger();
  final _supabaseService = SupabaseService.to;
  
  // Observables
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isAuthenticated = false.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  // User preferences
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _checkAuthState();
    _setupAuthListener();
  }
  
  Future<void> _checkAuthState() async {
    try {
      final session = _supabaseService.client.auth.currentSession;
      if (session?.user != null) {
        currentUser.value = session!.user;
        isAuthenticated.value = true;
        await _loadUserProfile();
        _logger.i('User authenticated: ${currentUser.value?.email}');
      }
    } catch (e) {
      _logger.e('Error checking auth state: $e');
    }
  }
  
  void _setupAuthListener() {
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;
      
      switch (event) {
        case AuthChangeEvent.signedIn:
          currentUser.value = user;
          isAuthenticated.value = true;
          if (user != null) {
            _loadUserProfile();
          }
          _logger.i('User signed in: ${user?.email}');
          break;
          
        case AuthChangeEvent.signedOut:
          currentUser.value = null;
          isAuthenticated.value = false;
          userProfile.value = null;
          _clearLocalData();
          _logger.i('User signed out');
          break;
          
        case AuthChangeEvent.tokenRefreshed:
          currentUser.value = user;
          _logger.d('Token refreshed for: ${user?.email}');
          break;
          
        default:
          break;
      }
    });
  }
  
  // ===================== AUTHENTICATION METHODS =====================
  
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Signing up user: $email');
      
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      
      if (response.user != null) {
        _logger.i('User signed up successfully: $email');
        // User profile will be created via database trigger
      }
      
      return response;
    } catch (e) {
      _logger.e('Sign up error: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Signing in user: $email');
      
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _logger.i('User signed in successfully: $email');
        await _saveLoginCredentials(email);
      }
      
      return response;
    } catch (e) {
      _logger.e('Sign in error: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Signing out user');
      await _supabaseService.client.auth.signOut();
      await _clearLocalData();
      
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out error: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Sending password reset email to: $email');
      await _supabaseService.client.auth.resetPasswordForEmail(email);
      
      _logger.i('Password reset email sent successfully');
    } catch (e) {
      _logger.e('Password reset error: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Updating user password');
      final response = await _supabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      _logger.i('Password updated successfully');
      return response;
    } catch (e) {
      _logger.e('Password update error: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<UserResponse> updateEmail({
    required String newEmail,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Updating user email to: $newEmail');
      final response = await _supabaseService.client.auth.updateUser(
        UserAttributes(email: newEmail),
      );
      
      _logger.i('Email update initiated successfully');
      return response;
    } catch (e) {
      _logger.e('Email update error: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // ===================== USER PROFILE METHODS =====================
  
  Future<void> _loadUserProfile() async {
    if (currentUser.value == null) return;
    
    try {
      final response = await _supabaseService.client
          .from('user_preferences')
          .select()
          .eq('user_id', currentUser.value!.id)
          .maybeSingle();
      
      if (response != null) {
        userProfile.value = UserModel.fromSupabase({
          ...response,
          'id': currentUser.value!.id,
          'email': currentUser.value!.email!,
          'full_name': currentUser.value!.userMetadata?['full_name'],
          'created_at': currentUser.value!.createdAt,
        });
        
        _logger.d('User profile loaded: ${userProfile.value?.email}');
      }
    } catch (e) {
      _logger.e('Error loading user profile: $e');
    }
  }
  
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? theme,
    bool? notificationsEnabled,
    bool? autoDiscoverDevices,
    Map<String, dynamic>? mqttSettings,
  }) async {
    try {
      if (currentUser.value == null) {
        throw Exception('User not authenticated');
      }
      
      isLoading.value = true;
      error.value = '';
      
      // Update auth metadata if full name changed
      if (fullName != null) {
        await _supabaseService.client.auth.updateUser(
          UserAttributes(
            data: {'full_name': fullName},
          ),
        );
      }
      
      // Update user preferences
      final updates = <String, dynamic>{};
      if (theme != null) updates['theme'] = theme;
      if (notificationsEnabled != null) {
        updates['notifications_enabled'] = notificationsEnabled;
      }
      if (autoDiscoverDevices != null) {
        updates['auto_discover_devices'] = autoDiscoverDevices;
      }
      if (mqttSettings != null) updates['mqtt_settings'] = mqttSettings;
      
      if (updates.isNotEmpty) {
        await _supabaseService.client
            .from('user_preferences')
            .update(updates)
            .eq('user_id', currentUser.value!.id);
      }
      
      // Reload profile
      await _loadUserProfile();
      
      _logger.i('User profile updated successfully');
      return userProfile.value!;
    } catch (e) {
      _logger.e('Error updating user profile: $e');
      error.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
  
  // ===================== SOCIAL AUTH METHODS =====================
  
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Signing in with Google');
      await _supabaseService.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.flutter.dev://yantra.smart.home/auth',
      );
      
      return true;
    } catch (e) {
      _logger.e('Google sign in error: $e');
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<bool> signInWithApple() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      _logger.i('Signing in with Apple');
      await _supabaseService.client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.flutter.dev://yantra.smart.home/auth',
      );
      
      return true;
    } catch (e) {
      _logger.e('Apple sign in error: $e');
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // ===================== LOCAL STORAGE METHODS =====================
  
  Future<void> _saveLoginCredentials(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_login_email', email);
      await prefs.setBool('remember_me', true);
    } catch (e) {
      _logger.w('Failed to save login credentials: $e');
    }
  }
  
  Future<String?> getLastLoginEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('last_login_email');
    } catch (e) {
      _logger.w('Failed to get last login email: $e');
      return null;
    }
  }
  
  Future<bool> getRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('remember_me') ?? false;
    } catch (e) {
      _logger.w('Failed to get remember me preference: $e');
      return false;
    }
  }
  
  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_login_email');
      await prefs.remove('remember_me');
    } catch (e) {
      _logger.w('Failed to clear local data: $e');
    }
  }
  
  // ===================== VALIDATION METHODS =====================
  
  bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
  
  bool isValidPassword(String password) {
    // At least 8 characters, 1 uppercase, 1 lowercase, 1 number
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]'));
  }
  
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }
  
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  }
  
  String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }
  
  // ===================== UTILITY METHODS =====================
  
  void clearError() {
    error.value = '';
  }
  
  bool get hasError => error.value.isNotEmpty;
  
  String? get userId => currentUser.value?.id;
  String? get userEmail => currentUser.value?.email;
  String? get userFullName => userProfile.value?.fullName;
  
  // Session management
  Future<bool> refreshSession() async {
    try {
      await _supabaseService.client.auth.refreshSession();
      return true;
    } catch (e) {
      _logger.e('Failed to refresh session: $e');
      return false;
    }
  }
  
  Future<bool> checkSessionValidity() async {
    try {
      final session = _supabaseService.client.auth.currentSession;
      if (session == null) return false;
      
      // Check if token is about to expire (within next 5 minutes)
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );
      final now = DateTime.now();
      final timeUntilExpiry = expiresAt.difference(now);
      
      if (timeUntilExpiry.inMinutes < 5) {
        return await refreshSession();
      }
      
      return true;
    } catch (e) {
      _logger.e('Error checking session validity: $e');
      return false;
    }
  }
  
  // Device-specific auth methods
  Future<void> authenticateForDeviceAccess() async {
    if (!isAuthenticated.value) {
      throw Exception('User not authenticated');
    }
    
    final isValid = await checkSessionValidity();
    if (!isValid) {
      throw Exception('Session expired. Please log in again.');
    }
  }
  
  // Get auth headers for API calls
  Map<String, String> getAuthHeaders() {
    final session = _supabaseService.client.auth.currentSession;
    if (session?.accessToken != null) {
      return {
        'Authorization': 'Bearer ${session!.accessToken}',
        'Content-Type': 'application/json',
      };
    }
    throw Exception('No valid session');
  }
}