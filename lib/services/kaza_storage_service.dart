import 'package:shared_preferences/shared_preferences.dart';
import 'hive_storage_service.dart';

class KazaStorageService {
  static const String _prefix = 'kaza_debt_';

  static const List<String> kazaVakitleri = [
    'Sabah',
    'Öğle',
    'İkindi',
    'Akşam',
    'Yatsı',
    'Vitir',
  ];

  static Future<Map<String, int>> getAllKazaDebts() async {
    final hiveDebts = HiveStorageService.getAllKazaDebts();
    if (hiveDebts.isNotEmpty) {
      // Ensure all 6 vakit exists
      for (final v in kazaVakitleri) {
        hiveDebts.putIfAbsent(v, () => 0);
      }
      return hiveDebts;
    }

    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> debts = {};
    for (final v in kazaVakitleri) {
      debts[v] = prefs.getInt('$_prefix$v') ?? 0;
    }
    return debts;
  }

  static Future<int> getKazaDebt(String vakit) async {
    final hiveVal = HiveStorageService.getKazaDebt(vakit);
    if (hiveVal > 0) return hiveVal;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$vakit') ?? 0;
  }

  static Future<void> setKazaDebt(String vakit, int count) async {
    final safeCount = count.clamp(0, 999999);
    await HiveStorageService.setKazaDebt(vakit, safeCount);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$vakit', safeCount);
  }

  static Future<int> changeKazaDebt(String vakit, int delta) async {
    final current = await getKazaDebt(vakit);
    final next = (current + delta).clamp(0, 999999);

    await HiveStorageService.setKazaDebt(vakit, next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$vakit', next);

    return next;
  }

  static Future<void> resetAllKazaDebts() async {
    for (final v in kazaVakitleri) {
      await HiveStorageService.setKazaDebt(v, 0);
    }
    final prefs = await SharedPreferences.getInstance();
    for (final v in kazaVakitleri) {
      await prefs.remove('$_prefix$v');
    }
  }
}
