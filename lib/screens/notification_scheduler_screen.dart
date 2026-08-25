import 'package:flutter/material.dart';
import '../services/hive_storage_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_exception.dart';

class NotificationSchedulerScreen extends StatefulWidget {
  const NotificationSchedulerScreen({super.key});

  @override
  State<NotificationSchedulerScreen> createState() => _NotificationSchedulerScreenState();
}

class _NotificationSchedulerScreenState extends State<NotificationSchedulerScreen> {
  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFD4AF37);

  static const List<String> _prayers = ['İmsak', 'Güneş', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
  static const List<String> _sounds = ['Sistem', 'Ezan', 'Zil'];

  final Map<String, bool> _prayerEnabled = {};
  final Map<String, int> _prayerOffsetMinutes = {};
  final Map<String, String> _prayerSound = {};
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    for (final prayer in _prayers) {
      final enabled = HiveStorageService.getSetting('notif_enabled_$prayer');
      final offset = HiveStorageService.getSetting('notif_offset_$prayer');
      final sound = HiveStorageService.getSetting('notif_sound_$prayer');
      _prayerEnabled[prayer] = (enabled is bool) ? enabled : true;
      _prayerOffsetMinutes[prayer] = (offset is int) ? offset : 0;
      _prayerSound[prayer] = (sound is String) ? sound : 'Ezan';
    }
    if (mounted) setState(() {});
  }

  Future<void> _saveEnabled(String prayer, bool value) async {
    setState(() => _prayerEnabled[prayer] = value);
    await HiveStorageService.setSetting('notif_enabled_$prayer', value);
  }

  Future<void> _saveOffset(String prayer, int value) async {
    setState(() => _prayerOffsetMinutes[prayer] = value);
    await HiveStorageService.setSetting('notif_offset_$prayer', value);
  }

  Future<void> _saveSound(String prayer, String value) async {
    setState(() => _prayerSound[prayer] = value);
    await HiveStorageService.setSetting('notif_sound_$prayer', value);
  }

  Future<void> _testNotification(String prayer) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isTesting = true);
    try {
      final testTime = DateTime.now().add(const Duration(seconds: 5));
      await NotificationService().scheduleAdhanNotification(prayer, testTime, 'Test');
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('$prayer için test bildirimi 5 saniye içinde gönderilecek.'), behavior: SnackBarBehavior.floating),
        );
      }
    } on AppException catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating));
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Test bildirimi gönderilemedi.'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bildirim Zamanlayıcı')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _prayers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final prayer = _prayers[index];
          final enabled = _prayerEnabled[prayer] ?? true;
          final offset = _prayerOffsetMinutes[prayer] ?? 0;
          final sound = _prayerSound[prayer] ?? 'Ezan';

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prayer,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.text(context)),
                      ),
                    ),
                    Switch(
                      value: enabled,
                      activeThumbColor: accentGold,
                      onChanged: (value) => _saveEnabled(prayer, value),
                    ),
                  ],
                ),
                if (enabled) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 6),
                      Text('Zamanlama:', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary(context))),
                      const Spacer(),
                      DropdownButton<int>(
                        value: offset,
                        items: const [
                          DropdownMenuItem(value: -10, child: Text('10 dk önce')),
                          DropdownMenuItem(value: -5, child: Text('5 dk önce')),
                          DropdownMenuItem(value: 0, child: Text('Vakit girdiğinde')),
                          DropdownMenuItem(value: 5, child: Text('5 dk sonra')),
                        ],
                        onChanged: (value) {
                          if (value != null) _saveOffset(prayer, value);
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.music_note_outlined, size: 16, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 6),
                      Text('Ses:', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary(context))),
                      const Spacer(),
                      DropdownButton<String>(
                        value: sound,
                        items: _sounds.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (value) {
                          if (value != null) _saveSound(prayer, value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _isTesting ? null : () => _testNotification(prayer),
                      icon: const Icon(Icons.notifications_active_outlined, size: 16, color: emeraldGreen),
                      label: const Text('Test Et', style: TextStyle(color: emeraldGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: emeraldGreen)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
