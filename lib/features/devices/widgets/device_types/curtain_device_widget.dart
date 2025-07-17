// lib/features/devices/widgets/device_types/curtain_device_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/controllers/device_controller.dart';

class CurtainDeviceWidget extends StatelessWidget {
  final DeviceModel device;

  const CurtainDeviceWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = DeviceController.to;

    return Column(
      children: [
        // Curtain Position Display
        Obx(
          () => Container(
            width: 250,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.3), width: 2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.blue.withOpacity(0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Window frame
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.lightBlue.withOpacity(0.1),
                    ),
                  ),
                ),

                // Curtain
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height:
                        ((device.sliderValue?.value ?? 0) / 100) * (200 - 16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.colors.primary.withOpacity(0.8),
                          AppTheme.colors.primary.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

                // Position indicator
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(device.sliderValue?.value ?? 0).round()}% Closed',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Position Control Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Curtain Position',
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
                      divisions: 10,
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

              // Position Indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Open', style: TextStyle(color: Colors.grey[600])),
                    Text('25%', style: TextStyle(color: Colors.grey[600])),
                    Text('50%', style: TextStyle(color: Colors.grey[600])),
                    Text('75%', style: TextStyle(color: Colors.grey[600])),
                    Text('Closed', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Quick Action Buttons
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.keyboard_arrow_up,
                label: 'Full Open',
                color: Colors.green,
                onTap:
                    device.isOnline.value
                        ? () => controller.curtainFullOpen(device.deviceId)
                        : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.keyboard_arrow_down,
                label: 'Full Close',
                color: Colors.red,
                onTap:
                    device.isOnline.value
                        ? () => controller.curtainFullClose(device.deviceId)
                        : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Partial Control Buttons
        Row(
          children: [
            Expanded(
              child: _buildPartialButton(
                icon: Icons.keyboard_double_arrow_up,
                label: 'Open Until Pressed',
                onTap:
                    device.isOnline.value
                        ? () => _showDurationDialog(
                          context,
                          'Open Until Pressed',
                          (seconds) => controller.curtainOpenUntilPressed(
                            device.deviceId,
                            seconds: seconds,
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPartialButton(
                icon: Icons.keyboard_double_arrow_down,
                label: 'Close Until Pressed',
                onTap:
                    device.isOnline.value
                        ? () => _showDurationDialog(
                          context,
                          'Close Until Pressed',
                          (seconds) => controller.curtainCloseUntilPressed(
                            device.deviceId,
                            seconds: seconds,
                          ),
                        )
                        : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Stop Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                device.isOnline.value
                    ? () => controller.curtainStop(device.deviceId)
                    : null,
            icon: const Icon(Icons.stop),
            label: const Text('STOP'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Preset Positions
        Text(
          'Preset Positions',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPresetButton('25%', 25, controller),
            _buildPresetButton('50%', 50, controller),
            _buildPresetButton('75%', 75, controller),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartialButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.colors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.colors.accent.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.colors.accent, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.colors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(
    String label,
    double value,
    DeviceController controller,
  ) {
    final isSelected =
        (device.sliderValue?.value ?? 0).round() == value.round();

    return GestureDetector(
      onTap:
          device.isOnline.value
              ? () => controller.setDeviceSliderValue(device, value)
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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

  void _showDurationDialog(
    BuildContext context,
    String title,
    Function(int) onConfirm,
  ) {
    int selectedSeconds = 10;

    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select duration in seconds:'),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    Slider(
                      value: selectedSeconds.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${selectedSeconds}s',
                      onChanged: (value) {
                        setState(() {
                          selectedSeconds = value.round();
                        });
                      },
                    ),
                    Text('${selectedSeconds} seconds'),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onConfirm(selectedSeconds);
              Get.back();
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}
