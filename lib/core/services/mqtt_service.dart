// lib/core/services/mqtt_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum MqttConnectionStatus { disconnected, connecting, connected, error }

class SmartHomeMqttMessage {
  final String topic;
  final String payload;
  final DateTime timestamp;

  SmartHomeMqttMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> get payloadJson {
    try {
      return jsonDecode(payload);
    } catch (e) {
      return {'raw': payload};
    }
  }
}

class MqttService extends GetxService {
  static MqttService get to => Get.find();

  final _logger = Logger();
  late MqttServerClient _client;

  // Observable states
  final Rx<MqttConnectionStatus> connectionStatus =
      MqttConnectionStatus.disconnected.obs;
  final RxList<String> subscribedTopics = <String>[].obs;
  final RxList<SmartHomeMqttMessage> recentMessages =
      <SmartHomeMqttMessage>[].obs;

  // Message handlers
  final Map<String, Function(String, String)> _messageHandlers = {};
  final StreamController<SmartHomeMqttMessage> _messageStream =
      StreamController<SmartHomeMqttMessage>.broadcast();

  // Connection management
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final Duration _reconnectInterval = const Duration(seconds: 5);
  final Duration _heartbeatInterval = const Duration(seconds: 30);

  // Configuration
  static const String _broker = 'anqg66n1fr3hi-ats.iot.eu-west-1.amazonaws.com';
  static const int _port = 8883;
  static const int _keepAlivePeriod = 30;
  static const int _maxReconnectAttempts = 5;
  int _reconnectAttempts = 0;

  // Getters
  bool get isConnected =>
      connectionStatus.value == MqttConnectionStatus.connected;
  bool get isConnecting =>
      connectionStatus.value == MqttConnectionStatus.connecting;
  Stream<SmartHomeMqttMessage> get messageStream => _messageStream.stream;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeMqttClient();
    _setupConnectivityListener();
  }

  @override
  void onClose() {
    _disconnect();
    _messageStream.close();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeMqttClient() async {
    try {
      final clientId = await _generateUniqueClientId();
      _client = MqttServerClient.withPort(_broker, clientId, _port);

      _client.logging(on: false); // Disable verbose logging
      _client.keepAlivePeriod = _keepAlivePeriod;
      _client.autoReconnect = false; // We'll handle reconnection manually
      _client.onDisconnected = _onDisconnected;
      _client.onConnected = _onConnected;
      // Note: onSubscribed and onUnsubscribed callbacks removed due to API changes

      // Set up SSL context
      _client.secure = true;
      _client.securityContext = await _createSecurityContext();

      // Set connection message
      final connMessage =
          MqttConnectMessage()
              .withClientIdentifier(clientId)
              .withWillTopic('status/$clientId')
              .withWillMessage('offline')
              .withWillQos(MqttQos.atLeastOnce)
              .startClean();

      _client.connectionMessage = connMessage;

      _logger.i('MQTT client initialized with ID: $clientId');
    } catch (e) {
      _logger.e('Failed to initialize MQTT client: $e');
      connectionStatus.value = MqttConnectionStatus.error;
    }
  }

  Future<String> _generateUniqueClientId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown';
      } else {
        deviceId = 'unknown';
      }

      return 'smart_home_${deviceId}_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      _logger.w('Failed to get device ID: $e');
      return 'smart_home_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<SecurityContext> _createSecurityContext() async {
    try {
      final context = SecurityContext.defaultContext;

      // Load certificates from assets
      final rootCA = await rootBundle.load('assets/secrets/root-CA.crt');
      final clientCert = await rootBundle.load('assets/secrets/pem.crt');
      final privateKey = await rootBundle.load(
        'assets/secrets/private.pem.key',
      );

      context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());
      context.useCertificateChainBytes(clientCert.buffer.asUint8List());
      context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

      return context;
    } catch (e) {
      _logger.e('Failed to create security context: $e');
      rethrow;
    }
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty &&
          results.first != ConnectivityResult.none &&
          !isConnected) {
        _logger.i('Network connectivity restored, attempting to reconnect...');
        connect();
      }
    });
  }

  // ===================== CONNECTION METHODS =====================

  Future<bool> connect() async {
    if (isConnected || isConnecting) {
      _logger.w('Already connected or connecting');
      return isConnected;
    }

    connectionStatus.value = MqttConnectionStatus.connecting;
    _logger.i('Connecting to MQTT broker: $_broker:$_port');

    try {
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        connectionStatus.value = MqttConnectionStatus.connected;
        _reconnectAttempts = 0;
        _setupMessageListener();
        _startHeartbeat();

        // Publish online status
        await _publishOnlineStatus();

        _logger.i('Successfully connected to MQTT broker');
        return true;
      } else {
        throw Exception(
          'Connection failed: ${_client.connectionStatus?.returnCode}',
        );
      }
    } catch (e) {
      _logger.e('MQTT connection error: $e');
      connectionStatus.value = MqttConnectionStatus.error;
      _scheduleReconnect();
      return false;
    }
  }

  void _disconnect() {
    try {
      _reconnectTimer?.cancel();
      _heartbeatTimer?.cancel();

      if (isConnected) {
        // Publish offline status before disconnecting
        _publishOfflineStatus();
        _client.disconnect();
      }

      connectionStatus.value = MqttConnectionStatus.disconnected;
      subscribedTopics.clear();
      _logger.i('Disconnected from MQTT broker');
    } catch (e) {
      _logger.e('Error during disconnect: $e');
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.e('Max reconnection attempts reached');
      connectionStatus.value = MqttConnectionStatus.error;
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      seconds: _reconnectInterval.inSeconds * _reconnectAttempts,
    );

    _logger.i(
      'Scheduling reconnect attempt $_reconnectAttempts in ${delay.inSeconds}s',
    );

    _reconnectTimer = Timer(delay, () {
      if (!isConnected) {
        connect();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        _publishHeartbeat();
      } else {
        timer.cancel();
      }
    });
  }

  // ===================== EVENT HANDLERS =====================

  void _onConnected() {
    _logger.i('MQTT client connected');
    connectionStatus.value = MqttConnectionStatus.connected;
  }

  void _onDisconnected() {
    _logger.w('MQTT client disconnected');
    connectionStatus.value = MqttConnectionStatus.disconnected;
    _scheduleReconnect();
  }

  void _onSubscribed(String topic) {
    _logger.d('Subscribed to: $topic');
    if (!subscribedTopics.contains(topic)) {
      subscribedTopics.add(topic);
    }
  }

  void _onUnsubscribed(String topic) {
    _logger.d('Unsubscribed from: $topic');
    subscribedTopics.remove(topic);
  }

  void _setupMessageListener() {
    _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
      for (final message in messages) {
        final recMessage = message.payload as MqttPublishMessage;
        final topic = message.topic;
        final payload = utf8.decode(recMessage.payload.message);

        final smartHomeMqttMessage = SmartHomeMqttMessage(
          topic: topic,
          payload: payload,
          timestamp: DateTime.now(),
        );

        // Add to recent messages (keep only last 100)
        recentMessages.insert(0, smartHomeMqttMessage);
        if (recentMessages.length > 100) {
          recentMessages.removeLast();
        }

        // Emit to stream
        _messageStream.add(smartHomeMqttMessage);

        // Call specific handlers
        _handleMessage(topic, payload);

        _logger.d(
          'Received message on $topic: ${payload.length > 100 ? '${payload.substring(0, 100)}...' : payload}',
        );
      }
    });
  }

  void _handleMessage(String topic, String payload) {
    // Call global handlers
    for (final handler in _messageHandlers.values) {
      try {
        handler(topic, payload);
      } catch (e) {
        _logger.e('Error in message handler: $e');
      }
    }

    // Call topic-specific handlers
    final specificHandler = _messageHandlers[topic];
    if (specificHandler != null) {
      try {
        specificHandler(topic, payload);
      } catch (e) {
        _logger.e('Error in topic-specific handler for $topic: $e');
      }
    }
  }

  // ===================== PUBLISH METHODS =====================

  Future<bool> publish(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atMostOnce,
  }) async {
    if (!isConnected) {
      _logger.w('Cannot publish: MQTT not connected');
      return false;
    }

    try {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      _client.publishMessage(topic, qos, builder.payload!);
      _logger.d(
        'Published to $topic: ${message.length > 100 ? '${message.substring(0, 100)}...' : message}',
      );
      return true;
    } catch (e) {
      _logger.e('Failed to publish message to $topic: $e');
      return false;
    }
  }

  Future<bool> publishJson(
    String topic,
    Map<String, dynamic> data, {
    MqttQos qos = MqttQos.atMostOnce,
  }) async {
    try {
      final message = jsonEncode(data);
      return await publish(topic, message, qos: qos);
    } catch (e) {
      _logger.e('Failed to encode JSON for topic $topic: $e');
      return false;
    }
  }

  Future<void> _publishOnlineStatus() async {
    final clientId = _client.clientIdentifier;
    await publishJson('status/$clientId', {
      'status': 'online',
      'timestamp': DateTime.now().toIso8601String(),
      'client_id': clientId,
    });
  }

  Future<void> _publishOfflineStatus() async {
    final clientId = _client.clientIdentifier;
    await publishJson('status/$clientId', {
      'status': 'offline',
      'timestamp': DateTime.now().toIso8601String(),
      'client_id': clientId,
    });
  }

  void _publishHeartbeat() {
    final clientId = _client.clientIdentifier;
    publishJson('heartbeat/$clientId', {
      'timestamp': DateTime.now().toIso8601String(),
      'uptime': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ===================== SUBSCRIPTION METHODS =====================

  Future<bool> subscribe(
    String topic, {
    MqttQos qos = MqttQos.atMostOnce,
  }) async {
    if (!isConnected) {
      _logger.w('Cannot subscribe: MQTT not connected');
      return false;
    }

    if (subscribedTopics.contains(topic)) {
      _logger.d('Already subscribed to: $topic');
      return true;
    }

    try {
      _client.subscribe(topic, qos);
      // Manually track subscriptions since callback was removed
      _onSubscribed(topic);
      _logger.i('Subscribed to: $topic');
      return true;
    } catch (e) {
      _logger.e('Failed to subscribe to $topic: $e');
      return false;
    }
  }

  Future<bool> unsubscribe(String topic) async {
    if (!isConnected) {
      _logger.w('Cannot unsubscribe: MQTT not connected');
      return false;
    }

    try {
      _client.unsubscribe(topic);
      // Manually track unsubscriptions since callback was removed
      _onUnsubscribed(topic);
      _logger.i('Unsubscribed from: $topic');
      return true;
    } catch (e) {
      _logger.e('Failed to unsubscribe from $topic: $e');
      return false;
    }
  }

  Future<void> subscribeToMultiple(
    List<String> topics, {
    MqttQos qos = MqttQos.atMostOnce,
  }) async {
    for (final topic in topics) {
      await subscribe(topic, qos: qos);
    }
  }

  Future<void> unsubscribeFromAll() async {
    final topics = List<String>.from(subscribedTopics);
    for (final topic in topics) {
      await unsubscribe(topic);
    }
  }

  // ===================== MESSAGE HANDLER METHODS =====================

  void setMessageHandler(
    String handlerId,
    Function(String topic, String payload) handler,
  ) {
    _messageHandlers[handlerId] = handler;
    _logger.d('Message handler registered: $handlerId');
  }

  void removeMessageHandler(String handlerId) {
    _messageHandlers.remove(handlerId);
    _logger.d('Message handler removed: $handlerId');
  }

  void clearMessageHandlers() {
    _messageHandlers.clear();
    _logger.d('All message handlers cleared');
  }

  // ===================== DEVICE-SPECIFIC METHODS =====================

  Future<bool> publishDeviceCommand(
    String deviceId,
    Map<String, dynamic> command,
  ) async {
    final topic = '$deviceId/device';
    return await publishJson(topic, command);
  }

  Future<bool> subscribeToDevice(String deviceId) async {
    final topic = '$deviceId/mobile';
    return await subscribe(topic);
  }

  Future<bool> subscribeToRegistration(String registrationId) async {
    final topic = '$registrationId/mobile';
    return await subscribe(topic);
  }

  Future<bool> publishIRCommand(
    String irHubId,
    String irDeviceId,
    String buttonId,
    String irCode,
  ) async {
    final topic = '$irHubId/device';
    final command = {
      'command': 'sendIR',
      'irDeviceId': irDeviceId,
      'buttonId': buttonId,
      'irCode': irCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await publishJson(topic, command);
  }

  Future<bool> publishIRLearnCommand(
    String irHubId,
    String irDeviceId,
    String buttonId,
  ) async {
    final topic = '$irHubId/device';
    final command = {
      'command': 'learnIR',
      'irDeviceId': irDeviceId,
      'buttonId': buttonId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await publishJson(topic, command);
  }

  Future<bool> publishWifiStatusRequest(String registrationId) async {
    final topic = '$registrationId/device';
    final command = {
      'command': 'wifiStatus',
      'registrationId': registrationId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await publishJson(topic, command);
  }

  Future<bool> publishWifiConfigCommand(String registrationId) async {
    final topic = '$registrationId/device';
    final command = {
      'command': 'configWifi',
      'registrationId': registrationId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await publishJson(topic, command);
  }

  Future<bool> publishCurtainCommand(
    String deviceId,
    String action, {
    int? seconds,
  }) async {
    final topic = '$deviceId/device';
    final command = {
      'command': 'curtainControl',
      'action':
          action, // 'fullOpen', 'fullClose', 'openUntilPressed', 'closeUntilPressed', 'stop'
      'deviceId': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (seconds != null) {
      command['seconds'] = seconds.toString();
    }

    return await publishJson(topic, command);
  }

  Future<bool> publishTimerCommand(
    String deviceId,
    Map<String, dynamic> timerAction,
  ) async {
    final topic = '$deviceId/device';
    final command = {
      'command': 'setTimer',
      'deviceId': deviceId,
      'action': timerAction,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return await publishJson(topic, command);
  }

  // ===================== UTILITY METHODS =====================

  Future<bool> testConnection() async {
    if (!isConnected) {
      return await connect();
    }

    // Test by publishing a heartbeat
    return await publishJson('test/connection', {
      'test': true,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Map<String, dynamic> getConnectionInfo() {
    return {
      'status': connectionStatus.value.toString(),
      'isConnected': isConnected,
      'broker': _broker,
      'port': _port,
      'clientId': _client.clientIdentifier,
      'subscribedTopics': subscribedTopics.length,
      'reconnectAttempts': _reconnectAttempts,
      'recentMessagesCount': recentMessages.length,
    };
  }

  List<SmartHomeMqttMessage> getRecentMessages({int? limit}) {
    if (limit != null && limit < recentMessages.length) {
      return recentMessages.take(limit).toList();
    }
    return recentMessages.toList();
  }

  List<SmartHomeMqttMessage> getMessagesForTopic(String topic, {int? limit}) {
    final filtered = recentMessages.where((msg) => msg.topic == topic).toList();
    if (limit != null && limit < filtered.length) {
      return filtered.take(limit).toList();
    }
    return filtered;
  }

  void clearRecentMessages() {
    recentMessages.clear();
    _logger.d('Recent messages cleared');
  }

  // Force reconnect (useful for debugging or manual recovery)
  Future<void> forceReconnect() async {
    _logger.i('Force reconnecting to MQTT broker...');
    _disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }
}

// Extension for easier topic building
extension MqttTopicBuilder on String {
  String get deviceTopic => '$this/device';
  String get mobileTopic => '$this/mobile';
  String get statusTopic => 'status/$this';
  String get heartbeatTopic => 'heartbeat/$this';
}
