// lib/core/models/device_model.dart - UPDATED with better icon handling
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

enum DeviceType {
  onOff('On/Off'),
  dimmableLight('Dimmable light'),
  rgb('RGB'),
  fan('Fan'),
  curtain('Curtain'),
  irHub('IR Hub');

  const DeviceType(this.displayName);
  final String displayName;

  static DeviceType fromString(String value) {
    return DeviceType.values.firstWhere(
      (type) => type.displayName == value,
      orElse: () => DeviceType.onOff,
    );
  }
}

enum DeviceStatus { online, offline, connecting, error }

class DeviceModel extends Equatable {
  final String id;
  final String deviceId;
  final String name;
  final DeviceType type;
  final String? roomId;
  final String? roomName;
  final RxBool state;
  final RxDouble? sliderValue;
  final RxString color;
  final String registrationId;
  final String iconPath;
  final RxBool isOnline;
  final DateTime? lastSeen;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.type,
    this.roomId,
    this.roomName,
    bool? initialState,
    double? initialSliderValue,
    String? initialColor,
    required this.registrationId,
    String? iconPath,
    bool? initialIsOnline,
    this.lastSeen,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : state = RxBool(initialState ?? false),
       sliderValue =
           type.supportsSlider ? RxDouble(initialSliderValue ?? 0.0) : null,
       color = RxString(initialColor ?? '#FFFFFF'),
       iconPath = iconPath ?? _getDefaultIconPath(type),
       isOnline = RxBool(initialIsOnline ?? false),
       settings = settings ?? {},
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Factory constructor from Supabase data
  factory DeviceModel.fromSupabase(Map<String, dynamic> data) {
    return DeviceModel(
      id: data['id'] as String,
      deviceId: data['device_id'] as String,
      name: data['name'] as String,
      type: DeviceType.fromString(data['type'] as String),
      roomId: data['room_id'] as String?,
      roomName: data['room_name'] as String?,
      initialState: data['state'] as bool? ?? false,
      // Convert integer to double for slider value
      initialSliderValue: (data['slider_value'] as num?)?.toDouble() ?? 0.0,
      initialColor: data['color'] as String? ?? '#FFFFFF',
      registrationId: data['registration_id'] as String,
      iconPath: data['icon_path'] as String?,
      initialIsOnline: data['is_online'] as bool? ?? false,
      lastSeen:
          data['last_seen'] != null
              ? DateTime.parse(data['last_seen'] as String)
              : null,
      settings: (data['settings'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  // Convert to Supabase data - FIXED VERSION
  Map<String, dynamic> toSupabase() {
    return {
      'device_id': deviceId,
      'name': name,
      'type': type.displayName,
      'room_id': roomId,
      'state': state.value,
      // Ensure slider_value is always an integer
      'slider_value': (sliderValue?.value ?? 0.0).round(),
      'color': color.value,
      'registration_id': registrationId,
      'icon_path': iconPath,
      'is_online': isOnline.value,
      'last_seen': lastSeen?.toIso8601String(),
      'settings': settings,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Convert to MQTT payload - also fix this
  Map<String, dynamic> toMqttPayload() {
    final payload = {
      'deviceId': deviceId,
      'deviceName': name,
      'deviceType': type.displayName,
      'state': state.value,
      'registrationId': registrationId,
      'roomName': roomName ?? 'Unknown Room',
    };

    if (sliderValue != null) {
      // Send as integer for MQTT as well
      payload['sliderValue'] = (sliderValue!.value).round();
    }

    if (type == DeviceType.rgb) {
      payload['color'] = color.value;
    }

    return payload;
  }

  // Helper methods
  bool get supportsSlider => type.supportsSlider;
  bool get supportsColor => type == DeviceType.rgb;
  bool get supportsCurtainControls => type == DeviceType.curtain;

  DeviceStatus get status {
    if (!isOnline.value) return DeviceStatus.offline;
    if (lastSeen != null &&
        DateTime.now().difference(lastSeen!).inMinutes > 5) {
      return DeviceStatus.connecting;
    }
    return DeviceStatus.online;
  }

  String get statusText {
    switch (status) {
      case DeviceStatus.online:
        return 'Online';
      case DeviceStatus.offline:
        return 'Offline';
      case DeviceStatus.connecting:
        return 'Connecting...';
      case DeviceStatus.error:
        return 'Error';
    }
  }

  String get stateText => state.value ? 'On' : 'Off';

  // Copy with method for updates
  DeviceModel copyWith({
    String? id,
    String? deviceId,
    String? name,
    DeviceType? type,
    String? roomId,
    String? roomName,
    bool? state,
    double? sliderValue,
    String? color,
    String? registrationId,
    String? iconPath,
    bool? isOnline,
    DateTime? lastSeen,
    Map<String, dynamic>? settings,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      type: type ?? this.type,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      initialState: state ?? this.state.value,
      initialSliderValue: sliderValue ?? this.sliderValue?.value,
      initialColor: color ?? this.color.value,
      registrationId: registrationId ?? this.registrationId,
      iconPath: iconPath ?? this.iconPath,
      initialIsOnline: isOnline ?? this.isOnline.value,
      lastSeen: lastSeen ?? this.lastSeen,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    name,
    type,
    roomId,
    roomName,
    state.value,
    sliderValue?.value,
    color.value,
    registrationId,
    iconPath,
    isOnline.value,
    lastSeen,
    settings,
    createdAt,
    updatedAt,
  ];

  static String _getDefaultIconPath(DeviceType type) {
    switch (type) {
      case DeviceType.onOff:
        return 'assets/light-bulb.png';
      case DeviceType.dimmableLight:
        return 'assets/light.png';
      case DeviceType.rgb:
        return 'assets/rgb.png';
      case DeviceType.fan:
        return 'assets/fan.png';
      case DeviceType.curtain:
        return 'assets/blinds.png';
      case DeviceType.irHub:
        return 'assets/power-socket.png';
    }
  }
}

// Extension for device type capabilities
extension DeviceTypeExtension on DeviceType {
  bool get supportsSlider {
    switch (this) {
      case DeviceType.dimmableLight:
      case DeviceType.fan:
      case DeviceType.curtain:
        return true;
      case DeviceType.onOff:
      case DeviceType.rgb:
      case DeviceType.irHub:
        return false;
    }
  }

  bool get supportsColor => this == DeviceType.rgb;

  bool get supportsCurtainControls => this == DeviceType.curtain;

  List<String> get availableIcons {
    switch (this) {
      case DeviceType.onOff:
      case DeviceType.dimmableLight:
        return [
          'assets/light-bulb.png',
          'assets/light.png',
          'assets/chandlier.png',
          'assets/power-socket.png',
        ];
      case DeviceType.rgb:
        return [
          'assets/rgb.png',
          'assets/led-strip.png',
          'assets/light.png',
          'assets/chandlier.png',
        ];
      case DeviceType.fan:
        return [
          'assets/fan.png',
          'assets/table_fan.png',
          'assets/cooling-fan.png',
        ];
      case DeviceType.curtain:
        return ['assets/blinds.png', 'assets/room.png'];
      case DeviceType.irHub:
        return ['assets/power-socket.png', 'assets/room.png'];
    }
  }
}
