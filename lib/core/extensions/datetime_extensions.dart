// lib/core/extensions/datetime_extensions.dart
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Format datetime as human-readable time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y ago';
    }
  }

  /// Format datetime as display time
  String get displayTime => DateFormat('HH:mm').format(this);

  /// Format datetime as display date
  String get displayDate => DateFormat('MMM dd, yyyy').format(this);

  /// Format datetime as display date and time
  String get displayDateTime => DateFormat('MMM dd, yyyy HH:mm').format(this);

  /// Format as ISO string for database storage
  String get toIsoString => toUtc().toIso8601String();

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    return isAfter(weekStart.subtract(const Duration(days: 1))) &&
        isBefore(weekEnd.add(const Duration(days: 1)));
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth =>
      DateTime(year, month + 1, 1).subtract(const Duration(days: 1)).endOfDay;

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    var result = this;
    var daysToAdd = days;

    while (daysToAdd > 0) {
      result = result.add(const Duration(days: 1));
      if (result.weekday <= 5) {
        // Monday to Friday
        daysToAdd--;
      }
    }

    return result;
  }

  /// Check if it's a weekend
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if it's a weekday
  bool get isWeekday => !isWeekend;

  /// Get friendly date format
  String get friendlyDate {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isThisWeek) return DateFormat('EEEE').format(this);
    return displayDate;
  }

  /// Get relative time with friendly format
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      // Future date
      final futureDiff = difference.abs();
      if (futureDiff.inMinutes < 60) {
        return 'In ${futureDiff.inMinutes}m';
      } else if (futureDiff.inHours < 24) {
        return 'In ${futureDiff.inHours}h';
      } else if (futureDiff.inDays < 7) {
        return 'In ${futureDiff.inDays}d';
      } else {
        return displayDate;
      }
    }

    return timeAgo;
  }

  /// Format for device last seen
  String get lastSeenFormat {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 30) {
      return 'Online';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Check if datetime is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if datetime is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Get duration until this datetime
  Duration get durationUntil {
    final now = DateTime.now();
    return difference(now);
  }

  /// Get duration since this datetime
  Duration get durationSince {
    final now = DateTime.now();
    return now.difference(this);
  }
}

/// Extensions for Duration
extension DurationExtensions on Duration {
  /// Format duration as human readable string
  String get formatted {
    if (inDays > 0) {
      return '${inDays}d ${inHours.remainder(24)}h';
    } else if (inHours > 0) {
      return '${inHours}h ${inMinutes.remainder(60)}m';
    } else if (inMinutes > 0) {
      return '${inMinutes}m ${inSeconds.remainder(60)}s';
    } else {
      return '${inSeconds}s';
    }
  }

  /// Format as timer display (MM:SS or HH:MM:SS)
  String get timerFormat {
    if (inHours > 0) {
      return '${inHours.toString().padLeft(2, '0')}:'
          '${inMinutes.remainder(60).toString().padLeft(2, '0')}:'
          '${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    } else {
      return '${inMinutes.toString().padLeft(2, '0')}:'
          '${inSeconds.remainder(60).toString().padLeft(2, '0')}';
    }
  }

  /// Format as short duration (e.g., "5m", "2h", "1d")
  String get shortFormat {
    if (inDays > 0) {
      return '${inDays}d';
    } else if (inHours > 0) {
      return '${inHours}h';
    } else if (inMinutes > 0) {
      return '${inMinutes}m';
    } else {
      return '${inSeconds}s';
    }
  }

  /// Check if duration is positive
  bool get isPositive => inMicroseconds > 0;

  /// Check if duration is negative
  bool get isNegative => inMicroseconds < 0;

  /// Get absolute duration
  Duration get abs => Duration(microseconds: inMicroseconds.abs());
}
