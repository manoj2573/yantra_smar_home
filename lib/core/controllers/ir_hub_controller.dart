// lib/core/controllers/ir_hub_controller.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/ir_device_model.dart';
import '../services/supabase_service.dart';
import '../services/mqtt_service.dart';

class IRHubController extends GetxController {
  static IRHubController get to => Get.find();

  final _logger = Logger();
  final _supabaseService = SupabaseService.to;
  final _mqttService = MqttService.to;

  final RxList<IRHubModel> irHubs = <IRHubModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isLearningMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadIRHubs();
  }

  Future<void> loadIRHubs() async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedHubs = await _supabaseService.getIRHubs();
      irHubs.assignAll(loadedHubs);

      _logger.i('Loaded ${irHubs.length} IR hubs');
    } catch (e) {
      _logger.e('Error loading IR hubs: $e');
      error.value = 'Failed to load IR hubs: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<IRHubModel?> createIRHub(IRHubModel hub) async {
    try {
      final createdHub = await _supabaseService.createIRHub(hub);
      irHubs.add(createdHub);

      _logger.i('IR Hub created: ${createdHub.name}');
      return createdHub;
    } catch (e) {
      _logger.e('Error creating IR hub: $e');
      error.value = 'Failed to create IR hub: $e';
      return null;
    }
  }

  Future<IRDeviceModel?> createIRDevice(IRDeviceModel device) async {
    try {
      final createdDevice = await _supabaseService.createIRDevice(device);

      _logger.i('IR Device created: ${createdDevice.name}');
      return createdDevice;
    } catch (e) {
      _logger.e('Error creating IR device: $e');
      error.value = 'Failed to create IR device: $e';
      return null;
    }
  }

  Future<void> sendIRCommand(
    String irHubId,
    String irDeviceId,
    String buttonId,
    String irCode,
  ) async {
    try {
      await _mqttService.publishIRCommand(
        irHubId,
        irDeviceId,
        buttonId,
        irCode,
      );
      _logger.d('IR command sent: $buttonId');
    } catch (e) {
      _logger.e('Error sending IR command: $e');
      error.value = 'Failed to send IR command: $e';
    }
  }

  Future<void> startLearningMode(
    String irHubId,
    String irDeviceId,
    String buttonId,
  ) async {
    try {
      isLearningMode.value = true;
      await _mqttService.publishIRLearnCommand(irHubId, irDeviceId, buttonId);
      _logger.i('Learning mode started for button: $buttonId');
    } catch (e) {
      _logger.e('Error starting learning mode: $e');
      error.value = 'Failed to start learning mode: $e';
      isLearningMode.value = false;
    }
  }

  void stopLearningMode() {
    isLearningMode.value = false;
    _logger.i('Learning mode stopped');
  }

  void clearError() {
    error.value = '';
  }
}
