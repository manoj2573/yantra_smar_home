// lib/core/models/user_model.dart
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String theme;
  final bool notificationsEnabled;
  final bool autoDiscoverDevices;
  final Map<String, dynamic> mqttSettings;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.theme = 'orange',
    this.notificationsEnabled = true,
    this.autoDiscoverDevices = true,
    this.mqttSettings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      fullName: data['full_name'] as String?,
      avatarUrl: data['avatar_url'] as String?,
      theme: data['theme'] as String? ?? 'orange',
      notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
      autoDiscoverDevices: data['auto_discover_devices'] as bool? ?? true,
      mqttSettings: (data['mqtt_settings'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'theme': theme,
      'notifications_enabled': notificationsEnabled,
      'auto_discover_devices': autoDiscoverDevices,
      'mqtt_settings': mqttSettings,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? theme,
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
      avatarUrl: avatarUrl ?? this.avatarUrl,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      autoDiscoverDevices: autoDiscoverDevices ?? this.autoDiscoverDevices,
      mqttSettings: mqttSettings ?? this.mqttSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    fullName,
    avatarUrl,
    theme,
    notificationsEnabled,
    autoDiscoverDevices,
    mqttSettings,
    createdAt,
    updatedAt,
  ];
}

// Theme preferences
class UserThemes {
  static const Map<String, String> themes = {
    'orange': 'Orange',
    'blue': 'Blue',
    'green': 'Green',
    'purple': 'Purple',
    'dark': 'Dark',
  };

  static List<String> get availableThemes => themes.keys.toList();

  static String getThemeName(String themeKey) {
    return themes[themeKey] ?? 'Orange';
  }
}
