// lib/features/schedules/controllers/schedule_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/models/device_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/controllers/device_controller.dart';

class ScheduleController extends GetxController {
  static ScheduleController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;
  final _deviceController = DeviceController.to;

  // Observable lists
  final RxList<ScheduleModel> schedules = <ScheduleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;

  // Timer for checking schedule execution
  Timer? _scheduleCheckTimer;

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
    _startScheduleChecker();
  }

  @override
  void onClose() {
    _scheduleCheckTimer?.cancel();
    super.onClose();
  }

  // ===================== SCHEDULE LOADING =====================

  Future<void> loadSchedules() async {
    try {
      isLoading.value = true;
      error.value = '';

      final response = await _supabaseService.client
          .from('schedules')
          .select('*, devices(name, type)')
          .eq('user_id', _supabaseService.userId!)
          .order('created_at', ascending: false);

      final loadedSchedules = <ScheduleModel>[];
      for (final data in response) {
        // Add device name from joined data
        if (data['devices'] != null) {
          data['device_name'] = data['devices']['name'];
        }
        loadedSchedules.add(ScheduleModel.fromSupabase(data));
      }

      schedules.assignAll(loadedSchedules);
      _logger.i('Loaded ${schedules.length} schedules');
    } catch (e) {
      _logger.e('Error loading schedules: $e');
      error.value = 'Failed to load schedules: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSchedules() async {
    try {
      isRefreshing.value = true;
      await loadSchedules();
    } finally {
      isRefreshing.value = false;
    }
  }

  // ===================== SCHEDULE OPERATIONS =====================

  Future<ScheduleModel?> createSchedule(ScheduleModel schedule) async {
    try {
      final data = schedule.toSupabase();
      data['user_id'] = _supabaseService.userId!;

      final response =
          await _supabaseService.client
              .from('schedules')
              .insert(data)
              .select()
              .single();

      final createdSchedule = ScheduleModel.fromSupabase(response);
      schedules.add(createdSchedule);

      _logger.i('Schedule created: ${schedule.name}');
      return createdSchedule;
    } catch (e) {
      _logger.e('Error creating schedule: $e');
      error.value = 'Failed to create schedule: $e';
      return null;
    }
  }

  Future<bool> updateSchedule(ScheduleModel schedule) async {
    try {
      final response =
          await _supabaseService.client
              .from('schedules')
              .update(schedule.toSupabase())
              .eq('id', schedule.id)
              .eq('user_id', _supabaseService.userId!)
              .select()
              .single();

      final updatedSchedule = ScheduleModel.fromSupabase(response);
      final index = schedules.indexWhere((s) => s.id == schedule.id);

      if (index != -1) {
        schedules[index] = updatedSchedule;
        _logger.d('Schedule updated: ${schedule.name}');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error updating schedule: $e');
      error.value = 'Failed to update schedule: $e';
      return false;
    }
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _supabaseService.client
          .from('schedules')
          .delete()
          .eq('id', scheduleId)
          .eq('user_id', _supabaseService.userId!);

      schedules.removeWhere((s) => s.id == scheduleId);
      _logger.i('Schedule deleted: $scheduleId');
      return true;
    } catch (e) {
      _logger.e('Error deleting schedule: $e');
      error.value = 'Failed to delete schedule: $e';
      return false;
    }
  }

  // ===================== SCHEDULE EXECUTION =====================

  void _startScheduleChecker() {
    // Check schedules every minute
    _scheduleCheckTimer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _checkSchedules(),
    );
  }

  void _checkSchedules() {
    final now = DateTime.now();
    final currentDay = WeekDay.fromDateTime(now);
    final currentTime = TimeOfDay.fromDateTime(now);

    for (final schedule in schedules) {
      if (!schedule.isActive.value || !schedule.runsToday) continue;

      _checkScheduleExecution(schedule, currentDay, currentTime);
    }
  }

  void _checkScheduleExecution(
    ScheduleModel schedule,
    WeekDay currentDay,
    TimeOfDay currentTime,
  ) {
    final device = _deviceController.getDeviceById(schedule.deviceId);
    if (device == null || !device.isOnline.value) return;

    // Check on time
    if (schedule.hasOnTime && _isTimeMatch(schedule.onTime!, currentTime)) {
      _executeScheduleAction(schedule, device, true);
    }

    // Check off time
    if (schedule.hasOffTime && _isTimeMatch(schedule.offTime!, currentTime)) {
      _executeScheduleAction(schedule, device, false);
    }

    // Check custom action
    if (schedule.hasAction &&
        schedule.hasOnTime &&
        _isTimeMatch(schedule.onTime!, currentTime)) {
      _executeCustomAction(schedule, device);
    }
  }

  bool _isTimeMatch(TimeOfDay scheduleTime, TimeOfDay currentTime) {
    return scheduleTime.hour == currentTime.hour &&
        scheduleTime.minute == currentTime.minute;
  }

  Future<void> _executeScheduleAction(
    ScheduleModel schedule,
    DeviceModel device,
    bool turnOn,
  ) async {
    try {
      if (device.state.value != turnOn) {
        await _deviceController.toggleDeviceState(device);

        _logger.i(
          'Schedule executed: ${schedule.name} - ${device.name} turned ${turnOn ? 'on' : 'off'}',
        );

        _showScheduleNotification(
          schedule,
          device,
          '${device.name} turned ${turnOn ? 'on' : 'off'}',
        );
      }
    } catch (e) {
      _logger.e('Error executing schedule action: $e');
    }
  }

  Future<void> _executeCustomAction(
    ScheduleModel schedule,
    DeviceModel device,
  ) async {
    try {
      final action = schedule.action!;

      switch (action.type) {
        case 'turn_on':
          if (!device.state.value) {
            await _deviceController.toggleDeviceState(device);
          }
          break;
        case 'turn_off':
          if (device.state.value) {
            await _deviceController.toggleDeviceState(device);
          }
          break;
        case 'set_brightness':
          final brightness = action.parameters['brightness'] as int? ?? 50;
          await _deviceController.setDeviceSliderValue(
            device,
            brightness.toDouble(),
          );
          break;
        case 'set_color':
          final color = action.parameters['color'] as String? ?? '#FFFFFF';
          await _deviceController.setDeviceColor(device, color);
          break;
        case 'toggle':
          await _deviceController.toggleDeviceState(device);
          break;
      }

      _logger.i(
        'Custom schedule action executed: ${schedule.name} - ${action.displayText}',
      );
      _showScheduleNotification(schedule, device, action.displayText);
    } catch (e) {
      _logger.e('Error executing custom schedule action: $e');
    }
  }

  void _showScheduleNotification(
    ScheduleModel schedule,
    DeviceModel device,
    String actionText,
  ) {
    Get.snackbar(
      'Schedule Executed',
      '${schedule.name}: $actionText',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.blue.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.schedule, color: Colors.white),
    );
  }

  // ===================== SCHEDULE MANAGEMENT =====================

  Future<bool> toggleSchedule(String scheduleId) async {
    final schedule = getScheduleById(scheduleId);
    if (schedule == null) return false;

    final updatedSchedule = schedule.copyWith(
      isActive: !schedule.isActive.value,
    );

    return await updateSchedule(updatedSchedule);
  }

  Future<bool> enableAllSchedules() async {
    try {
      for (final schedule in schedules) {
        if (!schedule.isActive.value) {
          await toggleSchedule(schedule.id);
        }
      }
      return true;
    } catch (e) {
      _logger.e('Error enabling all schedules: $e');
      return false;
    }
  }

  Future<bool> disableAllSchedules() async {
    try {
      for (final schedule in schedules) {
        if (schedule.isActive.value) {
          await toggleSchedule(schedule.id);
        }
      }
      return true;
    } catch (e) {
      _logger.e('Error disabling all schedules: $e');
      return false;
    }
  }

  // ===================== SCHEDULE QUERIES =====================

  List<ScheduleModel> getActiveSchedules() {
    return schedules.where((s) => s.status == ScheduleStatus.active).toList();
  }

  List<ScheduleModel> getSchedulesForDevice(String deviceId) {
    return schedules.where((s) => s.deviceId == deviceId).toList();
  }

  List<ScheduleModel> getSchedulesForToday() {
    return schedules.where((s) => s.runsToday).toList();
  }

  List<ScheduleModel> getUpcomingSchedules() {
    final now = DateTime.now();
    final today = WeekDay.fromDateTime(now);
    final currentTime = TimeOfDay.fromDateTime(now);

    return schedules.where((schedule) {
        if (!schedule.isActive.value) return false;

        final nextExecution = schedule.nextExecution;
        if (nextExecution == null) return false;

        final timeUntilNext = nextExecution.difference(now);
        return timeUntilNext.inHours <= 24;
      }).toList()
      ..sort((a, b) {
        final aNext = a.nextExecution;
        final bNext = b.nextExecution;
        if (aNext == null && bNext == null) return 0;
        if (aNext == null) return 1;
        if (bNext == null) return -1;
        return aNext.compareTo(bNext);
      });
  }

  // ===================== SEARCH & FILTER =====================

  List<ScheduleModel> searchSchedules(String query) {
    if (query.isEmpty) return schedules;

    final lowerQuery = query.toLowerCase();
    return schedules.where((schedule) {
      return schedule.name.toLowerCase().contains(lowerQuery) ||
          schedule.deviceName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<ScheduleModel> filterSchedulesByDay(WeekDay day) {
    return schedules.where((s) => s.days.contains(day)).toList();
  }

  List<ScheduleModel> filterSchedulesByStatus(ScheduleStatus status) {
    return schedules.where((s) => s.status == status).toList();
  }

  // ===================== UTILITY METHODS =====================

  ScheduleModel? getScheduleById(String scheduleId) {
    try {
      return schedules.firstWhere((s) => s.id == scheduleId);
    } catch (e) {
      return null;
    }
  }

  bool hasConflictingSchedule(ScheduleModel newSchedule) {
    return schedules.any((existing) {
      if (existing.deviceId != newSchedule.deviceId) return false;
      if (existing.id == newSchedule.id) return false;

      // Check for overlapping days
      final hasOverlappingDays = existing.days.any(
        (day) => newSchedule.days.contains(day),
      );

      if (!hasOverlappingDays) return false;

      // Check for time conflicts
      return _hasTimeConflict(existing, newSchedule);
    });
  }

  bool _hasTimeConflict(ScheduleModel existing, ScheduleModel newSchedule) {
    // Simple time conflict check - can be enhanced
    if (existing.hasOnTime && newSchedule.hasOnTime) {
      if (_timesAreEqual(existing.onTime!, newSchedule.onTime!)) {
        return true;
      }
    }

    if (existing.hasOffTime && newSchedule.hasOffTime) {
      if (_timesAreEqual(existing.offTime!, newSchedule.offTime!)) {
        return true;
      }
    }

    return false;
  }

  bool _timesAreEqual(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour == time2.hour && time1.minute == time2.minute;
  }

  void clearError() {
    error.value = '';
  }

  bool get hasError => error.value.isNotEmpty;

  // ===================== SCHEDULE STATISTICS =====================

  Map<String, dynamic> getScheduleStatistics() {
    final totalSchedules = schedules.length;
    final activeSchedules = getActiveSchedules().length;
    final todaySchedules = getSchedulesForToday().length;
    final upcomingSchedules = getUpcomingSchedules().length;

    // Device usage statistics
    final deviceUsage = <String, int>{};
    for (final schedule in schedules) {
      deviceUsage[schedule.deviceName] =
          (deviceUsage[schedule.deviceName] ?? 0) + 1;
    }

    // Day usage statistics
    final dayUsage = <WeekDay, int>{};
    for (final schedule in schedules) {
      for (final day in schedule.days) {
        dayUsage[day] = (dayUsage[day] ?? 0) + 1;
      }
    }

    return {
      'totalSchedules': totalSchedules,
      'activeSchedules': activeSchedules,
      'todaySchedules': todaySchedules,
      'upcomingSchedules': upcomingSchedules,
      'deviceUsage': deviceUsage,
      'dayUsage': dayUsage.map((day, count) => MapEntry(day.fullName, count)),
      'averageSchedulesPerDevice':
          deviceUsage.isNotEmpty ? totalSchedules / deviceUsage.length : 0,
    };
  }

  // ===================== BULK OPERATIONS =====================

  Future<List<ScheduleModel>> createWeeklySchedule({
    required String deviceId,
    required String baseName,
    required TimeOfDay onTime,
    required TimeOfDay offTime,
    List<WeekDay>? days,
  }) async {
    final selectedDays = days ?? WeekDay.values;
    final createdSchedules = <ScheduleModel>[];

    try {
      for (final day in selectedDays) {
        final schedule = ScheduleModel(
          id: '',
          deviceId: deviceId,
          name: '$baseName - ${day.fullName}',
          days: [day],
          onTime: onTime,
          offTime: offTime,
        );

        final created = await createSchedule(schedule);
        if (created != null) {
          createdSchedules.add(created);
        }
      }

      _logger.i('Created ${createdSchedules.length} weekly schedules');
      return createdSchedules;
    } catch (e) {
      _logger.e('Error creating weekly schedule: $e');
      return createdSchedules;
    }
  }

  Future<bool> deleteSchedulesForDevice(String deviceId) async {
    try {
      final deviceSchedules = getSchedulesForDevice(deviceId);

      for (final schedule in deviceSchedules) {
        await deleteSchedule(schedule.id);
      }

      _logger.i('Deleted ${deviceSchedules.length} schedules for device');
      return true;
    } catch (e) {
      _logger.e('Error deleting device schedules: $e');
      return false;
    }
  }

  // ===================== SCHEDULE TEMPLATES =====================

  Future<List<ScheduleModel>> createScheduleFromTemplate({
    required String templateName,
    required String deviceId,
  }) async {
    final createdSchedules = <ScheduleModel>[];

    try {
      switch (templateName) {
        case 'Workday Lighting':
          // Turn on at 7 AM, off at 11 PM on weekdays
          final workdaySchedule = ScheduleModel(
            id: '',
            deviceId: deviceId,
            name: 'Workday Lighting',
            days: [
              WeekDay.monday,
              WeekDay.tuesday,
              WeekDay.wednesday,
              WeekDay.thursday,
              WeekDay.friday,
            ],
            onTime: const TimeOfDay(hour: 7, minute: 0),
            offTime: const TimeOfDay(hour: 23, minute: 0),
          );
          final created = await createSchedule(workdaySchedule);
          if (created != null) createdSchedules.add(created);
          break;

        case 'Weekend Relaxed':
          // Turn on at 9 AM, off at midnight on weekends
          final weekendSchedule = ScheduleModel(
            id: '',
            deviceId: deviceId,
            name: 'Weekend Relaxed',
            days: [WeekDay.saturday, WeekDay.sunday],
            onTime: const TimeOfDay(hour: 9, minute: 0),
            offTime: const TimeOfDay(hour: 0, minute: 0),
          );
          final created = await createSchedule(weekendSchedule);
          if (created != null) createdSchedules.add(created);
          break;

        case 'Evening Dim':
          // Dim lights at 8 PM every day
          final eveningSchedule = ScheduleModel(
            id: '',
            deviceId: deviceId,
            name: 'Evening Dim',
            days: WeekDay.values,
            action: const ScheduleAction(
              type: 'set_brightness',
              parameters: {'brightness': 30},
            ),
            onTime: const TimeOfDay(hour: 20, minute: 0),
          );
          final created = await createSchedule(eveningSchedule);
          if (created != null) createdSchedules.add(created);
          break;

        case 'Security Lighting':
          // Random on/off times for security
          final securitySchedules = [
            ScheduleModel(
              id: '',
              deviceId: deviceId,
              name: 'Security On',
              days: WeekDay.values,
              onTime: const TimeOfDay(hour: 18, minute: 30),
            ),
            ScheduleModel(
              id: '',
              deviceId: deviceId,
              name: 'Security Off',
              days: WeekDay.values,
              offTime: const TimeOfDay(hour: 23, minute: 45),
            ),
          ];

          for (final schedule in securitySchedules) {
            final created = await createSchedule(schedule);
            if (created != null) createdSchedules.add(created);
          }
          break;
      }

      _logger.i(
        'Created ${createdSchedules.length} schedules from template: $templateName',
      );
      return createdSchedules;
    } catch (e) {
      _logger.e('Error creating schedule from template: $e');
      return createdSchedules;
    }
  }

  // ===================== SMART SCHEDULING =====================

  Future<List<ScheduleModel>> generateSmartSchedules(String deviceId) async {
    final device = _deviceController.getDeviceById(deviceId);
    if (device == null) return [];

    final suggestions = <ScheduleModel>[];

    try {
      // Generate suggestions based on device type and usage patterns
      switch (device.type) {
        case DeviceType.dimmableLight:
        case DeviceType.onOff:
          suggestions.addAll(
            await _generateLightingSchedules(deviceId, device),
          );
          break;
        case DeviceType.fan:
          suggestions.addAll(await _generateFanSchedules(deviceId, device));
          break;
        case DeviceType.rgb:
          suggestions.addAll(await _generateRGBSchedules(deviceId, device));
          break;
        default:
          suggestions.addAll(await _generateBasicSchedules(deviceId, device));
      }

      return suggestions;
    } catch (e) {
      _logger.e('Error generating smart schedules: $e');
      return [];
    }
  }

  Future<List<ScheduleModel>> _generateLightingSchedules(
    String deviceId,
    DeviceModel device,
  ) async {
    return [
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Morning Light - ${device.name}',
        days: WeekDay.values,
        onTime: const TimeOfDay(hour: 6, minute: 30),
        action: const ScheduleAction(
          type: 'set_brightness',
          parameters: {'brightness': 70},
        ),
      ),
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Evening Dim - ${device.name}',
        days: WeekDay.values,
        action: const ScheduleAction(
          type: 'set_brightness',
          parameters: {'brightness': 30},
        ),
        onTime: const TimeOfDay(hour: 20, minute: 0),
      ),
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Night Off - ${device.name}',
        days: WeekDay.values,
        offTime: const TimeOfDay(hour: 23, minute: 0),
      ),
    ];
  }

  Future<List<ScheduleModel>> _generateFanSchedules(
    String deviceId,
    DeviceModel device,
  ) async {
    return [
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Summer Cooling - ${device.name}',
        days: WeekDay.values,
        onTime: const TimeOfDay(hour: 14, minute: 0),
        offTime: const TimeOfDay(hour: 18, minute: 0),
        action: const ScheduleAction(
          type: 'set_brightness',
          parameters: {'brightness': 60},
        ),
      ),
    ];
  }

  Future<List<ScheduleModel>> _generateRGBSchedules(
    String deviceId,
    DeviceModel device,
  ) async {
    return [
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Warm Evening - ${device.name}',
        days: WeekDay.values,
        onTime: const TimeOfDay(hour: 19, minute: 0),
        action: const ScheduleAction(
          type: 'set_color',
          parameters: {'color': '#FF8C00'},
        ),
      ),
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Cool Morning - ${device.name}',
        days: WeekDay.values,
        onTime: const TimeOfDay(hour: 7, minute: 0),
        action: const ScheduleAction(
          type: 'set_color',
          parameters: {'color': '#87CEEB'},
        ),
      ),
    ];
  }

  Future<List<ScheduleModel>> _generateBasicSchedules(
    String deviceId,
    DeviceModel device,
  ) async {
    return [
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Basic On - ${device.name}',
        days: WeekDay.values,
        onTime: const TimeOfDay(hour: 7, minute: 0),
      ),
      ScheduleModel(
        id: '',
        deviceId: deviceId,
        name: 'Basic Off - ${device.name}',
        days: WeekDay.values,
        offTime: const TimeOfDay(hour: 22, minute: 0),
      ),
    ];
  }
}
