// lib/features/devices/widgets/device_types/rgb_device_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/models/device_model.dart';
import '../../../../core/controllers/device_controller.dart';

class RgbDeviceWidget extends StatelessWidget {
  final DeviceModel device;

  const RgbDeviceWidget({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final DeviceController controller = DeviceController.to;

    return Column(
      children: [
        // Color Display
        Obx(
          () => Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors:
                    device.state.value
                        ? [
                          _hexToColor(device.color.value),
                          _hexToColor(device.color.value).withOpacity(0.3),
                        ]
                        : [
                          Colors.grey.withOpacity(0.6),
                          Colors.grey.withOpacity(0.1),
                        ],
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      device.state.value
                          ? _hexToColor(device.color.value).withOpacity(0.4)
                          : Colors.grey.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.color_lens,
                  size: 40,
                  color: device.state.value ? Colors.white : Colors.grey[400],
                ),
                const SizedBox(height: 8),
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 6,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.black.withOpacity(0.3),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   // child: Text(
                //   //   device.color.value.toUpperCase(),
                //   //   style: const TextStyle(
                //   //     color: Colors.white,
                //   //     fontWeight: FontWeight.w600,
                //   //     fontSize: 12,
                //   //   ),
                //   // ),
                // ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Brightness Slider
        if (device.supportsSlider) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brightness',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Obx(
                  () => Slider(
                    value: device.sliderValue?.value ?? 100,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged:
                        device.isOnline.value
                            ? (value) =>
                                controller.setDeviceSliderValue(device, value)
                            : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Color Presets
        Text(
          'Color Presets',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _colorPresets
                  .map(
                    (preset) => _buildColorPreset(
                      preset['color'] as Color,
                      preset['name'] as String,
                      controller,
                    ),
                  )
                  .toList(),
        ),

        const SizedBox(height: 24),

        // Advanced Color Picker Button - ENHANCED
        ElevatedButton.icon(
          onPressed:
              device.isOnline.value
                  ? () => _showAdvancedColorPicker(context, controller)
                  : null,
          icon: const Icon(Icons.palette),
          label: const Text('Advanced Color Picker'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),

        const SizedBox(height: 16),

        // Quick Color Temperature Buttons
        Text(
          'Color Temperature',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTemperatureButton(
              'Warm',
              const Color(0xFFFFB366),
              controller,
            ),
            _buildTemperatureButton(
              'Cool',
              const Color(0xFFB3D9FF),
              controller,
            ),
            _buildTemperatureButton(
              'Daylight',
              const Color(0xFFFFFFFF),
              controller,
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

  Widget _buildColorPreset(
    Color color,
    String name,
    DeviceController controller,
  ) {
    final isSelected =
        _colorToHex(color).toLowerCase() == device.color.value.toLowerCase();

    return GestureDetector(
      onTap:
          device.isOnline.value
              ? () => controller.setDeviceColor(device, _colorToHex(color))
              : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.grey.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child:
            isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
      ),
    );
  }

  Widget _buildTemperatureButton(
    String label,
    Color color,
    DeviceController controller,
  ) {
    final isSelected =
        _colorToHex(color).toLowerCase() == device.color.value.toLowerCase();

    return GestureDetector(
      onTap:
          device.isOnline.value
              ? () => controller.setDeviceColor(device, _colorToHex(color))
              : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : color.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showAdvancedColorPicker(
    BuildContext context,
    DeviceController controller,
  ) {
    Color selectedColor = _hexToColor(device.color.value);

    Get.dialog(
      AlertDialog(
        title: const Text('Choose Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color Wheel Picker
              ColorPicker(
                pickerColor: selectedColor,
                onColorChanged: (color) => selectedColor = color,
                colorPickerWidth: 300,
                pickerAreaHeightPercent: 0.7,
                enableAlpha: false,
                displayThumbColor: true,
                paletteType: PaletteType.hueWheel,
                labelTypes: const [],
                pickerAreaBorderRadius: BorderRadius.circular(20),
              ),

              const SizedBox(height: 20),

              // RGB/HSV Values Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Hex: ${_colorToHex(selectedColor)}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RGB: ${selectedColor.red}, ${selectedColor.green}, ${selectedColor.blue}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Preview
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      color:
                          selectedColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.setDeviceColor(device, _colorToHex(selectedColor));
              Get.back();
              Get.snackbar(
                'Color Changed',
                'Color set to ${_colorToHex(selectedColor)}',
                backgroundColor: selectedColor.withOpacity(0.8),
                colorText:
                    selectedColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha channel
    }
    return Color(int.parse(hex, radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static final List<Map<String, dynamic>> _colorPresets = [
    {'color': Colors.red, 'name': 'Red'},
    {'color': Colors.green, 'name': 'Green'},
    {'color': Colors.blue, 'name': 'Blue'},
    {'color': Colors.yellow, 'name': 'Yellow'},
    {'color': Colors.purple, 'name': 'Purple'},
    {'color': Colors.orange, 'name': 'Orange'},
    {'color': Colors.pink, 'name': 'Pink'},
    {'color': Colors.cyan, 'name': 'Cyan'},
  ];
}
