// lib/core/controllers/timer_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:yantra_smart_home_automation/core/models/timer_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/controllers/device_controller.dart';

class TimerController extends GetxController {
  static TimerController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;
  final _deviceController = DeviceController.to;

  // Observable lists
  final RxList<TimerModel> timers = <TimerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Timer for periodic updates
  Timer? _updateTimer;

  @override
  void onInit() {
    super.onInit();
    loadTimers();
    _startPeriodicUpdates();
  }

  @override
  void onClose() {
    _updateTimer?.cancel();
    super.onClose();
  }

  // ===================== TIMER LOADING =====================

  Future<void> loadTimers() async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedTimers = await _supabaseService.getTimers();
      timers.assignAll(loadedTimers);

      _logger.i('Loaded ${timers.length} timers');
    } catch (e) {
      _logger.e('Error loading timers: $e');
      error.value = 'Failed to load timers: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshTimers() async {
    await loadTimers();
  }

  // ===================== TIMER OPERATIONS =====================

  Future<TimerModel?> createTimer({
    required String deviceId,
    required String name,
    required TimerAction action,
    required int durationMinutes,
  }) async {
    try {
      final device = _deviceController.getDeviceById(deviceId);
      if (device == null) {
        Get.snackbar('Error', 'Device not found');
        return null;
      }

      final timer = TimerModel(
        id: '',
        deviceId: deviceId,
        name: name,
        action: action,
        durationMinutes: durationMinutes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createdTimer = await _supabaseService.createTimer(timer);
      timers.add(createdTimer);

      _logger.i('Timer created: $name for ${device.name}');
      Get.snackbar('Success', 'Timer "$name" created successfully');

      return createdTimer;
    } catch (e) {
      _logger.e('Error creating timer: $e');
      error.value = 'Failed to create timer: $e';
      Get.snackbar('Error', 'Failed to create timer: $e');
      return null;
    }
  }

  Future<bool> startTimer(String timerId) async {
    try {
      final timer = getTimerById(timerId);
      if (timer == null) {
        Get.snackbar('Error', 'Timer not found');
        return false;
      }

      final device = _deviceController.getDeviceById(timer.deviceId);
      if (device == null) {
        Get.snackbar('Error', 'Device not found for timer');
        return false;
      }

      if (!device.isOnline.value) {
        Get.snackbar('Error', 'Device is offline');
        return false;
      }

      final startedTimer = timer.start();
      final updatedTimer = await _supabaseService.updateTimer(startedTimer);

      final index = timers.indexWhere((t) => t.id == timerId);
      if (index != -1) {
        timers[index] = updatedTimer;
      }

      _logger.i('Timer started: ${timer.name}');
      Get.snackbar(
        'Timer Started',
        '"${timer.name}" will execute in ${timer.durationText}',
      );

      return true;
    } catch (e) {
      _logger.e('Error starting timer: $e');
      error.value = 'Failed to start timer: $e';
      Get.snackbar('Error', 'Failed to start timer: $e');
      return false;
    }
  }

  Future<bool> stopTimer(String timerId) async {
    try {
      final timer = getTimerById(timerId);
      if (timer == null) {
        Get.snackbar('Error', 'Timer not found');
        return false;
      }

      final stoppedTimer = timer.stop();
      final updatedTimer = await _supabaseService.updateTimer(stoppedTimer);

      final index = timers.indexWhere((t) => t.id == timerId);
      if (index != -1) {
        timers[index] = updatedTimer;
      }

      _logger.i('Timer stopped: ${timer.name}');
      Get.snackbar('Timer Stopped', '"${timer.name}" has been stopped');

      return true;
    } catch (e) {
      _logger.e('Error stopping timer: $e');
      error.value = 'Failed to stop timer: $e';
      Get.snackbar('Error', 'Failed to stop timer: $e');
      return false;
    }
  }

  Future<bool> updateTimer(TimerModel timer) async {
    try {
      final updatedTimer = await _supabaseService.updateTimer(timer);

      final index = timers.indexWhere((t) => t.id == timer.id);
      if (index != -1) {
        timers[index] = updatedTimer;
        _logger.d('Timer updated: ${timer.name}');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error updating timer: $e');
      error.value = 'Failed to update timer: $e';
      return false;
    }
  }

  Future<bool> deleteTimer(String timerId) async {
    try {
      await _supabaseService.deleteTimer(timerId);
      timers.removeWhere((t) => t.id == timerId);

      _logger.i('Timer deleted: $timerId');
      Get.snackbar('Success', 'Timer deleted successfully');
      return true;
    } catch (e) {
      _logger.e('Error deleting timer: $e');
      error.value = 'Failed to delete timer: $e';
      Get.snackbar('Error', 'Failed to delete timer: $e');
      return false;
    }
  }

  // ===================== QUICK TIMER CREATION =====================

  Future<TimerModel?> createQuickTimer({
    required String deviceId,
    required int minutes,
    TimerActionType action = TimerActionType.turnOff,
  }) async {
    final device = _deviceController.getDeviceById(deviceId);
    if (device == null) return null;

    final timerAction = TimerAction(type: action);

    return await createTimer(
      deviceId: deviceId,
      name: 'Quick ${minutes}min Timer',
      action: timerAction,
      durationMinutes: minutes,
    );
  }

  Future<void> createQuickTimerFromTemplate(
    String templateName,
    String deviceId,
  ) async {
    final template = TimerTemplates.templates.firstWhere(
      (t) => t['name'] == templateName,
      orElse: () => TimerTemplates.templates.first,
    );

    final action = TimerAction.fromJson(
      template['action'] as Map<String, dynamic>,
    );

    await createTimer(
      deviceId: deviceId,
      name: templateName,
      action: action,
      durationMinutes: template['duration'] as int,
    );
  }

  // ===================== TIMER EXECUTION =====================

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateAllTimerCountdowns();
      _checkExpiredTimers();
    });
  }

  void _updateAllTimerCountdowns() {
    for (final timer in timers) {
      if (timer.status == TimerStatus.active) {
        timer.updateCountdown();
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
      final device = _deviceController.getDeviceById(timer.deviceId);
      if (device == null) {
        _logger.w('Device not found for timer: ${timer.name}');
        return;
      }

      _logger.i(
        'Executing timer action: ${timer.name} -> ${timer.action.displayText}',
      );

      // Execute the timer action
      switch (timer.action.type) {
        case TimerActionType.turnOn:
          if (!device.state.value) {
            await _deviceController.toggleDeviceState(device);
          }
          break;
        case TimerActionType.turnOff:
          if (device.state.value) {
            await _deviceController.toggleDeviceState(device);
          }
          break;
        case TimerActionType.toggle:
          await _deviceController.toggleDeviceState(device);
          break;
        case TimerActionType.setBrightness:
          final brightness =
              timer.action.parameters['brightness'] as int? ?? 50;
          await _deviceController.setDeviceSliderValue(
            device,
            brightness.toDouble(),
          );
          break;
        case TimerActionType.setColor:
          final color =
              timer.action.parameters['color'] as String? ?? '#FFFFFF';
          await _deviceController.setDeviceColor(device, color);
          break;
      }

      // Mark timer as completed
      final completedTimer = timer.complete();
      await updateTimer(completedTimer);

      Get.snackbar(
        'Timer Executed',
        '"${timer.name}" completed: ${timer.action.displayText}',
        snackPosition: SnackPosition.BOTTOM,
      );

      _logger.i('Timer action executed successfully: ${timer.name}');
    } catch (e) {
      _logger.e('Error executing timer action: $e');
      Get.snackbar(
        'Timer Error',
        'Failed to execute "${timer.name}": $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ===================== UTILITY METHODS =====================

  TimerModel? getTimerById(String timerId) {
    try {
      return timers.firstWhere((timer) => timer.id == timerId);
    } catch (e) {
      return null;
    }
  }

  List<TimerModel> getTimersForDevice(String deviceId) {
    return timers.where((timer) => timer.deviceId == deviceId).toList();
  }

  List<TimerModel> getActiveTimers() {
    return timers.where((timer) => timer.status == TimerStatus.active).toList();
  }

  List<TimerModel> getCompletedTimers() {
    return timers
        .where((timer) => timer.status == TimerStatus.completed)
        .toList();
  }

  List<TimerModel> searchTimers(String query) {
    if (query.isEmpty) return timers;

    final lowerQuery = query.toLowerCase();
    return timers.where((timer) {
      final device = _deviceController.getDeviceById(timer.deviceId);
      return timer.name.toLowerCase().contains(lowerQuery) ||
          (device?.name.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void clearError() {
    error.value = '';
  }

  bool get hasError => error.value.isNotEmpty;

  int get totalTimers => timers.length;
  int get activeTimersCount => getActiveTimers().length;
  int get completedTimersCount => getCompletedTimers().length;

  // ===================== BULK OPERATIONS =====================

  Future<void> stopAllActiveTimers() async {
    final activeTimers = getActiveTimers();

    for (final timer in activeTimers) {
      await stopTimer(timer.id);
    }

    Get.snackbar(
      'Timers Stopped',
      'Stopped ${activeTimers.length} active timers',
    );
  }

  Future<void> deleteCompletedTimers() async {
    final completedTimers = getCompletedTimers();

    for (final timer in completedTimers) {
      await deleteTimer(timer.id);
    }

    Get.snackbar(
      'Cleanup Complete',
      'Deleted ${completedTimers.length} completed timers',
    );
  }

  // ===================== DASHBOARD INSIGHTS =====================

  Map<String, dynamic> getTimerInsights() {
    return {
      'totalTimers': totalTimers,
      'activeTimers': activeTimersCount,
      'completedTimers': completedTimersCount,
      'averageDuration': _getAverageTimerDuration(),
      'mostUsedActions': _getMostUsedActions(),
      'timersByDevice': _getTimersByDevice(),
    };
  }

  double _getAverageTimerDuration() {
    if (timers.isEmpty) return 0.0;
    final totalMinutes = timers.fold<int>(
      0,
      (sum, timer) => sum + timer.durationMinutes,
    );
    return totalMinutes / timers.length;
  }

  Map<String, int> _getMostUsedActions() {
    final actionStats = <String, int>{};
    for (final timer in timers) {
      final actionName = timer.action.type.displayText;
      actionStats[actionName] = (actionStats[actionName] ?? 0) + 1;
    }
    return actionStats;
  }

  Map<String, int> _getTimersByDevice() {
    final deviceStats = <String, int>{};
    for (final timer in timers) {
      final device = _deviceController.getDeviceById(timer.deviceId);
      final deviceName = device?.name ?? 'Unknown Device';
      deviceStats[deviceName] = (deviceStats[deviceName] ?? 0) + 1;
    }
    return deviceStats;
  }

  // ===================== ADVANCED FEATURES =====================

  Future<void> createSleepTimer(String deviceId, int minutes) async {
    await createTimer(
      deviceId: deviceId,
      name: 'Sleep Timer ($minutes min)',
      action: const TimerAction(type: TimerActionType.turnOff),
      durationMinutes: minutes,
    );
  }

  Future<void> createWakeUpTimer(
    String deviceId,
    int minutes, {
    double brightness = 80,
  }) async {
    await createTimer(
      deviceId: deviceId,
      name: 'Wake Up Timer ($minutes min)',
      action: TimerAction(
        type: TimerActionType.setBrightness,
        parameters: {'brightness': brightness.round()},
      ),
      durationMinutes: minutes,
    );
  }

  Future<void> createSequentialTimers(
    List<Map<String, dynamic>> timerConfigs,
  ) async {
    for (int i = 0; i < timerConfigs.length; i++) {
      final config = timerConfigs[i];
      await createTimer(
        deviceId: config['deviceId'] as String,
        name: 'Sequential Timer ${i + 1}',
        action: TimerAction.fromJson(config['action'] as Map<String, dynamic>),
        durationMinutes: config['duration'] as int,
      );

      // Small delay between creating timers
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
