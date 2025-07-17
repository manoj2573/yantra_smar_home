// lib/features/devices/widgets/device_types/fan_device_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/controllers/device_controller.dart';

class FanDeviceWidget extends StatelessWidget {
  final DeviceModel device;

  const FanDeviceWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = DeviceController.to;

    return Column(
      children: [
        // Fan Speed Display
        Obx(
          () => Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors:
                    device.state.value
                        ? [
                          AppTheme.colors.primary.withOpacity(
                            (device.sliderValue?.value ?? 0) / 100,
                          ),
                          AppTheme.colors.primary.withOpacity(0.1),
                        ]
                        : [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.1),
                        ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating fan blades animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end:
                        device.state.value
                            ? (device.sliderValue?.value ?? 0) / 100
                            : 0.0,
                  ),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value * 6.28, // Full rotation
                      child: Icon(
                        Icons.toys,
                        size: 80,
                        color:
                            device.state.value
                                ? Colors.white
                                : Colors.grey[400],
                      ),
                    );
                  },
                ),

                // Speed percentage
                Positioned(
                  bottom: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Speed ${(device.sliderValue?.value ?? 0).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Speed Control Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fan Speed',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.withOpacity(0.1),
                  ),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      activeTrackColor: AppTheme.colors.primary,
                      inactiveTrackColor: Colors.grey.withOpacity(0.3),
                      thumbColor: AppTheme.colors.primary,
                      overlayColor: AppTheme.colors.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: device.sliderValue?.value ?? 0,
                      min: 0,
                      max: 100,
                      divisions: 5, // 0%, 20%, 40%, 60%, 80%, 100%
                      onChanged:
                          device.isOnline.value
                              ? (value) {
                                controller.setDeviceSliderValue(device, value);
                              }
                              : null,
                    ),
                  ),
                ),
              ),

              // Speed Level Indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Off', style: TextStyle(color: Colors.grey[600])),
                    Text('Low', style: TextStyle(color: Colors.grey[600])),
                    Text('Med', style: TextStyle(color: Colors.grey[600])),
                    Text('High', style: TextStyle(color: Colors.grey[600])),
                    Text('Max', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Speed Preset Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSpeedButton(
              label: 'Low',
              value: 20,
              icon: Icons.air,
              controller: controller,
            ),
            _buildSpeedButton(
              label: 'Medium',
              value: 50,
              icon: Icons.air,
              controller: controller,
            ),
            _buildSpeedButton(
              label: 'High',
              value: 80,
              icon: Icons.air,
              controller: controller,
            ),
            _buildSpeedButton(
              label: 'Max',
              value: 100,
              icon: Icons.air,
              controller: controller,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Fan Features
        Row(
          children: [
            Expanded(
              child: _buildFeatureButton(
                icon: Icons.swap_vert,
                label: 'Oscillate',
                isActive: false, // This would be a separate property
                onTap: () {
                  Get.snackbar('Feature', 'Oscillate function coming soon');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureButton(
                icon: Icons.timer,
                label: 'Timer',
                isActive: false,
                onTap: () {
                  Get.snackbar('Feature', 'Timer function coming soon');
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // On/Off Toggle
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    device.isOnline.value
                        ? () => controller.toggleDeviceState(device)
                        : null,
                icon: Icon(device.state.value ? Icons.stop : Icons.play_arrow),
                label: Text(device.state.value ? 'Turn Off' : 'Turn On'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      device.state.value ? Colors.red : AppTheme.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpeedButton({
    required String label,
    required double value,
    required IconData icon,
    required DeviceController controller,
  }) {
    final isSelected =
        (device.sliderValue?.value ?? 0).round() == value.round();

    return GestureDetector(
      onTap:
          device.isOnline.value
              ? () => controller.setDeviceSliderValue(device, value)
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.colors.primary
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.colors.primary
                    : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color:
              isActive
                  ? AppTheme.colors.accent.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isActive
                    ? AppTheme.colors.accent
                    : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.colors.accent : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.colors.accent : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
