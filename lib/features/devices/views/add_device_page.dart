// lib/features/devices/views/add_device_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yantra_smart_home_automation/shared/dialogs/add_device_dialog.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../controllers/add_device_controller.dart';

class AddDevicePage extends StatelessWidget {
  const AddDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddDeviceController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Add Device'),
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Addition Methods
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Add New Device',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose how you want to add your device',
                        style: TextStyle(color: Colors.white.withOpacity(0.8)),
                      ),
                      const SizedBox(height: 32),

                      // WiFi Provisioning Card
                      _buildAddMethodCard(
                        title: 'WiFi Provisioning',
                        subtitle: 'Add ESP32 devices via WiFi setup',
                        icon: Icons.wifi,
                        onTap: () => _showWiFiProvisionDialog(context),
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),

                      // Manual Device Entry Card
                      _buildAddMethodCard(
                        title: 'Manual Entry',
                        subtitle: 'Add device with known details',
                        icon: Icons.add_circle_outline,
                        onTap:
                            () => _showManualEntryDialog(context, controller),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),

                      // QR Code Scanner Card
                      _buildAddMethodCard(
                        title: 'QR Code Scanner',
                        subtitle: 'Scan device QR code',
                        icon: Icons.qr_code_scanner,
                        onTap: () => _showQRScannerDialog(context),
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),

                      // Device Discovery Card
                      _buildAddMethodCard(
                        title: 'Auto Discovery',
                        subtitle: 'Search for nearby devices',
                        icon: Icons.search,
                        onTap: () => controller.startDeviceDiscovery(),
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 32),

                      // Recently Added Devices
                      Obx(() {
                        if (controller.recentDevices.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recently Added',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              ...controller.recentDevices.map(
                                (device) => Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: Image.asset(
                                      device.iconPath,
                                      width: 32,
                                      height: 32,
                                    ),
                                    title: Text(device.name),
                                    subtitle: Text(device.type.displayName),
                                    trailing: Icon(
                                      device.isOnline.value
                                          ? Icons.circle
                                          : Icons.circle_outlined,
                                      color:
                                          device.isOnline.value
                                              ? Colors.green
                                              : Colors.grey,
                                    ),
                                    onTap:
                                        () => Get.toNamed(
                                          '/device-control',
                                          arguments: device,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showWiFiProvisionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WiFiProvisionDialog(),
    );
  }

  void _showManualEntryDialog(
    BuildContext context,
    AddDeviceController controller,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Device Manually'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: controller.deviceNameController,
                  label: 'Device Name',
                  icon: Icons.device_hub,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.deviceIdController,
                  label: 'Device ID',
                  icon: Icons.fingerprint,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: controller.registrationIdController,
                  label: 'Registration ID',
                  icon: Icons.app_registration,
                ),
                const SizedBox(height: 16),
                Obx(
                  () => DropdownButtonFormField<String>(
                    value:
                        controller.selectedDeviceType.value.isEmpty
                            ? null
                            : controller.selectedDeviceType.value,
                    decoration: const InputDecoration(
                      labelText: 'Device Type',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items:
                        controller.deviceTypes
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) =>
                            controller.selectedDeviceType.value = value ?? '',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              CustomButton(
                onPressed: () async {
                  await controller.addManualDevice();
                  Get.back();
                },
                isExpanded: false,
                child: const Text('Add Device'),
              ),
            ],
          ),
    );
  }

  void _showQRScannerDialog(BuildContext context) {
    Get.snackbar(
      'Coming Soon',
      'QR Code scanner will be available in the next update',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
