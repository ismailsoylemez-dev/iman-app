import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/hive_storage_service.dart';
import 'services/notification_service.dart';
import 'services/offline_sync_service.dart';
import 'providers/prayer_times_notifier.dart';
import 'providers/app_theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorageService.init();
  await NotificationService().init();
  try {
    await OfflineSyncService().syncOnStartup();
  } catch (_) {
    // Çevrimdışı başlatmada senkronizasyon başarısız olursa uygulama önbellekle devam eder
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF121712);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PrayerTimesNotifier()),
        ChangeNotifierProvider(create: (_) => AppThemeNotifier()),
      ],
      child: Consumer<AppThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp(
            title: 'İman Uygulaması',
            themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
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
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: darkBackground,
              colorScheme: ColorScheme.fromSeed(
                seedColor: emeraldGreen,
                brightness: Brightness.dark,
                primary: accentGold,
                secondary: accentGold,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Color(0xFF0F241C),
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
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(themeNotifier.fontScale),
                ),
                child: child!,
              );
            },
            home: const MainNavigationScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
