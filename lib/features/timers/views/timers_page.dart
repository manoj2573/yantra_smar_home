// lib/features/timers/views/timers_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/models/timer_model.dart';
import '../widgets/timer_card.dart';

class TimersPage extends StatelessWidget {
  const TimersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceController = DeviceController.to;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Timers'),
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.pagePadding,
            child: Column(
              children: [
                // Header with Statistics
                _buildHeader(deviceController),
                const SizedBox(height: 20),

                // Quick Timer Buttons
                _buildQuickTimers(context, deviceController),
                const SizedBox(height: 20),

                // Active/Recent Timers List
                Expanded(
                  child: Obx(() {
                    final timers = deviceController.timers;

                    if (timers.isEmpty) {
                      return _buildEmptyState(context, deviceController);
                    }

                    // Separate active and completed timers
                    final activeTimers =
                        timers
                            .where(
                              (t) =>
                                  t.status == TimerStatus.active ||
                                  t.status == TimerStatus.paused,
                            )
                            .toList();
                    final completedTimers =
                        timers
                            .where(
                              (t) =>
                                  t.status == TimerStatus.completed ||
                                  t.status == TimerStatus.expired,
                            )
                            .toList();

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active Timers Section
                          if (activeTimers.isNotEmpty) ...[
                            Text(
                              'Active Timers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...activeTimers.map(
                              (timer) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: TimerCard(
                                  timer: timer,
                                  onStart:
                                      () =>
                                          deviceController.startTimer(timer.id),
                                  onStop:
                                      () =>
                                          deviceController.stopTimer(timer.id),
                                  onDelete:
                                      () => _deleteTimer(
                                        context,
                                        timer,
                                        deviceController,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Completed Timers Section
                          if (completedTimers.isNotEmpty) ...[
                            Text(
                              'Recent Timers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...completedTimers
                                .take(5)
                                .map(
                                  (timer) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: TimerCard(
                                      timer: timer,
                                      onDelete:
                                          () => _deleteTimer(
                                            context,
                                            timer,
                                            deviceController,
                                          ),
                                    ),
                                  ),
                                ),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createCustomTimer(context, deviceController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(DeviceController deviceController) {
    return Obx(() {
      final activeCount = deviceController.getActiveTimers().length;
      final totalCount = deviceController.timers.length;

      return Container(
        padding: AppDimensions.paddingMD,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: AppDimensions.borderRadiusLG,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Timers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$activeCount active • $totalCount total',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.timer, color: Colors.white, size: 24),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuickTimers(
    BuildContext context,
    DeviceController deviceController,
  ) {
    final quickDurations = [
      {'label': '5m', 'minutes': 5, 'color': Colors.green},
      {'label': '10m', 'minutes': 10, 'color': Colors.blue},
      {'label': '15m', 'minutes': 15, 'color': Colors.orange},
      {'label': '30m', 'minutes': 30, 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Timers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children:
              quickDurations.map((duration) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap:
                          () => _showDeviceSelector(
                            context,
                            deviceController,
                            duration['minutes'] as int,
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: (duration['color'] as Color).withOpacity(0.2),
                          borderRadius: AppDimensions.borderRadiusMD,
                          border: Border.all(
                            color: (duration['color'] as Color).withOpacity(
                              0.5,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.timer,
                              color: duration['color'] as Color,
                              size: 24,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              duration['label'] as String,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    DeviceController deviceController,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No timers yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create timers to automatically control your devices',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _createCustomTimer(context, deviceController),
            icon: const Icon(Icons.add),
            label: const Text('Create Timer'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeviceSelector(
    BuildContext context,
    DeviceController deviceController,
    int minutes,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text('$minutes Minute Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select a device for this timer:'),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: SingleChildScrollView(
                child: Column(
                  children:
                      deviceController.devices.map((device) {
                        return ListTile(
                          leading: Image.asset(
                            device.iconPath,
                            width: 24,
                            height: 24,
                          ),
                          title: Text(device.name),
                          subtitle: Text(
                            '${device.type.displayName} • ${device.roomName ?? 'No room'}',
                          ),
                          trailing: Icon(
                            device.isOnline.value
                                ? Icons.circle
                                : Icons.circle_outlined,
                            color:
                                device.isOnline.value
                                    ? Colors.green
                                    : Colors.grey,
                            size: 12,
                          ),
                          onTap: () {
                            Get.back();
                            _createQuickTimer(
                              device,
                              minutes,
                              deviceController,
                            );
                          },
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Future<void> _createQuickTimer(
    device,
    int minutes,
    DeviceController deviceController,
  ) async {
    try {
      final timer = TimerModel(
        id: '',
        deviceId: device.id,
        name: '$minutes min timer - ${device.name}',
        action: const TimerAction(type: TimerActionType.turnOff),
        durationMinutes: minutes,
      );

      final createdTimer = await deviceController.createTimer(timer);
      if (createdTimer != null) {
        await deviceController.startTimer(createdTimer.id);
        Get.snackbar(
          'Timer Started',
          '$minutes minute timer started for ${device.name}',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to create timer: $e');
    }
  }

  void _createCustomTimer(
    BuildContext context,
    DeviceController deviceController,
  ) {
    Get.toNamed('/timer-editor');
  }

  void _deleteTimer(
    BuildContext context,
    TimerModel timer,
    DeviceController deviceController,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Timer'),
        content: Text('Are you sure you want to delete "${timer.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await deviceController.deleteTimer(timer.id);
                Get.snackbar('Success', 'Timer deleted successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete timer: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
