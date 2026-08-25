import 'package:flutter/material.dart';
import 'prayer_times_screen.dart';
import 'prayer_guide_screen.dart';
import 'zikir_screen.dart';
import 'dua_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFD4AF37);

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      PrayerTimesScreen(
        onOpenTesbihat: () => _changeTab(2),
      ),
      const PrayerGuideScreen(),
      const ZikirScreen(),
      const DuaScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: accentGold.withValues(alpha: 0.2),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: accentGold.withValues(alpha: 0.5), width: 1),
              ),
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: emeraldGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                }
                return TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: emeraldGreen, size: 24);
                }
                return IconThemeData(color: Colors.grey.shade600, size: 22);
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 64,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.access_time_outlined),
                  selectedIcon: Icon(Icons.access_time_filled),
                  label: 'Vakitler',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Rehber',
                ),
                NavigationDestination(
                  icon: Icon(Icons.touch_app_outlined),
                  selectedIcon: Icon(Icons.touch_app_rounded),
                  label: 'Zikirmatik',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_stories_outlined),
                  selectedIcon: Icon(Icons.auto_stories_rounded),
                  label: 'Dualar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
