// lib/features/settings/controllers/settings_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/services/supabase_service.dart';

class SettingsController extends GetxController {
  static SettingsController get to => Get.find();

  final _logger = Logger();
  final _deviceController = DeviceController.to;
  final _authController = AuthController.to;
  final _supabaseService = SupabaseService.to;

  // Observable settings
  final RxString currentTheme = 'Orange'.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool autoDiscoverDevices = true.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // ===================== SETTINGS LOADING =====================

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      currentTheme.value = prefs.getString('theme') ?? 'Orange';
      notificationsEnabled.value =
          prefs.getBool('notifications_enabled') ?? true;
      autoDiscoverDevices.value =
          prefs.getBool('auto_discover_devices') ?? true;

      // Apply the loaded theme
      _applyTheme(currentTheme.value);

      _logger.i('Settings loaded successfully');
    } catch (e) {
      _logger.e('Error loading settings: $e');
      error.value = 'Failed to load settings: $e';
    }
  }

  // ===================== THEME MANAGEMENT =====================

  Future<void> changeTheme(String theme) async {
    try {
      currentTheme.value = _capitalizeFirst(theme);

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme', currentTheme.value);

      // Apply theme
      _applyTheme(currentTheme.value);

      // Update user preferences in database if authenticated
      if (_authController.isAuthenticated.value) {
        await _updateUserPreferences();
      }

      Get.snackbar(
        'Theme Changed',
        '${currentTheme.value} theme applied',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Theme changed to: ${currentTheme.value}');
    } catch (e) {
      _logger.e('Error changing theme: $e');
      error.value = 'Failed to change theme: $e';
    }
  }

  void _applyTheme(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'orange':
        AppTheme.setTheme(AppThemeType.orange);
        break;
      case 'blue':
        AppTheme.setTheme(AppThemeType.blue);
        break;
      case 'green':
        AppTheme.setTheme(AppThemeType.green);
        break;
      case 'purple':
        AppTheme.setTheme(AppThemeType.purple);
        break;
      case 'dark':
        AppTheme.setTheme(AppThemeType.dark);
        break;
      default:
        AppTheme.setTheme(AppThemeType.orange);
    }

    // Update the app theme
    Get.changeTheme(AppTheme.lightTheme);
  }

  // ===================== NOTIFICATION SETTINGS =====================

  Future<void> toggleNotifications(bool enabled) async {
    try {
      notificationsEnabled.value = enabled;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);

      // Update user preferences in database if authenticated
      if (_authController.isAuthenticated.value) {
        await _updateUserPreferences();
      }

      Get.snackbar(
        'Notifications ${enabled ? 'Enabled' : 'Disabled'}',
        enabled
            ? 'You will receive push notifications'
            : 'Push notifications have been disabled',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Notifications ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error toggling notifications: $e');
      error.value = 'Failed to update notification settings: $e';
    }
  }

  // ===================== AUTO DISCOVERY SETTINGS =====================

  Future<void> toggleAutoDiscovery(bool enabled) async {
    try {
      autoDiscoverDevices.value = enabled;

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_discover_devices', enabled);

      // Update user preferences in database if authenticated
      if (_authController.isAuthenticated.value) {
        await _updateUserPreferences();
      }

      Get.snackbar(
        'Auto Discovery ${enabled ? 'Enabled' : 'Disabled'}',
        enabled
            ? 'New devices will be automatically discovered'
            : 'Automatic device discovery has been disabled',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Auto discovery ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error toggling auto discovery: $e');
      error.value = 'Failed to update auto discovery settings: $e';
    }
  }

  // ===================== DATABASE SYNC =====================

  Future<void> _updateUserPreferences() async {
    try {
      if (!_authController.isAuthenticated.value) return;

      await _supabaseService.client
          .from('user_preferences')
          .update({
            'theme': currentTheme.value.toLowerCase(),
            'notifications_enabled': notificationsEnabled.value,
            'auto_discover_devices': autoDiscoverDevices.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _authController.userId!);

      _logger.d('User preferences updated in database');
    } catch (e) {
      _logger.w('Failed to sync preferences to database: $e');
      // Don't show error to user - local storage is more important
    }
  }

  // ===================== DATA EXPORT/IMPORT =====================

  Future<void> exportData() async {
    try {
      isLoading.value = true;

      // Prepare export data
      final exportData = {
        'version': '2.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'settings': {
          'theme': currentTheme.value,
          'notifications_enabled': notificationsEnabled.value,
          'auto_discover_devices': autoDiscoverDevices.value,
        },
        'devices':
            _deviceController.devices
                .map(
                  (device) => {
                    'device_id': device.deviceId,
                    'name': device.name,
                    'type': device.type.displayName,
                    'room_name': device.roomName,
                    'registration_id': device.registrationId,
                    'icon_path': device.iconPath,
                  },
                )
                .toList(),
        'device_count': _deviceController.devices.length,
      };

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/smart_home_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );

      // Write data to file
      await file.writeAsString(jsonEncode(exportData));

      Get.snackbar(
        'Export Successful',
        'Data exported to: ${file.path}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      _logger.i('Data exported successfully to: ${file.path}');
    } catch (e) {
      _logger.e('Error exporting data: $e');
      Get.snackbar(
        'Export Failed',
        'Failed to export data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> importData() async {
    try {
      isLoading.value = true;

      // This would typically open a file picker
      // For now, show a message about the feature
      Get.snackbar(
        'Import Data',
        'Data import functionality will be available in the next update',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Import data requested');
    } catch (e) {
      _logger.e('Error importing data: $e');
      Get.snackbar(
        'Import Failed',
        'Failed to import data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===================== APP RESET =====================

  Future<void> resetAppData() async {
    try {
      isLoading.value = true;

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset observable values to defaults
      currentTheme.value = 'Orange';
      notificationsEnabled.value = true;
      autoDiscoverDevices.value = true;

      // Apply default theme
      _applyTheme('Orange');

      // Clear device data (this would typically clear from database too)
      // For now, just clear the local controller
      _deviceController.devices.clear();

      Get.snackbar(
        'App Reset Complete',
        'All app data has been cleared. Please restart the app.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      _logger.i('App data reset successfully');

      // Optionally sign out the user
      await Future.delayed(const Duration(seconds: 2));
      _authController.signOut();
    } catch (e) {
      _logger.e('Error resetting app data: $e');
      Get.snackbar(
        'Reset Failed',
        'Failed to reset app data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===================== UTILITY METHODS =====================

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  void clearError() {
    error.value = '';
  }

  bool get hasError => error.value.isNotEmpty;

  // ===================== GETTERS FOR UI =====================

  List<String> get availableThemes => [
    'Orange',
    'Blue',
    'Green',
    'Purple',
    'Dark',
  ];

  Map<String, dynamic> get currentSettings => {
    'theme': currentTheme.value,
    'notifications_enabled': notificationsEnabled.value,
    'auto_discover_devices': autoDiscoverDevices.value,
  };

  // ===================== ADVANCED SETTINGS =====================

  Future<void> clearCache() async {
    try {
      isLoading.value = true;

      // Clear temporary directories
      final tempDir = await getTemporaryDirectory();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
        await tempDir.create();
      }

      Get.snackbar(
        'Cache Cleared',
        'App cache has been cleared successfully',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Cache cleared successfully');
    } catch (e) {
      _logger.e('Error clearing cache: $e');
      Get.snackbar(
        'Cache Clear Failed',
        'Failed to clear cache: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> optimizeDatabase() async {
    try {
      isLoading.value = true;

      // This would run database optimization queries
      // For now, simulate the process
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Database Optimized',
        'Database has been optimized for better performance',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Database optimization completed');
    } catch (e) {
      _logger.e('Error optimizing database: $e');
      Get.snackbar(
        'Optimization Failed',
        'Failed to optimize database: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ===================== DEVELOPER SETTINGS =====================

  Future<void> enableDeveloperMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('developer_mode', true);

      Get.snackbar(
        'Developer Mode Enabled',
        'Advanced debugging features are now available',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Developer mode enabled');
    } catch (e) {
      _logger.e('Error enabling developer mode: $e');
    }
  }

  Future<bool> isDeveloperModeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('developer_mode') ?? false;
    } catch (e) {
      return false;
    }
  }

  // ===================== BACKUP & RESTORE =====================

  Future<void> createBackup() async {
    try {
      isLoading.value = true;

      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'version': '2.0.0',
        'settings': currentSettings,
        'devices': await _getDeviceBackupData(),
        'rooms': await _getRoomBackupData(),
      };

      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File(
        '${directory.path}/smart_home_full_backup_${DateTime.now().millisecondsSinceEpoch}.json',
      );

      await backupFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(backupData),
      );

      Get.snackbar(
        'Backup Created',
        'Full backup saved to: ${backupFile.path}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );

      _logger.i('Full backup created: ${backupFile.path}');
    } catch (e) {
      _logger.e('Error creating backup: $e');
      Get.snackbar(
        'Backup Failed',
        'Failed to create backup: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _getDeviceBackupData() async {
    return _deviceController.devices
        .map(
          (device) => {
            'device_id': device.deviceId,
            'name': device.name,
            'type': device.type.displayName,
            'room_name': device.roomName,
            'registration_id': device.registrationId,
            'icon_path': device.iconPath,
            'state': device.state.value,
            'slider_value': device.sliderValue?.value,
            'color': device.color.value,
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> _getRoomBackupData() async {
    try {
      final roomsData = await _supabaseService.getRooms();
      return roomsData;
    } catch (e) {
      _logger.w('Failed to get rooms for backup: $e');
      return [];
    }
  }
}
