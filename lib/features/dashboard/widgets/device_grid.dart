// lib/features/dashboard/widgets/device_grid.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/device_model.dart';
import '../../../core/controllers/device_controller.dart';

class DeviceGrid extends StatelessWidget {
  final List<DeviceModel> devices;

  const DeviceGrid({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    final deviceController = Get.find<DeviceController>();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];

        return Obx(
          () => GestureDetector(
            onTap: () => deviceController.toggleDeviceState(device),
            onLongPress: () {
              // Navigate to device control page
              // Get.toNamed('/device-control', arguments: device);
            },
            child: Container(
              decoration: BoxDecoration(
                color:
                    device.state.value
                        ? Colors.green.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      device.state.value
                          ? Colors.green
                          : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Device icon
                  Image.asset(
                    device.iconPath,
                    width: 32,
                    height: 32,
                    color: device.state.value ? Colors.white : Colors.white70,
                  ),
                  const SizedBox(height: 8),
                  // Device name
                  Text(
                    device.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight:
                          device.state.value
                              ? FontWeight.w600
                              : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Device status
                  Text(
                    device.stateText,
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          device.state.value
                              ? Colors.greenAccent
                              : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
