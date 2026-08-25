import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive_adapters.dart';

class HiveStorageService {
  static const String boxDuaFavorites = 'dua_favorites';
  static const String boxZikirRecords = 'zikir_records';
  static const String boxKazaRecords = 'kaza_records';
  static const String boxAppSettings = 'app_settings';

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await Hive.initFlutter();

      // TypeAdapter Kayıtları
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DuaFavoriteAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ZikirRecordAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(KazaRecordAdapter());
      }

      // Kutuları Aç
      await Future.wait([
        Hive.openBox<DuaFavorite>(boxDuaFavorites),
        Hive.openBox<ZikirRecord>(boxZikirRecords),
        Hive.openBox<KazaRecord>(boxKazaRecords),
        Hive.openBox(boxAppSettings),
      ]);

      _isInitialized = true;
    } catch (e) {
      debugPrint('Hive başlatma hatası: $e');
    }
  }

  // --- 1. Dua Favorileri İşlemleri ---

  static Box<DuaFavorite>? get _favoritesBox =>
      Hive.isBoxOpen(boxDuaFavorites) ? Hive.box<DuaFavorite>(boxDuaFavorites) : null;

  static Future<bool> toggleFavorite(String duaId) async {
    final box = _favoritesBox;
    if (box == null) return false;

    if (box.containsKey(duaId)) {
      await box.delete(duaId);
      return false;
    } else {
      await box.put(
        duaId,
        DuaFavorite(id: duaId, savedAt: DateTime.now()),
      );
      return true;
    }
  }

  static bool isFavorite(String duaId) {
    return _favoritesBox?.containsKey(duaId) ?? false;
  }

  static List<String> getFavoriteIds() {
    return _favoritesBox?.keys.cast<String>().toList() ?? [];
  }

  static Future<void> incrementDuaReadCount(String duaId) async {
    final box = _favoritesBox;
    if (box == null) return;

    final existing = box.get(duaId);
    if (existing != null) {
      await box.put(duaId, existing.copyWith(readCount: existing.readCount + 1));
    } else {
      await box.put(duaId, DuaFavorite(id: duaId, savedAt: DateTime.now(), readCount: 1));
    }
  }

  // --- 2. Zikir ve Hedef İşlemleri ---

  static Box<ZikirRecord>? get _zikirBox =>
      Hive.isBoxOpen(boxZikirRecords) ? Hive.box<ZikirRecord>(boxZikirRecords) : null;

  static ZikirRecord getZikir(String id, {String title = '', int defaultTarget = 33}) {
    final box = _zikirBox;
    if (box != null && box.containsKey(id)) {
      return box.get(id)!;
    }
    return ZikirRecord(id: id, title: title, target: defaultTarget);
  }

  static Future<void> saveZikir(ZikirRecord record) async {
    final box = _zikirBox;
    if (box != null) {
      await box.put(record.id, record);
    }
  }

  static List<ZikirRecord> getAllZikirRecords() {
    return _zikirBox?.values.toList() ?? [];
  }

  // --- 3. Kaza Borçları İşlemleri ---

  static Box<KazaRecord>? get _kazaBox =>
      Hive.isBoxOpen(boxKazaRecords) ? Hive.box<KazaRecord>(boxKazaRecords) : null;

  static Map<String, int> getAllKazaDebts() {
    final box = _kazaBox;
    final Map<String, int> result = {};
    if (box != null) {
      for (var record in box.values) {
        result[record.vakit] = record.debtCount;
      }
    }
    return result;
  }

  static int getKazaDebt(String vakit) {
    return _kazaBox?.get(vakit)?.debtCount ?? 0;
  }

  static Future<void> setKazaDebt(String vakit, int count) async {
    final box = _kazaBox;
    if (box != null) {
      await box.put(
        vakit,
        KazaRecord(vakit: vakit, debtCount: count.clamp(0, 999999)),
      );
    }
  }

  static Future<int> changeKazaDebt(String vakit, int delta) async {
    final box = _kazaBox;
    if (box != null) {
      final current = getKazaDebt(vakit);
      final next = (current + delta).clamp(0, 999999);
      await box.put(
        vakit,
        KazaRecord(vakit: vakit, debtCount: next),
      );
      return next;
    }
    return 0;
  }

  // --- 4. Genel Uygulama Ayarları ---

  static Box? get _settingsBox =>
      Hive.isBoxOpen(boxAppSettings) ? Hive.box(boxAppSettings) : null;

  static Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue) ?? defaultValue;
  }
}
