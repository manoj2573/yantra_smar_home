// lib/features/dashboard/views/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yantra_smart_home_automation/app/theme/app_dimensions.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/controllers/auth_controller.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _showLogoutDialog(context, authController);
                  break;
                case 'settings':
                  Get.toNamed('/settings');
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                    ),
                  ),
                ],
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
                      Center(
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
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => Get.toNamed('/add-device'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Device'),
                            ),
                          ],
                        ),
                      ),
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
