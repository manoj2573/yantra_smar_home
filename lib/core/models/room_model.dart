// lib/core/models/room_model.dart
import 'package:equatable/equatable.dart';
import 'device_model.dart';

class RoomModel extends Equatable {
  final String id;
  final String name;
  final String iconPath;
  final String color;
  final List<DeviceModel> devices;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoomModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.color,
    this.devices = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from Supabase data
  factory RoomModel.fromSupabase(Map<String, dynamic> data, {
    List<DeviceModel>? devices,
  }) {
    return RoomModel(
      id: data['id'] as String,
      name: data['name'] as String,
      iconPath: data['icon_path'] as String? ?? 'assets/room.png',
      color: data['color'] as String? ?? '#FF9800',
      devices: devices ?? [],
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  // Convert to Supabase data
  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'icon_path': iconPath,
      'color': color,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_path': iconPath,
      'color': color,
      'device_count': devices.length,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Factory constructor from JSON
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconPath: json['icon_path'] as String? ?? 'assets/room.png',
      color: json['color'] as String? ?? '#FF9800',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Helper getters
  int get deviceCount => devices.length;
  int get onlineDeviceCount => devices.where((d) => d.isOnline.value).length;
  int get activeDeviceCount => devices.where((d) => d.state.value).length;

  bool get hasDevices => devices.isNotEmpty;
  bool get allDevicesOnline => devices.isNotEmpty && devices.every((d) => d.isOnline.value);
  bool get allDevicesActive => devices.isNotEmpty && devices.every((d) => d.state.value);
  bool get anyDeviceActive => devices.any((d) => d.state.value);

  double get deviceOnlinePercentage {
    if (devices.isEmpty) return 0.0;
    return (onlineDeviceCount / deviceCount) * 100;
  }

  double get deviceActivePercentage {
    if (devices.isEmpty) return 0.0;
    return (activeDeviceCount / deviceCount) * 100;
  }

  // Get devices by type
  List<DeviceModel> getDevicesByType(DeviceType type) {
    return devices.where((device) => device.type == type).toList();
  }

  // Get devices by status
  List<DeviceModel> get onlineDevices => devices.where((d) => d.isOnline.value).toList();
  List<DeviceModel> get offlineDevices => devices.where((d) => !d.isOnline.value).toList();
  List<DeviceModel> get activeDevices => devices.where((d) => d.state.value).toList();
  List<DeviceModel> get inactiveDevices => devices.where((d) => !d.state.value).toList();

  // Status text for room
  String get statusText {
    if (devices.isEmpty) return 'No devices';
    if (allDevicesActive) return 'All devices on';
    if (!anyDeviceActive) return 'All devices off';
    return '$activeDeviceCount of $deviceCount devices on';
  }

  String get connectivityText {
    if (devices.isEmpty) return 'No devices';
    if (allDevicesOnline) return 'All devices online';
    if (onlineDeviceCount == 0) return 'All devices offline';
    return '$onlineDeviceCount of $deviceCount devices online';
  }

  // Room statistics
  Map<String, dynamic> get statistics {
    final deviceTypeStats = <String, int>{};
    for (final device in devices) {
      final typeName = device.type.displayName;
      deviceTypeStats[typeName] = (deviceTypeStats[typeName] ?? 0) + 1;
    }

    return {
      'total_devices': deviceCount,
      'online_devices': onlineDeviceCount,
      'active_devices': activeDeviceCount,
      'device_types': deviceTypeStats,
      'online_percentage': deviceOnlinePercentage.round(),
      'active_percentage': deviceActivePercentage.round(),
    };
  }

  // Copy with method for updates
  RoomModel copyWith({
    String? id,
    String? name,
    String? iconPath,
    String? color,
    List<DeviceModel>? devices,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      devices: devices ?? this.devices,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconPath,
        color,
        devices,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'RoomModel(id: $id, name: $name, devices: ${devices.length})';
  }
}

// Predefined room types and icons
class RoomTypes {
  static const Map<String, String> roomIcons = {
    'Living Room': 'assets/icons/rooms/living_room.png',
    'Bedroom': 'assets/icons/rooms/bedroom.png',
    'Kitchen': 'assets/icons/rooms/kitchen.png',
    'Bathroom': 'assets/icons/rooms/bathroom.png',
    'Office': 'assets/icons/rooms/office.png',
    'Dining Room': 'assets/icons/rooms/dining_room.png',
    'Garage': 'assets/icons/rooms/garage.png',
    'Garden': 'assets/icons/rooms/garden.png',
    'Balcony': 'assets/icons/rooms/balcony.png',
    'Guest Room': 'assets/icons/rooms/guest_room.png',
    'Laundry': 'assets/icons/rooms/laundry.png',
    'Storage': 'assets/icons/rooms/storage.png',
  };

  static const Map<String, String> roomColors = {
    'Living Room': '#FF9800',
    'Bedroom': '#9C27B0',
    'Kitchen': '#4CAF50',
    'Bathroom': '#2196F3',
    'Office': '#607D8B',
    'Dining Room': '#FF5722',
    'Garage': '#795548',
    'Garden': '#8BC34A',
    'Balcony': '#00BCD4',
    'Guest Room': '#E91E63',
    'Laundry': '#9E9E9E',
    'Storage': '#FFC107',
  };

  static String getIconForRoomName(String roomName) {
    return roomIcons[roomName] ?? 'assets/room.png';
  }

  static String getColorForRoomName(String roomName) {
    return roomColors[roomName] ?? '#FF9800';
  }

  static List<String> get availableRoomTypes => roomIcons.keys.toList();
  
  static List<String> get availableColors => [
    '#FF9800', // Orange
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#9C27B0', // Purple
    '#F44336', // Red
    '#FF5722', // Deep Orange
    '#607D8B', // Blue Grey
    '#795548', // Brown
    '#9E9E9E', // Grey
    '#FFC107', // Amber
    '#E91E63', // Pink
    '#00BCD4', // Cyan
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
  ];
}

// Room template for quick setup
class RoomTemplate {
  final String name;
  final String iconPath;
  final String color;
  final List<DeviceTemplate> suggestedDevices;

  const RoomTemplate({
    required this.name,
    required this.iconPath,
    required this.color,
    this.suggestedDevices = const [],
  });

  RoomModel toRoomModel({
    required String id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomModel(
      id: id,
      name: name,
      iconPath: iconPath,
      color: color,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class DeviceTemplate {
  final String name;
  final DeviceType type;
  final String iconPath;

  const DeviceTemplate({
    required this.name,
    required this.type,
    required this.iconPath,
  });
}

// Predefined room templates
class RoomTemplates {
  static const List<RoomTemplate> templates = [
    RoomTemplate(
      name: 'Living Room',
      iconPath: 'assets/icons/rooms/living_room.png',
      color: '#FF9800',
      suggestedDevices: [
        DeviceTemplate(
          name: 'Main Light',
          type: DeviceType.dimmableLight,
          iconPath: 'assets/chandlier.png',
        ),
        DeviceTemplate(
          name: 'TV Light Strip',
          type: DeviceType.rgb,
          iconPath: 'assets/led-strip.png',
        ),
        DeviceTemplate(
          name: 'Ceiling Fan',
          type: DeviceType.fan,
          iconPath: 'assets/fan.png',
        ),
      ],
    ),
    RoomTemplate(
      name: 'Bedroom',
      iconPath: 'assets/icons/rooms/bedroom.png',
      color: '#9C27B0',
      suggestedDevices: [
        DeviceTemplate(
          name: 'Bedside Lamp',
          type: DeviceType.dimmableLight,
          iconPath: 'assets/light.png',
        ),
        DeviceTemplate(
          name: 'Main Light',
          type: DeviceType.onOff,
          iconPath: 'assets/light-bulb.png',
        ),
        DeviceTemplate(
          name: 'Curtains',
          type: DeviceType.curtain,
          iconPath: 'assets/blinds.png',
        ),
      ],
    ),
    RoomTemplate(
      name: 'Kitchen',
      iconPath: 'assets/icons/rooms/kitchen.png',
      color: '#4CAF50',
      suggestedDevices: [
        DeviceTemplate(
          name: 'Main Light',
          type: DeviceType.onOff,
          iconPath: 'assets/light-bulb.png',
        ),
        DeviceTemplate(
          name: 'Under Cabinet Lights',
          type: DeviceType.dimmableLight,
          iconPath: 'assets/led-strip.png',
        ),
      ],
    ),
  ];

  static RoomTemplate? getTemplate(String roomName) {
    try {
      return templates.firstWhere((template) => template.name == roomName);
    } catch (e) {
      return null;
    }
  }
}