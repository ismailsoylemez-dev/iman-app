import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/app_theme_notifier.dart';
import '../providers/prayer_times_notifier.dart';
import '../services/hive_storage_service.dart';
import '../services/offline_sync_service.dart';
import '../services/permission_service.dart';
import '../services/prayer_time_service.dart';
import 'notification_scheduler_screen.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  static const String _keyCalcMethod = 'settings_calc_method';
  static const String _keyNotifEnabled = 'settings_notif_enabled';
  static const String _keyNotifTiming = 'settings_notif_timing';

  String _calcMethod = 'Türkiye';
  bool _notificationsEnabled = true;
  String _notifTiming = 'Vakit girdiğinde';
  DateTime? _lastSync;

  final List<String> _calcMethods = const ['Türkiye', 'Şafi\'i', 'Hanbeli'];
  final List<String> _notifTimings = const ['5 dakika önce', 'Vakit girdiğinde', 'Vakitten sonra'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final calc = HiveStorageService.getSetting(_keyCalcMethod);
    final notif = HiveStorageService.getSetting(_keyNotifEnabled);
    final timing = HiveStorageService.getSetting(_keyNotifTiming);
    setState(() {
      if (calc is String) _calcMethod = calc;
      if (notif is bool) _notificationsEnabled = notif;
      if (timing is String) _notifTiming = timing;
      _lastSync = OfflineSyncService().getLastSyncTime();
    });
  }

  void _copyToClipboardAndNotify(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _changeCity() async {
    final hasPermission = await PermissionService().requestLocationPermission();
    if (!hasPermission || !mounted) return;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      final nearest = PrayerTimeService.findNearestCity(position.latitude, position.longitude);

      if (!mounted) return;
      await context.read<PrayerTimesNotifier>().updateCity(nearest);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konum alınamadı.'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  Future<String> _buildExportCsv() async {
    final favoriteIds = HiveStorageService.getFavoriteIds();
    final buffer = StringBuffer('tip,id\n');
    for (final id in favoriteIds) {
      buffer.writeln('favori_dua,$id');
    }
    for (final record in HiveStorageService.getAllZikirRecords()) {
      buffer.writeln('zikir,${record.id},${record.count}');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<AppThemeNotifier>();
    final selectedCity = context.watch<PrayerTimesNotifier>().selectedCity;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Görünüm'),
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            value: themeNotifier.isDarkMode,
            activeThumbColor: AppColors.accent(context),
            onChanged: (_) => themeNotifier.toggleDarkMode(),
          ),
          ListTile(
            title: const Text('Yazı Boyutu'),
            subtitle: Slider(
              value: AppFontSize.values.indexOf(themeNotifier.fontSize).toDouble(),
              min: 0,
              max: 2,
              divisions: 2,
              activeColor: AppColors.primary(context),
              label: switch (themeNotifier.fontSize) {
                AppFontSize.small => 'Küçük',
                AppFontSize.medium => 'Orta',
                AppFontSize.large => 'Büyük',
              },
              onChanged: (value) => themeNotifier.setFontSize(AppFontSize.values[value.round()]),
            ),
          ),
          ListTile(
            title: const Text('Dil'),
            trailing: DropdownButton<String>(
              value: themeNotifier.language,
              items: const [
                DropdownMenuItem(value: 'Türkçe', child: Text('Türkçe')),
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'العربية', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) themeNotifier.setLanguage(value);
              },
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Namaz Ayarları'),
          ListTile(
            title: const Text('Hesaplama Yöntemi'),
            trailing: DropdownButton<String>(
              value: _calcMethod,
              items: _calcMethods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (value) async {
                if (value == null) return;
                setState(() => _calcMethod = value);
                await HiveStorageService.setSetting(_keyCalcMethod, value);
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Ezan Bildirimleri'),
            value: _notificationsEnabled,
            activeThumbColor: AppColors.accent(context),
            onChanged: (value) async {
              setState(() => _notificationsEnabled = value);
              await HiveStorageService.setSetting(_keyNotifEnabled, value);
            },
          ),
          ListTile(
            title: const Text('Bildirim Zamanı'),
            trailing: DropdownButton<String>(
              value: _notifTiming,
              items: _notifTimings.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (value) async {
                if (value == null) return;
                setState(() => _notifTiming = value);
                await HiveStorageService.setSetting(_keyNotifTiming, value);
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active_outlined, color: AppColors.primary(context)),
            title: const Text('Vakit Bazlı Bildirim Zamanlayıcı'),
            subtitle: const Text('Her vakit için ayrı zaman ve ses ayarla', style: TextStyle(fontSize: 11.5)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationSchedulerScreen()),
            ),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Şehir Seçimi'),
          ListTile(
            title: Text('Seçili Şehir: ${selectedCity.name}'),
            trailing: TextButton(onPressed: _changeCity, child: const Text('Değiştir')),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Veri Yönetimi'),
          ListTile(
            leading: Icon(Icons.delete_outline_rounded, color: AppColors.primary(context)),
            title: const Text('Önbelleği Temizle'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              await HiveStorageService.setSetting(_keyCalcMethod, null);
              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Önbellek temizlendi.'), behavior: SnackBarBehavior.floating),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.ios_share_rounded, color: AppColors.primary(context)),
            title: const Text('Verileri CSV Olarak Dışa Aktar'),
            onTap: () async {
              final csv = await _buildExportCsv();
              if (!mounted) return;
              _copyToClipboardAndNotify(csv, 'CSV verisi panoya kopyalandı.');
            },
          ),
          ListTile(
            leading: Icon(Icons.sync_rounded, color: AppColors.primary(context)),
            title: const Text('Senkronizasyon Durumu'),
            subtitle: Text(_lastSync != null ? 'Son senkronizasyon: $_lastSync' : 'Henüz senkronize edilmedi'),
          ),
          const Divider(height: 32),
          _buildSectionTitle('Hakkında'),
          const ListTile(title: Text('Sürüm'), trailing: Text('1.0.0')),
          ListTile(
            title: const Text('Değişiklik Günlüğü'),
            onTap: () => _copyToClipboardAndNotify(
              'https://example.com/changelog',
              'Değişiklik günlüğü bağlantısı panoya kopyalandı.',
            ),
          ),
          ListTile(
            title: const Text('Geri Bildirim Gönder'),
            onTap: () => _copyToClipboardAndNotify(
              'destek@imanuygulamasi.com',
              'E-posta adresi panoya kopyalandı.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary(context)),
      ),
    );
  }
}
