// lib/core/models/schedule_model.dart
import 'package:equatable/equatable.dart';
import 'package:get/get.dart';

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
    return days.map((day) => WeekDay.values.firstWhere((d) => d.value == day)).toList();
  }

  static List<int> toIntList(List<WeekDay> days) {
    return days.map((day) => day.value).toList();
  }
}

class ScheduleAction extends Equatable {
  final String type; // 'turn_on', 'turn_off', 'set_brightness', 'set_color', 'toggle'
  final Map<String, dynamic> parameters;

  const ScheduleAction({
    required this.type,
    this.parameters = const {},
  });

  factory ScheduleAction.fromJson(Map<String, dynamic> json) {
    return ScheduleAction(
      type: json['type'] as String,
      parameters: (json['parameters'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'parameters': parameters,
    };
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
  })  : isActive = RxBool(initialIsActive ?? true),
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
      action = ScheduleAction.fromJson(data['action'] as Map<String, dynamic>);
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
      'action': action?.toJson(),
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

  // Helper getters
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
    if (days.length == 7) {
      return 'Every day';
    } else if (days.length == 5 && 
               days.contains(WeekDay.monday) &&
               days.contains(WeekDay.tuesday) &&
               days.contains(WeekDay.wednesday) &&
               days.contains(WeekDay.thursday) &&
               days.contains(WeekDay.friday)) {
      return 'Weekdays';
    } else if (days.length == 2 &&
               days.contains(WeekDay.saturday) &&
               days.contains(WeekDay.sunday)) {
      return 'Weekends';
    } else {
      return days.map((day) => day.shortName).join(', ');
    }
  }

  String get timeText {
    final parts = <String>[];
    
    if (hasOnTime) {
      parts.add('On at ${onTime!.format12Hour()}');
    }
    
    if (hasOffTime) {
      parts.add('Off at ${offTime!.format12Hour()}');
    }
    
    if (hasAction) {
      parts.add(action!.displayText);
    }
    
    return parts.join(', ');
  }

  String get scheduleDescription {
    return '$daysText - $timeText';
  }

  // Check if schedule should run today
  bool get runsToday {
    final today = WeekDay.fromDateTime(DateTime.now());
    return days.contains(today);
  }

  // Check if schedule should run on specific day
  bool runsOnDay(DateTime date) {
    final day = WeekDay.fromDateTime(date);
    return days.contains(day);
  }

  // Get next execution time
  DateTime? get nextExecution {
    if (!isActive.value || days.isEmpty) return null;

    final now = DateTime.now();
    final today = WeekDay.fromDateTime(now);
    
    // Check times for execution today or in the future
    final possibleTimes = <DateTime>[];
    
    if (hasOnTime) {
      possibleTimes.add(_getNextDateTime(onTime!, today, now));
    }
    
    if (hasOffTime) {
      possibleTimes.add(_getNextDateTime(offTime!, today, now));
    }
    
    if (hasAction) {
      // For custom actions, use onTime if available, otherwise assume morning
      final actionTime = onTime ?? const TimeOfDay(hour: 8, minute: 0);
      possibleTimes.add(_getNextDateTime(actionTime, today, now));
    }
    
    possibleTimes.removeWhere((time) => time.isBefore(now));
    
    if (possibleTimes.isEmpty) return null;
    
    possibleTimes.sort();
    return possibleTimes.first;
  }

  DateTime _getNextDateTime(TimeOfDay timeOfDay, WeekDay today, DateTime now) {
    // Check if time can run today
    if (days.contains(today)) {
      final todayTime = DateTime(
        now.year,
        now.month,
        now.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      
      if (todayTime.isAfter(now)) {
        return todayTime;
      }
    }
    
    // Find next day this schedule runs
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
    
    return now.add(const Duration(days: 7)); // Fallback
  }

  // Time until next execution
  Duration? get timeUntilNextExecution {
    final next = nextExecution;
    if (next == null) return null;
    
    final now = DateTime.now();
    return next.difference(now);
  }

  String get nextExecutionText {
    final next = nextExecution;
    if (next == null) return 'Not scheduled';
    
    final now = DateTime.now();
    final difference = next.difference(now);
    
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

  // Validation
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (name.isEmpty) {
      errors.add('Schedule name cannot be empty');
    }
    
    if (days.isEmpty) {
      errors.add('Must select at least one day');
    }
    
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

  // Copy with method
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
      updatedAt: updatedAt ?? DateTime.now(),
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

  @override
  String toString() {
    return 'ScheduleModel(id: $id, name: $name, days: $daysText)';
  }
}

// Extension for TimeOfDay formatting
extension TimeOfDayExtension on TimeOfDay {
  String format24Hour() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String format12Hour() {
    final isPM = hour >= 12;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final period = isPM ? 'PM' : 'AM';
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  int get totalMinutes => hour * 60 + minute;

  bool isBefore(TimeOfDay other) => totalMinutes < other.totalMinutes;
  bool isAfter(TimeOfDay other) => totalMinutes > other.totalMinutes;
}

// Predefined schedule templates
class ScheduleTemplate {
  final String name;
  final String description;
  final List<WeekDay> days;
  final TimeOfDay? onTime;
  final TimeOfDay? offTime;
  final ScheduleAction? action;

  const ScheduleTemplate({
    required this.name,
    required this.description,
    required this.days,
    this.onTime,
    this.offTime,
    this.action,
  });

  ScheduleModel toScheduleModel({
    required String id,
    required String deviceId,
    String? deviceName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleModel(
      id: id,
      deviceId: deviceId,
      deviceName: deviceName ?? '',
      name: name,
      days: days,
      onTime: onTime,
      offTime: offTime,
      action: action,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class ScheduleTemplates {
  static const List<ScheduleTemplate> templates = [
    ScheduleTemplate(
      name: 'Weekday Morning',
      description: 'Turn on during weekday mornings',
      days: [
        WeekDay.monday,
        WeekDay.tuesday,
        WeekDay.wednesday,
        WeekDay.thursday,
        WeekDay.friday,
      ],
      onTime: TimeOfDay(hour: 7, minute: 0),
      offTime: TimeOfDay(hour: 9, minute: 0),
    ),
    ScheduleTemplate(
      name: 'Evening Lights',
      description: 'Turn on lights in the evening',
      days: WeekDay.values,
      onTime: TimeOfDay(hour: 18, minute: 0),
      offTime: TimeOfDay(hour: 23, minute: 0),
    ),
    ScheduleTemplate(
      name: 'Weekend Sleep-in',
      description: 'Later schedule for weekends',
      days: [WeekDay.saturday, WeekDay.sunday],
      onTime: TimeOfDay(hour: 9, minute: 0),
      offTime: TimeOfDay(hour: 12, minute: 0),
    ),
    ScheduleTemplate(
      name: 'Security Lights',
      description: 'Nighttime security lighting',
      days: WeekDay.values,
      onTime: TimeOfDay(hour: 22, minute: 0),
      offTime: TimeOfDay(hour: 6, minute: 0),
    ),
    ScheduleTemplate(
      name: 'Work Hours',
      description: 'Active during work hours',
      days: [
        WeekDay.monday,
        WeekDay.tuesday,
        WeekDay.wednesday,
        WeekDay.thursday,
        WeekDay.friday,
      ],
      onTime: TimeOfDay(hour: 9, minute: 0),
      offTime: TimeOfDay(hour: 17, minute: 0),
    ),
  ];

  static ScheduleTemplate? getTemplate(String name) {
    try {
      return templates.firstWhere((template) => template.name == name);
    } catch (e) {
      return null;
    }
  }

  static List<String> get availableTemplateNames =>
      templates.map((t) => t.name).toList();
}