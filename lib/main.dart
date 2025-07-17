// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

// Core configuration
import 'app/config/supabase_config.dart';
import 'app/theme/app_theme.dart';
import 'app/routes/app_pages.dart';

// Services
import 'core/services/supabase_service.dart';
import 'core/services/mqtt_service.dart';

// Controllers
import 'core/controllers/auth_controller.dart';
import 'core/controllers/device_controller.dart';
import 'core/controllers/timer_controller.dart';
import 'core/controllers/scene_controller.dart';
import 'core/controllers/ir_hub_controller.dart';

// Features
import 'features/auth/controllers/auth_page_controller.dart';
import 'features/dashboard/controllers/dashboard_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Initialize logger
  Logger.level = Level.info;
  final logger = Logger();

  try {
    logger.i('🚀 Starting Smart Home Automation App...');

    // Initialize Supabase
    logger.i('📡 Initializing Supabase...');
    await SupabaseConfig.initialize();
    logger.i('✅ Supabase initialized successfully');

    // Register services FIRST
    logger.i('🔧 Registering services...');
    Get.put(SupabaseService(), permanent: true);
    Get.put(MqttService(), permanent: true);
    logger.i('✅ Services registered');

    // Register controllers in the correct order
    logger.i('🎮 Registering controllers...');
    Get.put(AuthController(), permanent: true);
    Get.put(DeviceController(), permanent: true);
    Get.put(TimerController(), permanent: true);
    Get.put(SceneController(), permanent: true);
    Get.put(IRHubController(), permanent: true);
    logger.i('✅ Controllers registered');

    // Initialize MQTT connection
    logger.i('📱 Connecting to MQTT...');
    final mqttService = Get.find<MqttService>();
    await mqttService.connect();

    if (mqttService.isConnected) {
      logger.i('✅ MQTT connected successfully');
    } else {
      logger.w('⚠️ MQTT connection failed, will retry automatically');
    }

    logger.i('🎉 App initialization completed successfully!');
  } catch (error, stackTrace) {
    logger.e('❌ App initialization failed: $error');
    logger.e('Stack trace: $stackTrace');

    // Still run the app but show error state
    runApp(ErrorApp(error: error.toString()));
    return;
  }

  // Run the main app
  runApp(SmartHomeApp());
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Home Automation',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routing
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      unknownRoute: AppPages.unknownRoute,

      // Localization
      fallbackLocale: const Locale('en', 'US'),

      // Global bindings
      initialBinding: InitialBinding(),

      // Default transitions
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),

      // Error handling
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Prevent text scaling issues
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load feature controllers
    Get.lazyPut(() => AuthPageController());
    Get.lazyPut(() => DashboardController());
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home - Error',
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red.shade600),
                const SizedBox(height: 24),
                Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize the app. Please check your configuration and try again.',
                  style: TextStyle(fontSize: 16, color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: SelectableText(
                    error,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.red.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
