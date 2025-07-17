// lib/features/devices/views/device_control_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/models/device_model.dart';
import '../../../core/controllers/device_controller.dart';
import '../widgets/device_types/switch_device_widget.dart';
import '../widgets/device_types/dimmer_device_widget.dart';
import '../widgets/device_types/rgb_device_widget.dart';
import '../widgets/device_types/fan_device_widget.dart';
import '../widgets/device_types/curtain_device_widget.dart';

class DeviceControlPage extends StatelessWidget {
  const DeviceControlPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DeviceModel device = Get.arguments as DeviceModel;
    final DeviceController deviceController = DeviceController.to;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: device.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/device-settings', arguments: device),
          ),
        ],
      ),
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.pagePadding,
            child: Column(
              children: [
                // Device Status Header
                _buildDeviceHeader(device),
                const SizedBox(height: 24),

                // Device Control Widget
                Expanded(
                  child: _buildDeviceControlWidget(device, deviceController),
                ),

                // Quick Actions
                _buildQuickActions(device, deviceController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceHeader(DeviceModel device) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.colors.primary.withOpacity(0.1),
              AppTheme.colors.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Device Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    device.state.value
                        ? AppTheme.colors.primary.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                device.iconPath,
                width: 48,
                height: 48,
                color:
                    device.state.value ? AppTheme.colors.primary : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),

            // Device Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: Theme.of(Get.context!).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.type.displayName,
                    style: Theme.of(Get.context!).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Obx(
                        () => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                device.isOnline.value
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                device.isOnline.value
                                    ? Icons.circle
                                    : Icons.circle_outlined,
                                color:
                                    device.isOnline.value
                                        ? Colors.green
                                        : Colors.red,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                device.statusText,
                                style: TextStyle(
                                  color:
                                      device.isOnline.value
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (device.roomName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.colors.secondary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.room, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                device.roomName!,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Master Switch
            Obx(
              () => Switch.adaptive(
                value: device.state.value,
                onChanged:
                    device.isOnline.value
                        ? (value) => Get.find<DeviceController>()
                            .toggleDeviceState(device)
                        : null,
                activeColor: AppTheme.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceControlWidget(
    DeviceModel device,
    DeviceController controller,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _getDeviceWidget(device, controller),
      ),
    );
  }

  Widget _getDeviceWidget(DeviceModel device, DeviceController controller) {
    switch (device.type) {
      case DeviceType.onOff:
        return SwitchDeviceWidget(device: device);
      case DeviceType.dimmableLight:
        return DimmerDeviceWidget(device: device);
      case DeviceType.rgb:
        return RgbDeviceWidget(device: device);
      case DeviceType.fan:
        return FanDeviceWidget(device: device);
      case DeviceType.curtain:
        return CurtainDeviceWidget(device: device);
      case DeviceType.irHub:
        return _buildIRHubWidget(device);
    }
  }

  Widget _buildIRHubWidget(DeviceModel device) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.settings_remote, size: 64, color: AppTheme.colors.primary),
        const SizedBox(height: 16),
        Text(
          'IR Hub Control',
          style: Theme.of(Get.context!).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'This device controls infrared devices',
          style: Theme.of(Get.context!).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Get.toNamed('/ir-hub', arguments: device),
          icon: const Icon(Icons.settings_remote),
          label: const Text('Open IR Control'),
        ),
      ],
    );
  }

  Widget _buildQuickActions(DeviceModel device, DeviceController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(Get.context!).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.timer,
                    label: 'Set Timer',
                    onTap: () => _showTimerDialog(device),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.schedule,
                    label: 'Schedule',
                    onTap: () => _showScheduleDialog(device),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.movie,
                    label: 'Add to Scene',
                    onTap: () => _showSceneDialog(device),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.colors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showTimerDialog(DeviceModel device) {
    Get.dialog(
      AlertDialog(
        title: const Text('Set Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Set a timer for ${device.name}'),
            const SizedBox(height: 16),
            // Timer duration selector would go here
            const Text('Timer functionality coming soon'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Timer',
                'Timer functionality will be available soon',
              );
            },
            child: const Text('Set Timer'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(DeviceModel device) {
    Get.dialog(
      AlertDialog(
        title: const Text('Create Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Create a schedule for ${device.name}'),
            const SizedBox(height: 16),
            const Text('Schedule functionality coming soon'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Schedule',
                'Schedule functionality will be available soon',
              );
            },
            child: const Text('Create Schedule'),
          ),
        ],
      ),
    );
  }

  void _showSceneDialog(DeviceModel device) {
    Get.dialog(
      AlertDialog(
        title: const Text('Add to Scene'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add ${device.name} to a scene'),
            const SizedBox(height: 16),
            const Text('Scene functionality coming soon'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Scene',
                'Scene functionality will be available soon',
              );
            },
            child: const Text('Add to Scene'),
          ),
        ],
      ),
    );
  }
}
