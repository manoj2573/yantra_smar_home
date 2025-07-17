// lib/core/models/timer_model.dart
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

enum TimerStatus { inactive, active, paused, expired, completed }

enum TimerActionType {
  turnOn('Turn On'),
  turnOff('Turn Off'),
  toggle('Toggle'),
  setBrightness('Set Brightness'),
  setColor('Set Color');

  const TimerActionType(this.displayText);
  final String displayText;

  static TimerActionType fromString(String value) {
    return TimerActionType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => TimerActionType.toggle,
    );
  }
}

class TimerAction extends Equatable {
  final TimerActionType type;
  final Map<String, dynamic> parameters;

  const TimerAction({required this.type, this.parameters = const {}});

  factory TimerAction.fromJson(Map<String, dynamic> json) {
    return TimerAction(
      type: TimerActionType.fromString(json['type'] as String),
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type.name, 'parameters': parameters};
  }

  String get displayText {
    switch (type) {
      case TimerActionType.turnOn:
        return 'Turn On';
      case TimerActionType.turnOff:
        return 'Turn Off';
      case TimerActionType.toggle:
        return 'Toggle';
      case TimerActionType.setBrightness:
        final brightness = parameters['brightness'] as int? ?? 50;
        return 'Set Brightness to $brightness%';
      case TimerActionType.setColor:
        final color = parameters['color'] as String? ?? '#FFFFFF';
        return 'Set Color to $color';
    }
  }

  @override
  List<Object?> get props => [type, parameters];
}

class TimerModel extends Equatable {
  final String id;
  final String deviceId;
  final String name;
  final TimerAction action;
  final int durationMinutes;
  final DateTime? startedAt;
  final DateTime? endsAt;
  final RxBool isActive;
  final RxBool isCompleted;
  final RxInt remainingSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimerModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.action,
    required this.durationMinutes,
    this.startedAt,
    this.endsAt,
    bool? initialIsActive,
    bool? initialIsCompleted,
    int? initialRemainingSeconds,
    required this.createdAt,
    required this.updatedAt,
  }) : isActive = RxBool(initialIsActive ?? false),
       isCompleted = RxBool(initialIsCompleted ?? false),
       remainingSeconds = RxInt(
         initialRemainingSeconds ?? durationMinutes * 60,
       );

  factory TimerModel.fromSupabase(Map<String, dynamic> data) {
    final startedAt =
        data['started_at'] != null
            ? DateTime.parse(data['started_at'] as String)
            : null;
    final endsAt =
        data['ends_at'] != null
            ? DateTime.parse(data['ends_at'] as String)
            : null;

    int remainingSeconds = 0;
    if (startedAt != null && endsAt != null && endsAt.isAfter(DateTime.now())) {
      remainingSeconds = endsAt.difference(DateTime.now()).inSeconds;
    }

    return TimerModel(
      id: data['id'] as String,
      deviceId: data['device_id'] as String,
      name: data['name'] as String,
      action: TimerAction.fromJson(data['action'] as Map<String, dynamic>),
      durationMinutes: data['duration_minutes'] as int,
      startedAt: startedAt,
      endsAt: endsAt,
      initialIsActive: data['is_active'] as bool? ?? false,
      initialIsCompleted: data['is_completed'] as bool? ?? false,
      initialRemainingSeconds: remainingSeconds,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'device_id': deviceId,
      'name': name,
      'action': action.toJson(),
      'duration_minutes': durationMinutes,
      'started_at': startedAt?.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'is_active': isActive.value,
      'is_completed': isCompleted.value,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Timer control methods
  TimerModel start() {
    final now = DateTime.now();
    final endTime = now.add(Duration(minutes: durationMinutes));

    return copyWith(
      startedAt: now,
      endsAt: endTime,
      isActive: true,
      isCompleted: false,
      remainingSeconds: durationMinutes * 60,
    );
  }

  TimerModel stop() {
    return copyWith(
      startedAt: null,
      endsAt: null,
      isActive: false,
      remainingSeconds: durationMinutes * 60,
    );
  }

  TimerModel complete() {
    return copyWith(isActive: false, isCompleted: true, remainingSeconds: 0);
  }

  void updateCountdown() {
    if (endsAt != null && isActive.value) {
      final remaining = endsAt!.difference(DateTime.now()).inSeconds;
      remainingSeconds.value = remaining > 0 ? remaining : 0;
    }
  }

  // Status getters
  TimerStatus get status {
    if (isCompleted.value) return TimerStatus.completed;
    if (!isActive.value) return TimerStatus.inactive;
    if (endsAt != null && DateTime.now().isAfter(endsAt!)) {
      return TimerStatus.expired;
    }
    return TimerStatus.active;
  }

  String get statusText {
    switch (status) {
      case TimerStatus.inactive:
        return 'Not Started';
      case TimerStatus.active:
        return 'Running';
      case TimerStatus.paused:
        return 'Paused';
      case TimerStatus.expired:
        return 'Expired';
      case TimerStatus.completed:
        return 'Completed';
    }
  }

  String get remainingTimeText {
    final minutes = remainingSeconds.value ~/ 60;
    final seconds = remainingSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get durationText {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  double get progressPercentage {
    if (durationMinutes == 0) return 0.0;
    final totalSeconds = durationMinutes * 60;
    final elapsed = totalSeconds - remainingSeconds.value;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  TimerModel copyWith({
    String? id,
    String? deviceId,
    String? name,
    TimerAction? action,
    int? durationMinutes,
    DateTime? startedAt,
    DateTime? endsAt,
    bool? isActive,
    bool? isCompleted,
    int? remainingSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimerModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      action: action ?? this.action,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      startedAt: startedAt ?? this.startedAt,
      endsAt: endsAt ?? this.endsAt,
      initialIsActive: isActive ?? this.isActive.value,
      initialIsCompleted: isCompleted ?? this.isCompleted.value,
      initialRemainingSeconds: remainingSeconds ?? this.remainingSeconds.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    name,
    action,
    durationMinutes,
    startedAt,
    endsAt,
    isActive.value,
    isCompleted.value,
    remainingSeconds.value,
    createdAt,
    updatedAt,
  ];
}

// Predefined timer templates
class TimerTemplates {
  static const List<Map<String, dynamic>> templates = [
    {
      'name': 'Quick 5 min',
      'duration': 5,
      'action': {'type': 'turnOff', 'parameters': {}},
    },
    {
      'name': 'Quick 15 min',
      'duration': 15,
      'action': {'type': 'turnOff', 'parameters': {}},
    },
    {
      'name': 'Quick 30 min',
      'duration': 30,
      'action': {'type': 'turnOff', 'parameters': {}},
    },
    {
      'name': '1 Hour',
      'duration': 60,
      'action': {'type': 'turnOff', 'parameters': {}},
    },
    {
      'name': 'Sleep Timer (2h)',
      'duration': 120,
      'action': {'type': 'turnOff', 'parameters': {}},
    },
  ];

  static List<String> get quickDurations => ['5', '15', '30', '60', '120'];
}
