// lib/core/models/schedule_model.dart
import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

enum ScheduleStatus { active, inactive, expired, error }

enum WeekDay {
  monday(1, 'Monday', 'Mon'),
  tuesday(2, 'Tuesday', 'Tue'),
  wednesday(3, 'Wednesday', 'Wed'),
  thursday(4, 'Thursday', 'Thu'),
  friday(5, 'Friday', 'Fri'),
  saturday(6, 'Saturday', 'Sat'),
  sunday(7, 'Sunday', 'Sun');

  const WeekDay(this.value, this.fullName, this.shortName);
  final int value;
  final String fullName;
  final String shortName;

  static WeekDay fromDateTime(DateTime dateTime) {
    return WeekDay.values.firstWhere((day) => day.value == dateTime.weekday);
  }

  static List<WeekDay> fromIntList(List<int> days) {
    return days
        .map((day) => WeekDay.values.firstWhere((d) => d.value == day))
        .toList();
  }

  static List<int> toIntList(List<WeekDay> days) {
    return days.map((day) => day.value).toList();
  }
}

class ScheduleAction extends Equatable {
  final String type;
  final Map<String, dynamic> parameters;

  const ScheduleAction({required this.type, this.parameters = const {}});

  factory ScheduleAction.fromJson(Map<String, dynamic> json) {
    return ScheduleAction(
      type: json['type'] as String,
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'parameters': parameters};
  }

  String get displayText {
    switch (type) {
      case 'turn_on':
        return 'Turn On';
      case 'turn_off':
        return 'Turn Off';
      case 'set_brightness':
        final brightness = parameters['brightness'] as int? ?? 0;
        return 'Set Brightness to $brightness%';
      case 'set_color':
        final color = parameters['color'] as String? ?? '#FFFFFF';
        return 'Set Color to $color';
      case 'toggle':
        return 'Toggle State';
      default:
        return 'Custom Action';
    }
  }

  @override
  List<Object?> get props => [type, parameters];
}

class ScheduleModel extends Equatable {
  final String id;
  final String deviceId;
  final String deviceName;
  final String name;
  final List<WeekDay> days;
  final TimeOfDay? onTime;
  final TimeOfDay? offTime;
  final ScheduleAction? action;
  final RxBool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleModel({
    required this.id,
    required this.deviceId,
    this.deviceName = '',
    required this.name,
    required this.days,
    this.onTime,
    this.offTime,
    this.action,
    bool? initialIsActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : isActive = RxBool(initialIsActive ?? true),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory ScheduleModel.fromSupabase(Map<String, dynamic> data) {
    final daysData = (data['days'] as List<dynamic>?)?.cast<int>() ?? [];
    final days = WeekDay.fromIntList(daysData);

    TimeOfDay? onTime;
    TimeOfDay? offTime;

    if (data['on_time'] != null) {
      final onTimeString = data['on_time'] as String;
      final onTimeParts = onTimeString.split(':');
      onTime = TimeOfDay(
        hour: int.parse(onTimeParts[0]),
        minute: int.parse(onTimeParts[1]),
      );
    }

    if (data['off_time'] != null) {
      final offTimeString = data['off_time'] as String;
      final offTimeParts = offTimeString.split(':');
      offTime = TimeOfDay(
        hour: int.parse(offTimeParts[0]),
        minute: int.parse(offTimeParts[1]),
      );
    }

    ScheduleAction? action;
    if (data['action'] != null) {
      final raw = data['action'];
      if (raw is String) {
        action = ScheduleAction.fromJson(jsonDecode(raw));
      } else if (raw is Map<String, dynamic>) {
        action = ScheduleAction.fromJson(raw);
      }
    }

    return ScheduleModel(
      id: data['id'] as String,
      deviceId: data['device_id'] as String,
      deviceName: data['device_name'] as String? ?? '',
      name: data['name'] as String,
      days: days,
      onTime: onTime,
      offTime: offTime,
      action: action,
      initialIsActive: data['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'device_id': deviceId,
      'name': name,
      'days': WeekDay.toIntList(days),
      'on_time': onTime?.format24Hour(),
      'off_time': offTime?.format24Hour(),
      'action': action != null ? jsonEncode(action!.toJson()) : null,
      'is_active': isActive.value,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'device_name': deviceName,
      'name': name,
      'days': WeekDay.toIntList(days),
      'on_time': onTime?.format24Hour(),
      'off_time': offTime?.format24Hour(),
      'action': action?.toJson(),
      'is_active': isActive.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get hasOnTime => onTime != null;
  bool get hasOffTime => offTime != null;
  bool get hasAction => action != null;
  bool get isValid => days.isNotEmpty && (hasOnTime || hasOffTime || hasAction);

  ScheduleStatus get status {
    if (!isActive.value) return ScheduleStatus.inactive;
    if (!isValid) return ScheduleStatus.error;
    return ScheduleStatus.active;
  }

  String get statusText {
    switch (status) {
      case ScheduleStatus.active:
        return 'Active';
      case ScheduleStatus.inactive:
        return 'Inactive';
      case ScheduleStatus.expired:
        return 'Expired';
      case ScheduleStatus.error:
        return 'Error';
    }
  }

  String get daysText {
    if (days.length == 7) return 'Every day';
    if (days.length == 5 &&
        days.contains(WeekDay.monday) &&
        days.contains(WeekDay.tuesday) &&
        days.contains(WeekDay.wednesday) &&
        days.contains(WeekDay.thursday) &&
        days.contains(WeekDay.friday)) {
      return 'Weekdays';
    }
    if (days.length == 2 &&
        days.contains(WeekDay.saturday) &&
        days.contains(WeekDay.sunday)) {
      return 'Weekends';
    }
    return days.map((day) => day.shortName).join(', ');
  }

  String get timeText {
    final parts = <String>[];
    if (hasOnTime) parts.add('On at ${onTime!.format12Hour()}');
    if (hasOffTime) parts.add('Off at ${offTime!.format12Hour()}');
    if (hasAction) parts.add(action!.displayText);
    return parts.join(', ');
  }

  String get scheduleDescription => '$daysText - $timeText';

  bool get runsToday => days.contains(WeekDay.fromDateTime(DateTime.now()));

  bool runsOnDay(DateTime date) {
    final day = WeekDay.fromDateTime(date);
    return days.contains(day);
  }

  DateTime? get nextExecution {
    if (!isActive.value || days.isEmpty) return null;

    final now = DateTime.now();
    final today = WeekDay.fromDateTime(now);
    final possibleTimes = <DateTime>[];

    if (hasOnTime) possibleTimes.add(_getNextDateTime(onTime!, today, now));
    if (hasOffTime) possibleTimes.add(_getNextDateTime(offTime!, today, now));
    if (hasAction) {
      final actionTime = onTime ?? const TimeOfDay(hour: 8, minute: 0);
      possibleTimes.add(_getNextDateTime(actionTime, today, now));
    }

    possibleTimes.removeWhere((t) => t.isBefore(now));
    if (possibleTimes.isEmpty) return null;

    possibleTimes.sort();
    return possibleTimes.first;
  }

  DateTime _getNextDateTime(TimeOfDay timeOfDay, WeekDay today, DateTime now) {
    if (days.contains(today)) {
      final todayTime = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      if (todayTime.isAfter(now)) return todayTime;
    }

    for (int i = 1; i <= 7; i++) {
      final futureDate = now.add(Duration(days: i));
      final futureDay = WeekDay.fromDateTime(futureDate);
      if (days.contains(futureDay)) {
        return DateTime(
          futureDate.year,
          futureDate.month,
          futureDate.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
      }
    }

    return now.add(const Duration(days: 7));
  }

  Duration? get timeUntilNextExecution {
    final next = nextExecution;
    if (next == null) return null;
    return next.difference(DateTime.now());
  }

  String get nextExecutionText {
    final next = nextExecution;
    if (next == null) return 'Not scheduled';

    final difference = next.difference(DateTime.now());

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Soon';
    }
  }

  List<String> get validationErrors {
    final errors = <String>[];

    if (name.isEmpty) errors.add('Schedule name cannot be empty');
    if (days.isEmpty) errors.add('Must select at least one day');
    if (!hasOnTime && !hasOffTime && !hasAction) {
      errors.add('Must specify at least one time or action');
    }

    if (hasOnTime && hasOffTime) {
      final onMinutes = onTime!.hour * 60 + onTime!.minute;
      final offMinutes = offTime!.hour * 60 + offTime!.minute;
      if (onMinutes >= offMinutes) {
        errors.add('Off time must be after on time');
      }
    }

    return errors;
  }

  ScheduleModel copyWith({
    String? id,
    String? deviceId,
    String? deviceName,
    String? name,
    List<WeekDay>? days,
    TimeOfDay? onTime,
    TimeOfDay? offTime,
    ScheduleAction? action,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      name: name ?? this.name,
      days: days ?? this.days,
      onTime: onTime ?? this.onTime,
      offTime: offTime ?? this.offTime,
      action: action ?? this.action,
      initialIsActive: isActive ?? this.isActive.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    deviceName,
    name,
    days,
    onTime,
    offTime,
    action,
    isActive.value,
    createdAt,
    updatedAt,
  ];
}

// Extensions for time formatting
extension TimeOfDayExtensions on TimeOfDay {
  String format24Hour() {
    final hourStr = hour.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  String format12Hour() {
    final hour12 = hourOfPeriod == 0 ? 12 : hourOfPeriod;
    final periodStr = period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour12:${minute.toString().padLeft(2, '0')} $periodStr';
  }
}
