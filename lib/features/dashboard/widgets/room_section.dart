// lib/features/dashboard/widgets/room_section.dart
import 'package:flutter/material.dart';
import '../../../core/models/device_model.dart';
import 'device_grid.dart';

class RoomSection extends StatelessWidget {
  final String roomName;
  final List<DeviceModel> devices;

  const RoomSection({super.key, required this.roomName, required this.devices});

  @override
  Widget build(BuildContext context) {
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
              Text(
                roomName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Switch(
                value: devices.every((device) => device.state.value),
                onChanged: (value) {
                  // Toggle all devices in room
                  // This would be handled by the device controller
                },
                activeColor: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          DeviceGrid(devices: devices),
        ],
      ),
    );
  }
}
