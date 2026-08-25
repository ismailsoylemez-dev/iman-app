import 'dart:math';
import 'package:adhan_dart/adhan_dart.dart';
import '../models/city_model.dart';

class SpecialIslamicDay {
  final String name;
  final DateTime date;
  final String description;

  const SpecialIslamicDay({
    required this.name,
    required this.date,
    required this.description,
  });
}

class PrayerTimeService {
  static Map<String, DateTime> getPrayerTimes(City city, DateTime date) {
    final coordinates = Coordinates(city.latitude, city.longitude);
    final params = CalculationParameters(
      method: CalculationMethod.turkiye,
      fajrAngle: 18.0,
      ishaAngle: 17.0,
    );
    params.madhab = Madhab.hanafi;

    final prayerTimes = PrayerTimes(
      coordinates: coordinates,
      date: date,
      calculationParameters: params,
      precision: true,
    );

    return {
      'İmsak': prayerTimes.fajr.toLocal(),
      'Güneş': prayerTimes.sunrise.toLocal(),
      'Öğle': prayerTimes.dhuhr.toLocal(),
      'İkindi': prayerTimes.asr.toLocal(),
      'Akşam': prayerTimes.maghrib.toLocal(),
      'Yatsı': prayerTimes.isha.toLocal(),
    };
  }

  /// Koordinata en yakın ili 81 il arasından bulur
  static City findNearestCity(double latitude, double longitude) {
    City nearest = City.turkishCities.first;
    double minDistance = double.infinity;

    for (final city in City.turkishCities) {
      final dLat = (city.latitude - latitude);
      final dLng = (city.longitude - longitude);
      final distance = sqrt(dLat * dLat + dLng * dLng);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = city;
      }
    }

    return nearest;
  }

  /// Sıradaki vakti ve bir önceki vakti bulur
  static MapEntry<String, DateTime>? getNextPrayer(
    Map<String, DateTime> prayerTimes,
    DateTime now,
  ) {
    for (var entry in prayerTimes.entries) {
      if (entry.value.isAfter(now)) {
        return entry;
      }
    }
    return null;
  }

  /// İki vakit arasındaki ilerleme yüzdesini hesaplar (0.0 - 1.0)
  static double getPrayerProgress(Map<String, DateTime> prayerTimes, DateTime now) {
    final entries = prayerTimes.entries.toList();
    DateTime? prevTime;
    DateTime? nextTime;

    for (int i = 0; i < entries.length; i++) {
      if (entries[i].value.isAfter(now)) {
        nextTime = entries[i].value;
        prevTime = i > 0 ? entries[i - 1].value : entries[i].value.subtract(const Duration(hours: 8));
        break;
      }
    }

    if (nextTime == null) {
      prevTime = entries.last.value;
      nextTime = entries.first.value.add(const Duration(days: 1));
    }

    final total = nextTime.difference(prevTime!).inSeconds;
    final elapsed = now.difference(prevTime).inSeconds;

    if (total <= 0) return 0.0;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// Kıble açısı hesaplama
  static double getQiblaDirection(City city) {
    return Qibla.qibla(Coordinates(city.latitude, city.longitude));
  }

  /// Yaklaşık Hicri Takvim Karşılığı
  static String getHijriDate(DateTime gregorian) {
    final List<String> hijriMonths = [
      'Muharrem',
      'Safer',
      'Rebiülevvel',
      'Rebiülahir',
      'Cemaziyelevvel',
      'Cemaziyelahir',
      'Recep',
      'Şaban',
      'Ramazan',
      'Şevval',
      'Zilkade',
      'Zilhicce',
    ];

    final int jd = _gregorianToJulianDay(gregorian.year, gregorian.month, gregorian.day);
    final int l = jd - 1948440 + 10632;
    final int n = ((l - 1) / 10631).floor();
    final int l2 = l - 10631 * n + 354;
    final int j = (((10985 - l2) / 5316).floor()) * (((50 * l2) / 17719).floor()) +
        ((l2 / 5670).floor()) * (((43 * l2) / 15238).floor());
    final int l3 = l2 -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;
    final int m = ((24 * l3) / 709).floor();
    final int day = l3 - ((709 * m) / 24).floor();
    final int year = 30 * n + j - 30;

    final monthName = (m >= 1 && m <= 12) ? hijriMonths[m - 1] : hijriMonths[0];
    return '$day $monthName $year';
  }

  static int _gregorianToJulianDay(int year, int month, int day) {
    if (month < 3) {
      year -= 1;
      month += 12;
    }
    final int a = (year / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() + (30.6001 * (month + 1)).floor() + day + b - 1524;
  }

  /// 2026-2027 Yılları Yaklaşan Dini Günler Listesi
  static List<SpecialIslamicDay> getSpecialIslamicDays() {
    return [
      SpecialIslamicDay(
        name: 'Mevlid Kandili',
        date: DateTime(2026, 8, 25),
        description: 'Peygamber Efendimiz (s.a.v.)\'in dünyayı teşrif gecesi.',
      ),
      SpecialIslamicDay(
        name: 'Üç Ayların Başlangıcı',
        date: DateTime(2026, 12, 10),
        description: 'Recep, Şaban ve Ramazan aylarının başlangıcı.',
      ),
      SpecialIslamicDay(
        name: 'Regâib Kandili',
        date: DateTime(2026, 12, 17),
        description: 'İlahi lütuf ve ihsanların bol olduğu gece.',
      ),
      SpecialIslamicDay(
        name: 'Mi\'râc Kandili',
        date: DateTime(2027, 1, 5),
        description: 'Peygamberimiz\'in semaya yükselişi ve 5 vakit namaz müjdesi.',
      ),
      SpecialIslamicDay(
        name: 'Berât Kandili',
        date: DateTime(2027, 1, 23),
        description: 'Bağışlanma, af ve rızık takdiri gecesi.',
      ),
      SpecialIslamicDay(
        name: 'Ramazan-ı Şerif Başlangıcı',
        date: DateTime(2027, 2, 8),
        description: 'Oruç ve Kur\'an ayının ilk günü.',
      ),
      SpecialIslamicDay(
        name: 'Kadir Gecesi',
        date: DateTime(2027, 3, 5),
        description: 'Bin aydan daha hayırlı Kur\'an gecesi.',
      ),
      SpecialIslamicDay(
        name: 'Ramazan Bayramı (1. Gün)',
        date: DateTime(2027, 3, 10),
        description: 'Mübarek Ramazan Bayramı.',
      ),
      SpecialIslamicDay(
        name: 'Kurban Bayramı (1. Gün)',
        date: DateTime(2027, 5, 17),
        description: 'Mübarek Kurban Bayramı ve hac günleri.',
      ),
    ];
  }

  /// Sıradaki en yakın dini günü ve kalan gün sayısını döner
  static Map<String, dynamic> getNextSpecialDay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = getSpecialIslamicDays();

    for (final item in days) {
      final diff = item.date.difference(today).inDays;
      if (diff >= 0) {
        return {
          'day': item,
          'remainingDays': diff,
        };
      }
    }

    return {
      'day': days.first,
      'remainingDays': 0,
    };
  }
}
