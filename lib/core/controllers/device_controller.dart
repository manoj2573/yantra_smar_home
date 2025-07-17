// lib/core/controllers/device_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/device_model.dart';
import '../models/timer_model.dart';
import '../services/supabase_service.dart';
import '../services/mqtt_service.dart';

class DeviceController extends GetxController {
  static DeviceController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;
  final _mqttService = MqttService.to;

  // Observable lists
  final RxList<DeviceModel> devices = <DeviceModel>[].obs;
  final RxList<TimerModel> timers = <TimerModel>[].obs;
  final RxMap<String, List<DeviceModel>> devicesByRoom =
      <String, List<DeviceModel>>{}.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;

  // Timers for periodic updates
  Timer? _deviceStatusTimer;
  Timer? _timerUpdateTimer;

  // Subscriptions
  StreamSubscription? _deviceSubscription;
  StreamSubscription? _timerSubscription;

  @override
  void onInit() {
    super.onInit();
    _setupMqttHandlers();
    _startPeriodicUpdates();
    loadDevices();
    loadTimers();
  }

  @override
  void onClose() {
    _deviceStatusTimer?.cancel();
    _timerUpdateTimer?.cancel();
    _deviceSubscription?.cancel();
    _timerSubscription?.cancel();
    super.onClose();
  }

  // ===================== DEVICE LOADING =====================

  Future<void> loadDevices() async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedDevices = await _supabaseService.getDevices();
      devices.assignAll(loadedDevices);
      _groupDevicesByRoom();

      // Subscribe to MQTT topics for all devices
      await _subscribeToDeviceTopics();

      _logger.i('Loaded ${devices.length} devices');
    } catch (e) {
      _logger.e('Error loading devices: $e');
      error.value = 'Failed to load devices: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDevices() async {
    try {
      isRefreshing.value = true;
      await loadDevices();
    } finally {
      isRefreshing.value = false;
    }
  }

  void _groupDevicesByRoom() {
    final grouped = <String, List<DeviceModel>>{};

    for (final device in devices) {
      final roomName = device.roomName ?? 'Unknown Room';
      grouped.putIfAbsent(roomName, () => []).add(device);
    }

    devicesByRoom.assignAll(grouped);
  }

  // ===================== DEVICE OPERATIONS =====================

  Future<DeviceModel?> addDevice(DeviceModel device) async {
    try {
      final createdDevice = await _supabaseService.createDevice(device);
      devices.add(createdDevice);
      _groupDevicesByRoom();

      // Subscribe to the new device's MQTT topic
      await _mqttService.subscribeToDevice(createdDevice.deviceId);

      _logger.i('Device added: ${createdDevice.name}');
      return createdDevice;
    } catch (e) {
      _logger.e('Error adding device: $e');
      error.value = 'Failed to add device: $e';
      return null;
    }
  }

  Future<bool> updateDevice(DeviceModel device) async {
    try {
      final updatedDevice = await _supabaseService.updateDevice(device);
      final index = devices.indexWhere((d) => d.id == device.id);

      if (index != -1) {
        devices[index] = updatedDevice;
        _groupDevicesByRoom();
        _logger.d('Device updated: ${updatedDevice.name}');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error updating device: $e');
      error.value = 'Failed to update device: $e';
      return false;
    }
  }

  Future<bool> deleteDevice(String deviceId) async {
    try {
      await _supabaseService.deleteDevice(deviceId);
      devices.removeWhere((d) => d.id == deviceId);
      _groupDevicesByRoom();

      _logger.i('Device deleted: $deviceId');
      return true;
    } catch (e) {
      _logger.e('Error deleting device: $e');
      error.value = 'Failed to delete device: $e';
      return false;
    }
  }

  // ===================== DEVICE CONTROL =====================

  Future<void> toggleDeviceState(DeviceModel device) async {
    final newState = !device.state.value;

    // Optimistic update
    device.state.value = newState;

    try {
      // Send MQTT command
      final success = await _mqttService.publishDeviceCommand(
        device.deviceId,
        device.toMqttPayload(),
      );

      if (!success) {
        // Revert on failure
        device.state.value = !newState;
        error.value = 'Failed to send device command';
        return;
      }

      // Update database
      await updateDevice(device);

      _logger.d('Device ${device.name} turned ${newState ? 'on' : 'off'}');
    } catch (e) {
      // Revert on error
      device.state.value = !newState;
      _logger.e('Error toggling device state: $e');
      error.value = 'Failed to control device: $e';
    }
  }

  Future<void> setDeviceSliderValue(DeviceModel device, double value) async {
    if (!device.supportsSlider) return;

    final oldValue = device.sliderValue?.value ?? 0;

    // Optimistic update
    device.sliderValue?.value = value;
    if (value > 0) device.state.value = true;
    if (value == 0) device.state.value = false;

    try {
      // Send MQTT command
      final success = await _mqttService.publishDeviceCommand(
        device.deviceId,
        device.toMqttPayload(),
      );

      if (!success) {
        // Revert on failure
        device.sliderValue?.value = oldValue;
        error.value = 'Failed to send device command';
        return;
      }

      // Update database
      await updateDevice(device);

      _logger.d('Device ${device.name} slider set to $value');
    } catch (e) {
      // Revert on error
      device.sliderValue?.value = oldValue;
      _logger.e('Error setting device slider: $e');
      error.value = 'Failed to control device: $e';
    }
  }

  Future<void> setDeviceColor(DeviceModel device, String colorHex) async {
    if (!device.supportsColor) return;

    final oldColor = device.color.value;

    // Optimistic update
    device.color.value = colorHex;
    device.state.value = true; // Turn on when setting color

    try {
      // Send MQTT command
      final success = await _mqttService.publishDeviceCommand(
        device.deviceId,
        device.toMqttPayload(),
      );

      if (!success) {
        // Revert on failure
        device.color.value = oldColor;
        error.value = 'Failed to send device command';
        return;
      }

      // Update database
      await updateDevice(device);

      _logger.d('Device ${device.name} color set to $colorHex');
    } catch (e) {
      // Revert on error
      device.color.value = oldColor;
      _logger.e('Error setting device color: $e');
      error.value = 'Failed to control device: $e';
    }
  }

  // ===================== CURTAIN CONTROLS =====================

  Future<void> curtainFullOpen(String deviceId) async {
    await _mqttService.publishCurtainCommand(deviceId, 'fullOpen');
    _logger.d('Curtain full open command sent to $deviceId');
  }

  Future<void> curtainFullClose(String deviceId) async {
    await _mqttService.publishCurtainCommand(deviceId, 'fullClose');
    _logger.d('Curtain full close command sent to $deviceId');
  }

  Future<void> curtainOpenUntilPressed(String deviceId, {int? seconds}) async {
    await _mqttService.publishCurtainCommand(
      deviceId,
      'openUntilPressed',
      seconds: seconds,
    );
    _logger.d('Curtain open until pressed command sent to $deviceId');
  }

  Future<void> curtainCloseUntilPressed(String deviceId, {int? seconds}) async {
    await _mqttService.publishCurtainCommand(
      deviceId,
      'closeUntilPressed',
      seconds: seconds,
    );
    _logger.d('Curtain close until pressed command sent to $deviceId');
  }

  Future<void> curtainStop(String deviceId) async {
    await _mqttService.publishCurtainCommand(deviceId, 'stop');
    _logger.d('Curtain stop command sent to $deviceId');
  }

  // ===================== ROOM OPERATIONS =====================

  Future<void> toggleRoomDevices(String roomName, bool turnOn) async {
    final roomDevices = devicesByRoom[roomName] ?? [];

    for (final device in roomDevices) {
      if (device.state.value != turnOn) {
        await toggleDeviceState(device);
      }
    }

    _logger.i('Room $roomName devices turned ${turnOn ? 'on' : 'off'}');
  }

  // ===================== TIMER OPERATIONS =====================

  Future<void> loadTimers() async {
    try {
      final loadedTimers = await _supabaseService.getTimers();
      timers.assignAll(loadedTimers);
      _logger.i('Loaded ${timers.length} timers');
    } catch (e) {
      _logger.e('Error loading timers: $e');
      error.value = 'Failed to load timers: $e';
    }
  }

  Future<TimerModel?> createTimer(TimerModel timer) async {
    try {
      final createdTimer = await _supabaseService.createTimer(timer);
      timers.add(createdTimer);

      _logger.i('Timer created: ${createdTimer.name}');
      return createdTimer;
    } catch (e) {
      _logger.e('Error creating timer: $e');
      error.value = 'Failed to create timer: $e';
      return null;
    }
  }

  Future<bool> startTimer(String timerId) async {
    try {
      final timer = timers.firstWhere((t) => t.id == timerId);
      final startedTimer = timer.start();

      final success = await _supabaseService.updateTimer(startedTimer);
      final index = timers.indexWhere((t) => t.id == timerId);
      timers[index] = success;

      _logger.i('Timer started: ${timer.name}');
      return true;

      return false;
    } catch (e) {
      _logger.e('Error starting timer: $e');
      error.value = 'Failed to start timer: $e';
      return false;
    }
  }

  Future<bool> stopTimer(String timerId) async {
    try {
      final timer = timers.firstWhere((t) => t.id == timerId);
      final stoppedTimer = timer.stop();

      final success = await _supabaseService.updateTimer(stoppedTimer);
      final index = timers.indexWhere((t) => t.id == timerId);
      timers[index] = success;

      _logger.i('Timer stopped: ${timer.name}');
      return true;

      return false;
    } catch (e) {
      _logger.e('Error stopping timer: $e');
      error.value = 'Failed to stop timer: $e';
      return false;
    }
  }

  Future<void> deleteTimer(String timerId) async {
    try {
      await _supabaseService.deleteTimer(timerId);
      timers.removeWhere((t) => t.id == timerId);

      _logger.i('Timer deleted: $timerId');
    } catch (e) {
      _logger.e('Error deleting timer: $e');
      error.value = 'Failed to delete timer: $e';
    }
  }

  // ===================== DEVICE STATUS MANAGEMENT =====================

  Future<void> requestDeviceStatus() async {
    final registrationIds = devices.map((d) => d.registrationId).toSet();

    for (final regId in registrationIds) {
      await _mqttService.publishWifiStatusRequest(regId);
    }

    _logger.d(
      'Device status requested for ${registrationIds.length} registrations',
    );
  }

  void updateDeviceOnlineStatus(String deviceId, bool isOnline) {
    final device = devices.firstWhereOrNull((d) => d.deviceId == deviceId);
    if (device != null) {
      device.isOnline.value = isOnline;
      // Update in database asynchronously
      updateDevice(device);
    }
  }

  // ===================== MQTT HANDLERS =====================

  void _setupMqttHandlers() {
    _mqttService.setMessageHandler('device_controller', _onMqttMessage);
  }

  void _onMqttMessage(String topic, String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final parts = topic.split('/');

      if (parts.length < 2) return;

      final deviceId = parts[0];
      final messageType = parts[1];

      if (messageType == 'mobile') {
        _handleDeviceStateUpdate(deviceId, data);
      }
    } catch (e) {
      _logger.e('Error processing MQTT message: $e');
    }
  }

  void _handleDeviceStateUpdate(String deviceId, Map<String, dynamic> data) {
    final device = devices.firstWhereOrNull((d) => d.deviceId == deviceId);
    if (device == null) return;

    bool hasChanges = false;

    // Update state
    if (data.containsKey('state') && data['state'] != device.state.value) {
      device.state.value = data['state'] as bool;
      hasChanges = true;
    }

    // Update slider value
    if (data.containsKey('sliderValue') && device.sliderValue != null) {
      final newValue = (data['sliderValue'] as num?)?.toDouble() ?? 0;
      if (newValue != device.sliderValue!.value) {
        device.sliderValue!.value = newValue;
        hasChanges = true;
      }
    }

    // Update color
    if (data.containsKey('color') && data['color'] != device.color.value) {
      device.color.value = data['color'] as String;
      hasChanges = true;
    }

    // Update online status
    device.isOnline.value = true;

    if (hasChanges) {
      // Update database asynchronously
      updateDevice(device);
      _logger.d('Device ${device.name} state updated from MQTT');
    }
  }

  Future<void> _subscribeToDeviceTopics() async {
    for (final device in devices) {
      await _mqttService.subscribeToDevice(device.deviceId);
    }

    // Subscribe to registration topics for status updates
    final registrationIds = devices.map((d) => d.registrationId).toSet();
    for (final regId in registrationIds) {
      await _mqttService.subscribeToRegistration(regId);
    }
  }

  // ===================== PERIODIC UPDATES =====================

  void _startPeriodicUpdates() {
    // Update device status every 30 seconds
    _deviceStatusTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      requestDeviceStatus();
    });

    // Update timer countdown every second
    _timerUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimerCountdowns();
      _checkExpiredTimers();
    });
  }

  void _updateTimerCountdowns() {
    for (final timer in timers) {
      if (timer.status == TimerStatus.active) {
        timer.updateCountdown(); // Call the public method
      }
    }
  }

  void _checkExpiredTimers() {
    for (final timer in timers) {
      if (timer.status == TimerStatus.expired && !timer.isCompleted.value) {
        _executeTimerAction(timer);
      }
    }
  }

  Future<void> _executeTimerAction(TimerModel timer) async {
    try {
      final device = devices.firstWhereOrNull((d) => d.id == timer.deviceId);
      if (device == null) {
        _logger.w('Device not found for timer: ${timer.name}');
        return;
      }

      // Execute the timer action
      switch (timer.action.type) {
        case TimerActionType.turnOn:
          if (!device.state.value) await toggleDeviceState(device);
          break;
        case TimerActionType.turnOff:
          if (device.state.value) await toggleDeviceState(device);
          break;
        case TimerActionType.setBrightness:
          final brightness =
              timer.action.parameters['brightness'] as int? ?? 50;
          await setDeviceSliderValue(device, brightness.toDouble());
          break;
        case TimerActionType.setColor:
          final color =
              timer.action.parameters['color'] as String? ?? '#FFFFFF';
          await setDeviceColor(device, color);
          break;
        case TimerActionType.toggle:
          await toggleDeviceState(device);
          break;
      }

      // Mark timer as completed
      final completedTimer = timer.complete();
      await _supabaseService.updateTimer(completedTimer);

      final index = timers.indexWhere((t) => t.id == timer.id);
      if (index != -1) {
        timers[index] = completedTimer;
      }

      _logger.i(
        'Timer action executed: ${timer.name} -> ${timer.action.displayText}',
      );
    } catch (e) {
      _logger.e('Error executing timer action: $e');
    }
  }

  // ===================== UTILITY METHODS =====================

  DeviceModel? getDeviceById(String deviceId) {
    return devices.firstWhereOrNull((d) => d.id == deviceId);
  }

  DeviceModel? getDeviceByDeviceId(String deviceId) {
    return devices.firstWhereOrNull((d) => d.deviceId == deviceId);
  }

  List<DeviceModel> getDevicesByRoom(String roomName) {
    return devicesByRoom[roomName] ?? [];
  }

  List<DeviceModel> getDevicesByType(DeviceType type) {
    return devices.where((d) => d.type == type).toList();
  }

  List<DeviceModel> getOnlineDevices() {
    return devices.where((d) => d.isOnline.value).toList();
  }

  List<DeviceModel> getOfflineDevices() {
    return devices.where((d) => !d.isOnline.value).toList();
  }

  List<TimerModel> getActiveTimers() {
    return timers.where((t) => t.status == TimerStatus.active).toList();
  }

  List<TimerModel> getTimersForDevice(String deviceId) {
    return timers.where((t) => t.deviceId == deviceId).toList();
  }

  int get totalDevices => devices.length;
  int get onlineDevicesCount => getOnlineDevices().length;
  int get activeTimersCount => getActiveTimers().length;

  double get deviceOnlinePercentage {
    if (totalDevices == 0) return 0.0;
    return (onlineDevicesCount / totalDevices) * 100;
  }

  // ===================== BULK OPERATIONS =====================

  Future<void> turnOffAllDevices() async {
    for (final device in devices) {
      if (device.state.value) {
        await toggleDeviceState(device);
      }
    }
    _logger.i('All devices turned off');
  }

  Future<void> turnOnAllDevices() async {
    for (final device in devices) {
      if (!device.state.value) {
        await toggleDeviceState(device);
      }
    }
    _logger.i('All devices turned on');
  }

  Future<void> setAllDevicesBrightness(double brightness) async {
    for (final device in devices) {
      if (device.supportsSlider) {
        await setDeviceSliderValue(device, brightness);
      }
    }
    _logger.i('All dimmable devices set to brightness: $brightness');
  }

  // ===================== DIAGNOSTICS =====================

  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'totalDevices': totalDevices,
      'onlineDevices': onlineDevicesCount,
      'offlineDevices': totalDevices - onlineDevicesCount,
      'deviceOnlinePercentage': deviceOnlinePercentage,
      'activeTimers': activeTimersCount,
      'totalTimers': timers.length,
      'roomCount': devicesByRoom.length,
      'deviceTypes': _getDeviceTypeStats(),
      'lastError': error.value,
    };
  }

  Map<String, int> _getDeviceTypeStats() {
    final stats = <String, int>{};
    for (final device in devices) {
      final typeName = device.type.displayName;
      stats[typeName] = (stats[typeName] ?? 0) + 1;
    }
    return stats;
  }

  // ===================== ERROR HANDLING =====================

  void clearError() {
    error.value = '';
  }

  bool get hasError => error.value.isNotEmpty;

  // ===================== SEARCH & FILTER =====================

  List<DeviceModel> searchDevices(String query) {
    if (query.isEmpty) return devices;

    final lowerQuery = query.toLowerCase();
    return devices.where((device) {
      return device.name.toLowerCase().contains(lowerQuery) ||
          device.type.displayName.toLowerCase().contains(lowerQuery) ||
          (device.roomName?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<DeviceModel> filterDevicesByStatus(DeviceStatus status) {
    return devices.where((device) => device.status == status).toList();
  }

  // ===================== DEVICE UPDATES =====================

  Future<void> updateDeviceName(String deviceId, String newName) async {
    final device = getDeviceById(deviceId);
    if (device == null) return;

    final updatedDevice = device.copyWith(name: newName);
    await updateDevice(updatedDevice);
  }

  Future<void> updateDeviceIcon(String deviceId, String newIconPath) async {
    final device = getDeviceById(deviceId);
    if (device == null) return;

    final updatedDevice = device.copyWith(iconPath: newIconPath);
    await updateDevice(updatedDevice);
  }

  Future<void> updateDeviceRoom(String deviceId, String roomId) async {
    final device = getDeviceById(deviceId);
    if (device == null) return;

    final updatedDevice = device.copyWith(roomId: roomId);
    await updateDevice(updatedDevice);
    _groupDevicesByRoom(); // Refresh room grouping
  }

  // ===================== REAL-TIME SUBSCRIPTIONS =====================

  void startRealtimeSubscriptions() {
    // Subscribe to device changes
    _deviceSubscription =
        _supabaseService.subscribeToDevices(
              onData: (updatedDevices) {
                devices.assignAll(updatedDevices);
                _groupDevicesByRoom();
                _logger.d('Devices updated via real-time subscription');
              },
            )
            as StreamSubscription?;

    // Subscribe to timer changes
    _timerSubscription =
        _supabaseService.subscribeToTimers(
              onData: (updatedTimers) {
                timers.assignAll(updatedTimers);
                _logger.d('Timers updated via real-time subscription');
              },
            )
            as StreamSubscription?;
  }

  void stopRealtimeSubscriptions() {
    _deviceSubscription?.cancel();
    _timerSubscription?.cancel();
    _deviceSubscription = null;
    _timerSubscription = null;
  }
}
