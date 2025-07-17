// lib/app/routes/app_pages.dart
import 'package:get/get.dart';
import '../../features/auth/views/login_page.dart';
import '../../features/auth/views/signup_page.dart';
import '../../features/dashboard/views/dashboard_page.dart';
import '../../shared/views/not_found_page.dart';
import '../../shared/views/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
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
    // Additional routes can be added here
  ];

  static final unknownRoute = GetPage(
    name: '/not-found',
    page: () => const NotFoundPage(),
  );
}
