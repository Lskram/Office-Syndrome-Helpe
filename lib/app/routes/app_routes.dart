import 'package:get/get.dart';

import '../ui/pages/splash_page.dart';
import '../ui/pages/first_time_setup_page.dart';
import '../ui/pages/home_page.dart';
import '../ui/pages/todo_page.dart';
import '../ui/pages/settings_page.dart';
import '../ui/pages/statistics_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String firstTimeSetup = '/first-time-setup';
  static const String home = '/home';
  static const String todo = '/todo';
  static const String settings = '/settings';
  static const String statistics = '/statistics';

  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: firstTimeSetup,
      page: () => const FirstTimeSetupPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: todo,
      page: () => const TodoPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    GetPage(
      name: statistics,
      page: () => const StatisticsPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
