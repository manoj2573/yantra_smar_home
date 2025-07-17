// lib/features/devices/widgets/device_types/switch_device_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/controllers/device_controller.dart';

class SwitchDeviceWidget extends StatelessWidget {
  final DeviceModel device;

  const SwitchDeviceWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = DeviceController.to;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large Switch Button
        Obx(
          () => GestureDetector(
            onTap:
                device.isOnline.value
                    ? () => controller.toggleDeviceState(device)
                    : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors:
                      device.state.value
                          ? [
                            AppTheme.colors.primary.withOpacity(0.8),
                            AppTheme.colors.primary.withOpacity(0.4),
                          ]
                          : [
                            Colors.grey.withOpacity(0.6),
                            Colors.grey.withOpacity(0.2),
                          ],
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        device.state.value
                            ? AppTheme.colors.primary.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                device.state.value ? Icons.power : Icons.power_off,
                size: 80,
                color: device.state.value ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Status Text
        Obx(
          () => Text(
            device.state.value ? 'ON' : 'OFF',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  device.state.value
                      ? AppTheme.colors.primary
                      : Colors.grey[600],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Device Info
        Text(
          'Tap to ${device.state.value ? 'turn off' : 'turn on'}',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),

        const SizedBox(height: 32),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              icon: Icons.power_off,
              label: 'Turn Off',
              isActive: !device.state.value,
              onTap:
                  device.isOnline.value && device.state.value
                      ? () => controller.toggleDeviceState(device)
                      : null,
            ),
            _buildActionButton(
              icon: Icons.power,
              label: 'Turn On',
              isActive: device.state.value,
              onTap:
                  device.isOnline.value && !device.state.value
                      ? () => controller.toggleDeviceState(device)
                      : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isActive,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppTheme.colors.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
          border: Border.all(
            color:
                isActive
                    ? AppTheme.colors.primary
                    : Colors.grey.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.colors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.colors.primary : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
