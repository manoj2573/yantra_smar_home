// lib/core/services/mock_data_service.dart
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/device_model.dart';
import '../controllers/device_controller.dart';
import 'supabase_service.dart';

class MockDataService extends GetxService {
  static MockDataService get to => Get.find();

  final _logger = Logger();
  final DeviceController _deviceController = DeviceController.to;
  final SupabaseService _supabaseService = SupabaseService.to;

  // Mock room data
  static const List<Map<String, dynamic>> mockRooms = [
    {'name': 'Living Room', 'icon_path': 'assets/room.png', 'color': '#FF9800'},
    {'name': 'Bedroom', 'icon_path': 'assets/room.png', 'color': '#9C27B0'},
    {'name': 'Kitchen', 'icon_path': 'assets/room.png', 'color': '#4CAF50'},
    {'name': 'Bathroom', 'icon_path': 'assets/room.png', 'color': '#2196F3'},
    {'name': 'Office', 'icon_path': 'assets/room.png', 'color': '#607D8B'},
  ];

  // Mock device data
  // lib/core/services/mock_data_services.dart - Fix the mockDevices data
  // Replace the mockDevices list with this corrected version:

  static final List<Map<String, dynamic>> mockDevices = [
    {
      'device_id': 'MOCK_LIGHT_001',
      'name': 'Living Room Main Light',
      'type': 'Dimmable light',
      'room_name': 'Living Room',
      'state': true,
      'slider_value': 75, // Changed from 75.0 to 75 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_001',
      'icon_path': 'assets/chandlier.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_FAN_001',
      'name': 'Bedroom Ceiling Fan',
      'type': 'Fan',
      'room_name': 'Bedroom',
      'state': false,
      'slider_value': 0, // Changed from 0.0 to 0 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_002',
      'icon_path': 'assets/fan.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_RGB_001',
      'name': 'TV Background Light',
      'type': 'RGB',
      'room_name': 'Living Room',
      'state': true,
      'slider_value': 100, // Changed from 100.0 to 100 (integer)
      'color': '#FF5722',
      'registration_id': 'REG_MOCK_003',
      'icon_path': 'assets/led-strip.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_SWITCH_001',
      'name': 'Kitchen Main Switch',
      'type': 'On/Off',
      'room_name': 'Kitchen',
      'state': false,
      'slider_value': 0, // Changed from 0.0 to 0 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_004',
      'icon_path': 'assets/light-bulb.png',
      'is_online': false,
    },
    {
      'device_id': 'MOCK_CURTAIN_001',
      'name': 'Living Room Curtains',
      'type': 'Curtain',
      'room_name': 'Living Room',
      'state': false,
      'slider_value': 25, // Changed from 25.0 to 25 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_005',
      'icon_path': 'assets/blinds.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_RGB_002',
      'name': 'Bedroom Accent Light',
      'type': 'RGB',
      'room_name': 'Bedroom',
      'state': true,
      'slider_value': 60, // Changed from 60.0 to 60 (integer)
      'color': '#9C27B0',
      'registration_id': 'REG_MOCK_006',
      'icon_path': 'assets/rgb.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_LIGHT_002',
      'name': 'Kitchen Under Cabinet',
      'type': 'Dimmable light',
      'room_name': 'Kitchen',
      'state': false,
      'slider_value': 0, // Changed from 0.0 to 0 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_007',
      'icon_path': 'assets/led-strip.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_FAN_002',
      'name': 'Office Table Fan',
      'type': 'Fan',
      'room_name': 'Office',
      'state': true,
      'slider_value': 40, // Changed from 40.0 to 40 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_008',
      'icon_path': 'assets/table_fan.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_SWITCH_002',
      'name': 'Bathroom Exhaust Fan',
      'type': 'On/Off',
      'room_name': 'Bathroom',
      'state': false,
      'slider_value': 0, // Changed from 0.0 to 0 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_009',
      'icon_path': 'assets/cooling-fan.png',
      'is_online': true,
    },
    {
      'device_id': 'MOCK_IR_001',
      'name': 'Living Room IR Hub',
      'type': 'IR Hub',
      'room_name': 'Living Room',
      'state': true,
      'slider_value': 0, // Changed from 0.0 to 0 (integer)
      'color': '#FFFFFF',
      'registration_id': 'REG_MOCK_010',
      'icon_path': 'assets/power-socket.png',
      'is_online': true,
    },
  ];
  Future<void> initializeMockData() async {
    try {
      _logger.i('Initializing mock data...');

      // Create mock rooms first
      await _createMockRooms();

      // Create mock devices
      await _createMockDevices();

      _logger.i('Mock data initialization completed');
    } catch (e) {
      _logger.e('Error initializing mock data: $e');
    }
  }

  Future<void> _createMockRooms() async {
    try {
      for (final roomData in mockRooms) {
        await _supabaseService.createRoom(
          roomData['name'] as String,
          iconPath: roomData['icon_path'] as String,
          color: roomData['color'] as String,
        );
      }
      _logger.i('Mock rooms created successfully');
    } catch (e) {
      _logger.w('Some mock rooms may already exist: $e');
    }
  }

  Future<void> _createMockDevices() async {
    int successCount = 0;
    int skipCount = 0;

    for (final deviceData in mockDevices) {
      try {
        // Check if device already exists
        final existingDevice = _deviceController.getDeviceByDeviceId(
          deviceData['device_id'] as String,
        );

        if (existingDevice != null) {
          skipCount++;
          continue;
        }

        final device = DeviceModel(
          id: '', // Will be set by database
          deviceId: deviceData['device_id'] as String,
          name: deviceData['name'] as String,
          type: DeviceType.fromString(deviceData['type'] as String),
          roomName: deviceData['room_name'] as String,
          initialState: deviceData['state'] as bool,
          // Fix: Convert integer to double when creating the model
          initialSliderValue: (deviceData['slider_value'] as int).toDouble(),
          initialColor: deviceData['color'] as String,
          registrationId: deviceData['registration_id'] as String,
          iconPath: deviceData['icon_path'] as String,
          initialIsOnline: deviceData['is_online'] as bool,
        );

        await _deviceController.addDevice(device);
        successCount++;
      } catch (e) {
        _logger.e('Error creating mock device ${deviceData['name']}: $e');
      }
    }

    _logger.i('Mock devices created: $successCount, skipped: $skipCount');
  }

  Future<void> resetMockData() async {
    try {
      _logger.i('Resetting mock data...');

      // Delete all existing devices
      final existingDevices = _deviceController.devices.toList();
      for (final device in existingDevices) {
        try {
          await _deviceController.deleteDevice(device.id);
        } catch (e) {
          _logger.w('Error deleting device ${device.name}: $e');
        }
      }

      // Recreate mock data
      await initializeMockData();

      _logger.i('Mock data reset completed');

      Get.snackbar(
        'Mock Data',
        'Mock data has been reset successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      _logger.e('Error resetting mock data: $e');
      Get.snackbar(
        'Error',
        'Failed to reset mock data: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void simulateDeviceActivity() {
    _logger.i('Starting device activity simulation...');

    // Simulate random device state changes every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      _randomlyToggleDevices();
      simulateDeviceActivity(); // Continue simulation
    });
  }

  void _randomlyToggleDevices() {
    final onlineDevices = _deviceController.getOnlineDevices();
    if (onlineDevices.isEmpty) return;

    // Randomly toggle 1-2 devices
    final devicesToToggle = onlineDevices.take(2).toList();

    for (final device in devicesToToggle) {
      if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
        _deviceController.toggleDeviceState(device);
        _logger.d('Simulated toggle for device: ${device.name}');
      }
    }
  }

  // Helper method to add specific device types for testing
  Future<void> addTestDevice(DeviceType type) async {
    final deviceId =
        'TEST_${type.name.toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}';

    final device = DeviceModel(
      id: '',
      deviceId: deviceId,
      name: 'Test ${type.displayName}',
      type: type,
      roomName: 'Test Room',
      registrationId: 'REG_TEST_${DateTime.now().millisecondsSinceEpoch}',
      initialState: false,
      initialSliderValue: type.supportsSlider ? 50.0 : 0.0,
      initialColor: type == DeviceType.rgb ? '#FF5722' : '#FFFFFF',
    );

    try {
      await _deviceController.addDevice(device);
      Get.snackbar(
        'Test Device',
        'Added test ${type.displayName}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add test device: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Method to create a quick device for testing specific functionality
  Future<void> addQuickTestDevice({
    required String name,
    required DeviceType type,
    String roomName = 'Test Room',
    bool initialState = false,
    double initialSliderValue = 0.0,
    String initialColor = '#FFFFFF',
  }) async {
    final deviceId = 'QUICK_${DateTime.now().millisecondsSinceEpoch}';

    final device = DeviceModel(
      id: '',
      deviceId: deviceId,
      name: name,
      type: type,
      roomName: roomName,
      registrationId: 'REG_$deviceId',
      initialState: initialState,
      initialSliderValue: initialSliderValue, // This is already a double
      initialColor: initialColor,
      initialIsOnline: true,
    );

    try {
      await _deviceController.addDevice(device);
      _logger.i('Quick test device added: $name');
    } catch (e) {
      _logger.e('Error adding quick test device: $e');
    }
  }

  // Batch operations for testing
  Future<void> addMultipleTestDevices() async {
    final testDevices = [
      {
        'name': 'Test Dimmer',
        'type': DeviceType.dimmableLight,
        'brightness': 75.0,
      },
      {'name': 'Test RGB', 'type': DeviceType.rgb, 'color': '#00FF00'},
      {'name': 'Test Fan', 'type': DeviceType.fan, 'speed': 60.0},
      {'name': 'Test Switch', 'type': DeviceType.onOff},
      {'name': 'Test Curtain', 'type': DeviceType.curtain, 'position': 30.0},
    ];

    for (final deviceConfig in testDevices) {
      await addQuickTestDevice(
        name: deviceConfig['name'] as String,
        type: deviceConfig['type'] as DeviceType,
        initialSliderValue:
            (deviceConfig['brightness'] ??
                    deviceConfig['speed'] ??
                    deviceConfig['position'] ??
                    0.0)
                as double,
        initialColor: deviceConfig['color'] as String? ?? '#FFFFFF',
        initialState: true,
      );
    }

    Get.snackbar(
      'Test Devices',
      'Added ${testDevices.length} test devices',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Clear all test devices
  Future<void> clearTestDevices() async {
    final testDevices =
        _deviceController.devices
            .where(
              (device) =>
                  device.deviceId.startsWith('TEST_') ||
                  device.deviceId.startsWith('QUICK_') ||
                  device.name.startsWith('Test '),
            )
            .toList();

    for (final device in testDevices) {
      try {
        await _deviceController.deleteDevice(device.id);
      } catch (e) {
        _logger.w('Error deleting test device ${device.name}: $e');
      }
    }

    Get.snackbar(
      'Test Devices',
      'Cleared ${testDevices.length} test devices',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Generate realistic device activity patterns
  void startRealisticSimulation() {
    _logger.i('Starting realistic device simulation...');

    // Morning routine (7-9 AM simulation)
    Future.delayed(const Duration(seconds: 5), () => _simulateMorningRoutine());

    // Evening routine (6-8 PM simulation)
    Future.delayed(
      const Duration(seconds: 15),
      () => _simulateEveningRoutine(),
    );

    // Night routine (10-11 PM simulation)
    Future.delayed(const Duration(seconds: 25), () => _simulateNightRoutine());
  }

  void _simulateMorningRoutine() {
    _logger.d('Simulating morning routine...');

    // Turn on kitchen lights
    final kitchenDevices = _deviceController.getDevicesByRoom('Kitchen');
    for (final device in kitchenDevices) {
      if (device.type == DeviceType.dimmableLight ||
          device.type == DeviceType.onOff) {
        if (!device.state.value) {
          _deviceController.toggleDeviceState(device);
        }
      }
    }

    // Turn on bathroom fan
    final bathroomDevices = _deviceController.getDevicesByRoom('Bathroom');
    for (final device in bathroomDevices) {
      if (device.name.toLowerCase().contains('fan')) {
        if (!device.state.value) {
          _deviceController.toggleDeviceState(device);
        }
      }
    }
  }

  void _simulateEveningRoutine() {
    _logger.d('Simulating evening routine...');

    // Turn on living room lights
    final livingRoomDevices = _deviceController.getDevicesByRoom('Living Room');
    for (final device in livingRoomDevices) {
      if (device.type == DeviceType.dimmableLight ||
          device.type == DeviceType.rgb) {
        if (!device.state.value) {
          _deviceController.toggleDeviceState(device);
        }
        // Set comfortable evening brightness
        if (device.supportsSlider) {
          _deviceController.setDeviceSliderValue(device, 60.0);
        }
      }
    }
  }

  void _simulateNightRoutine() {
    _logger.d('Simulating night routine...');

    // Dim bedroom lights
    final bedroomDevices = _deviceController.getDevicesByRoom('Bedroom');
    for (final device in bedroomDevices) {
      if (device.type == DeviceType.dimmableLight ||
          device.type == DeviceType.rgb) {
        if (device.supportsSlider) {
          _deviceController.setDeviceSliderValue(device, 20.0);
        }
      }
    }

    // Turn off office devices
    final officeDevices = _deviceController.getDevicesByRoom('Office');
    for (final device in officeDevices) {
      if (device.state.value) {
        _deviceController.toggleDeviceState(device);
      }
    }
  }
}
