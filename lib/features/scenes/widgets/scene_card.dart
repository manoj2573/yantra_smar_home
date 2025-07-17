// lib/features/scenes/widgets/scene_card.dart
import 'package:flutter/material.dart';
import '../../../core/models/scene_model.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_theme.dart';

class SceneCard extends StatelessWidget {
  final SceneModel scene;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SceneCard({
    super.key,
    required this.scene,
    this.onTap,
    this.onEdit,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.borderRadiusLG,
          child: Padding(
            padding: AppDimensions.paddingMD,
            child: Row(
              children: [
                // Scene Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getSceneColor().withOpacity(0.1),
                    borderRadius: AppDimensions.borderRadiusMD,
                  ),
                  child: Icon(
                    _getSceneIcon(),
                    color: _getSceneColor(),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Scene Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scene.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '${scene.deviceCount} device${scene.deviceCount != 1 ? 's' : ''}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),

                      const SizedBox(height: 8),

                      // Device Actions Preview
                      if (scene.deviceActions.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children:
                              scene.deviceActions.take(3).map((action) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        action.state
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          action.state
                                              ? Colors.green.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    '${action.deviceName} ${action.state ? 'ON' : 'OFF'}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          action.state
                                              ? Colors.green[700]
                                              : Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                      if (scene.deviceActions.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+${scene.deviceActions.length - 3} more',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    // Play Button
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onTap,
                        icon: Icon(
                          Icons.play_arrow,
                          color: AppTheme.colors.primary,
                        ),
                        tooltip: 'Execute Scene',
                      ),
                    ),

                    // Options Menu
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderRadiusMD,
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              onEdit?.call();
                              break;
                            case 'delete':
                              onDelete?.call();
                              break;
                          }
                        },
                        itemBuilder:
                            (context) => [
                              if (onEdit != null)
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                              if (onDelete != null)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getSceneIcon() {
    final lowerName = scene.name.toLowerCase();

    if (lowerName.contains('night') || lowerName.contains('sleep')) {
      return Icons.bedtime;
    } else if (lowerName.contains('morning') || lowerName.contains('wake')) {
      return Icons.wb_sunny;
    } else if (lowerName.contains('movie') || lowerName.contains('cinema')) {
      return Icons.movie;
    } else if (lowerName.contains('party') ||
        lowerName.contains('celebration')) {
      return Icons.celebration;
    } else if (lowerName.contains('work') || lowerName.contains('focus')) {
      return Icons.work;
    } else if (lowerName.contains('relax') || lowerName.contains('chill')) {
      return Icons.spa;
    } else if (lowerName.contains('dinner') || lowerName.contains('dining')) {
      return Icons.restaurant;
    } else if (lowerName.contains('read') || lowerName.contains('study')) {
      return Icons.menu_book;
    } else if (lowerName.contains('away') || lowerName.contains('security')) {
      return Icons.security;
    } else {
      return Icons.movie;
    }
  }

  Color _getSceneColor() {
    final lowerName = scene.name.toLowerCase();

    if (lowerName.contains('night') || lowerName.contains('sleep')) {
      return Colors.indigo;
    } else if (lowerName.contains('morning') || lowerName.contains('wake')) {
      return Colors.orange;
    } else if (lowerName.contains('movie') || lowerName.contains('cinema')) {
      return Colors.red;
    } else if (lowerName.contains('party') ||
        lowerName.contains('celebration')) {
      return Colors.pink;
    } else if (lowerName.contains('work') || lowerName.contains('focus')) {
      return Colors.blue;
    } else if (lowerName.contains('relax') || lowerName.contains('chill')) {
      return Colors.green;
    } else if (lowerName.contains('dinner') || lowerName.contains('dining')) {
      return Colors.brown;
    } else if (lowerName.contains('read') || lowerName.contains('study')) {
      return Colors.deepPurple;
    } else if (lowerName.contains('away') || lowerName.contains('security')) {
      return Colors.grey;
    } else {
      return AppTheme.colors.primary;
    }
  }
}
