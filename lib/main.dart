import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_navigation_screen.dart';
import 'services/hive_storage_service.dart';
import 'services/notification_service.dart';
import 'services/offline_sync_service.dart';
import 'providers/prayer_times_notifier.dart';
import 'providers/app_theme_notifier.dart';
import 'utils/app_colors.dart';

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

  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color accentGold = AppColors.accentOrange;
  static const Color backgroundColor = AppColors.lightBackground;
  static const Color darkBackground = AppColors.darkBackground;

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
                brightness: Brightness.light,
                primary: emeraldGreen,
                secondary: accentGold,
                tertiary: AppColors.secondaryCream,
                surface: AppColors.lightCard,
              ),
              cardTheme: CardThemeData(
                elevation: 3,
                color: AppColors.lightCard,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.lightBorder, width: 1),
                ),
              ),
              textTheme: const TextTheme().apply(
                bodyColor: AppColors.lightText,
                displayColor: AppColors.lightText,
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
                tertiary: AppColors.secondaryCream,
                surface: AppColors.darkCard,
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                color: AppColors.darkCard,
                shadowColor: Colors.black.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.darkBorder, width: 1),
                ),
              ),
              textTheme: const TextTheme().apply(
                bodyColor: AppColors.darkText,
                displayColor: AppColors.darkText,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: AppColors.emeraldDark,
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
