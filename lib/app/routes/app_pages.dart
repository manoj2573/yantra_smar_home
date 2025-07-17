// lib/app/routes/app_pages.dart - Updated with missing routes
import 'package:get/get.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/signup_page.dart';
import '../../features/dashboard/views/dashboard_page.dart';
import '../../features/devices/views/add_device_page.dart';
import '../../features/devices/views/device_control_page.dart';
import '../../features/devices/views/device_settings_page.dart';
import '../../features/rooms/views/rooms_page.dart';
import '../../features/scenes/views/scenes_page.dart';
import '../../features/timers/views/timers_page.dart';
import '../../features/settings/views/settings_page.dart';
import '../../features/settings/views/debug_menu_page.dart';
import '../../shared/views/not_found_page.dart';
import '../../shared/views/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Core Routes
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      transition: Transition.cupertino,
    ),

    // Device Management
    GetPage(
      name: AppRoutes.addDevice,
      page: () => const AddDevicePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.deviceControl,
      page: () => const DeviceControlPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.deviceSettings,
      page: () => const DeviceSettingsPage(),
      transition: Transition.rightToLeft,
    ),

    // Room Management
    GetPage(
      name: '/rooms',
      page: () => const RoomsPage(),
      transition: Transition.rightToLeft,
    ),

    // Scene Management
    GetPage(
      name: AppRoutes.scenes,
      page: () => const ScenesPage(),
      transition: Transition.rightToLeft,
    ),

    // Timer Management
    GetPage(
      name: AppRoutes.timers,
      page: () => const TimersPage(),
      transition: Transition.rightToLeft,
    ),

    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/debug-menu',
      page: () => const DebugMenuPage(),
      transition: Transition.rightToLeft,
    ),

    // Additional routes can be added here as you implement them
    // GetPage(
    //   name: AppRoutes.schedules,
    //   page: () => const SchedulesPage(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.irHub,
    //   page: () => const IRHubPage(),
    //   transition: Transition.rightToLeft,
    // ),
    // GetPage(
    //   name: AppRoutes.wifi,
    //   page: () => const WiFiConfigPage(),
    //   transition: Transition.rightToLeft,
    // ),
  ];

  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => const NotFoundPage(),
  );
}
