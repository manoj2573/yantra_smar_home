// lib/features/rooms/views/rooms_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/room_model.dart';
import '../widgets/room_card.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final DeviceController deviceController = DeviceController.to;
  final SupabaseService supabaseService = SupabaseService.to;

  List<RoomModel> rooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      setState(() => isLoading = true);

      final roomsData = await supabaseService.getRooms();
      final List<RoomModel> loadedRooms = [];

      for (final roomData in roomsData) {
        final roomDevices =
            deviceController.devices
                .where((device) => device.roomId == roomData['id'])
                .toList();

        loadedRooms.add(RoomModel.fromSupabase(roomData, devices: roomDevices));
      }

      setState(() {
        rooms = loadedRooms;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'Failed to load rooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Rooms'),
      body: GradientContainer(
        child: SafeArea(
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: AppDimensions.pagePadding,
                    child: Column(
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Rooms',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${rooms.length} rooms',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Rooms Grid
                        Expanded(
                          child:
                              rooms.isEmpty
                                  ? _buildEmptyState()
                                  : RefreshIndicator(
                                    onRefresh: _loadRooms,
                                    child: GridView.builder(
                                      padding: EdgeInsets.zero,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                            childAspectRatio: 0.85,
                                          ),
                                      itemCount: rooms.length,
                                      itemBuilder: (context, index) {
                                        return RoomCard(
                                          room: rooms[index],
                                          onTap:
                                              () => _openRoomDetails(
                                                rooms[index],
                                              ),
                                          onEdit: () => _editRoom(rooms[index]),
                                          onDelete:
                                              () => _deleteRoom(rooms[index]),
                                        );
                                      },
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewRoom,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.room_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No rooms yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first room to organize your devices',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _addNewRoom,
            icon: const Icon(Icons.add),
            label: const Text('Add Room'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _openRoomDetails(RoomModel room) {
    Get.toNamed('/room-details', arguments: room);
  }

  void _editRoom(RoomModel room) {
    _showRoomDialog(room: room);
  }

  void _deleteRoom(RoomModel room) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Room'),
        content: Text(
          'Are you sure you want to delete "${room.name}"?\n\n'
          'Devices in this room will be moved to "Unassigned".',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _performDeleteRoom(room);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDeleteRoom(RoomModel room) async {
    try {
      // Move devices to unassigned first
      for (final device in room.devices) {
        final updatedDevice = device.copyWith(
          roomId: null,
          roomName: 'Unassigned',
        );
        await deviceController.updateDevice(updatedDevice);
      }

      // Delete room from database
      await supabaseService.client.from('rooms').delete().eq('id', room.id);

      await _loadRooms();
      Get.snackbar('Success', 'Room deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete room: $e');
    }
  }

  void _addNewRoom() {
    _showRoomDialog();
  }

  void _showRoomDialog({RoomModel? room}) {
    final isEditing = room != null;
    final nameController = TextEditingController(text: room?.name ?? '');
    String selectedColor = room?.color ?? RoomTypes.availableColors.first;
    String selectedIcon = room?.iconPath ?? 'assets/room.png';

    Get.dialog(
      AlertDialog(
        title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Room Name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Room Name',
                      hintText: 'Enter room name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Color Selection
                  const Text(
                    'Choose Color:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        RoomTypes.availableColors.map((color) {
                          final isSelected = color == selectedColor;
                          return GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(
                                  int.parse(color.replaceFirst('#', '0xFF')),
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Colors.black
                                          : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child:
                                  isSelected
                                      ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                      : null,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Quick Room Types
                  const Text(
                    'Quick Setup:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        RoomTypes.availableRoomTypes.map((roomType) {
                          return ActionChip(
                            label: Text(roomType),
                            onPressed: () {
                              nameController.text = roomType;
                              selectedColor = RoomTypes.getColorForRoomName(
                                roomType,
                              );
                              selectedIcon = RoomTypes.getIconForRoomName(
                                roomType,
                              );
                              setState(() {});
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please enter a room name');
                return;
              }

              Get.back();
              await _saveRoom(
                isEditing: isEditing,
                roomId: room?.id,
                name: nameController.text.trim(),
                color: selectedColor,
                iconPath: selectedIcon,
              );
            },
            child: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRoom({
    required bool isEditing,
    String? roomId,
    required String name,
    required String color,
    required String iconPath,
  }) async {
    try {
      if (isEditing && roomId != null) {
        // Update existing room
        await supabaseService.client
            .from('rooms')
            .update({
              'name': name,
              'color': color,
              'icon_path': iconPath,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', roomId);

        Get.snackbar('Success', 'Room updated successfully');
      } else {
        // Create new room
        await supabaseService.createRoom(
          name,
          iconPath: iconPath,
          color: color,
        );

        Get.snackbar('Success', 'Room created successfully');
      }

      await _loadRooms();
    } catch (e) {
      Get.snackbar('Error', 'Failed to save room: $e');
    }
  }
}
