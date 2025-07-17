// lib/core/controllers/room_controller.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/room_model.dart';
import '../models/device_model.dart';
import '../services/supabase_service.dart';
import 'device_controller.dart';

class RoomController extends GetxController {
  static RoomController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;
  final _deviceController = DeviceController.to;

  // Observable lists
  final RxList<RoomModel> rooms = <RoomModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }

  // ===================== ROOM LOADING =====================

  Future<void> loadRooms() async {
    try {
      isLoading.value = true;
      error.value = '';

      final roomsData = await _supabaseService.getRooms();
      final List<RoomModel> loadedRooms = [];

      for (final roomData in roomsData) {
        // Get devices for this room
        final roomDevices =
            _deviceController.devices
                .where((device) => device.roomId == roomData['id'])
                .toList();

        loadedRooms.add(RoomModel.fromSupabase(roomData, devices: roomDevices));
      }

      rooms.assignAll(loadedRooms);
      _logger.i('Loaded ${rooms.length} rooms');
    } catch (e) {
      _logger.e('Error loading rooms: $e');
      error.value = 'Failed to load rooms: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRooms() async {
    try {
      isRefreshing.value = true;
      await loadRooms();
    } finally {
      isRefreshing.value = false;
    }
  }

  // ===================== ROOM OPERATIONS =====================

  Future<RoomModel?> createRoom({
    required String name,
    String? iconPath,
    String? color,
  }) async {
    try {
      final roomData = await _supabaseService.createRoom(
        name,
        iconPath: iconPath ?? RoomTypes.getIconForRoomName(name),
        color: color ?? RoomTypes.getColorForRoomName(name),
      );

      final newRoom = RoomModel.fromSupabase(roomData);
      rooms.add(newRoom);

      _logger.i('Room created: $name');
      return newRoom;
    } catch (e) {
      _logger.e('Error creating room: $e');
      error.value = 'Failed to create room: $e';
      return null;
    }
  }

  Future<bool> updateRoom(RoomModel room) async {
    try {
      await _supabaseService.client
          .from('rooms')
          .update(room.toSupabase())
          .eq('id', room.id);

      final index = rooms.indexWhere((r) => r.id == room.id);
      if (index != -1) {
        rooms[index] = room;
        _logger.d('Room updated: ${room.name}');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error updating room: $e');
      error.value = 'Failed to update room: $e';
      return false;
    }
  }

  Future<bool> deleteRoom(String roomId) async {
    try {
      // First, move all devices in this room to "Unassigned"
      final roomDevices =
          _deviceController.devices
              .where((device) => device.roomId == roomId)
              .toList();

      for (final device in roomDevices) {
        final updatedDevice = device.copyWith(
          roomId: null,
          roomName: 'Unassigned',
        );
        await _deviceController.updateDevice(updatedDevice);
      }

      // Delete the room
      await _supabaseService.client.from('rooms').delete().eq('id', roomId);

      rooms.removeWhere((r) => r.id == roomId);
      _logger.i('Room deleted: $roomId');
      return true;
    } catch (e) {
      _logger.e('Error deleting room: $e');
      error.value = 'Failed to delete room: $e';
      return false;
    }
  }

  // ===================== ROOM DEVICE MANAGEMENT =====================

  Future<void> toggleRoomDevices(String roomId, bool turnOn) async {
    final room = getRoomById(roomId);
    if (room == null) return;

    for (final device in room.devices) {
      if (device.isOnline.value && device.state.value != turnOn) {
        await _deviceController.toggleDeviceState(device);
      }
    }

    _logger.i('Room ${room.name} devices turned ${turnOn ? 'on' : 'off'}');
  }

  Future<void> setRoomBrightness(String roomId, double brightness) async {
    final room = getRoomById(roomId);
    if (room == null) return;

    for (final device in room.devices) {
      if (device.supportsSlider && device.isOnline.value) {
        await _deviceController.setDeviceSliderValue(device, brightness);
      }
    }

    _logger.i('Room ${room.name} brightness set to $brightness%');
  }

  Future<void> addDeviceToRoom(String deviceId, String roomId) async {
    final device = _deviceController.getDeviceById(deviceId);
    if (device == null) return;

    final updatedDevice = device.copyWith(roomId: roomId);
    await _deviceController.updateDevice(updatedDevice);

    // Refresh rooms to update device lists
    await loadRooms();
  }

  Future<void> removeDeviceFromRoom(String deviceId) async {
    await addDeviceToRoom(deviceId, ''); // Empty string for unassigned
  }

  // ===================== ROOM STATISTICS =====================

  Map<String, dynamic> getRoomStatistics(String roomId) {
    final room = getRoomById(roomId);
    if (room == null) return {};

    return room.statistics;
  }

  List<RoomModel> getRoomsByDeviceCount({bool ascending = false}) {
    final sortedRooms = List<RoomModel>.from(rooms);
    sortedRooms.sort((a, b) {
      return ascending
          ? a.deviceCount.compareTo(b.deviceCount)
          : b.deviceCount.compareTo(a.deviceCount);
    });
    return sortedRooms;
  }

  List<RoomModel> getRoomsWithActiveDevices() {
    return rooms.where((room) => room.anyDeviceActive).toList();
  }

  List<RoomModel> getRoomsWithOfflineDevices() {
    return rooms
        .where((room) => room.hasDevices && !room.allDevicesOnline)
        .toList();
  }

  // ===================== SEARCH & FILTER =====================

  List<RoomModel> searchRooms(String query) {
    if (query.isEmpty) return rooms;

    final lowerQuery = query.toLowerCase();
    return rooms.where((room) {
      return room.name.toLowerCase().contains(lowerQuery) ||
          room.devices.any(
            (device) => device.name.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  List<RoomModel> filterRoomsByColor(String color) {
    return rooms.where((room) => room.color == color).toList();
  }

  // ===================== UTILITY METHODS =====================

  RoomModel? getRoomById(String roomId) {
    try {
      return rooms.firstWhere((room) => room.id == roomId);
    } catch (e) {
      return null;
    }
  }

  RoomModel? getRoomByName(String name) {
    try {
      return rooms.firstWhere(
        (room) => room.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<DeviceModel> getDevicesInRoom(String roomId) {
    final room = getRoomById(roomId);
    return room?.devices ?? [];
  }

  bool roomExists(String name) {
    return rooms.any((room) => room.name.toLowerCase() == name.toLowerCase());
  }

  void clearError() {
    error.value = '';
  }

  bool get hasError => error.value.isNotEmpty;

  // ===================== DASHBOARD INSIGHTS =====================

  Map<String, dynamic> getDashboardInsights() {
    if (rooms.isEmpty) return {};

    final totalDevices = rooms.fold<int>(
      0,
      (sum, room) => sum + room.deviceCount,
    );

    final totalOnlineDevices = rooms.fold<int>(
      0,
      (sum, room) => sum + room.onlineDeviceCount,
    );

    final totalActiveDevices = rooms.fold<int>(
      0,
      (sum, room) => sum + room.activeDeviceCount,
    );

    final mostActiveRoom =
        rooms.isNotEmpty
            ? rooms.reduce(
              (a, b) => a.activeDeviceCount > b.activeDeviceCount ? a : b,
            )
            : null;

    final roomsWithOfflineDevices = getRoomsWithOfflineDevices().length;

    return {
      'totalRooms': rooms.length,
      'totalDevices': totalDevices,
      'totalOnlineDevices': totalOnlineDevices,
      'totalActiveDevices': totalActiveDevices,
      'averageDevicesPerRoom':
          rooms.isNotEmpty ? totalDevices / rooms.length : 0,
      'onlinePercentage':
          totalDevices > 0 ? (totalOnlineDevices / totalDevices) * 100 : 0,
      'activePercentage':
          totalDevices > 0 ? (totalActiveDevices / totalDevices) * 100 : 0,
      'mostActiveRoom': mostActiveRoom?.name,
      'roomsWithOfflineDevices': roomsWithOfflineDevices,
    };
  }

  // ===================== ROOM TEMPLATES =====================

  Future<List<RoomModel>> createRoomsFromTemplate() async {
    final createdRooms = <RoomModel>[];

    for (final template in RoomTemplates.templates) {
      if (!roomExists(template.name)) {
        final room = await createRoom(
          name: template.name,
          iconPath: template.iconPath,
          color: template.color,
        );

        if (room != null) {
          createdRooms.add(room);
        }
      }
    }

    return createdRooms;
  }

  // ===================== BULK OPERATIONS =====================

  Future<void> turnOffAllRooms() async {
    for (final room in rooms) {
      if (room.anyDeviceActive) {
        await toggleRoomDevices(room.id, false);
      }
    }
    _logger.i('All rooms turned off');
  }

  Future<void> turnOnAllRooms() async {
    for (final room in rooms) {
      if (room.hasDevices && !room.allDevicesActive) {
        await toggleRoomDevices(room.id, true);
      }
    }
    _logger.i('All rooms turned on');
  }

  // ===================== ROOM AUTOMATION =====================

  Future<void> createRoomScene(
    String roomId,
    String sceneName,
    Map<String, dynamic> sceneConfig,
  ) async {
    final room = getRoomById(roomId);
    if (room == null) return;

    // This would integrate with the scene controller to create room-specific scenes
    // Implementation depends on scene controller structure
    _logger.i('Creating scene "$sceneName" for room ${room.name}');
  }

  // ===================== REAL-TIME UPDATES =====================

  void refreshRoomDevices() {
    // Update room device lists when devices change
    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final updatedDevices =
          _deviceController.devices
              .where((device) => device.roomId == room.id)
              .toList();

      if (updatedDevices.length != room.devices.length) {
        rooms[i] = room.copyWith(devices: updatedDevices);
      }
    }
  }
}
