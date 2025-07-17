// lib/features/settings/views/debug_menu_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/services/mock_data_services.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/services/mqtt_service.dart';
import '../../../core/models/device_model.dart';

class DebugMenuPage extends StatelessWidget {
  const DebugMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mockDataService = Get.put(MockDataService());
    final deviceController = DeviceController.to;
    final mqttService = MqttService.to;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Debug Menu'),
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.pagePadding,
            child: ListView(
              children: [
                const SizedBox(height: 20),

                // Mock Data Section
                _buildSection(
                  title: 'Mock Data',
                  icon: Icons.data_object,
                  children: [
                    _buildDebugButton(
                      'Initialize Mock Data',
                      'Add sample devices and rooms',
                      Icons.download,
                      () => mockDataService.initializeMockData(),
                    ),
                    _buildDebugButton(
                      'Reset All Data',
                      'Clear and recreate mock data',
                      Icons.refresh,
                      () => mockDataService.resetMockData(),
                    ),
                    _buildDebugButton(
                      'Add Multiple Test Devices',
                      'Add various device types for testing',
                      Icons.add_box,
                      () => mockDataService.addMultipleTestDevices(),
                    ),
                    _buildDebugButton(
                      'Clear Test Devices',
                      'Remove all test devices',
                      Icons.clear,
                      () => mockDataService.clearTestDevices(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Device Testing Section
                _buildSection(
                  title: 'Device Testing',
                  icon: Icons.memory,
                  children: [
                    _buildDebugButton(
                      'Add Test Light',
                      'Add a dimmable light for testing',
                      Icons.lightbulb,
                      () => mockDataService.addTestDevice(
                        DeviceType.dimmableLight,
                      ),
                    ),
                    _buildDebugButton(
                      'Add Test RGB Light',
                      'Add an RGB light for testing',
                      Icons.color_lens,
                      () => mockDataService.addTestDevice(DeviceType.rgb),
                    ),
                    _buildDebugButton(
                      'Add Test Fan',
                      'Add a fan for testing',
                      Icons.air,
                      () => mockDataService.addTestDevice(DeviceType.fan),
                    ),
                    _buildDebugButton(
                      'Add Test Curtain',
                      'Add curtains for testing',
                      Icons.window,
                      () => mockDataService.addTestDevice(DeviceType.curtain),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Simulation Section
                _buildSection(
                  title: 'Simulation',
                  icon: Icons.play_circle,
                  children: [
                    _buildDebugButton(
                      'Start Device Activity',
                      'Simulate random device changes',
                      Icons.shuffle,
                      () => mockDataService.simulateDeviceActivity(),
                    ),
                    _buildDebugButton(
                      'Realistic Simulation',
                      'Simulate daily routines',
                      Icons.schedule,
                      () => mockDataService.startRealisticSimulation(),
                    ),
                    _buildDebugButton(
                      'Toggle All Devices',
                      'Turn all devices on/off',
                      Icons.power_settings_new,
                      () => _toggleAllDevices(deviceController),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // MQTT Section
                _buildSection(
                  title: 'MQTT Testing',
                  icon: Icons.wifi,
                  children: [
                    Obx(
                      () => _buildInfoTile(
                        'Connection Status',
                        mqttService.isConnected ? 'Connected' : 'Disconnected',
                        mqttService.isConnected
                            ? Icons.check_circle
                            : Icons.error,
                        mqttService.isConnected ? Colors.green : Colors.red,
                      ),
                    ),
                    _buildDebugButton(
                      'Test Connection',
                      'Test MQTT connectivity',
                      Icons.network_check,
                      () => mqttService.testConnection(),
                    ),
                    _buildDebugButton(
                      'Force Reconnect',
                      'Force MQTT reconnection',
                      Icons.refresh,
                      () => mqttService.forceReconnect(),
                    ),
                    Obx(
                      () => _buildInfoTile(
                        'Subscribed Topics',
                        '${mqttService.subscribedTopics.length}',
                        Icons.topic,
                        Colors.blue,
                      ),
                    ),
                    Obx(
                      () => _buildInfoTile(
                        'Recent Messages',
                        '${mqttService.recentMessages.length}',
                        Icons.message,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Device Statistics Section
                _buildSection(
                  title: 'Device Statistics',
                  icon: Icons.analytics,
                  children: [
                    Obx(
                      () => _buildInfoTile(
                        'Total Devices',
                        '${deviceController.totalDevices}',
                        Icons.devices,
                        Colors.blue,
                      ),
                    ),
                    Obx(
                      () => _buildInfoTile(
                        'Online Devices',
                        '${deviceController.onlineDevicesCount}',
                        Icons.online_prediction,
                        Colors.green,
                      ),
                    ),
                    Obx(
                      () => _buildInfoTile(
                        'Active Timers',
                        '${deviceController.activeTimersCount}',
                        Icons.timer,
                        Colors.purple,
                      ),
                    ),
                    Obx(
                      () => _buildInfoTile(
                        'Rooms',
                        '${deviceController.devicesByRoom.length}',
                        Icons.room,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Advanced Actions
                _buildSection(
                  title: 'Advanced Actions',
                  icon: Icons.build,
                  children: [
                    _buildDebugButton(
                      'Show Device Diagnostics',
                      'View detailed device information',
                      Icons.info,
                      () => _showDeviceDiagnostics(deviceController),
                    ),
                    _buildDebugButton(
                      'Export Debug Log',
                      'Export debugging information',
                      Icons.file_download,
                      () => _exportDebugLog(),
                    ),
                    _buildDebugButton(
                      'Clear All Data',
                      'WARNING: Delete all devices',
                      Icons.delete_forever,
                      () => _showClearDataConfirmation(deviceController),
                    ),
                  ],
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.colors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(
                    Get.context!,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDebugButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.colors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppTheme.colors.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }

  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.grey.withOpacity(0.05),
      ),
    );
  }

  void _toggleAllDevices(DeviceController controller) {
    final allDevices = controller.devices;
    final onDevices = allDevices.where((d) => d.state.value).length;
    final shouldTurnOn = onDevices < (allDevices.length / 2);

    if (shouldTurnOn) {
      controller.turnOnAllDevices();
      Get.snackbar('Debug', 'Turned on all devices');
    } else {
      controller.turnOffAllDevices();
      Get.snackbar('Debug', 'Turned off all devices');
    }
  }

  void _showDeviceDiagnostics(DeviceController controller) {
    final diagnostics = controller.getDiagnosticInfo();

    Get.dialog(
      AlertDialog(
        title: const Text('Device Diagnostics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ...diagnostics.entries.map(
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
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _exportDebugLog() {
    // This would export debug information
    Get.snackbar(
      'Debug Export',
      'Debug log export functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showClearDataConfirmation(DeviceController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all devices, rooms, and settings. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              // Clear all devices
              final devices = controller.devices.toList();
              for (final device in devices) {
                try {
                  await controller.deleteDevice(device.id);
                } catch (e) {
                  print('Error deleting device: $e');
                }
              }

              Get.snackbar(
                'Debug',
                'All data cleared successfully',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
