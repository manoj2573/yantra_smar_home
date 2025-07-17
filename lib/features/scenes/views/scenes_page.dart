// lib/features/scenes/views/scenes_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yantra_smart_home_automation/core/models/device_model.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/controllers/scene_controller.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/models/scene_model.dart';
import '../widgets/scene_card.dart';

class ScenesPage extends StatelessWidget {
  const ScenesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sceneController = Get.find<SceneController>();
    final deviceController = Get.find<DeviceController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: 'Scenes'),
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.pagePadding,
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Scenes',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${sceneController.scenes.length} scenes',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Scene Templates
                _buildQuickTemplates(context),
                const SizedBox(height: 20),

                // Scenes List
                Expanded(
                  child: Obx(() {
                    if (sceneController.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (sceneController.scenes.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return RefreshIndicator(
                      onRefresh: sceneController.loadScenes,
                      child: ListView.builder(
                        itemCount: sceneController.scenes.length,
                        itemBuilder: (context, index) {
                          final sceneData = sceneController.scenes[index];
                          final scene = SceneModel.fromSupabase(sceneData);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: SceneCard(
                              scene: scene,
                              onTap:
                                  () => _executeScene(
                                    context,
                                    scene,
                                    sceneController,
                                  ),
                              onEdit: () => _editScene(context, scene),
                              onDelete:
                                  () => _deleteScene(
                                    context,
                                    scene,
                                    sceneController,
                                  ),
                            ),
                          );
                        },
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
        onPressed: () => _createNewScene(context, deviceController),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickTemplates(BuildContext context) {
    final templates = [
      {'name': 'Good Night', 'icon': Icons.bedtime, 'color': Colors.indigo},
      {'name': 'Good Morning', 'icon': Icons.wb_sunny, 'color': Colors.orange},
      {'name': 'Movie Time', 'icon': Icons.movie, 'color': Colors.red},
      {'name': 'Party Mode', 'icon': Icons.celebration, 'color': Colors.pink},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Setup',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap:
                      () => _createFromTemplate(
                        context,
                        template['name'] as String,
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (template['color'] as Color).withOpacity(0.2),
                      borderRadius: AppDimensions.borderRadiusMD,
                      border: Border.all(
                        color: (template['color'] as Color).withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          template['icon'] as IconData,
                          color: template['color'] as Color,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          template['name'] as String,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.movie_outlined,
            size: 80,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'No scenes yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create scenes to control multiple devices at once',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed:
                () => _createNewScene(context, Get.find<DeviceController>()),
            icon: const Icon(Icons.add),
            label: const Text('Create Scene'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _createFromTemplate(BuildContext context, String templateName) {
    Get.dialog(
      AlertDialog(
        title: Text('Create $templateName Scene'),
        content: Text(
          'This will create a "$templateName" scene with recommended device settings. '
          'You can customize it after creation.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _createSceneFromTemplate(templateName);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _createSceneFromTemplate(String templateName) async {
    final deviceController = Get.find<DeviceController>();
    final sceneController = Get.find<SceneController>();

    try {
      final devices = deviceController.devices;
      final sceneDevices = <Map<String, dynamic>>[];

      // Define template logic
      switch (templateName) {
        case 'Good Night':
          // Turn off all lights and devices
          for (final device in devices) {
            sceneDevices.add({
              'device_id': device.id,
              'device_name': device.name,
              'device_type': device.type.displayName,
              'state': false,
              'delay_seconds': 0,
            });
          }
          break;

        case 'Good Morning':
          // Turn on lights at comfortable brightness
          for (final device in devices) {
            if (device.type == DeviceType.dimmableLight ||
                device.type == DeviceType.onOff ||
                device.type == DeviceType.rgb) {
              sceneDevices.add({
                'device_id': device.id,
                'device_name': device.name,
                'device_type': device.type.displayName,
                'state': true,
                'slider_value': device.supportsSlider ? 70 : null,
                'color': device.type == DeviceType.rgb ? '#FFEB3B' : null,
                'delay_seconds': 0,
              });
            }
          }
          break;

        case 'Movie Time':
          // Dim lights to 20%
          for (final device in devices) {
            if (device.type == DeviceType.dimmableLight) {
              sceneDevices.add({
                'device_id': device.id,
                'device_name': device.name,
                'device_type': device.type.displayName,
                'state': true,
                'slider_value': 20,
                'delay_seconds': 0,
              });
            } else if (device.type == DeviceType.rgb) {
              sceneDevices.add({
                'device_id': device.id,
                'device_name': device.name,
                'device_type': device.type.displayName,
                'state': true,
                'slider_value': 30,
                'color': '#4A148C',
                'delay_seconds': 0,
              });
            }
          }
          break;

        case 'Party Mode':
          // Colorful lighting
          final colors = [
            '#E91E63',
            '#9C27B0',
            '#3F51B5',
            '#00BCD4',
            '#4CAF50',
          ];
          int colorIndex = 0;

          for (final device in devices) {
            if (device.type == DeviceType.rgb) {
              sceneDevices.add({
                'device_id': device.id,
                'device_name': device.name,
                'device_type': device.type.displayName,
                'state': true,
                'slider_value': 100,
                'color': colors[colorIndex % colors.length],
                'delay_seconds': 0,
              });
              colorIndex++;
            } else if (device.type == DeviceType.dimmableLight) {
              sceneDevices.add({
                'device_id': device.id,
                'device_name': device.name,
                'device_type': device.type.displayName,
                'state': true,
                'slider_value': 90,
                'delay_seconds': 0,
              });
            }
          }
          break;
      }

      if (sceneDevices.isEmpty) {
        Get.snackbar(
          'No Compatible Devices',
          'No devices found that are compatible with this scene template.',
        );
        return;
      }

      await sceneController.createScene(templateName, sceneDevices);
      Get.snackbar('Success', '$templateName scene created successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create scene: $e');
    }
  }

  void _createNewScene(
    BuildContext context,
    DeviceController deviceController,
  ) {
    Get.toNamed('/scene-editor');
  }

  void _editScene(BuildContext context, SceneModel scene) {
    Get.toNamed('/scene-editor', arguments: scene);
  }

  Future<void> _executeScene(
    BuildContext context,
    SceneModel scene,
    SceneController sceneController,
  ) async {
    Get.snackbar(
      'Executing Scene',
      'Running "${scene.name}" scene...',
      duration: const Duration(seconds: 2),
    );

    // Here you would implement scene execution logic
    // This would involve sending commands to devices via MQTT

    try {
      // Simulate scene execution
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Scene Executed',
        '"${scene.name}" scene completed successfully',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Execution Failed',
        'Failed to execute scene: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void _deleteScene(
    BuildContext context,
    SceneModel scene,
    SceneController sceneController,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Scene'),
        content: Text(
          'Are you sure you want to delete the "${scene.name}" scene?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              try {
                await sceneController.deleteScene(scene.id);
                Get.snackbar('Success', 'Scene deleted successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to delete scene: $e');
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
