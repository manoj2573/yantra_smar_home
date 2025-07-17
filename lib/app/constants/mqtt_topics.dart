// lib/app/constants/mqtt_topics.dart
class MqttTopics {
  // Device topics
  static String deviceCommand(String deviceId) => '$deviceId/device';
  static String deviceStatus(String deviceId) => '$deviceId/mobile';

  // Registration topics
  static String registrationStatus(String registrationId) =>
      '$registrationId/mobile';
  static String registrationCommand(String registrationId) =>
      '$registrationId/device';

  // IR Hub topics
  static String irHubCommand(String hubId) => '$hubId/device';
  static String irHubStatus(String hubId) => '$hubId/mobile';

  // Status topics
  static String deviceStatusTopic(String clientId) => 'status/$clientId';
  static String heartbeatTopic(String clientId) => 'heartbeat/$clientId';

  // WiFi topics
  static String wifiStatusTopic(String registrationId) =>
      '$registrationId/wifi/status';
  static String wifiConfigTopic(String registrationId) =>
      '$registrationId/wifi/config';

  // System topics
  static const String systemStatus = 'system/status';
  static const String systemHeartbeat = 'system/heartbeat';
}
