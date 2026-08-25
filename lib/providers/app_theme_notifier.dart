import 'package:flutter/foundation.dart';
import '../services/hive_storage_service.dart';

enum AppFontSize { small, medium, large }

class AppThemeNotifier extends ChangeNotifier {
  static const String _keyDarkMode = 'app_dark_mode';
  static const String _keyFontSize = 'app_font_size';
  static const String _keyLanguage = 'app_language';

  bool _isDarkMode = false;
  AppFontSize _fontSize = AppFontSize.medium;
  String _language = 'Türkçe';

  bool get isDarkMode => _isDarkMode;
  AppFontSize get fontSize => _fontSize;
  String get language => _language;

  double get fontScale {
    switch (_fontSize) {
      case AppFontSize.small:
        return 0.9;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.2;
    }
  }

  AppThemeNotifier() {
    final darkVal = HiveStorageService.getSetting(_keyDarkMode);
    if (darkVal is bool) _isDarkMode = darkVal;

    final fontVal = HiveStorageService.getSetting(_keyFontSize);
    if (fontVal is String) {
      _fontSize = AppFontSize.values.firstWhere(
        (f) => f.name == fontVal,
        orElse: () => AppFontSize.medium,
      );
    }

    final langVal = HiveStorageService.getSetting(_keyLanguage);
    if (langVal is String) _language = langVal;
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await HiveStorageService.setSetting(_keyDarkMode, _isDarkMode);
    notifyListeners();
  }

  Future<void> setFontSize(AppFontSize size) async {
    _fontSize = size;
    await HiveStorageService.setSetting(_keyFontSize, size.name);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    await HiveStorageService.setSetting(_keyLanguage, language);
    notifyListeners();
  }
}
