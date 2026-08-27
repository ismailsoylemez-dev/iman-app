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
              fontFamily: 'Manrope',
              scaffoldBackgroundColor: backgroundColor,
              colorScheme: ColorScheme.fromSeed(
                seedColor: emeraldGreen,
                brightness: Brightness.light,
                primary: emeraldGreen,
                secondary: accentGold,
                tertiary: AppColors.secondaryCream,
                surface: AppColors.lightSurface,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: AppColors.lightSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.lightBorder, width: 1),
                ),
              ),
              textTheme: const TextTheme().apply(
                fontFamily: 'Manrope',
                bodyColor: AppColors.lightText,
                displayColor: AppColors.lightText,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: emeraldGreen,
                foregroundColor: Colors.white,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontFamily: 'Manrope',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                hintStyle: TextStyle(color: AppColors.lightTextSecondary),
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightBorder)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightBorder)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lightPrimary)),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              fontFamily: 'Manrope',
              scaffoldBackgroundColor: darkBackground,
              colorScheme: ColorScheme.fromSeed(
                seedColor: emeraldGreen,
                brightness: Brightness.dark,
                primary: accentGold,
                secondary: accentGold,
                tertiary: AppColors.secondaryCream,
                surface: AppColors.darkSurface,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                color: AppColors.darkSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.darkBorder, width: 1),
                ),
              ),
              textTheme: const TextTheme().apply(
                fontFamily: 'Manrope',
                bodyColor: AppColors.darkText,
                displayColor: AppColors.darkText,
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: AppColors.emeraldDark,
                foregroundColor: Colors.white,
                centerTitle: true,
                titleTextStyle: TextStyle(
                  fontFamily: 'Manrope',
                  color: AppColors.accentOrangeDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                hintStyle: TextStyle(color: AppColors.darkTextSecondary),
                border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkBorder)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.darkPrimary)),
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
