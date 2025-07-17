// lib/features/dashboard/widgets/quick_stats.dart
import 'package:flutter/material.dart';

class QuickStats extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const QuickStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) => _buildStatItem(stat)).toList(),
      ),
    );
  }

  Widget _buildStatItem(Map<String, dynamic> stat) {
    return Column(
      children: [
        Text(
          stat['value'] ?? '0',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat['title'] ?? '',
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }
}
