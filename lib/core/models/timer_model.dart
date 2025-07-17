// lib/core/models/timer_model.dart
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

enum TimerStatus { inactive, active, paused, completed, expired }

enum TimerActionType { turnOn, turnOff, setBrightness, setColor, toggle }

class TimerAction extends Equatable {
  final TimerActionType type;
  final Map<String, dynamic> parameters;

  const TimerAction({required this.type, this.parameters = const {}});

  factory TimerAction.fromJson(Map<String, dynamic> json) {
    return TimerAction(
      type: TimerActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TimerActionType.toggle,
      ),
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
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
      case TimerActionType.setBrightness:
        final brightness = parameters['brightness'] as int? ?? 0;
        return 'Set Brightness to $brightness%';
      case TimerActionType.setColor:
        final color = parameters['color'] as String? ?? '#FFFFFF';
        return 'Set Color to $color';
      case TimerActionType.toggle:
        return 'Toggle State';
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
  final DateTime createdAt;
  final DateTime updatedAt;

  // Reactive properties for countdown
  final RxInt remainingSeconds;
  final RxDouble progress;

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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : isActive = RxBool(initialIsActive ?? false),
       isCompleted = RxBool(initialIsCompleted ?? false),
       remainingSeconds = RxInt(0),
       progress = RxDouble(0.0),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now() {
    updateCountdown(); // Call the public method
  }

  factory TimerModel.fromSupabase(Map<String, dynamic> data) {
    return TimerModel(
      id: data['id'] as String,
      deviceId: data['device_id'] as String,
      name: data['name'] as String,
      action: TimerAction.fromJson(data['action'] as Map<String, dynamic>),
      durationMinutes: data['duration_minutes'] as int,
      startedAt:
          data['started_at'] != null
              ? DateTime.parse(data['started_at'] as String)
              : null,
      endsAt:
          data['ends_at'] != null
              ? DateTime.parse(data['ends_at'] as String)
              : null,
      initialIsActive: data['is_active'] as bool? ?? false,
      initialIsCompleted: data['is_completed'] as bool? ?? false,
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
    final newEndsAt = now.add(Duration(minutes: durationMinutes));

    return copyWith(
      startedAt: now,
      endsAt: newEndsAt,
      isActive: true,
      isCompleted: false,
    );
  }

  TimerModel pause() {
    if (!isActive.value || isCompleted.value) return this;

    return copyWith(
      isActive: false,
      // Keep startedAt and endsAt for resume functionality
    );
  }

  TimerModel resume() {
    if (isActive.value || isCompleted.value) return this;
    if (startedAt == null) return start();

    final now = DateTime.now();
    final elapsed = now.difference(startedAt!);
    final remaining = Duration(minutes: durationMinutes) - elapsed;

    if (remaining.isNegative) {
      return copyWith(isCompleted: true, isActive: false);
    }

    return copyWith(endsAt: now.add(remaining), isActive: true);
  }

  TimerModel stop() {
    return copyWith(
      isActive: false,
      isCompleted: false,
      startedAt: null,
      endsAt: null,
    );
  }

  TimerModel complete() {
    return copyWith(isActive: false, isCompleted: true);
  }

  // Helper methods
  TimerStatus get status {
    if (isCompleted.value) return TimerStatus.completed;
    if (isActive.value) {
      if (endsAt != null && DateTime.now().isAfter(endsAt!)) {
        return TimerStatus.expired;
      }
      return TimerStatus.active;
    }
    if (startedAt != null && !isCompleted.value) {
      return TimerStatus.paused;
    }
    return TimerStatus.inactive;
  }

  Duration get totalDuration => Duration(minutes: durationMinutes);

  Duration get remainingDuration {
    if (endsAt == null || !isActive.value) return Duration.zero;
    final remaining = endsAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration get elapsedDuration {
    if (startedAt == null) return Duration.zero;
    if (endsAt == null) return Duration.zero;

    final totalDuration = Duration(minutes: durationMinutes);
    final remaining = remainingDuration;
    return totalDuration - remaining;
  }

  double get progressPercentage {
    if (startedAt == null || endsAt == null) return 0.0;

    final total = totalDuration.inSeconds;
    final elapsed = elapsedDuration.inSeconds;

    if (total == 0) return 0.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String get remainingTimeText {
    final remaining = remainingDuration;
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get statusText {
    switch (status) {
      case TimerStatus.inactive:
        return 'Ready';
      case TimerStatus.active:
        return 'Running';
      case TimerStatus.paused:
        return 'Paused';
      case TimerStatus.completed:
        return 'Completed';
      case TimerStatus.expired:
        return 'Expired';
    }
  }

  bool get canStart => status == TimerStatus.inactive;
  bool get canPause => status == TimerStatus.active;
  bool get canResume => status == TimerStatus.paused;
  bool get canStop =>
      status == TimerStatus.active || status == TimerStatus.paused;

  // Update countdown (called periodically)
  void updateCountdown() {
    if (status == TimerStatus.active) {
      final remaining = remainingDuration;
      remainingSeconds.value = remaining.inSeconds;
      progress.value = progressPercentage;
    }
  }

  // Copy with method
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
      createdAt: createdAt,
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
    createdAt,
    updatedAt,
  ];
}

// Predefined timer durations
class TimerDurations {
  static const List<int> quickDurations = [1, 5, 10, 15, 30, 60]; // minutes

  static const Map<String, int> namedDurations = {
    '1 minute': 1,
    '5 minutes': 5,
    '10 minutes': 10,
    '15 minutes': 15,
    '30 minutes': 30,
    '1 hour': 60,
    '2 hours': 120,
    '4 hours': 240,
    '8 hours': 480,
  };

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}
