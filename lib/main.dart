import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/hive_storage_service.dart';
import 'services/notification_service.dart';
import 'providers/prayer_times_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageService.init();
  await NotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerTimesNotifier()),
      ],
      child: MaterialApp(
        title: 'İman Uygulaması',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: backgroundColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: emeraldGreen,
            primary: emeraldGreen,
            secondary: accentGold,
            surface: backgroundColor,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            color: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFECEFF1), width: 1),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: emeraldGreen,
            foregroundColor: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        home: const MainNavigationScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
