import 'package:flutter/foundation.dart';
import '../models/city_model.dart';
import '../services/prayer_time_service.dart';
import '../services/hive_storage_service.dart';

class PrayerTimesNotifier extends ChangeNotifier {
  static const String _cityPlateKey = 'selected_city_plate';

  City _selectedCity = City.turkishCities.firstWhere(
    (c) => c.name == 'İstanbul',
    orElse: () => City.turkishCities.first,
  );
  Map<String, DateTime> _prayerTimes = {};
  MapEntry<String, DateTime>? _nextPrayer;
  double _qiblaAngle = 0.0;
  String _hijriDate = '';

  City get selectedCity => _selectedCity;
  Map<String, DateTime> get prayerTimes => _prayerTimes;
  MapEntry<String, DateTime>? get nextPrayer => _nextPrayer;
  double get qiblaAngle => _qiblaAngle;
  String get hijriDate => _hijriDate;

  PrayerTimesNotifier() {
    final savedPlate = HiveStorageService.getSetting(_cityPlateKey);
    if (savedPlate is int) {
      _selectedCity = City.turkishCities.firstWhere(
        (c) => c.plateCode == savedPlate,
        orElse: () => _selectedCity,
      );
    }

    // İlk kare boş gelmesin diye vakitler senkron olarak da hesaplanır
    final now = DateTime.now();
    _prayerTimes = PrayerTimeService.getPrayerTimes(_selectedCity, now);
    _nextPrayer = PrayerTimeService.getNextPrayer(_prayerTimes, now);
    _hijriDate = PrayerTimeService.getHijriDate(now);
    _qiblaAngle = PrayerTimeService.getQiblaDirection(_selectedCity);
  }

  /// Seçilen ili kaydeder, o ile ait vakitleri ve kıbleyi günceller
  Future<void> updateCity(City city) async {
    _selectedCity = city;
    await HiveStorageService.setSetting(_cityPlateKey, city.plateCode);
    await fetchPrayerTimes();
    await updateQibla();
  }

  /// Seçili il için güncel namaz vakitlerini ve sıradaki vakti hesaplar
  Future<void> fetchPrayerTimes() async {
    final now = DateTime.now();
    _prayerTimes = PrayerTimeService.getPrayerTimes(_selectedCity, now);
    _nextPrayer = PrayerTimeService.getNextPrayer(_prayerTimes, now);
    _hijriDate = PrayerTimeService.getHijriDate(now);
    notifyListeners();
  }

  /// Seçili il için kıble açısını günceller
  Future<void> updateQibla() async {
    _qiblaAngle = PrayerTimeService.getQiblaDirection(_selectedCity);
    notifyListeners();
  }
}
