import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dua_model.dart';
import '../utils/app_exception.dart';
import '../utils/error_handler.dart';
import 'hive_storage_service.dart';

class DuaService {
  static const String _favoritesKey = 'dua_favorites_list';
  static const String _fontScaleKey = 'dua_font_scale_factor';
  static const String _counterPrefix = 'dua_counter_';
  static const String _readPrefix = 'dua_read_date_';

  List<DuaModel>? _cachedDuas;

  /// JSON dosyasından tüm duaları yükler
  Future<List<DuaModel>> getAllDuas() async {
    if (_cachedDuas != null && _cachedDuas!.isNotEmpty) {
      return _cachedDuas!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/quran_prayers.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      _cachedDuas = jsonList.map((item) => DuaModel.fromJson(item as Map<String, dynamic>)).toList();
      return _cachedDuas!;
    } on FormatException catch (e, stackTrace) {
      ErrorHandler.logError(e, stackTrace);
      throw DataException(message: 'JSON parse hatası', originalError: e);
    } catch (e, stackTrace) {
      ErrorHandler.logError(Exception(e.toString()), stackTrace);
      throw DataException(message: 'Dualar yüklenemedi', originalError: e);
    }
  }

  /// Favori dua kimliklerini getirir (Hive & SharedPreferences Hibrit)
  Future<Set<String>> getFavorites() async {
    final hiveFavs = HiveStorageService.getFavoriteIds();
    if (hiveFavs.isNotEmpty) {
      return hiveFavs.toSet();
    }

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_favoritesKey) ?? [];
    return list.toSet();
  }

  /// Duayı favorilere ekler veya çıkarır. Güncel favori durumunu döner.
  Future<bool> toggleFavorite(String id) async {
    final isFav = await HiveStorageService.toggleFavorite(id);

    // Yedek SharedPreferences kaydı
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (isFav) {
      if (!favorites.contains(id)) favorites.add(id);
    } else {
      favorites.remove(id);
    }
    await prefs.setStringList(_favoritesKey, favorites);

    return isFav;
  }

  /// Belirtilen tarihte okunan duaların ID setini getirir
  Future<Set<String>> getReadDuaIds(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '$_readPrefix${date.year}_${date.month}_${date.day}';
    final list = prefs.getStringList(dateKey) ?? [];
    return list.toSet();
  }

  /// Belirtilen dua için okundu durumunu tersine çevirir
  Future<bool> toggleReadStatus(String id, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = '$_readPrefix${date.year}_${date.month}_${date.day}';
    final list = prefs.getStringList(dateKey) ?? [];
    bool isRead;
    if (list.contains(id)) {
      list.remove(id);
      isRead = false;
    } else {
      list.add(id);
      isRead = true;
      await HiveStorageService.incrementDuaReadCount(id);
    }
    await prefs.setStringList(dateKey, list);
    return isRead;
  }

  /// Duaya özel vird / sayaç değerini getirir
  Future<int> getCounter(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_counterPrefix$id') ?? 0;
  }

  /// Duaya özel sayacı 1 artırır ve güncel değeri döner
  Future<int> incrementCounter(String id, int target) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('$_counterPrefix$id') ?? 0;
    final next = current + 1;
    await prefs.setInt('$_counterPrefix$id', next);
    await HiveStorageService.incrementDuaReadCount(id);
    return next;
  }

  /// Duaya özel sayacı sıfırlar
  Future<void> resetCounter(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_counterPrefix$id');
  }

  /// Kayıtlı font ölçekleme çarpanını getirir (varsayılan 1.0)
  Future<double> getFontScale() async {
    final hiveVal = HiveStorageService.getSetting(_fontScaleKey);
    if (hiveVal != null && hiveVal is double) {
      return hiveVal;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontScaleKey) ?? 1.0;
  }

  /// Font ölçekleme çarpanını kaydeder
  Future<void> setFontScale(double scale) async {
    await HiveStorageService.setSetting(_fontScaleKey, scale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
  }
}
