// lib/features/devices/controllers/add_device_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/models/device_model.dart';

class AddDeviceController extends GetxController {
  static AddDeviceController get to => Get.find();

  final _logger = Logger();
  final DeviceController _deviceController = DeviceController.to;

  // Form controllers
  final deviceNameController = TextEditingController();
  final deviceIdController = TextEditingController();
  final registrationIdController = TextEditingController();

  // Observable states
  final RxString selectedDeviceType = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isDiscovering = false.obs;
  final RxList<DeviceModel> recentDevices = <DeviceModel>[].obs;
  final RxList<DeviceModel> discoveredDevices = <DeviceModel>[].obs;

  // Device types
  final List<String> deviceTypes = [
    'On/Off',
    'Dimmable light',
    'RGB',
    'Fan',
    'Curtain',
    'IR Hub',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadRecentDevices();
  }

  @override
  void onClose() {
    deviceNameController.dispose();
    deviceIdController.dispose();
    registrationIdController.dispose();
    super.onClose();
  }

  void _loadRecentDevices() {
    // Load recently added devices (last 5)
    final allDevices = _deviceController.devices;
    if (allDevices.isNotEmpty) {
      recentDevices.assignAll(allDevices.take(5).toList());
    }
  }

  Future<void> addManualDevice() async {
    if (!_validateManualForm()) return;

    try {
      isLoading.value = true;

      final device = DeviceModel(
        id: '', // Will be set by database
        deviceId: deviceIdController.text.trim(),
        name: deviceNameController.text.trim(),
        type: DeviceType.fromString(selectedDeviceType.value),
        registrationId: registrationIdController.text.trim(),
        roomName: 'Unassigned', // Will be set in device settings
        initialState: false,
      );

      final createdDevice = await _deviceController.addDevice(device);

      if (createdDevice != null) {
        _clearForm();
        _loadRecentDevices();
        Get.snackbar(
          'Success',
          'Device added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to device settings to set room
        Get.toNamed('/device-settings', arguments: createdDevice);
      }
    } catch (e) {
      _logger.e('Error adding manual device: $e');
      Get.snackbar(
        'Error',
        'Failed to add device: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateManualForm() {
    if (deviceNameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Device name is required');
      return false;
    }

    if (deviceIdController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Device ID is required');
      return false;
    }

    if (registrationIdController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Registration ID is required');
      return false;
    }

    if (selectedDeviceType.value.isEmpty) {
      Get.snackbar('Error', 'Please select device type');
      return false;
    }

    // Check if device ID already exists
    final existingDevice = _deviceController.getDeviceByDeviceId(
      deviceIdController.text.trim(),
    );
    if (existingDevice != null) {
      Get.snackbar('Error', 'Device ID already exists');
      return false;
    }

    return true;
  }

  void _clearForm() {
    deviceNameController.clear();
    deviceIdController.clear();
    registrationIdController.clear();
    selectedDeviceType.value = '';
  }

  Future<void> startDeviceDiscovery() async {
    try {
      isDiscovering.value = true;
      discoveredDevices.clear();

      Get.snackbar(
        'Searching',
        'Looking for nearby devices...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Simulate device discovery with mock data
      await _simulateDeviceDiscovery();

      if (discoveredDevices.isNotEmpty) {
        _showDiscoveredDevicesDialog();
      } else {
        Get.snackbar(
          'No Devices',
          'No devices found nearby',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _logger.e('Error during device discovery: $e');
      Get.snackbar(
        'Error',
        'Failed to discover devices: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isDiscovering.value = false;
    }
  }

  Future<void> _simulateDeviceDiscovery() async {
    // Simulate network scanning delay
    await Future.delayed(const Duration(seconds: 3));

    // Add mock discovered devices
    final mockDevices = [
      DeviceModel(
        id: '',
        deviceId: 'ESP32_001',
        name: 'Living Room Light',
        type: DeviceType.dimmableLight,
        registrationId: 'REG_001',
        roomName: 'Unassigned',
      ),
      DeviceModel(
        id: '',
        deviceId: 'ESP32_002',
        name: 'Bedroom Fan',
        type: DeviceType.fan,
        registrationId: 'REG_002',
        roomName: 'Unassigned',
      ),
      DeviceModel(
        id: '',
        deviceId: 'ESP32_003',
        name: 'Kitchen RGB Strip',
        type: DeviceType.rgb,
        registrationId: 'REG_003',
        roomName: 'Unassigned',
      ),
    ];

    // Filter out devices that already exist
    for (final device in mockDevices) {
      final existing = _deviceController.getDeviceByDeviceId(device.deviceId);
      if (existing == null) {
        discoveredDevices.add(device);
      }
    }
  }

  void _showDiscoveredDevicesDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Discovered Devices'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Found ${discoveredDevices.length} device(s)',
                style: Get.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ...discoveredDevices.map(
                (device) => Card(
                  child: ListTile(
                    leading: Image.asset(
                      device.iconPath,
                      width: 32,
                      height: 32,
                    ),
                    title: Text(device.name),
                    subtitle: Text(device.type.displayName),
                    trailing: ElevatedButton(
                      onPressed: () => _addDiscoveredDevice(device),
                      child: const Text('Add'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _addDiscoveredDevice(DeviceModel device) async {
    try {
      final createdDevice = await _deviceController.addDevice(device);

      if (createdDevice != null) {
        discoveredDevices.remove(device);
        _loadRecentDevices();

        Get.snackbar(
          'Success',
          'Device "${device.name}" added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Close dialog if no more devices
        if (discoveredDevices.isEmpty) {
          Get.back();
        }
      }
    } catch (e) {
      _logger.e('Error adding discovered device: $e');
      Get.snackbar(
        'Error',
        'Failed to add device: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Quick add presets
  void addQuickDevice(String type) {
    switch (type) {
      case 'light':
        deviceNameController.text = 'New Light';
        selectedDeviceType.value = 'Dimmable light';
        break;
      case 'fan':
        deviceNameController.text = 'New Fan';
        selectedDeviceType.value = 'Fan';
        break;
      case 'rgb':
        deviceNameController.text = 'New RGB Light';
        selectedDeviceType.value = 'RGB';
        break;
      case 'switch':
        deviceNameController.text = 'New Switch';
        selectedDeviceType.value = 'On/Off';
        break;
    }

    // Generate IDs
    deviceIdController.text = 'DEV_${DateTime.now().millisecondsSinceEpoch}';
    registrationIdController.text =
        'REG_${DateTime.now().millisecondsSinceEpoch}';
  }
}
