// lib/features/settings/views/settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yantra_smart_home_automation/features/settings/views/debug_menu_page.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/mqtt_service.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = AuthController.to;
    final supabaseService = SupabaseService.to;
    final mqttService = MqttService.to;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Settings'),
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.pagePadding,
            child: ListView(
              children: [
                const SizedBox(height: 20),

                // User Profile Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.colors.primary.withOpacity(
                            0.1,
                          ),
                          child: Text(
                            supabaseService.currentUser?.email
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.colors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                supabaseService.currentUser?.email ?? 'User',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Premium User',
                                style: TextStyle(
                                  color: AppTheme.colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.toNamed('/profile'),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Preferences
                _buildSection(
                  title: 'App Preferences',
                  icon: Icons.tune,
                  children: [
                    SettingsTile(
                      title: 'Theme',
                      subtitle: 'Customize app appearance',
                      leading: Icons.palette,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/theme-settings'),
                    ),
                    SettingsTile(
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      leading: Icons.notifications,
                      trailing: Switch.adaptive(
                        value: true, // This should be from user preferences
                        onChanged: (value) {
                          // Handle notification toggle
                        },
                      ),
                    ),
                    SettingsTile(
                      title: 'Auto Discovery',
                      subtitle: 'Automatically find new devices',
                      leading: Icons.search,
                      trailing: Switch.adaptive(
                        value: true, // This should be from user preferences
                        onChanged: (value) {
                          // Handle auto discovery toggle
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Device Management
                _buildSection(
                  title: 'Device Management',
                  icon: Icons.devices,
                  children: [
                    SettingsTile(
                      title: 'Rooms',
                      subtitle: 'Manage rooms and assignments',
                      leading: Icons.room,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/rooms'),
                    ),
                    SettingsTile(
                      title: 'Scenes',
                      subtitle: 'Create and manage scenes',
                      leading: Icons.movie,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/scenes'),
                    ),
                    SettingsTile(
                      title: 'Schedules',
                      subtitle: 'Manage device schedules',
                      leading: Icons.schedule,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/schedules'),
                    ),
                    SettingsTile(
                      title: 'Timers',
                      subtitle: 'View and manage timers',
                      leading: Icons.timer,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/timers'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Connectivity
                _buildSection(
                  title: 'Connectivity',
                  icon: Icons.wifi,
                  children: [
                    Obx(
                      () => SettingsTile(
                        title: 'MQTT Status',
                        subtitle:
                            mqttService.isConnected
                                ? 'Connected'
                                : 'Disconnected',
                        leading: Icons.wifi,
                        trailing: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                mqttService.isConnected
                                    ? Colors.green
                                    : Colors.red,
                          ),
                        ),
                        onTap: () => _showMqttInfo(context, mqttService),
                      ),
                    ),
                    SettingsTile(
                      title: 'WiFi Configuration',
                      subtitle: 'Configure device WiFi settings',
                      leading: Icons.router,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/wifi'),
                    ),
                    SettingsTile(
                      title: 'Add Device',
                      subtitle: 'Add new smart devices',
                      leading: Icons.add_circle,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/add-device'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Advanced
                _buildSection(
                  title: 'Advanced',
                  icon: Icons.build,
                  children: [
                    SettingsTile(
                      title: 'Debug Menu',
                      subtitle: 'Developer tools and diagnostics',
                      leading: Icons.bug_report,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.to(() => const DebugMenuPage()),
                    ),
                    SettingsTile(
                      title: 'Backup & Restore',
                      subtitle: 'Backup your settings and data',
                      leading: Icons.backup,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showBackupDialog(context),
                    ),
                    SettingsTile(
                      title: 'Reset Settings',
                      subtitle: 'Reset app to default settings',
                      leading: Icons.restore,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showResetDialog(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // About
                _buildSection(
                  title: 'About',
                  icon: Icons.info,
                  children: [
                    SettingsTile(
                      title: 'App Version',
                      subtitle: '2.0.0',
                      leading: Icons.info,
                    ),
                    SettingsTile(
                      title: 'Privacy Policy',
                      subtitle: 'View privacy policy',
                      leading: Icons.privacy_tip,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/privacy-policy'),
                    ),
                    SettingsTile(
                      title: 'Terms of Service',
                      subtitle: 'View terms of service',
                      leading: Icons.description,
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => Get.toNamed('/terms'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Logout Button
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Sign out of your account'),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.red,
                    ),
                    onTap: () => _showLogoutDialog(context, authController),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showMqttInfo(BuildContext context, MqttService mqttService) {
    final info = mqttService.getConnectionInfo();

    Get.dialog(
      AlertDialog(
        title: const Text('MQTT Connection Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...info.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text('${entry.value}'),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          if (!mqttService.isConnected)
            ElevatedButton(
              onPressed: () {
                mqttService.connect();
                Get.back();
              },
              child: const Text('Reconnect'),
            ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text(
          'Backup functionality will save your device configurations, '
          'scenes, schedules, and settings to cloud storage.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Coming Soon',
                'Backup functionality will be available in the next update',
              );
            },
            child: const Text('Create Backup'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all app settings to default values. '
          'Your devices and configurations will not be affected.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Settings Reset',
                'App settings have been reset to defaults',
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
