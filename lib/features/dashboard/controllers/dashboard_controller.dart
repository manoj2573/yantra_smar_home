// lib/features/dashboard/controllers/dashboard_controller.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/controllers/scene_controller.dart';
import '../../../core/controllers/timer_controller.dart';

class DashboardController extends GetxController {
  static DashboardController get to => Get.find();

  final _logger = Logger();
  final DeviceController _deviceController = DeviceController.to;
  final SceneController _sceneController = SceneController.to;
  final TimerController _timerController = TimerController.to;

  final RxInt selectedTabIndex = 0.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _logger.i('Dashboard controller initialized');
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  Future<void> refreshAllData() async {
    try {
      isRefreshing.value = true;

      await Future.wait([
        _deviceController.refreshDevices(),
        _sceneController.loadScenes(),
        _timerController.loadTimers(),
      ]);

      _logger.i('All data refreshed successfully');
    } catch (e) {
      _logger.e('Error refreshing data: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  // Getters for easy access to data
  List<Map<String, dynamic>> get quickStats => [
    {
      'title': 'Total Devices',
      'value': _deviceController.totalDevices.toString(),
      'icon': 'devices',
    },
    {
      'title': 'Online',
      'value': _deviceController.onlineDevicesCount.toString(),
      'icon': 'online',
    },
    {
      'title': 'Active Timers',
      'value': _deviceController.activeTimersCount.toString(),
      'icon': 'timer',
    },
    {
      'title': 'Scenes',
      'value': _sceneController.scenes.length.toString(),
      'icon': 'scene',
    },
  ];
}
