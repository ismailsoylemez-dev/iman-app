import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zikir_model.dart';
import '../models/zikir_stats_model.dart';
import '../models/hive_adapters.dart';
import 'hive_storage_service.dart';

class ZikirStorageService {
  static const String _keyActiveZikirId = 'active_zikir_id';
  static const String _keyVibration = 'is_vibration_enabled';
  static const String _keyCustomZikirler = 'custom_zikirler_list';
  static const String _keyDailyStatsPrefix = 'stat_daily_dhikr_';
  static const String _keyAllTimeCount = 'zikir_all_time_count';

  static Future<String?> getActiveZikirId() async {
    final hiveActive = HiveStorageService.getSetting(_keyActiveZikirId);
    if (hiveActive != null && hiveActive is String) return hiveActive;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyActiveZikirId);
  }

  static Future<void> saveActiveZikirId(String id) async {
    await HiveStorageService.setSetting(_keyActiveZikirId, id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyActiveZikirId, id);
  }

  static Future<int> getCount(String zikirId) async {
    final record = HiveStorageService.getZikir(zikirId);
    if (record.count > 0) return record.count;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('count_$zikirId') ?? 0;
  }

  static Future<void> saveCount(String zikirId, int count) async {
    final record = HiveStorageService.getZikir(zikirId);
    await HiveStorageService.saveZikir(record.copyWith(count: count));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_$zikirId', count);
  }

  static Future<int> getLap(String zikirId) async {
    final record = HiveStorageService.getZikir(zikirId);
    if (record.lap > 0) return record.lap;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lap_$zikirId') ?? 0;
  }

  static Future<void> saveLap(String zikirId, int lap) async {
    final record = HiveStorageService.getZikir(zikirId);
    await HiveStorageService.saveZikir(record.copyWith(lap: lap));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lap_$zikirId', lap);
  }

  static Future<int> getTarget(String zikirId, int defaultTarget) async {
    final record = HiveStorageService.getZikir(zikirId, defaultTarget: defaultTarget);
    if (record.target != 33) return record.target;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('target_$zikirId') ?? defaultTarget;
  }

  static Future<void> saveTarget(String zikirId, int target) async {
    final record = HiveStorageService.getZikir(zikirId);
    await HiveStorageService.saveZikir(record.copyWith(target: target));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('target_$zikirId', target);
  }

  static Future<bool> isVibrationEnabled() async {
    final hiveVal = HiveStorageService.getSetting(_keyVibration);
    if (hiveVal != null && hiveVal is bool) return hiveVal;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyVibration) ?? true;
  }

  static Future<void> setVibrationEnabled(bool enabled) async {
    await HiveStorageService.setSetting(_keyVibration, enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVibration, enabled);
  }

  static Future<void> resetZikir(String zikirId, {bool resetLaps = true}) async {
    final record = HiveStorageService.getZikir(zikirId);
    await HiveStorageService.saveZikir(record.copyWith(
      count: 0,
      lap: resetLaps ? 0 : record.lap,
    ));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_$zikirId', 0);
    if (resetLaps) {
      await prefs.setInt('lap_$zikirId', 0);
    }
  }

  // --- Özel Zikir Yönetimi ---

  static Future<List<ZikirModel>> getCustomZikirler() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList(_keyCustomZikirler) ?? [];
    return stringList.map((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return ZikirModel.fromJson(map);
    }).toList();
  }

  static Future<void> saveCustomZikir(ZikirModel zikir) async {
    final prefs = await SharedPreferences.getInstance();
    final customList = await getCustomZikirler();
    customList.removeWhere((z) => z.id == zikir.id);
    customList.add(zikir);

    final stringList = customList.map((z) => jsonEncode(z.toJson())).toList();
    await prefs.setStringList(_keyCustomZikirler, stringList);

    await HiveStorageService.saveZikir(ZikirRecord(
      id: zikir.id,
      title: zikir.title,
      target: zikir.defaultTarget,
    ));
  }

  static Future<void> deleteCustomZikir(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final customList = await getCustomZikirler();
    customList.removeWhere((z) => z.id == id);

    final stringList = customList.map((z) => jsonEncode(z.toJson())).toList();
    await prefs.setStringList(_keyCustomZikirler, stringList);
    await resetZikir(id);
  }

  // --- Günlük ve Haftalık İstatistikler ---

  static String _getDayKey(DateTime date) => '$_keyDailyStatsPrefix${date.year}_${date.month}_${date.day}';

  static Future<void> recordDhikrIncrement() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDayKey(DateTime.now());
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  static Future<int> getTodayTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDayKey(DateTime.now());
    return prefs.getInt(key) ?? 0;
  }

  static Future<int> getWeeklyTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    int total = 0;
    for (int i = 0; i < 7; i++) {
      final d = now.subtract(Duration(days: i));
      final key = _getDayKey(d);
      total += prefs.getInt(key) ?? 0;
    }
    return total;
  }

  static Future<int> getMonthlyTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    int total = 0;
    for (int i = 0; i < 30; i++) {
      final d = now.subtract(Duration(days: i));
      final key = _getDayKey(d);
      total += prefs.getInt(key) ?? 0;
    }
    return total;
  }

  static Future<int> getAllTimeCount() async {
    final hiveVal = HiveStorageService.getSetting(_keyAllTimeCount);
    if (hiveVal != null && hiveVal is int) return hiveVal;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAllTimeCount) ?? 0;
  }

  /// Bir zikir sayacını artırır; günlük ve toplam istatistiklere işler
  static Future<void> incrementZikir(String zikirId) async {
    await recordDhikrIncrement();

    final allTime = await getAllTimeCount() + 1;
    await HiveStorageService.setSetting(_keyAllTimeCount, allTime);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAllTimeCount, allTime);
  }

  static Future<ZikirStats> getZikirStats() async {
    final thisWeek = await getWeeklyTotalCount();
    final thisMonth = await getMonthlyTotalCount();
    final allTime = await getAllTimeCount();
    return ZikirStats(thisWeek: thisWeek, thisMonth: thisMonth, allTime: allTime);
  }

  /// Son 7 günün günlük zikir sayılarını (eskiden yeniye) döner
  static Future<List<int>> getLast7DaysCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    return [
      for (int i = 6; i >= 0; i--) prefs.getInt(_getDayKey(now.subtract(Duration(days: i)))) ?? 0,
    ];
  }

  /// Bugünden geriye doğru kesintisiz aktivite gün sayısını döner
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final count = prefs.getInt(_getDayKey(now.subtract(Duration(days: i)))) ?? 0;
      if (count > 0) {
        streak++;
      } else if (i == 0) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }
}
