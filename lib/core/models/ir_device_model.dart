// lib/core/models/ir_device_model.dart
import 'package:equatable/equatable.dart';

enum IRDeviceType {
  tv('TV'),
  ac('Air Conditioner'),
  fan('Fan'),
  chandelier('Chandelier'),
  speaker('Speaker'),
  custom('Custom');

  const IRDeviceType(this.displayName);
  final String displayName;

  static IRDeviceType fromString(String value) {
    return IRDeviceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => IRDeviceType.custom,
    );
  }
}

enum IRButtonType { action, toggle, value }

class IRButtonModel extends Equatable {
  final String id;
  final String irDeviceId;
  final String name;
  final String? iconName;
  final int positionX;
  final int positionY;
  final int width;
  final int height;
  final String? irCode;
  final IRButtonType buttonType;
  final bool isLearned;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IRButtonModel({
    required this.id,
    required this.irDeviceId,
    required this.name,
    this.iconName,
    this.positionX = 0,
    this.positionY = 0,
    this.width = 1,
    this.height = 1,
    this.irCode,
    this.buttonType = IRButtonType.action,
    this.isLearned = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IRButtonModel.fromSupabase(Map<String, dynamic> data) {
    return IRButtonModel(
      id: data['id'] as String,
      irDeviceId: data['ir_device_id'] as String,
      name: data['name'] as String,
      iconName: data['icon_name'] as String?,
      positionX: data['position_x'] as int? ?? 0,
      positionY: data['position_y'] as int? ?? 0,
      width: data['width'] as int? ?? 1,
      height: data['height'] as int? ?? 1,
      irCode: data['ir_code'] as String?,
      buttonType: IRButtonType.values.firstWhere(
        (type) => type.name == data['button_type'],
        orElse: () => IRButtonType.action,
      ),
      isLearned: data['is_learned'] as bool? ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'ir_device_id': irDeviceId,
      'name': name,
      'icon_name': iconName,
      'position_x': positionX,
      'position_y': positionY,
      'width': width,
      'height': height,
      'ir_code': irCode,
      'button_type': buttonType.name,
      'is_learned': isLearned,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  IRButtonModel copyWith({
    String? id,
    String? irDeviceId,
    String? name,
    String? iconName,
    int? positionX,
    int? positionY,
    int? width,
    int? height,
    String? irCode,
    IRButtonType? buttonType,
    bool? isLearned,
    DateTime? updatedAt,
  }) {
    return IRButtonModel(
      id: id ?? this.id,
      irDeviceId: irDeviceId ?? this.irDeviceId,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      width: width ?? this.width,
      height: height ?? this.height,
      irCode: irCode ?? this.irCode,
      buttonType: buttonType ?? this.buttonType,
      isLearned: isLearned ?? this.isLearned,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    irDeviceId,
    name,
    iconName,
    positionX,
    positionY,
    width,
    height,
    irCode,
    buttonType,
    isLearned,
    createdAt,
    updatedAt,
  ];
}

class IRDeviceModel extends Equatable {
  final String id;
  final String irHubId;
  final String name;
  final IRDeviceType type;
  final String? iconPath;
  final Map<String, dynamic> layoutConfig;
  final List<IRButtonModel> buttons;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IRDeviceModel({
    required this.id,
    required this.irHubId,
    required this.name,
    required this.type,
    this.iconPath,
    this.layoutConfig = const {},
    this.buttons = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory IRDeviceModel.fromSupabase(
    Map<String, dynamic> data, {
    List<IRButtonModel>? buttons,
  }) {
    return IRDeviceModel(
      id: data['id'] as String,
      irHubId: data['ir_hub_id'] as String,
      name: data['name'] as String,
      type: IRDeviceType.fromString(data['type'] as String),
      iconPath: data['icon_path'] as String?,
      layoutConfig: (data['layout_config'] as Map<String, dynamic>?) ?? {},
      buttons: buttons ?? [],
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'ir_hub_id': irHubId,
      'name': name,
      'type': type.name,
      'icon_path': iconPath,
      'layout_config': layoutConfig,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  String get defaultIconPath {
    switch (type) {
      case IRDeviceType.tv:
        return 'assets/icons/devices/tv.png';
      case IRDeviceType.ac:
        return 'assets/air-conditioner.png';
      case IRDeviceType.fan:
        return 'assets/fan.png';
      case IRDeviceType.chandelier:
        return 'assets/chandlier.png';
      case IRDeviceType.speaker:
        return 'assets/icons/devices/speaker.png';
      case IRDeviceType.custom:
        return 'assets/power-socket.png';
    }
  }

  List<IRButtonModel> get learnedButtons =>
      buttons.where((b) => b.isLearned).toList();
  List<IRButtonModel> get unlearnedButtons =>
      buttons.where((b) => !b.isLearned).toList();

  bool get isFullyConfigured =>
      buttons.isNotEmpty && buttons.every((b) => b.isLearned);

  int get learningProgress {
    if (buttons.isEmpty) return 0;
    final learned = learnedButtons.length;
    return ((learned / buttons.length) * 100).round();
  }

  IRDeviceModel copyWith({
    String? id,
    String? irHubId,
    String? name,
    IRDeviceType? type,
    String? iconPath,
    Map<String, dynamic>? layoutConfig,
    List<IRButtonModel>? buttons,
    DateTime? updatedAt,
  }) {
    return IRDeviceModel(
      id: id ?? this.id,
      irHubId: irHubId ?? this.irHubId,
      name: name ?? this.name,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      layoutConfig: layoutConfig ?? this.layoutConfig,
      buttons: buttons ?? this.buttons,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    irHubId,
    name,
    type,
    iconPath,
    layoutConfig,
    buttons,
    createdAt,
    updatedAt,
  ];
}

class IRHubModel extends Equatable {
  final String id;
  final String deviceId;
  final String name;
  final String? roomId;
  final String? roomName;
  final String registrationId;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<IRDeviceModel> irDevices;
  final DateTime createdAt;
  final DateTime updatedAt;

  const IRHubModel({
    required this.id,
    required this.deviceId,
    required this.name,
    this.roomId,
    this.roomName,
    required this.registrationId,
    this.isOnline = false,
    this.lastSeen,
    this.irDevices = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory IRHubModel.fromSupabase(
    Map<String, dynamic> data, {
    List<IRDeviceModel>? irDevices,
  }) {
    return IRHubModel(
      id: data['id'] as String,
      deviceId: data['device_id'] as String,
      name: data['name'] as String,
      roomId: data['room_id'] as String?,
      roomName: data['room_name'] as String?,
      registrationId: data['registration_id'] as String,
      isOnline: data['is_online'] as bool? ?? false,
      lastSeen:
          data['last_seen'] != null
              ? DateTime.parse(data['last_seen'] as String)
              : null,
      irDevices: irDevices ?? [],
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'device_id': deviceId,
      'name': name,
      'room_id': roomId,
      'registration_id': registrationId,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  String get statusText => isOnline ? 'Online' : 'Offline';

  int get totalDevices => irDevices.length;
  int get configuredDevices =>
      irDevices.where((d) => d.isFullyConfigured).length;

  bool get isFullySetup =>
      irDevices.isNotEmpty && irDevices.every((d) => d.isFullyConfigured);

  IRHubModel copyWith({
    String? id,
    String? deviceId,
    String? name,
    String? roomId,
    String? roomName,
    String? registrationId,
    bool? isOnline,
    DateTime? lastSeen,
    List<IRDeviceModel>? irDevices,
    DateTime? updatedAt,
  }) {
    return IRHubModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      registrationId: registrationId ?? this.registrationId,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      irDevices: irDevices ?? this.irDevices,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    name,
    roomId,
    roomName,
    registrationId,
    isOnline,
    lastSeen,
    irDevices,
    createdAt,
    updatedAt,
  ];
}

// Predefined layouts for different IR device types
class IRDeviceLayouts {
  static Map<String, dynamic> getTVLayout() {
    return {
      'type': 'tv',
      'gridRows': 6,
      'gridCols': 4,
      'buttons': [
        {'name': 'Power', 'x': 1, 'y': 0, 'w': 2, 'h': 1, 'icon': 'power'},
        {'name': 'Mute', 'x': 0, 'y': 1, 'w': 1, 'h': 1, 'icon': 'volume_off'},
        {'name': 'Vol+', 'x': 0, 'y': 2, 'w': 1, 'h': 1, 'icon': 'volume_up'},
        {'name': 'Vol-', 'x': 0, 'y': 3, 'w': 1, 'h': 1, 'icon': 'volume_down'},
        {
          'name': 'Ch+',
          'x': 3,
          'y': 2,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_up',
        },
        {
          'name': 'Ch-',
          'x': 3,
          'y': 3,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_down',
        },
        {
          'name': 'Up',
          'x': 1,
          'y': 2,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_up',
        },
        {
          'name': 'Down',
          'x': 1,
          'y': 4,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_down',
        },
        {
          'name': 'Left',
          'x': 0,
          'y': 3,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_left',
        },
        {
          'name': 'Right',
          'x': 2,
          'y': 3,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_right',
        },
        {'name': 'OK', 'x': 1, 'y': 3, 'w': 1, 'h': 1, 'icon': 'check_circle'},
        {'name': 'Menu', 'x': 0, 'y': 5, 'w': 1, 'h': 1, 'icon': 'menu'},
        {'name': 'Home', 'x': 1, 'y': 5, 'w': 1, 'h': 1, 'icon': 'home'},
        {'name': 'Back', 'x': 2, 'y': 5, 'w': 1, 'h': 1, 'icon': 'arrow_back'},
        {'name': 'Exit', 'x': 3, 'y': 5, 'w': 1, 'h': 1, 'icon': 'exit_to_app'},
      ],
    };
  }

  static Map<String, dynamic> getACLayout() {
    return {
      'type': 'ac',
      'gridRows': 5,
      'gridCols': 3,
      'buttons': [
        {'name': 'Power', 'x': 1, 'y': 0, 'w': 1, 'h': 1, 'icon': 'power'},
        {'name': 'Temp+', 'x': 2, 'y': 1, 'w': 1, 'h': 1, 'icon': 'add'},
        {'name': 'Temp-', 'x': 2, 'y': 2, 'w': 1, 'h': 1, 'icon': 'remove'},
        {'name': 'Mode', 'x': 1, 'y': 1, 'w': 1, 'h': 1, 'icon': 'ac_unit'},
        {
          'name': 'Fan+',
          'x': 0,
          'y': 1,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_up',
        },
        {
          'name': 'Fan-',
          'x': 0,
          'y': 2,
          'w': 1,
          'h': 1,
          'icon': 'keyboard_arrow_down',
        },
        {'name': 'Timer', 'x': 0, 'y': 3, 'w': 1, 'h': 1, 'icon': 'timer'},
        {'name': 'Swing', 'x': 1, 'y': 3, 'w': 1, 'h': 1, 'icon': 'swap_vert'},
        {'name': 'Sleep', 'x': 2, 'y': 3, 'w': 1, 'h': 1, 'icon': 'bedtime'},
      ],
    };
  }

  static Map<String, dynamic> getFanLayout() {
    return {
      'type': 'fan',
      'gridRows': 3,
      'gridCols': 3,
      'buttons': [
        {'name': 'Power', 'x': 1, 'y': 0, 'w': 1, 'h': 1, 'icon': 'power'},
        {'name': 'Speed+', 'x': 2, 'y': 1, 'w': 1, 'h': 1, 'icon': 'add'},
        {'name': 'Speed-', 'x': 0, 'y': 1, 'w': 1, 'h': 1, 'icon': 'remove'},
        {'name': 'Timer', 'x': 1, 'y': 1, 'w': 1, 'h': 1, 'icon': 'timer'},
        {
          'name': 'Oscillate',
          'x': 1,
          'y': 2,
          'w': 1,
          'h': 1,
          'icon': 'swap_horiz',
        },
      ],
    };
  }

  static Map<String, dynamic> getChandelierLayout() {
    return {
      'type': 'chandelier',
      'gridRows': 3,
      'gridCols': 3,
      'buttons': [
        {'name': 'Power', 'x': 1, 'y': 0, 'w': 1, 'h': 1, 'icon': 'power'},
        {
          'name': 'Bright+',
          'x': 2,
          'y': 1,
          'w': 1,
          'h': 1,
          'icon': 'brightness_high',
        },
        {
          'name': 'Bright-',
          'x': 0,
          'y': 1,
          'w': 1,
          'h': 1,
          'icon': 'brightness_low',
        },
        {
          'name': 'Scene 1',
          'x': 0,
          'y': 2,
          'w': 1,
          'h': 1,
          'icon': 'looks_one',
        },
        {
          'name': 'Scene 2',
          'x': 1,
          'y': 2,
          'w': 1,
          'h': 1,
          'icon': 'looks_two',
        },
        {'name': 'Scene 3', 'x': 2, 'y': 2, 'w': 1, 'h': 1, 'icon': 'looks_3'},
      ],
    };
  }

  static Map<String, dynamic> getSpeakerLayout() {
    return {
      'type': 'speaker',
      'gridRows': 4,
      'gridCols': 3,
      'buttons': [
        {'name': 'Power', 'x': 1, 'y': 0, 'w': 1, 'h': 1, 'icon': 'power'},
        {'name': 'Vol+', 'x': 2, 'y': 1, 'w': 1, 'h': 1, 'icon': 'volume_up'},
        {'name': 'Vol-', 'x': 0, 'y': 1, 'w': 1, 'h': 1, 'icon': 'volume_down'},
        {
          'name': 'Play/Pause',
          'x': 1,
          'y': 1,
          'w': 1,
          'h': 1,
          'icon': 'play_arrow',
        },
        {
          'name': 'Previous',
          'x': 0,
          'y': 2,
          'w': 1,
          'h': 1,
          'icon': 'skip_previous',
        },
        {'name': 'Next', 'x': 2, 'y': 2, 'w': 1, 'h': 1, 'icon': 'skip_next'},
        {'name': 'Mute', 'x': 1, 'y': 2, 'w': 1, 'h': 1, 'icon': 'volume_off'},
        {'name': 'Source', 'x': 0, 'y': 3, 'w': 1, 'h': 1, 'icon': 'input'},
        {
          'name': 'Bluetooth',
          'x': 1,
          'y': 3,
          'w': 1,
          'h': 1,
          'icon': 'bluetooth',
        },
        {'name': 'WiFi', 'x': 2, 'y': 3, 'w': 1, 'h': 1, 'icon': 'wifi'},
      ],
    };
  }

  static Map<String, dynamic> getCustomLayout() {
    return {
      'type': 'custom',
      'gridRows': 4,
      'gridCols': 4,
      'buttons': [], // Empty - user will add custom buttons
    };
  }

  static Map<String, dynamic> getLayoutForType(IRDeviceType type) {
    switch (type) {
      case IRDeviceType.tv:
        return getTVLayout();
      case IRDeviceType.ac:
        return getACLayout();
      case IRDeviceType.fan:
        return getFanLayout();
      case IRDeviceType.chandelier:
        return getChandelierLayout();
      case IRDeviceType.speaker:
        return getSpeakerLayout();
      case IRDeviceType.custom:
        return getCustomLayout();
    }
  }
}
