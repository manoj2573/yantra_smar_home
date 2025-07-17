// lib/shared/dialogs/add_device_dialog.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'dart:convert';

import '../../core/models/device_model.dart';
import '../../core/controllers/device_controller.dart';

class WiFiProvisionDialog extends StatefulWidget {
  const WiFiProvisionDialog({super.key});

  @override
  State<WiFiProvisionDialog> createState() => _WiFiProvisionDialogState();
}

class _WiFiProvisionDialogState extends State<WiFiProvisionDialog> {
  final passwordController = TextEditingController();
  bool isConnectedToESP = false;
  bool isSending = false;
  bool isScanning = false;

  List<WifiNetwork> availableNetworks = [];
  WifiNetwork? selectedNetwork;
  String? manualSsid;
  bool showManualEntry = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Request location permissions for WiFi scanning
    await [
      Permission.location,
      Permission.locationWhenInUse,
      Permission.locationAlways,
    ].request();

    // Connect to ESP32 hotspot
    final connected = await WiFiForIoTPlugin.connect(
      "ESP32_Config",
      security: NetworkSecurity.WPA,
      password: "12345678",
      joinOnce: true,
      withInternet: false,
    );

    if (connected) {
      await WiFiForIoTPlugin.forceWifiUsage(true);
      setState(() => isConnectedToESP = true);
      await _scanWifiNetworks();
    } else {
      Get.snackbar(
        "Connection Error",
        "Failed to connect to ESP32. Make sure the device is in setup mode.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _scanWifiNetworks() async {
    setState(() => isScanning = true);

    try {
      // Get available WiFi networks
      final networks = await WiFiForIoTPlugin.loadWifiList();

      setState(() {
        availableNetworks =
            networks
                .where(
                  (network) =>
                      network.ssid != null &&
                      network.ssid!.isNotEmpty &&
                      network.ssid != "ESP32_Config" &&
                      !network.ssid!.startsWith('ESP32_'),
                )
                .toList();

        // Sort by signal strength (strongest first)
        availableNetworks.sort(
          (a, b) => (b.level ?? -100).compareTo(a.level ?? -100),
        );

        isScanning = false;
      });
    } catch (e) {
      setState(() => isScanning = false);
      print('Error scanning WiFi networks: $e');
      Get.snackbar(
        "Scan Error",
        "Failed to scan WiFi networks: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _provisionDevice() async {
    // Validate inputs
    if (selectedNetwork == null &&
        (manualSsid == null || manualSsid!.isEmpty)) {
      Get.snackbar("Error", "Please select or enter a WiFi network");
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar("Error", "Please enter WiFi password");
      return;
    }

    setState(() => isSending = true);

    try {
      // Step 1: Get device information from ESP32
      final deviceResp = await http
          .get(
            Uri.parse("http://192.168.4.1/device-info"),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (deviceResp.statusCode != 200) {
        throw Exception(
          "Failed to get device info. Status: ${deviceResp.statusCode}",
        );
      }

      final deviceData = jsonDecode(deviceResp.body) as Map<String, dynamic>;
      print('Device info received: $deviceData');

      // Step 2: Send WiFi credentials to ESP32
      final ssid = selectedNetwork?.ssid ?? manualSsid!;
      final wifiResp = await http
          .post(
            Uri.parse("http://192.168.4.1/connect"),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'ssid': ssid, 'password': passwordController.text},
          )
          .timeout(const Duration(seconds: 15));

      print('WiFi response: ${wifiResp.statusCode} - ${wifiResp.body}');

      if (wifiResp.statusCode == 200) {
        final responseBody = wifiResp.body.toLowerCase();
        if (responseBody.contains("received") ||
            responseBody.contains("success")) {
          // Step 3: Create devices in the app
          await _createDevicesFromESP32Data(deviceData);

          // Step 4: Disconnect from ESP32 hotspot
          try {
            await WiFiForIoTPlugin.disconnect();
          } catch (e) {
            print('Disconnect error (non-critical): $e');
          }

          Get.back(); // Close dialog
          Get.snackbar(
            "Success",
            "Device(s) added successfully! You can now configure them in device settings.",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
        } else {
          throw Exception("ESP32 rejected WiFi credentials: ${wifiResp.body}");
        }
      } else {
        throw Exception(
          "WiFi configuration failed. Status: ${wifiResp.statusCode}",
        );
      }
    } catch (e) {
      print('Provisioning error: $e');
      Get.snackbar(
        "Error",
        "Provisioning failed: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _createDevicesFromESP32Data(Map<String, dynamic> espData) async {
    final deviceController = Get.find<DeviceController>();

    try {
      // Handle single device or multiple devices
      final devicesData = espData['devices'] as List<dynamic>? ?? [];
      final registrationId =
          espData['registrationId'] as String? ??
          espData['registration_id'] as String? ??
          'REG_${DateTime.now().millisecondsSinceEpoch}';

      if (devicesData.isEmpty) {
        // Single device format
        final deviceType = espData['type'] as String? ?? 'On/Off';
        final deviceId =
            espData['deviceId'] as String? ??
            espData['device_id'] as String? ??
            'DEV_${DateTime.now().millisecondsSinceEpoch}';

        final device = DeviceModel(
          id: '', // Will be set by database
          deviceId: deviceId,
          name: deviceType, // Use type as default name
          type: DeviceType.fromString(deviceType),
          registrationId: registrationId,
          roomName: 'Unassigned', // Will be set in device settings
          initialState: false,
          initialIsOnline: true, // Device just connected
        );

        await deviceController.addDevice(device);
        print('Single device added: ${device.name}');
      } else {
        // Multiple devices format
        for (var deviceInfo in devicesData) {
          final deviceMap = deviceInfo as Map<String, dynamic>;
          final deviceType = deviceMap['type'] as String? ?? 'On/Off';
          final deviceId =
              deviceMap['deviceId'] as String? ??
              deviceMap['device_id'] as String? ??
              'DEV_${DateTime.now().millisecondsSinceEpoch}_${devicesData.indexOf(deviceInfo)}';

          final device = DeviceModel(
            id: '', // Will be set by database
            deviceId: deviceId,
            name: deviceMap['name'] as String? ?? deviceType,
            type: DeviceType.fromString(deviceType),
            registrationId: registrationId,
            roomName: 'Unassigned',
            initialState: false,
            initialIsOnline: true,
          );

          await deviceController.addDevice(device);
          print('Device added: ${device.name} (${device.deviceId})');
        }
      }
    } catch (e) {
      print('Error creating devices: $e');
      throw Exception('Failed to create devices in database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.wifi, color: Colors.blue),
          const SizedBox(width: 8),
          const Text("Add New Device"),
        ],
      ),
      content:
          isConnectedToESP
              ? SizedBox(
                width: double.maxFinite,
                height: 400, // Fixed height to prevent overflow
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Connection Status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Connected to ESP32 device",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // WiFi Network Selection
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Select WiFi Network",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: isScanning ? null : _scanWifiNetworks,
                            icon: Icon(
                              isScanning ? Icons.refresh : Icons.wifi_find,
                            ),
                            tooltip: "Refresh network list",
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (isScanning)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text("Scanning for networks..."),
                            ],
                          ),
                        )
                      else ...[
                        // Network Dropdown
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<WifiNetwork?>(
                              isExpanded: true,
                              value: selectedNetwork,
                              hint: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text("Choose your WiFi network"),
                              ),
                              items: [
                                ...availableNetworks.map(
                                  (network) => DropdownMenuItem<WifiNetwork?>(
                                    value: network,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getWifiIcon(network.level ?? -100),
                                            size: 20,
                                            color: _getSignalColor(
                                              network.level ?? -100,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              network.ssid ?? "Unknown Network",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (network.capabilities?.contains(
                                                "WPA",
                                              ) ==
                                              true)
                                            const Icon(
                                              Icons.lock,
                                              size: 16,
                                              color: Colors.orange,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const DropdownMenuItem<WifiNetwork?>(
                                  value: null,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 12),
                                        Text("Enter network manually..."),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (value == null) {
                                    selectedNetwork = null;
                                    showManualEntry = true;
                                  } else {
                                    selectedNetwork = value;
                                    showManualEntry = false;
                                    manualSsid = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ),

                        // Manual SSID Entry
                        if (showManualEntry) ...[
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: "Network Name (SSID)",
                              hintText: "Enter WiFi network name",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.wifi),
                            ),
                            onChanged: (value) => manualSsid = value,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                showManualEntry = false;
                                manualSsid = null;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Back to network list"),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(
                            labelText: "WiFi Password",
                            hintText: "Enter network password",
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),

                        const SizedBox(height: 24),

                        // Provision Button
                        SizedBox(
                          width: double.infinity,
                          child:
                              isSending
                                  ? const Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 12),
                                      Text("Configuring device..."),
                                      Text(
                                        "This may take a few moments",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                  : ElevatedButton.icon(
                                    onPressed: _provisionDevice,
                                    icon: const Icon(Icons.add_circle),
                                    label: const Text("Add Device"),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
              : const SizedBox(
                height: 150,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text("Connecting to ESP32..."),
                      SizedBox(height: 8),
                      Text(
                        "Make sure your ESP32 is in setup mode",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
      actions: [
        TextButton(
          onPressed: isSending ? null : () => Get.back(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  IconData _getWifiIcon(int level) {
    if (level > -50) return Icons.signal_wifi_4_bar;
    if (level > -60) return Icons.wifi_2_bar;
    if (level > -70) return Icons.wifi_2_bar;
    if (level > -80) return Icons.wifi_1_bar;
    return Icons.signal_wifi_0_bar;
  }

  Color _getSignalColor(int level) {
    if (level > -50) return Colors.green;
    if (level > -70) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
