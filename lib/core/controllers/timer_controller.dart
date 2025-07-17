// lib/core/controllers/timer_controller.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/timer_model.dart';
import '../services/supabase_service.dart';

class TimerController extends GetxController {
  static TimerController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;

  final RxList<TimerModel> timers = <TimerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTimers();
  }

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

  Future<bool> updateTimer(TimerModel timer) async {
    try {
      final updatedTimer = await _supabaseService.updateTimer(timer);
      final index = timers.indexWhere((t) => t.id == timer.id);

      if (index != -1) {
        timers[index] = updatedTimer;
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Error updating timer: $e');
      error.value = 'Failed to update timer: $e';
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

  void clearError() {
    error.value = '';
  }
}
