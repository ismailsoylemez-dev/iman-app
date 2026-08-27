import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import 'prayer_guide_screen.dart';
import 'zikir_screen.dart';
import 'dua_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import '../widgets/status_bar_widget.dart';
import '../utils/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _copyToClipboardAndNotify(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onNavigateToTab: _changeTab,
        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      const DuaScreen(),
      const ZikirScreen(),
      const PrayerGuideScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                color: AppColors.primary(context),
                child: const Text(
                  'İman Uygulaması',
                  style: TextStyle(color: AppColors.onPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: Icon(Icons.bar_chart_rounded, color: AppColors.primary(context)),
                title: const Text('İstatistikler'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline_rounded, color: AppColors.primary(context)),
                title: const Text('Hakkında'),
                onTap: () {
                  Navigator.pop(context);
                  showAboutDialog(
                    context: context,
                    applicationName: 'İman Uygulaması',
                    applicationVersion: '1.0.0',
                    applicationIcon: Icon(Icons.auto_stories_rounded, color: AppColors.primary(context)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite_border_rounded, color: AppColors.primary(context)),
                title: const Text('Geri Bildirim'),
                onTap: () {
                  Navigator.pop(context);
                  _copyToClipboardAndNotify(
                    context,
                    'destek@imanuygulamasi.com',
                    'E-posta adresi panoya kopyalandı.',
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const StatusBarWidget(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.card(context),
          boxShadow: [
            BoxShadow(
              color: AppColors.border(context).withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColors.accent(context).withValues(alpha: 0.2),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.accent(context).withValues(alpha: 0.5), width: 1),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                }
                return TextStyle(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: AppColors.primary(context), size: 24);
                }
                return IconThemeData(color: AppColors.textSecondary(context), size: 22);
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              onDestinationSelected: _changeTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Ana Sayfa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories_rounded),
                  label: 'Dualar',
                ),
                NavigationDestination(
                  icon: Icon(Icons.touch_app_outlined),
                  selectedIcon: Icon(Icons.touch_app_rounded),
                  label: 'Zikirmatik',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Namaz Rehberi',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Ayarlar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
