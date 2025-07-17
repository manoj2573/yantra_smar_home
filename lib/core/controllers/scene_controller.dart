// lib/core/controllers/scene_controller.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../services/supabase_service.dart';

class SceneController extends GetxController {
  static SceneController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;

  final RxList<Map<String, dynamic>> scenes = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadScenes();
  }

  Future<void> loadScenes() async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedScenes = await _supabaseService.getScenes();
      scenes.assignAll(loadedScenes);

      _logger.i('Loaded ${scenes.length} scenes');
    } catch (e) {
      _logger.e('Error loading scenes: $e');
      error.value = 'Failed to load scenes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> createScene(
    String name,
    List<Map<String, dynamic>> devices,
  ) async {
    try {
      final createdScene = await _supabaseService.createScene(name, devices);
      scenes.add(createdScene);

      _logger.i('Scene created: $name');
      return createdScene;
    } catch (e) {
      _logger.e('Error creating scene: $e');
      error.value = 'Failed to create scene: $e';
      return null;
    }
  }

  Future<void> updateScene(
    String sceneId,
    String name,
    List<Map<String, dynamic>> devices,
  ) async {
    try {
      await _supabaseService.updateScene(sceneId, name, devices);
      loadScenes(); // Reload to get updated data

      _logger.i('Scene updated: $name');
    } catch (e) {
      _logger.e('Error updating scene: $e');
      error.value = 'Failed to update scene: $e';
    }
  }

  Future<void> deleteScene(String sceneId) async {
    try {
      await _supabaseService.deleteScene(sceneId);
      scenes.removeWhere((s) => s['id'] == sceneId);

      _logger.i('Scene deleted: $sceneId');
    } catch (e) {
      _logger.e('Error deleting scene: $e');
      error.value = 'Failed to delete scene: $e';
    }
  }

  void clearError() {
    error.value = '';
  }
}
