// lib/app/constants/supabase_tables.dart
class SupabaseTables {
  // Table names
  static const String rooms = 'rooms';
  static const String devices = 'devices';
  static const String scenes = 'scenes';
  static const String schedules = 'schedules';
  static const String timers = 'timers';
  static const String irHubs = 'ir_hubs';
  static const String irDevices = 'ir_devices';
  static const String irButtons = 'ir_buttons';
  static const String userPreferences = 'user_preferences';
  static const String notifications = 'notifications';

  // Device table columns
  static const String deviceId = 'device_id';
  static const String deviceName = 'name';
  static const String deviceType = 'type';
  static const String deviceState = 'state';
  static const String deviceSliderValue = 'slider_value';
  static const String deviceColor = 'color';
  static const String deviceRoomId = 'room_id';
  static const String deviceRegistrationId = 'registration_id';
  static const String deviceIconPath = 'icon_path';
  static const String deviceIsOnline = 'is_online';
  static const String deviceLastSeen = 'last_seen';
  static const String deviceSettings = 'settings';

  // Room table columns
  static const String roomName = 'name';
  static const String roomIconPath = 'icon_path';
  static const String roomColor = 'color';

  // Common columns
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // Device types
  static const List<String> deviceTypes = [
    'On/Off',
    'Dimmable light',
    'RGB',
    'Fan',
    'Curtain',
    'IR Hub',
  ];

  // Scene status
  static const String sceneIsActive = 'is_active';
  static const String sceneDevices = 'devices';

  // Schedule columns
  static const String scheduleDays = 'days';
  static const String scheduleOnTime = 'on_time';
  static const String scheduleOffTime = 'off_time';
  static const String scheduleAction = 'action';
  static const String scheduleIsActive = 'is_active';

  // Timer columns
  static const String timerAction = 'action';
  static const String timerDurationMinutes = 'duration_minutes';
  static const String timerStartedAt = 'started_at';
  static const String timerEndsAt = 'ends_at';
  static const String timerIsActive = 'is_active';
  static const String timerIsCompleted = 'is_completed';

  // IR Hub columns
  static const String irHubRegistrationId = 'registration_id';
  static const String irHubIsOnline = 'is_online';
  static const String irHubLastSeen = 'last_seen';

  // IR Device columns
  static const String irDeviceIrHubId = 'ir_hub_id';
  static const String irDeviceType = 'type';
  static const String irDeviceLayoutConfig = 'layout_config';

  // IR Button columns
  static const String irButtonIrDeviceId = 'ir_device_id';
  static const String irButtonIconName = 'icon_name';
  static const String irButtonPositionX = 'position_x';
  static const String irButtonPositionY = 'position_y';
  static const String irButtonWidth = 'width';
  static const String irButtonHeight = 'height';
  static const String irButtonIrCode = 'ir_code';
  static const String irButtonType = 'button_type';
  static const String irButtonIsLearned = 'is_learned';

  // User preferences columns
  static const String userPrefTheme = 'theme';
  static const String userPrefNotificationsEnabled = 'notifications_enabled';
  static const String userPrefAutoDiscoverDevices = 'auto_discover_devices';
  static const String userPrefMqttSettings = 'mqtt_settings';

  // Notification columns
  static const String notificationTitle = 'title';
  static const String notificationMessage = 'message';
  static const String notificationType = 'type';
  static const String notificationIsRead = 'is_read';
  static const String notificationActionData = 'action_data';
}
