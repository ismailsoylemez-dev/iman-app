import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/city_model.dart';
import '../models/dua_model.dart';
import 'hive_storage_service.dart';
import 'prayer_time_service.dart';
import 'dua_service.dart';

class OfflineSyncService {
  OfflineSyncService._internal();
  static final OfflineSyncService _instance = OfflineSyncService._internal();
  factory OfflineSyncService() => _instance;

  static const String _keyPrayerTimesCache = 'offline_prayer_times_cache';
  static const String _keyLastSync = 'offline_last_sync';

  final DuaService _duaService = DuaService();

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  /// Bir sonraki güne ait namaz vakitlerini önceden hesaplayıp Hive'a kaydeder
  Future<void> syncPrayerTimes(List<City> cities) async {
    await _withRetry(() async {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final cache = <String, Map<String, String>>{};

      for (final city in cities) {
        final times = PrayerTimeService.getPrayerTimes(city, tomorrow);
        cache[city.plateCode.toString()] = times.map(
          (key, value) => MapEntry(key, value.toIso8601String()),
        );
      }

      await HiveStorageService.setSetting(_keyPrayerTimesCache, cache);
      await HiveStorageService.setSetting(_keyLastSync, DateTime.now().toIso8601String());
    });
  }

  /// Duaları yerelde önbelleğe alır; asıl kaynak assets/data/quran_prayers.json'dur
  Future<List<DuaModel>> syncDuas() async {
    return await _withRetry(() => _duaService.getAllDuas());
  }

  DateTime? getLastSyncTime() {
    final value = HiveStorageService.getSetting(_keyLastSync);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Uygulama açılışında offline durum için önbellekleri tazeler
  Future<void> syncOnStartup() async {
    if (!await isOnline()) return;
    await _withRetry(() => _duaService.getAllDuas());
  }

  Future<T> _withRetry<T>(Future<T> Function() action, {int maxAttempts = 3}) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        return await action();
      } catch (e) {
        if (attempt >= maxAttempts) rethrow;
        final backoff = Duration(seconds: 1 << attempt);
        debugPrint('Senkronizasyon denemesi $attempt başarısız, $backoff sonra tekrar denenecek: $e');
        await Future.delayed(backoff);
      }
    }
  }
}
