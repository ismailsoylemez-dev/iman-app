import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const String _channelId = 'adhan_channel';
  static const String _channelName = 'Ezan Bildirimleri';

  /// Bildirim eklentisini Android ve iOS için başlatır
  Future<void> init() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();
    // Uygulama yalnızca Türkiye illerini desteklediği için sabit saat dilimi kullanılır
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);

    _isInitialized = true;
  }

  /// Belirtilen vakit için ezan bildirimi zamanlar, oluşturulan bildirim id'sini döner
  Future<int> scheduleAdhanNotification(String prayerName, DateTime dateTime, String cityName) async {
    if (!_isInitialized) {
      await init();
    }

    final scheduledDate = tz.TZDateTime.from(dateTime, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return -1;
    }

    final id = dateTime.millisecondsSinceEpoch.remainder(1 << 31);

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Namaz vakti girdiğinde gönderilen ezan bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      '$prayerName Vakti Girdi',
      '$cityName için $prayerName ezanı okunuyor.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    return id;
  }

  /// Zamanlanmış bir bildirimi iptal eder
  Future<void> cancelNotification(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  /// Verilen asset yolundaki ezan sesini anında çalar
  Future<void> playAdhanSound(String soundPath) async {
    final player = AudioPlayer();
    try {
      await player.play(AssetSource(soundPath));
      await player.onPlayerComplete.first;
    } catch (e) {
      debugPrint('Ezan sesi çalınamadı: $e');
    } finally {
      await player.dispose();
    }
  }

  /// Bildirim izninin verilip verilmediğini kontrol eder
  Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
