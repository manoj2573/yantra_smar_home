// lib/features/dashboard/views/dashboard_page.dart - Updated with debug access
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yantra_smart_home_automation/app/theme/app_dimensions.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../features/settings/views/debug_menu_page.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/room_section.dart';
import '../widgets/quick_stats.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final deviceController = Get.find<DeviceController>();
    final authController = Get.find<AuthController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Smart Home',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshAllData,
          ),
          // Debug shortcut - long press to access
          GestureDetector(
            onLongPress: () => Get.to(() => const DebugMenuPage()),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'debug':
                    Get.to(() => const DebugMenuPage());
                    break;
                  case 'settings':
                    Get.toNamed('/settings');
                    break;
                  case 'logout':
                    _showLogoutDialog(context, authController);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'debug',
                      child: ListTile(
                        leading: Icon(Icons.bug_report),
                        title: Text('Debug Menu'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
      body: GradientContainer(
        child: SafeArea(
          child: Obx(() {
            if (deviceController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: controller.refreshAllData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: AppDimensions.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick stats
                    QuickStats(stats: controller.quickStats),
                    const SizedBox(height: 24),

                    // Quick Setup Card (if no devices)
                    if (deviceController.devices.isEmpty) ...[
                      _buildQuickSetupCard(),
                      const SizedBox(height: 24),
                    ],

                    // Rooms and devices
                    if (deviceController.devicesByRoom.isNotEmpty) ...[
                      Text(
                        'Rooms',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      ...deviceController.devicesByRoom.entries.map(
                        (entry) => RoomSection(
                          roomName: entry.key,
                          devices: entry.value,
                        ),
                      ),
                    ] else ...[
                      // Empty state
                      _buildEmptyState(),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/add-device'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickSetupCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.rocket_launch, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Quick Setup',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Get started quickly with sample devices',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const DebugMenuPage()),
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Add Sample Data'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.home_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No devices found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first device to get started',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => Get.toNamed('/add-device'),
                icon: const Icon(Icons.add),
                label: const Text('Add Device'),
              ),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => const DebugMenuPage()),
                icon: const Icon(Icons.science),
                label: const Text('Test Data'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  authController.signOut();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }
}
