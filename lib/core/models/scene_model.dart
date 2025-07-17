// lib/core/models/scene_model.dart
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'device_model.dart';

enum SceneStatus { inactive, active, executing, error }

class SceneDeviceAction extends Equatable {
  final String deviceId;
  final String deviceName;
  final DeviceType deviceType;
  final bool state;
  final double? sliderValue;
  final String? color;
  final int delaySeconds;
  final Map<String, dynamic> customParameters;

  const SceneDeviceAction({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.state,
    this.sliderValue,
    this.color,
    this.delaySeconds = 0,
    this.customParameters = const {},
  });

  factory SceneDeviceAction.fromJson(Map<String, dynamic> json) {
    return SceneDeviceAction(
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String? ?? 'Unknown Device',
      deviceType: DeviceType.fromString(json['device_type'] as String? ?? 'On/Off'),
      state: json['state'] as bool,
      sliderValue: (json['slider_value'] as num?)?.toDouble(),
      color: json['color'] as String?,
      delaySeconds: json['delay_seconds'] as int? ?? 0,
      customParameters: (json['custom_parameters'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType.displayName,
      'state': state,
      if (sliderValue != null) 'slider_value': sliderValue,
      if (color != null) 'color': color,
      'delay_seconds': delaySeconds,
      'custom_parameters': customParameters,
    };
  }

  // Convert to device MQTT payload
  Map<String, dynamic> toMqttPayload(String registrationId) {
    final payload = {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType.displayName,
      'state': state,
      'registrationId': registrationId,
    };

    if (sliderValue != null) {
      payload['sliderValue'] = sliderValue!.toInt();
    }

    if (color != null) {
      payload['color'] = color!;
    }

    // Add custom parameters
    payload.addAll(customParameters);

    return payload;
  }

  String get actionDescription {
    final List<String> parts = [];
    
    if (state) {
      parts.add('Turn ON');
    } else {
      parts.add('Turn OFF');
    }

    if (sliderValue != null && sliderValue! > 0) {
      parts.add('Set to ${sliderValue!.toInt()}%');
    }

    if (color != null) {
      parts.add('Color: $color');
    }

    if (delaySeconds > 0) {
      parts.add('Delay: ${delaySeconds}s');
    }

    return parts.join(', ');
  }

  SceneDeviceAction copyWith({
    String? deviceId,
    String? deviceName,
    DeviceType? deviceType,
    bool? state,
    double? sliderValue,
    String? color,
    int? delaySeconds,
    Map<String, dynamic>? customParameters,
  }) {
    return SceneDeviceAction(
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      state: state ?? this.state,
      sliderValue: sliderValue ?? this.sliderValue,
      color: color ?? this.color,
      delaySeconds: delaySeconds ?? this.delaySeconds,
      customParameters: customParameters ?? this.customParameters,
    );
  }

  @override
  List<Object?> get props => [
        deviceId,
        deviceName,
        deviceType,
        state,
        sliderValue,
        color,
        delaySeconds,
        customParameters,
      ];
}

class SceneModel extends Equatable {
  final String id;
  final String name;
  final String iconPath;
  final List<SceneDeviceAction> deviceActions;
  final RxBool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Runtime properties
  final RxString status;
  final RxDouble executionProgress;
  final RxString currentAction;

  SceneModel({
    required this.id,
    required this.name,
    String? iconPath,
    List<SceneDeviceAction>? deviceActions,
    bool? initialIsActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : iconPath = iconPath ?? _getDefaultIconPath(name),
        deviceActions = deviceActions ?? [],
        isActive = RxBool(initialIsActive ?? false),
        status = RxString('inactive'),
        executionProgress = RxDouble(0.0),
        currentAction = RxString(''),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory SceneModel.fromSupabase(Map<String, dynamic> data) {
    final devicesData = data['devices'] as List<dynamic>? ?? [];
    final deviceActions = devicesData
        .cast<Map<String, dynamic>>()
        .map((deviceData) => SceneDeviceAction.fromJson(deviceData))
        .toList();

    return SceneModel(
      id: data['id'] as String,
      name: data['name'] as String,
      iconPath: data['icon_path'] as String?,
      deviceActions: deviceActions,
      initialIsActive: data['is_active'] as bool? ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'name': name,
      'icon_path': iconPath,
      'devices': deviceActions.map((action) => action.toJson()).toList(),
      'is_active': isActive.value,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_path': iconPath,
      'device_actions': deviceActions.map((action) => action.toJson()).toList(),
      'is_active': isActive.value,
      'device_count': deviceActions.length,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  int get deviceCount => deviceActions.length;
  bool get hasDevices => deviceActions.isNotEmpty;
  bool get isEmpty => deviceActions.isEmpty;

  // Get actions with delays
  List<SceneDeviceAction> get actionsWithDelay =>
      deviceActions.where((action) => action.delaySeconds > 0).toList();

  List<SceneDeviceAction> get immediateActions =>
      deviceActions.where((action) => action.delaySeconds == 0).toList();

  // Get total execution time (max delay + buffer)
  int get totalExecutionTimeSeconds {
    if (deviceActions.isEmpty) return 0;
    final maxDelay = deviceActions
        .map((action) => action.delaySeconds)
        .reduce((a, b) => a > b ? a : b);
    return maxDelay + 5; // Add 5 seconds buffer
  }

  // Scene statistics
  Map<String, dynamic> get statistics {
    final deviceTypeStats = <String, int>{};
    final onDeviceCount = deviceActions.where((a) => a.state).length;
    final offDeviceCount = deviceActions.where((a) => !a.state).length;

    for (final action in deviceActions) {
      final typeName = action.deviceType.displayName;
      deviceTypeStats[typeName] = (deviceTypeStats[typeName] ?? 0) + 1;
    }

    return {
      'total_devices': deviceCount,
      'turn_on_count': onDeviceCount,
      'turn_off_count': offDeviceCount,
      'device_types': deviceTypeStats,
      'has_delays': actionsWithDelay.isNotEmpty,
      'total_execution_time': totalExecutionTimeSeconds,
    };
  }

  // Scene execution methods
  SceneModel activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  SceneModel deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  // Add device action
  SceneModel addDeviceAction(SceneDeviceAction action) {
    final updatedActions = List<SceneDeviceAction>.from(deviceActions);
    
    // Remove existing action for the same device if any
    updatedActions.removeWhere((a) => a.deviceId == action.deviceId);
    updatedActions.add(action);
    
    return copyWith(
      deviceActions: updatedActions,
      updatedAt: DateTime.now(),
    );
  }

  // Remove device action
  SceneModel removeDeviceAction(String deviceId) {
    final updatedActions = deviceActions
        .where((action) => action.deviceId != deviceId)
        .toList();
    
    return copyWith(
      deviceActions: updatedActions,
      updatedAt: DateTime.now(),
    );
  }

  // Update device action
  SceneModel updateDeviceAction(SceneDeviceAction updatedAction) {
    final updatedActions = deviceActions.map((action) {
      if (action.deviceId == updatedAction.deviceId) {
        return updatedAction;
      }
      return action;
    }).toList();
    
    return copyWith(
      deviceActions: updatedActions,
      updatedAt: DateTime.now(),
    );
  }

  // Check if device is in scene
  bool hasDevice(String deviceId) {
    return deviceActions.any((action) => action.deviceId == deviceId);
  }

  // Get action for specific device
  SceneDeviceAction? getActionForDevice(String deviceId) {
    try {
      return deviceActions.firstWhere((action) => action.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  // Validation
  bool get isValid => name.isNotEmpty && deviceActions.isNotEmpty;

  List<String> get validationErrors {
    final errors = <String>[];
    
    if (name.isEmpty) {
      errors.add('Scene name cannot be empty');
    }
    
    if (deviceActions.isEmpty) {
      errors.add('Scene must have at least one device action');
    }
    
    // Check for duplicate device IDs
    final deviceIds = deviceActions.map((a) => a.deviceId).toList();
    final uniqueDeviceIds = deviceIds.toSet();
    if (deviceIds.length != uniqueDeviceIds.length) {
      errors.add('Scene contains duplicate device actions');
    }
    
    return errors;
  }

  // Copy with method
  SceneModel copyWith({
    String? id,
    String? name,
    String? iconPath,
    List<SceneDeviceAction>? deviceActions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SceneModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      deviceActions: deviceActions ?? this.deviceActions,
      initialIsActive: isActive ?? this.isActive.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconPath,
        deviceActions,
        isActive.value,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'SceneModel(id: $id, name: $name, devices: ${deviceActions.length})';
  }

  static String _getDefaultIconPath(String sceneName) {
    final lowerName = sceneName.toLowerCase();
    
    if (lowerName.contains('movie') || lowerName.contains('cinema')) {
      return 'assets/icons/scenes/movie.png';
    } else if (lowerName.contains('party') || lowerName.contains('celebration')) {
      return 'assets/icons/scenes/party.png';
    } else if (lowerName.contains('sleep') || lowerName.contains('night')) {
      return 'assets/icons/scenes/sleep.png';
    } else if (lowerName.contains('work') || lowerName.contains('focus')) {
      return 'assets/icons/scenes/work.png';
    } else if (lowerName.contains('relax') || lowerName.contains('chill')) {
      return 'assets/icons/scenes/relax.png';
    } else if (lowerName.contains('morning') || lowerName.contains('wake')) {
      return 'assets/icons/scenes/morning.png';
    } else if (lowerName.contains('dinner') || lowerName.contains('dining')) {
      return 'assets/icons/scenes/dinner.png';
    } else if (lowerName.contains('read') || lowerName.contains('study')) {
      return 'assets/icons/scenes/reading.png';
    } else {
      return 'assets/icons/scenes/custom.png';
    }
  }
}

// Predefined scene templates
class SceneTemplate {
  final String name;
  final String iconPath;
  final String description;
  final List<SceneDeviceAction> deviceActions;

  const SceneTemplate({
    required this.name,
    required this.iconPath,
    required this.description,
    this.deviceActions = const [],
  });

  SceneModel toSceneModel({
    required String id,
    List<SceneDeviceAction>? customActions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SceneModel(
      id: id,
      name: name,
      iconPath: iconPath,
      deviceActions: customActions ?? deviceActions,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class SceneTemplates {
  static const List<SceneTemplate> templates = [
    SceneTemplate(
      name: 'Good Night',
      iconPath: 'assets/icons/scenes/sleep.png',
      description: 'Turn off all lights and devices for sleep',
    ),
    SceneTemplate(
      name: 'Good Morning',
      iconPath: 'assets/icons/scenes/morning.png',
      description: 'Gradually turn on lights and start the day',
    ),
    SceneTemplate(
      name: 'Movie Time',
      iconPath: 'assets/icons/scenes/movie.png',
      description: 'Dim lights and create cinema atmosphere',
    ),
    SceneTemplate(
      name: 'Party Mode',
      iconPath: 'assets/icons/scenes/party.png',
      description: 'Colorful lighting and energetic ambiance',
    ),
    SceneTemplate(
      name: 'Work Focus',
      iconPath: 'assets/icons/scenes/work.png',
      description: 'Bright lighting for productivity',
    ),
    SceneTemplate(
      name: 'Relax Time',
      iconPath: 'assets/icons/scenes/relax.png',
      description: 'Soft lighting for relaxation',
    ),
    SceneTemplate(
      name: 'Dinner Time',
      iconPath: 'assets/icons/scenes/dinner.png',
      description: 'Warm lighting for dining',
    ),
    SceneTemplate(
      name: 'Away Mode',
      iconPath: 'assets/icons/scenes/away.png',
      description: 'Security settings when leaving home',
    ),
  ];

  static SceneTemplate? getTemplate(String sceneName) {
    try {
      return templates.firstWhere((template) => template.name == sceneName);
    } catch (e) {
      return null;
    }
  }

  static List<String> get availableSceneNames =>
      templates.map((t) => t.name).toList();
}