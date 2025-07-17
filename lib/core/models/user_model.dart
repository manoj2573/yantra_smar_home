// lib/core/models/user_model.dart
import 'package:equatable/equatable.dart';

enum UserTheme {
  orange('orange'),
  blue('blue'), 
  green('green'),
  purple('purple'),
  dark('dark');

  const UserTheme(this.value);
  final String value;

  static UserTheme fromString(String value) {
    return UserTheme.values.firstWhere(
      (theme) => theme.value == value,
      orElse: () => UserTheme.orange,
    );
  }
}

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final UserTheme theme;
  final bool notificationsEnabled;
  final bool autoDiscoverDevices;
  final Map<String, dynamic> mqttSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.theme = UserTheme.orange,
    this.notificationsEnabled = true,
    this.autoDiscoverDevices = true,
    this.mqttSettings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from Supabase data
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String?,
      theme: UserTheme.fromString(data['theme'] as String? ?? 'orange'),
      notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
      autoDiscoverDevices: data['auto_discover_devices'] as bool? ?? true,
      mqttSettings: (data['mqtt_settings'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  // Convert to Supabase data for user_preferences table
  Map<String, dynamic> toSupabase() {
    return {
      'user_id': id,
      'theme': theme.value,
      'notifications_enabled': notificationsEnabled,
      'auto_discover_devices': autoDiscoverDevices,
      'mqtt_settings': mqttSettings,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'theme': theme.value,
      'notifications_enabled': notificationsEnabled,
      'auto_discover_devices': autoDiscoverDevices,
      'mqtt_settings': mqttSettings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Factory constructor from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      theme: UserTheme.fromString(json['theme'] as String? ?? 'orange'),
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      autoDiscoverDevices: json['auto_discover_devices'] as bool? ?? true,
      mqttSettings: (json['mqtt_settings'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    UserTheme? theme,
    bool? notificationsEnabled,
    bool? autoDiscoverDevices,
    Map<String, dynamic>? mqttSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoDiscoverDevices: autoDiscoverDevices ?? this.autoDiscoverDevices,
      mqttSettings: mqttSettings ?? this.mqttSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper getters
  String get displayName => fullName ?? email.split('@').first;
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get hasCompleteProfile => fullName != null && fullName!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        theme,
        notificationsEnabled,
        autoDiscoverDevices,
        mqttSettings,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, theme: ${theme.value})';
  }
}

// Extension for theme-related operations
extension UserThemeExtension on UserTheme {
  String get displayName {
    switch (this) {
      case UserTheme.orange:
        return 'Orange';
      case UserTheme.blue:
        return 'Blue';
      case UserTheme.green:
        return 'Green';
      case UserTheme.purple:
        return 'Purple';
      case UserTheme.dark:
        return 'Dark';
    }
  }

  String get primaryColorHex {
    switch (this) {
      case UserTheme.orange:
        return '#FF9800';
      case UserTheme.blue:
        return '#2196F3';
      case UserTheme.green:
        return '#4CAF50';
      case UserTheme.purple:
        return '#9C27B0';
      case UserTheme.dark:
        return '#424242';
    }
  }

  String get accentColorHex {
    switch (this) {
      case UserTheme.orange:
        return '#FFB74D';
      case UserTheme.blue:
        return '#64B5F6';
      case UserTheme.green:
        return '#81C784';
      case UserTheme.purple:
        return '#BA68C8';
      case UserTheme.dark:
        return '#616161';
    }
  }

  bool get isDarkTheme => this == UserTheme.dark;
}

// User preferences model for detailed settings
class UserPreferences extends Equatable {
  final String userId;
  final UserTheme theme;
  final bool notificationsEnabled;
  final bool autoDiscoverDevices;
  final bool soundEffectsEnabled;
  final bool hapticFeedbackEnabled;
  final bool automaticBackup;
  final int deviceStatusUpdateInterval;
  final Map<String, dynamic> mqttSettings;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    required this.userId,
    this.theme = UserTheme.orange,
    this.notificationsEnabled = true,
    this.autoDiscoverDevices = true,
    this.soundEffectsEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.automaticBackup = true,
    this.deviceStatusUpdateInterval = 30,
    this.mqttSettings = const {},
    this.customSettings = const {},
  });

  factory UserPreferences.fromSupabase(Map<String, dynamic> data) {
    final mqttSettings = data['mqtt_settings'] as Map<String, dynamic>? ?? {};
    
    return UserPreferences(
      userId: data['user_id'] as String,
      theme: UserTheme.fromString(data['theme'] as String? ?? 'orange'),
      notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
      autoDiscoverDevices: data['auto_discover_devices'] as bool? ?? true,
      soundEffectsEnabled: mqttSettings['sound_effects'] as bool? ?? true,
      hapticFeedbackEnabled: mqttSettings['haptic_feedback'] as bool? ?? true,
      automaticBackup: mqttSettings['automatic_backup'] as bool? ?? true,
      deviceStatusUpdateInterval: mqttSettings['update_interval'] as int? ?? 30,
      mqttSettings: mqttSettings,
      customSettings: data['custom_settings'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'theme': theme.value,
      'notifications_enabled': notificationsEnabled,
      'auto_discover_devices': autoDiscoverDevices,
      'mqtt_settings': {
        'sound_effects': soundEffectsEnabled,
        'haptic_feedback': hapticFeedbackEnabled,
        'automatic_backup': automaticBackup,
        'update_interval': deviceStatusUpdateInterval,
        ...mqttSettings,
      },
      'custom_settings': customSettings,
    };
  }

  UserPreferences copyWith({
    String? userId,
    UserTheme? theme,
    bool? notificationsEnabled,
    bool? autoDiscoverDevices,
    bool? soundEffectsEnabled,
    bool? hapticFeedbackEnabled,
    bool? automaticBackup,
    int? deviceStatusUpdateInterval,
    Map<String, dynamic>? mqttSettings,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoDiscoverDevices: autoDiscoverDevices ?? this.autoDiscoverDevices,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      automaticBackup: automaticBackup ?? this.automaticBackup,
      deviceStatusUpdateInterval: deviceStatusUpdateInterval ?? this.deviceStatusUpdateInterval,
      mqttSettings: mqttSettings ?? this.mqttSettings,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        theme,
        notificationsEnabled,
        autoDiscoverDevices,
        soundEffectsEnabled,
        hapticFeedbackEnabled,
        automaticBackup,
        deviceStatusUpdateInterval,
        mqttSettings,
        customSettings,
      ];
}