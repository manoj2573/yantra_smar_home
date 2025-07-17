// lib/features/timers/widgets/timer_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/models/timer_model.dart';
import '../../../app/theme/app_dimensions.dart';

class TimerCard extends StatelessWidget {
  final TimerModel timer;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onDelete;

  const TimerCard({
    super.key,
    required this.timer,
    this.onStart,
    this.onStop,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppDimensions.borderRadiusLG,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: AppDimensions.paddingMD,
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                // Timer Icon with Status
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: AppDimensions.borderRadiusMD,
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Timer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timer.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timer.action.displayText,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor().withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    timer.statusText,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress and Time Display
            if (timer.status == TimerStatus.active ||
                timer.status == TimerStatus.paused) ...[
              // Circular Progress
              Obx(
                () => Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: timer.progress.value,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Obx(
                          () => Text(
                            timer.remainingTimeText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'remaining',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ] else ...[
              // Static display for inactive/completed timers
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Text(
                      TimerDurations.formatDuration(timer.durationMinutes),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'duration',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (timer.canStart && onStart != null)
                  _buildActionButton(
                    icon: Icons.play_arrow,
                    label: 'Start',
                    color: Colors.green,
                    onTap: onStart!,
                  ),

                if (timer.canPause && onStop != null)
                  _buildActionButton(
                    icon: Icons.pause,
                    label: 'Pause',
                    color: Colors.orange,
                    onTap: onStop!,
                  ),

                if (timer.canResume && onStart != null)
                  _buildActionButton(
                    icon: Icons.play_arrow,
                    label: 'Resume',
                    color: Colors.blue,
                    onTap: onStart!,
                  ),

                if (timer.canStop && onStop != null)
                  _buildActionButton(
                    icon: Icons.stop,
                    label: 'Stop',
                    color: Colors.red,
                    onTap: onStop!,
                  ),

                if (onDelete != null)
                  _buildActionButton(
                    icon: Icons.delete,
                    label: 'Delete',
                    color: Colors.grey,
                    onTap: onDelete!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (timer.status) {
      case TimerStatus.active:
        return Colors.green;
      case TimerStatus.paused:
        return Colors.orange;
      case TimerStatus.completed:
        return Colors.blue;
      case TimerStatus.expired:
        return Colors.red;
      case TimerStatus.inactive:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (timer.status) {
      case TimerStatus.active:
        return Icons.play_arrow;
      case TimerStatus.paused:
        return Icons.pause;
      case TimerStatus.completed:
        return Icons.check_circle;
      case TimerStatus.expired:
        return Icons.timer_off;
      case TimerStatus.inactive:
        return Icons.timer;
    }
  }
}
