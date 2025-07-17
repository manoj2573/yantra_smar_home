import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace with your actual Supabase credentials
  static const String supabaseUrl = 'https://jqqjapokqsfmuejexunv.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxcWphcG9rcXNmbXVlamV4dW52Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2MDI3NDgsImV4cCI6MjA2ODE3ODc0OH0.U-DPp0euum68U_rmKnTf6R9xv6sMJAVrTUPvkABgbRI';

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Set to false in production
    );
  }

  // Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  // Get current user
  static User? get currentUser => client.auth.currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
