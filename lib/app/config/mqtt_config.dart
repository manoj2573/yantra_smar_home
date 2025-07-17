// lib/app/config/mqtt_config.dart
class MqttConfig {
  // AWS IoT Core Configuration
  static const String broker = 'anqg66n1fr3hi-ats.iot.eu-west-1.amazonaws.com';
  static const int port = 8883;
  static const int keepAlivePeriod = 30;
  static const int maxReconnectAttempts = 5;
  static const Duration reconnectInterval = Duration(seconds: 5);
  static const Duration heartbeatInterval = Duration(seconds: 30);
  
  // Certificate paths (stored in assets/secrets/)
  static const String rootCACertPath = 'assets/secrets/root-CA.crt';
  static const String clientCertPath = 'assets/secrets/pem.crt';
  static const String privateKeyPath = 'assets/secrets/private.pem.key';
  
  // Topic patterns
  static const String deviceTopicPattern = '{deviceId}/device';
  static const String mobileTopicPattern = '{deviceId}/mobile';
  static const String statusTopicPattern = 'status/{clientId}';
  static const String heartbeatTopicPattern = 'heartbeat/{clientId}';
  static const String registrationTopicPattern = '{registrationId}/mobile';
  
  // Quality of Service levels
  static const int defaultQoS = 0; // AtMostOnce
  static const int reliableQoS = 1; // AtLeastOnce
  static const int exactlyOnceQoS = 2; // ExactlyOnce
  
  // Connection timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration publishTimeout = Duration(seconds: 10);
  static const Duration subscribeTimeout = Duration(seconds: 10);
  
  // Message limits
  static const int maxRecentMessages = 100;
  static const int maxMessageSize = 1024 * 1024; // 1MB
  
  // Device command templates
  static Map<String, dynamic> createDeviceCommand({
    required String command,
    required String deviceId,
    Map<String, dynamic>? parameters,
  }) {
    return {
      'command': command,
      'deviceId': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
      if (parameters != null) ...parameters,
    };
  }
  
  static Map<String, dynamic> createStatusMessage({
    required String status,
    required String clientId,
    Map<String, dynamic>? metadata,
  }) {
    return {
      'status': status,
      'clientId': clientId,
      'timestamp': DateTime.now().toIso8601String(),
      if (metadata != null) ...metadata,
    };
  }
  
  static Map<String, dynamic> createHeartbeatMessage({
    required String clientId,
  }) {
    return {
      'type': 'heartbeat',
      'clientId': clientId,
      'timestamp': DateTime.now().toIso8601String(),
      'uptime': DateTime.now().millisecondsSinceEpoch,
    };
  }
}