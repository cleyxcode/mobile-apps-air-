import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/service_locator.dart';
import 'core/notification_service.dart';
import 'core/schedule_foreground_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.setup();
  ScheduleForegroundService.instance.start();
  await NotificationService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Siram Pintar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/app': (context) => const AppShell(),
      },
    );
  }
}
