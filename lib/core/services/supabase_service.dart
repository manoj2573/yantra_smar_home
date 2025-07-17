// lib/core/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/device_model.dart';
import '../models/timer_model.dart';
import '../models/ir_device_model.dart';
import '../../app/config/supabase_config.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();

  final _logger = Logger();
  late final SupabaseClient _client;

  // Getters
  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  String? get userId => currentUser?.id;

  @override
  Future<void> onInit() async {
    super.onInit();
    _client = SupabaseConfig.client;
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;

      _logger.i('Auth state changed: $event, User: ${user?.email}');

      switch (event) {
        case AuthChangeEvent.signedIn:
          _logger.i('User signed in: ${user?.email}');
          break;
        case AuthChangeEvent.signedOut:
          _logger.i('User signed out');
          break;
        case AuthChangeEvent.tokenRefreshed:
          _logger.d('Token refreshed for: ${user?.email}');
          break;
        default:
          break;
      }
    });
  }

  // ===================== AUTH METHODS =====================

  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      _logger.i('Signing up user: $email');
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _logger.i('User signed up successfully: $email');
        // Create default room and preferences
        await _createUserDefaults(response.user!.id);
      }

      return response;
    } catch (e) {
      _logger.e('Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      _logger.i('Signing in user: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _logger.i('User signed in successfully: $email');
      }

      return response;
    } catch (e) {
      _logger.e('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _logger.i('Signing out user');
      await _client.auth.signOut();
      _logger.i('User signed out successfully');
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _client.auth.resetPasswordForEmail(email);
      _logger.i('Password reset email sent successfully');
    } catch (e) {
      _logger.e('Password reset error: $e');
      rethrow;
    }
  }

  Future<void> _createUserDefaults(String userId) async {
    try {
      // Create default room
      await _client.from('rooms').insert({
        'user_id': userId,
        'name': 'Living Room',
        'icon_path': 'assets/room.png',
        'color': '#FF9800',
      });

      // Create user preferences
      await _client.from('user_preferences').insert({
        'user_id': userId,
        'theme': 'orange',
        'notifications_enabled': true,
        'auto_discover_devices': true,
      });

      _logger.i('Created default data for user: $userId');
    } catch (e) {
      _logger.e('Error creating user defaults: $e');
      // Don't rethrow - this is not critical
    }
  }

  // ===================== DEVICE METHODS =====================

  Future<List<DeviceModel>> getDevices() async {
    try {
      _ensureAuthenticated();

      final response = await _client
          .from('devices')
          .select('*, rooms(name)')
          .eq('user_id', userId!)
          .order('name');

      return response.map<DeviceModel>((data) {
        // Add room name to device data
        final roomData = data['rooms'];
        if (roomData != null) {
          data['room_name'] = roomData['name'];
        }
        return DeviceModel.fromSupabase(data);
      }).toList();
    } catch (e) {
      _logger.e('Error fetching devices: $e');
      rethrow;
    }
  }

  Future<DeviceModel> createDevice(DeviceModel device) async {
    try {
      _ensureAuthenticated();

      final data = device.toSupabase();
      data['user_id'] = userId!;

      final response =
          await _client.from('devices').insert(data).select().single();

      _logger.i('Device created: ${device.name}');
      return DeviceModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error creating device: $e');
      rethrow;
    }
  }

  Future<DeviceModel> updateDevice(DeviceModel device) async {
    try {
      _ensureAuthenticated();

      final response =
          await _client
              .from('devices')
              .update(device.toSupabase())
              .eq('id', device.id)
              .eq('user_id', userId!)
              .select()
              .single();

      _logger.d('Device updated: ${device.name}');
      return DeviceModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error updating device: $e');
      rethrow;
    }
  }

  Future<void> deleteDevice(String deviceId) async {
    try {
      _ensureAuthenticated();

      await _client
          .from('devices')
          .delete()
          .eq('id', deviceId)
          .eq('user_id', userId!);

      _logger.i('Device deleted: $deviceId');
    } catch (e) {
      _logger.e('Error deleting device: $e');
      rethrow;
    }
  }

  Stream<List<DeviceModel>> watchDevices() {
    _ensureAuthenticated();

    return _client
        .from('devices')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId!)
        .order('name')
        .map(
          (data) =>
              data
                  .map<DeviceModel>((item) => DeviceModel.fromSupabase(item))
                  .toList(),
        );
  }

  // ===================== TIMER METHODS =====================

  Future<List<TimerModel>> getTimers() async {
    try {
      _ensureAuthenticated();

      final response = await _client
          .from('timers')
          .select()
          .eq('user_id', userId!)
          .order('created_at', ascending: false);

      return response
          .map<TimerModel>((data) => TimerModel.fromSupabase(data))
          .toList();
    } catch (e) {
      _logger.e('Error fetching timers: $e');
      rethrow;
    }
  }

  Future<TimerModel> createTimer(TimerModel timer) async {
    try {
      _ensureAuthenticated();

      final data = timer.toSupabase();
      data['user_id'] = userId!;

      final response =
          await _client.from('timers').insert(data).select().single();

      _logger.i('Timer created: ${timer.name}');
      return TimerModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error creating timer: $e');
      rethrow;
    }
  }

  Future<TimerModel> updateTimer(TimerModel timer) async {
    try {
      _ensureAuthenticated();

      final response =
          await _client
              .from('timers')
              .update(timer.toSupabase())
              .eq('id', timer.id)
              .eq('user_id', userId!)
              .select()
              .single();

      _logger.d('Timer updated: ${timer.name}');
      return TimerModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error updating timer: $e');
      rethrow;
    }
  }

  Future<void> deleteTimer(String timerId) async {
    try {
      _ensureAuthenticated();

      await _client
          .from('timers')
          .delete()
          .eq('id', timerId)
          .eq('user_id', userId!);

      _logger.i('Timer deleted: $timerId');
    } catch (e) {
      _logger.e('Error deleting timer: $e');
      rethrow;
    }
  }

  Stream<List<TimerModel>> watchTimers() {
    _ensureAuthenticated();

    return _client
        .from('timers')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId!)
        .order('created_at', ascending: false)
        .map(
          (data) =>
              data
                  .map<TimerModel>((item) => TimerModel.fromSupabase(item))
                  .toList(),
        );
  }

  // ===================== IR HUB METHODS =====================

  Future<List<IRHubModel>> getIRHubs() async {
    try {
      _ensureAuthenticated();

      final response = await _client
          .from('ir_hubs')
          .select('*, rooms(name)')
          .eq('user_id', userId!)
          .order('name');

      List<IRHubModel> hubs = [];

      for (final hubData in response) {
        // Get IR devices for this hub
        final devicesResponse = await _client
            .from('ir_devices')
            .select('*, ir_buttons(*)')
            .eq('ir_hub_id', hubData['id']);

        List<IRDeviceModel> irDevices = [];
        for (final deviceData in devicesResponse) {
          final buttons =
              (deviceData['ir_buttons'] as List?)
                  ?.map((b) => IRButtonModel.fromSupabase(b))
                  .toList() ??
              [];

          irDevices.add(
            IRDeviceModel.fromSupabase(deviceData, buttons: buttons),
          );
        }

        // Add room name to hub data
        final roomData = hubData['rooms'];
        if (roomData != null) {
          hubData['room_name'] = roomData['name'];
        }

        hubs.add(IRHubModel.fromSupabase(hubData, irDevices: irDevices));
      }

      return hubs;
    } catch (e) {
      _logger.e('Error fetching IR hubs: $e');
      rethrow;
    }
  }

  Future<IRHubModel> createIRHub(IRHubModel hub) async {
    try {
      _ensureAuthenticated();

      final data = hub.toSupabase();
      data['user_id'] = userId!;

      final response =
          await _client.from('ir_hubs').insert(data).select().single();

      _logger.i('IR Hub created: ${hub.name}');
      return IRHubModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error creating IR hub: $e');
      rethrow;
    }
  }

  Future<IRDeviceModel> createIRDevice(IRDeviceModel device) async {
    try {
      _ensureAuthenticated();

      final response =
          await _client
              .from('ir_devices')
              .insert(device.toSupabase())
              .select()
              .single();

      _logger.i('IR Device created: ${device.name}');
      return IRDeviceModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error creating IR device: $e');
      rethrow;
    }
  }

  Future<IRButtonModel> createIRButton(IRButtonModel button) async {
    try {
      _ensureAuthenticated();

      final response =
          await _client
              .from('ir_buttons')
              .insert(button.toSupabase())
              .select()
              .single();

      _logger.i('IR Button created: ${button.name}');
      return IRButtonModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error creating IR button: $e');
      rethrow;
    }
  }

  Future<IRButtonModel> updateIRButton(IRButtonModel button) async {
    try {
      _ensureAuthenticated();

      final response =
          await _client
              .from('ir_buttons')
              .update(button.toSupabase())
              .eq('id', button.id)
              .select()
              .single();

      _logger.d('IR Button updated: ${button.name}');
      return IRButtonModel.fromSupabase(response);
    } catch (e) {
      _logger.e('Error updating IR button: $e');
      rethrow;
    }
  }

  // ===================== ROOM METHODS =====================

  Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      _ensureAuthenticated();

      final response = await _client
          .from('rooms')
          .select()
          .eq('user_id', userId!)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Error fetching rooms: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createRoom(
    String name, {
    String? iconPath,
    String? color,
  }) async {
    try {
      _ensureAuthenticated();

      final response =
          await _client
              .from('rooms')
              .insert({
                'user_id': userId!,
                'name': name,
                'icon_path': iconPath ?? 'assets/room.png',
                'color': color ?? '#FF9800',
              })
              .select()
              .single();

      _logger.i('Room created: $name');
      return response;
    } catch (e) {
      _logger.e('Error creating room: $e');
      rethrow;
    }
  }

  // ===================== SCENES METHODS =====================

  Future<List<Map<String, dynamic>>> getScenes() async {
    try {
      _ensureAuthenticated();

      final response = await _client
          .from('scenes')
          .select()
          .eq('user_id', userId!)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.e('Error fetching scenes: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createScene(
    String name,
    List<Map<String, dynamic>> devices,
  ) async {
    try {
      _ensureAuthenticated();

      final response =
          await _client
              .from('scenes')
              .insert({'user_id': userId!, 'name': name, 'devices': devices})
              .select()
              .single();

      _logger.i('Scene created: $name');
      return response;
    } catch (e) {
      _logger.e('Error creating scene: $e');
      rethrow;
    }
  }

  Future<void> updateScene(
    String sceneId,
    String name,
    List<Map<String, dynamic>> devices,
  ) async {
    try {
      _ensureAuthenticated();

      await _client
          .from('scenes')
          .update({'name': name, 'devices': devices})
          .eq('id', sceneId)
          .eq('user_id', userId!);

      _logger.i('Scene updated: $name');
    } catch (e) {
      _logger.e('Error updating scene: $e');
      rethrow;
    }
  }

  Future<void> deleteScene(String sceneId) async {
    try {
      _ensureAuthenticated();

      await _client
          .from('scenes')
          .delete()
          .eq('id', sceneId)
          .eq('user_id', userId!);

      _logger.i('Scene deleted: $sceneId');
    } catch (e) {
      _logger.e('Error deleting scene: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> watchScenes() {
    _ensureAuthenticated();

    return _client
        .from('scenes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId!)
        .order('name')
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  // ===================== UTILITY METHODS =====================

  void _ensureAuthenticated() {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }
  }

  Future<bool> checkConnection() async {
    try {
      await _client.from('rooms').select('id').limit(1);
      return true;
    } catch (e) {
      _logger.w('Connection check failed: $e');
      return false;
    }
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToDevices({
    required Function(List<DeviceModel>) onData,
  }) {
    _ensureAuthenticated();

    return _client
        .channel('devices_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'devices',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId!,
          ),
          callback: (payload) async {
            try {
              final devices = await getDevices();
              onData(devices);
            } catch (e) {
              _logger.e('Error in device subscription callback: $e');
            }
          },
        )
        .subscribe();
  }

  RealtimeChannel subscribeToTimers({
    required Function(List<TimerModel>) onData,
  }) {
    _ensureAuthenticated();

    return _client
        .channel('timers_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'timers',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId!,
          ),
          callback: (payload) async {
            try {
              final timers = await getTimers();
              onData(timers);
            } catch (e) {
              _logger.e('Error in timer subscription callback: $e');
            }
          },
        )
        .subscribe();
  }
}
