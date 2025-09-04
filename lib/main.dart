import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Core imports
import 'app/data/models/user_settings.dart';
import 'app/data/models/notification_session.dart';
import 'app/data/models/treatment.dart';
import 'app/data/models/pain_point.dart';

// Services
import 'app/services/database_service.dart';
import 'app/services/notification_service.dart';
import 'app/services/permission_service.dart';

// Controllers
import 'app/controllers/settings_controller.dart';
import 'app/controllers/notification_controller.dart';
import 'app/controllers/home_controller.dart';
import 'app/controllers/statistics_controller.dart';

// Pages
import 'app/ui/pages/splash_page.dart';
import 'app/ui/pages/home_page.dart';
import 'app/ui/pages/todo_page.dart';
import 'app/ui/pages/settings_page.dart';
import 'app/ui/pages/statistics_page.dart';
import 'app/ui/pages/first_time_setup_page.dart';

// Routes
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(NotificationSessionAdapter());
  Hive.registerAdapter(TreatmentAdapter());
  Hive.registerAdapter(PainPointAdapter());
  Hive.registerAdapter(SessionStatusAdapter());
  Hive.registerAdapter(BreakPeriodAdapter());

  // Initialize services
  await DatabaseService.initialize();
  await NotificationService.initialize();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Office Syndrome Helper',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.notoSansThaiTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // Routes
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,

      // Initialize controllers
      initialBinding: BindingsBuilder(() {
        Get.put(SettingsController());
        Get.put(NotificationController());
        Get.put(HomeController());
        Get.put(StatisticsController());
      }),

      // Default transition
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
