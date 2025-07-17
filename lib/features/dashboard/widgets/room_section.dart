// lib/features/dashboard/widgets/room_section.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/device_model.dart';
import '../../../core/controllers/device_controller.dart';
import 'device_grid.dart';

class RoomSection extends StatelessWidget {
  final String roomName;
  final List<DeviceModel> devices;

  const RoomSection({super.key, required this.roomName, required this.devices});

  @override
  Widget build(BuildContext context) {
    final deviceController = Get.find<DeviceController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to room details
                    Get.toNamed('/rooms');
                  },
                  child: Row(
                    children: [
                      Text(
                        roomName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ],
                  ),
                ),
              ),

              // Room controls
              Row(
                children: [
                  // Device count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${devices.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Room toggle switch
                  Obx(() {
                    final allOn = devices.every((device) => device.state.value);
                    final anyOn = devices.any((device) => device.state.value);

                    return Switch(
                      value: allOn,
                      onChanged:
                          (value) =>
                              _toggleRoomDevices(value, deviceController),
                      activeColor: Colors.green,
                      inactiveThumbColor: anyOn ? Colors.orange : Colors.grey,
                      inactiveTrackColor:
                          anyOn
                              ? Colors.orange.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                    );
                  }),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Room status
          Obx(() {
            final onlineCount = devices.where((d) => d.isOnline.value).length;
            final activeCount = devices.where((d) => d.state.value).length;

            return Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        onlineCount == devices.length
                            ? Colors.green
                            : onlineCount > 0
                            ? Colors.orange
                            : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$onlineCount/${devices.length} online • $activeCount active',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 16),
          DeviceGrid(devices: devices),
        ],
      ),
    );
  }

  void _toggleRoomDevices(bool turnOn, DeviceController deviceController) {
    for (final device in devices) {
      if (device.isOnline.value && device.state.value != turnOn) {
        deviceController.toggleDeviceState(device);
      }
    }

    Get.snackbar(
      'Room Control',
      'All devices in $roomName turned ${turnOn ? 'on' : 'off'}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }
}
