import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/prayer_times_notifier.dart';
import '../services/notification_service.dart';
import '../services/offline_sync_service.dart';
import '../services/prayer_time_service.dart';
import 'prayer_times_screen.dart';
import 'prayer_guide_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigateToTab;
  final VoidCallback? onOpenDrawer;

  const HomeScreen({super.key, this.onNavigateToTab, this.onOpenDrawer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color emeraldDark = Color(0xFF0F241C);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF9E8B2);
  static const Color darkText = Color(0xFF212529);

  bool _isOnline = true;
  bool _isGpsEnabled = true;
  bool _hasNotificationPermission = true;

  @override
  void initState() {
    super.initState();
    _checkSystemState();
  }

  Future<void> _checkSystemState() async {
    final online = await OfflineSyncService().isOnline();
    final gpsEnabled = await Geolocator.isLocationServiceEnabled();
    final notifPermission = await NotificationService().hasNotificationPermission();

    if (mounted) {
      setState(() {
        _isOnline = online;
        _isGpsEnabled = gpsEnabled;
        _hasNotificationPermission = notifPermission;
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(duration.inHours)}:${twoDigits(duration.inMinutes.remainder(60))}:${twoDigits(duration.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('İman Uygulaması'),
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: widget.onOpenDrawer,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () async {
                await context.read<PrayerTimesNotifier>().fetchPrayerTimes();
                await _checkSystemState();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!_isOnline)
                    _buildBanner(
                      icon: Icons.wifi_off_rounded,
                      text: 'Çevrimdışı mod - önbellekteki veriler gösteriliyor',
                      color: Colors.blueGrey,
                    ),
                  if (_isOnline && !_isGpsEnabled)
                    _buildBanner(
                      icon: Icons.location_off_rounded,
                      text: 'GPS kapalı. Varsayılan il kullanılıyor.',
                      color: Colors.amber.shade800,
                      actionLabel: 'Ayarlar',
                      onAction: _openSettings,
                    ),
                  if (_isOnline && !_hasNotificationPermission)
                    _buildBanner(
                      icon: Icons.notifications_off_rounded,
                      text: 'Bildirim izni yok. Ezan alarmı çalışmayacak.',
                      color: Colors.red.shade700,
                      actionLabel: 'İzin Ver',
                      onAction: _openSettings,
                    ),
                  _buildNextPrayerCard(),
                  const SizedBox(height: 12),
                  _buildHijriDateCard(),
                  const SizedBox(height: 12),
                  _buildSpecialDayCard(),
                  const SizedBox(height: 16),
                  _buildQuickActionGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  Widget _buildBanner({
    required IconData icon,
    required String text,
    required Color color,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600)),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
              child: Text(actionLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    return Consumer<PrayerTimesNotifier>(
      builder: (context, notifier, child) {
        final now = DateTime.now();
        final nextPrayerEntry = PrayerTimeService.getNextPrayer(notifier.prayerTimes, now);
        final nextPrayerName = nextPrayerEntry?.key ?? 'İmsak (Yarın)';
        final remaining = nextPrayerEntry != null
            ? nextPrayerEntry.value.difference(now)
            : const Duration();

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [emeraldDark, emeraldGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accentGold.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${notifier.selectedCity.name} • Sıradaki Vakit',
                  style: const TextStyle(color: goldLight, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  nextPrayerName,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDuration(remaining),
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.explore_rounded, color: accentGold, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Kıble: ${notifier.qiblaAngle.toStringAsFixed(0)}°',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PrayerGuideScreen()),
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 16, color: accentGold),
                      label: const Text('Namaz Rehberi', style: TextStyle(color: Colors.white, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: accentGold),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHijriDateCard() {
    return Consumer<PrayerTimesNotifier>(
      builder: (context, notifier, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: goldLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accentGold.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: Color(0xFF8C6D0F)),
              const SizedBox(width: 10),
              Text(
                notifier.hijriDate.isNotEmpty ? notifier.hijriDate : PrayerTimeService.getHijriDate(DateTime.now()),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF8C6D0F)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecialDayCard() {
    final specialDayInfo = PrayerTimeService.getNextSpecialDay();
    final specialDay = specialDayInfo['day'] as SpecialIslamicDay;
    final remainingDays = specialDayInfo['remainingDays'] as int;

    if (remainingDays > 30) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFF8C6D0F)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(specialDay.name, style: const TextStyle(fontWeight: FontWeight.bold, color: emeraldGreen)),
                Text(specialDay.description, style: const TextStyle(fontSize: 11.5, color: darkText), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: emeraldGreen, borderRadius: BorderRadius.circular(12)),
            child: Text(
              remainingDays == 0 ? 'Bugün' : '$remainingDays gün',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid() {
    final actions = [
      (icon: Icons.mosque_rounded, label: 'Namaz Rehberi', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PrayerGuideScreen()))),
      (icon: Icons.auto_stories_rounded, label: 'Dualar', onTap: () => widget.onNavigateToTab?.call(1)),
      (icon: Icons.touch_app_rounded, label: 'Zikir', onTap: () => widget.onNavigateToTab?.call(2)),
      (icon: Icons.settings_rounded, label: 'Ayarlar', onTap: _openSettings),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: actions.map((action) {
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: action.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE9ECEF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, color: emeraldGreen, size: 20),
                const SizedBox(width: 8),
                Text(action.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: darkText)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
