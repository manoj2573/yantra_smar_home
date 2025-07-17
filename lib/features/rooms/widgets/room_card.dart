// lib/features/rooms/widgets/room_card.dart
import 'package:flutter/material.dart';
import '../../../core/models/room_model.dart';
import '../../../app/theme/app_dimensions.dart';

class RoomCard extends StatelessWidget {
  final RoomModel room;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RoomCard({
    super.key,
    required this.room,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final roomColor = Color(int.parse(room.color.replaceFirst('#', '0xFF')));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppDimensions.borderRadiusLG,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [roomColor.withOpacity(0.8), roomColor.withOpacity(0.6)],
          ),
          boxShadow: [
            BoxShadow(
              color: roomColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: AppDimensions.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppDimensions.borderRadiusMD,
                    ),
                    child: Icon(Icons.room, color: Colors.white, size: 32),
                  ),

                  const Spacer(),

                  // Room Name
                  Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Device Count
                  Text(
                    '${room.deviceCount} device${room.deviceCount != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Status Indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              room.hasDevices
                                  ? (room.anyDeviceActive
                                      ? Colors.green
                                      : Colors.grey)
                                  : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          room.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Options Menu
            if (onEdit != null || onDelete != null)
              Positioned(
                top: 8,
                right: 8,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusMD,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                      ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
