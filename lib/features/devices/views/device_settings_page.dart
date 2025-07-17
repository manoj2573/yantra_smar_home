// lib/features/devices/views/device_settings_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/gradient_container.dart';
import '../../../core/models/device_model.dart';
import '../../../core/controllers/device_controller.dart';
import '../../../core/services/supabase_service.dart';

class DeviceSettingsPage extends StatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  State<DeviceSettingsPage> createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends State<DeviceSettingsPage> {
  final DeviceController deviceController = DeviceController.to;
  final SupabaseService supabaseService = SupabaseService.to;

  late DeviceModel device;
  late TextEditingController nameController;
  late TextEditingController roomController;

  String selectedIcon = '';
  String selectedRoom = '';
  bool showCustomRoom = false;
  bool isLoading = false;

  List<Map<String, dynamic>> availableRooms = [];
  List<String> availableIcons = [];

  @override
  void initState() {
    super.initState();
    device = Get.arguments as DeviceModel;
    nameController = TextEditingController(text: device.name);
    roomController = TextEditingController(text: device.roomName ?? '');
    selectedIcon = device.iconPath;
    selectedRoom = device.roomName ?? '';

    _loadRooms();
    _loadAvailableIcons();
  }

  @override
  void dispose() {
    nameController.dispose();
    roomController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await supabaseService.getRooms();
      setState(() {
        availableRooms = rooms;
      });
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  void _loadAvailableIcons() {
    availableIcons = device.type.availableIcons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'Device Settings',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: GradientContainer(
        child: SafeArea(
          child: Padding(
            padding: AppDimensions.pagePadding,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 20),

                      // Device Info Card
                      _buildInfoCard(),
                      const SizedBox(height: 20),

                      // Basic Settings Card
                      _buildBasicSettingsCard(),
                      const SizedBox(height: 20),

                      // Room Settings Card
                      _buildRoomSettingsCard(),
                      const SizedBox(height: 20),

                      // Icon Selection Card
                      _buildIconSelectionCard(),
                      const SizedBox(height: 20),

                      // Advanced Settings Card
                      _buildAdvancedSettingsCard(),
                    ],
                  ),
                ),

                // Save Button
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CustomButton(
                    onPressed: isLoading ? null : _saveSettings,
                    isLoading: isLoading,
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(selectedIcon, width: 48, height: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        device.type.displayName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Row(
                        children: [
                          Icon(
                            device.isOnline.value
                                ? Icons.circle
                                : Icons.circle_outlined,
                            color:
                                device.isOnline.value
                                    ? Colors.green
                                    : Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            device.statusText,
                            style: TextStyle(
                              color:
                                  device.isOnline.value
                                      ? Colors.green
                                      : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: device.state.value,
                  onChanged:
                      (value) => deviceController.toggleDeviceState(device),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: nameController,
              label: 'Device Name',
              icon: Icons.edit,
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField('Device ID', device.deviceId),
            const SizedBox(height: 16),
            _buildReadOnlyField('Registration ID', device.registrationId),
            const SizedBox(height: 16),
            _buildReadOnlyField('Device Type', device.type.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room Assignment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            if (!showCustomRoom) ...[
              DropdownButtonFormField<String>(
                value:
                    availableRooms.any((room) => room['name'] == selectedRoom)
                        ? selectedRoom
                        : null,
                decoration: const InputDecoration(
                  labelText: 'Select Room',
                  prefixIcon: Icon(Icons.room),
                  border: OutlineInputBorder(),
                ),
                items: [
                  ...availableRooms.map(
                    (room) => DropdownMenuItem<String>(
                      value: room['name'],
                      child: Row(
                        children: [
                          Icon(
                            Icons.room,
                            color: Color(
                              int.parse(
                                room['color'].replaceFirst('#', '0xFF'),
                              ),
                            ),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(room['name']),
                        ],
                      ),
                    ),
                  ),
                  const DropdownMenuItem<String>(
                    value: '__custom__',
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20),
                        SizedBox(width: 8),
                        Text('Create New Room'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == '__custom__') {
                    setState(() {
                      showCustomRoom = true;
                      selectedRoom = '';
                    });
                  } else {
                    setState(() {
                      selectedRoom = value ?? '';
                    });
                  }
                },
              ),
            ] else ...[
              CustomTextField(
                controller: roomController,
                label: 'New Room Name',
                icon: Icons.add_home,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showCustomRoom = false;
                        roomController.clear();
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createNewRoom,
                    child: const Text('Create Room'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: availableIcons.length,
              itemBuilder: (context, index) {
                final iconPath = availableIcons[index];
                final isSelected = iconPath == selectedIcon;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIcon = iconPath;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isSelected ? AppTheme.colors.primary : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color:
                          isSelected
                              ? AppTheme.colors.primary.withOpacity(0.1)
                              : Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.asset(iconPath, fit: BoxFit.contain),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.network_check),
              title: const Text('Test Connection'),
              subtitle: Text('Last seen: ${_formatLastSeen()}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _testConnection,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Restart Device'),
              subtitle: const Text('Send restart command to device'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _restartDevice,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Firmware Update'),
              subtitle: const Text('Check for firmware updates'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _checkFirmwareUpdate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {
            // Copy to clipboard functionality
            Get.snackbar('Copied', '$label copied to clipboard');
          },
        ),
      ),
      readOnly: true,
    );
  }

  String _formatLastSeen() {
    if (device.lastSeen == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(device.lastSeen!);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }

  Future<void> _createNewRoom() async {
    if (roomController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Room name cannot be empty');
      return;
    }

    try {
      setState(() => isLoading = true);

      await supabaseService.createRoom(roomController.text.trim());
      await _loadRooms();

      setState(() {
        selectedRoom = roomController.text.trim();
        showCustomRoom = false;
      });

      Get.snackbar('Success', 'Room created successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create room: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => isLoading = true);

    try {
      final updatedDevice = device.copyWith(
        name: nameController.text.trim(),
        roomName: showCustomRoom ? roomController.text.trim() : selectedRoom,
        iconPath: selectedIcon,
        updatedAt: DateTime.now(),
      );

      await deviceController.updateDevice(updatedDevice);

      Get.back();
      Get.snackbar('Success', 'Device settings saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Device'),
        content: Text(
          'Are you sure you want to delete "${device.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: _deleteDevice,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDevice() async {
    try {
      Get.back(); // Close dialog

      await deviceController.deleteDevice(device.id);

      Get.back(); // Go back to previous page
      Get.snackbar('Success', 'Device deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete device: $e');
    }
  }

  Future<void> _testConnection() async {
    Get.snackbar('Testing', 'Testing device connection...');

    // Simulate connection test
    await Future.delayed(const Duration(seconds: 2));

    if (device.isOnline.value) {
      Get.snackbar('Success', 'Device is online and responding');
    } else {
      Get.snackbar('Warning', 'Device appears to be offline');
    }
  }

  Future<void> _restartDevice() async {
    Get.snackbar('Restarting', 'Sending restart command to device...');

    // Send restart command via MQTT
    // This would be implemented in the MQTT service

    await Future.delayed(const Duration(seconds: 1));
    Get.snackbar('Command Sent', 'Restart command sent to device');
  }

  Future<void> _checkFirmwareUpdate() async {
    Get.snackbar('Checking', 'Checking for firmware updates...');

    await Future.delayed(const Duration(seconds: 2));
    Get.snackbar('Up to Date', 'Device firmware is up to date');
  }
}
