// lib/features/devices/widgets/device_types/dimmer_device_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/controllers/device_controller.dart';

class DimmerDeviceWidget extends StatelessWidget {
  final DeviceModel device;

  const DimmerDeviceWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = DeviceController.to;

    return Column(
      children: [
        // Brightness Display
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb,
                  size: 60,
                  color: device.state.value ? Colors.white : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  '${(device.sliderValue?.value ?? 0).round()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: device.state.value ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Brightness Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brightness',
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
                      divisions: 20,
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

              // Brightness Level Indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0%', style: TextStyle(color: Colors.grey[600])),
                    Text('25%', style: TextStyle(color: Colors.grey[600])),
                    Text('50%', style: TextStyle(color: Colors.grey[600])),
                    Text('75%', style: TextStyle(color: Colors.grey[600])),
                    Text('100%', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Quick Brightness Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickButton(label: '25%', value: 25, controller: controller),
            _buildQuickButton(label: '50%', value: 50, controller: controller),
            _buildQuickButton(label: '75%', value: 75, controller: controller),
            _buildQuickButton(
              label: '100%',
              value: 100,
              controller: controller,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // On/Off Toggle
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    device.isOnline.value
                        ? () => controller.toggleDeviceState(device)
                        : null,
                icon: Icon(
                  device.state.value
                      ? Icons.lightbulb
                      : Icons.lightbulb_outline,
                ),
                label: Text(device.state.value ? 'Turn Off' : 'Turn On'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      device.state.value
                          ? Colors.orange
                          : AppTheme.colors.primary,
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

  Widget _buildQuickButton({
    required String label,
    required double value,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.colors.primary
                  : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.colors.primary
                    : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
