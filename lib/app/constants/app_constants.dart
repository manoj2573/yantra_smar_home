// lib/app/constants/app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'Smart Home Automation';
  static const String appVersion = '2.0.0';
  static const String appDescription = 'Advanced IoT Home Automation System';

  // Database
  static const int maxDevicesPerUser = 100;
  static const int maxScenesPerUser = 50;
  static const int maxTimersPerDevice = 10;
  static const int maxIRDevicesPerHub = 20;

  // UI Constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 3);
  static const Duration snackBarDuration = Duration(seconds: 4);

  // MQTT Constants
  static const Duration mqttConnectTimeout = Duration(seconds: 30);
  static const Duration mqttKeepAlive = Duration(seconds: 30);
  static const int mqttMaxReconnectAttempts = 5;

  // Timer Constants
  static const int minTimerMinutes = 1;
  static const int maxTimerMinutes = 1440; // 24 hours
  static const Duration timerUpdateInterval = Duration(seconds: 1);

  // Device Constants
  static const int maxSliderValue = 100;
  static const int curtainMaxSeconds = 300; // 5 minutes
  static const Duration deviceStatusTimeout = Duration(minutes: 5);

  // IR Constants
  static const int maxIRButtons = 50;
  static const Duration irLearnTimeout = Duration(seconds: 30);
  static const int maxIRCodeLength = 1000;

  // File paths
  static const String defaultDeviceIcon = 'assets/light-bulb.png';
  static const String defaultRoomIcon = 'assets/room.png';
  static const String appLogo = 'assets/logo.png';

  // Error messages
  static const String networkErrorMessage =
      'Network connection error. Please check your internet connection.';
  static const String deviceOfflineMessage = 'Device is currently offline.';
  static const String authErrorMessage =
      'Authentication failed. Please sign in again.';
  static const String unknownErrorMessage =
      'An unexpected error occurred. Please try again.';
}
