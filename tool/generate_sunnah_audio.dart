// Build-time script — NOT part of the app bundle.
//
// Faz 2: Sünnet (Hadis-i Şerif) dualarını Hisnul Muslim ses arşiviyle
// (archive.org/details/HisnulMuslimAudio_201510) Arapça metin benzerliği
// üzerinden eşleştirir. Eşik altında kalanlara URL YAZMAZ.
//
// Çalıştırma: dart run tool/generate_sunnah_audio.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const String jsonPath = 'assets/data/quran_prayers.json';
const String husnEnUrl =
    'https://raw.githubusercontent.com/wafaaelmaandy/Hisn-Muslim-Json/master/husn_en.json';
const String archiveMetadataUrl = 'https://archive.org/metadata/HisnulMuslimAudio_201510';
const double matchThreshold = 0.75;

/// Arapça metni normalize eder: harekeler, tatweel, noktalama kaldırılır;
/// elif varyantları ve ta marbuta sadeleştirilir.
String normalizeArabic(String input) {
  var s = input;
  // Harekeler (U+064B–U+0652) ve ilgili Kur'an işaretleri (U+0610-U+061A, U+06D6-U+06ED, U+0670)
  s = s.replaceAll(RegExp(r'[ؐ-ًؚ-ٰٟۖ-ۭ]'), '');
  // Tatweel
  s = s.replaceAll('ـ', '');
  // Elif varyantları
  s = s.replaceAll(RegExp('[أإآٱ]'), 'ا');
  // Ta marbuta
  s = s.replaceAll('ة', 'ه');
  // Noktalama / parantez / yıldız / Kur'an ayet işaretleri / rakamlar
  s = s.replaceAll(RegExp(r'[^ء-ي\s]'), ' ');
  // Boşlukları sadeleştir
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

Set<String> charBigrams(String s) {
  final clean = s.replaceAll(' ', '');
  if (clean.length < 2) return {clean};
  final grams = <String>{};
  for (var i = 0; i < clean.length - 1; i++) {
    grams.add(clean.substring(i, i + 2));
  }
  return grams;
}

double jaccard(Set<String> a, Set<String> b) {
  if (a.isEmpty && b.isEmpty) return 0;
  final intersection = a.intersection(b).length;
  final union = a.union(b).length;
  if (union == 0) return 0;
  return intersection / union;
}

/// Örtüşme (containment) katsayısı: kısa metnin büyük ölçüde uzun metnin
/// içinde geçip geçmediğini ölçer. Uygulamadaki dua metinleri çoğu zaman
/// Hisnul Muslim referansının kısaltılmış/başlangıç kısmı olduğundan,
/// simetrik Jaccard'a göre bu ölçüt daha güvenilir eşleşme verir.
double overlapCoefficient(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) return 0;
  final intersection = a.intersection(b).length;
  final minSize = math.min(a.length, b.length);
  if (minSize == 0) return 0;
  return intersection / minSize;
}

class HusnEntry {
  final int audioNum;
  final String arabicNormalized;
  HusnEntry(this.audioNum, this.arabicNormalized);
}

Future<String> httpGet(String url) async {
  final client = HttpClient();
  try {
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close();
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode} for $url');
    }
    return await res.transform(utf8.decoder).join();
  } finally {
    client.close();
  }
}

Future<void> main() async {
  stdout.writeln('Hisnul Muslim referans verisi indiriliyor...');
  final husnRaw = (await httpGet(husnEnUrl)).replaceFirst('﻿', '');
  final husnDecoded = jsonDecode(husnRaw) as Map<String, dynamic>;
  final sections = husnDecoded['English'] as List<dynamic>;

  final husnEntries = <HusnEntry>[];
  for (final s in sections) {
    final texts = (s as Map<String, dynamic>)['TEXT'] as List<dynamic>?;
    if (texts == null) continue;
    for (final t in texts) {
      final entry = t as Map<String, dynamic>;
      final arabic = entry['ARABIC_TEXT'] as String? ?? '';
      final audio = entry['AUDIO'] as String? ?? '';
      final m = RegExp(r'(\d+)\.mp3').firstMatch(audio);
      if (m == null || arabic.isEmpty) continue;
      husnEntries.add(HusnEntry(int.parse(m.group(1)!), normalizeArabic(arabic)));
    }
  }
  stdout.writeln('Referans dua sayısı: ${husnEntries.length}');

  stdout.writeln('archive.org dosya listesi alınıyor...');
  final metaRaw = await httpGet(archiveMetadataUrl);
  final meta = jsonDecode(metaRaw) as Map<String, dynamic>;
  final files = meta['files'] as List<dynamic>;
  final availableNums = <int>{};
  for (final f in files) {
    final name = (f as Map<String, dynamic>)['name'] as String? ?? '';
    final m = RegExp(r'^n(\d+)\.mp3$').firstMatch(name);
    if (m != null) availableNums.add(int.parse(m.group(1)!));
  }
  stdout.writeln('archive.org üzerinde bulunan mp3 sayısı: ${availableNums.length}');

  // Sadece gerçekten indirilebilir referans kayıtlarını kullan.
  final usableHusn = husnEntries.where((e) => availableNums.contains(e.audioNum)).toList();
  stdout.writeln('İndirilebilir referans dua sayısı: ${usableHusn.length}');

  final file = File(jsonPath);
  final raw = await file.readAsString();
  final List<dynamic> records = jsonDecode(raw) as List<dynamic>;

  final sunnahRecords = records.where((r) {
    final rec = r as Map<String, dynamic>;
    final surahName = (rec['surahName'] as String?) ?? '';
    return surahName == 'Hadis-i Şerif' || surahName == 'Siyer';
  }).toList();

  stdout.writeln('Sünnet kaynaklı kayıt sayısı: ${sunnahRecords.length}');

  // Önceki çalıştırmalardan kalan eşleşmeleri temizle; yalnızca bu çalıştırmanın
  // ürettiği eşleşmeler kalıcı olsun.
  for (final r in sunnahRecords) {
    (r as Map<String, dynamic>)['audioUrl'] = null;
  }

  final husnBigrams = usableHusn.map((e) => charBigrams(e.arabicNormalized)).toList();

  int matched = 0;
  final unmatched = <Map<String, dynamic>>[];

  for (final r in sunnahRecords) {
    final rec = r as Map<String, dynamic>;
    final arabic = (rec['arabic'] as String?) ?? (rec['arabicText'] as String?) ?? '';
    final normalized = normalizeArabic(arabic);
    final targetBigrams = charBigrams(normalized);

    double bestScore = 0;
    double bestJaccard = 0;
    int bestIdx = -1;
    for (var i = 0; i < usableHusn.length; i++) {
      final overlap = overlapCoefficient(targetBigrams, husnBigrams[i]);
      if (overlap > bestScore) {
        bestScore = overlap;
        bestJaccard = jaccard(targetBigrams, husnBigrams[i]);
        bestIdx = i;
      }
    }

    // Kısa/tesadüfi eşleşmeleri elemek için Jaccard tabanlı bir alt sınır da uygulanır.
    if (bestIdx >= 0 && bestScore >= matchThreshold && bestJaccard >= 0.25) {
      final audioNum = usableHusn[bestIdx].audioNum;
      rec['audioUrl'] = 'https://archive.org/download/HisnulMuslimAudio_201510/n$audioNum.mp3';
      matched++;
    } else {
      unmatched.add({
        'id': rec['id'],
        'title': rec['title'],
        'bestScore': bestScore.toStringAsFixed(2),
        'bestJaccard': bestJaccard.toStringAsFixed(2),
        'targetLen': targetBigrams.length,
        'refLen': bestIdx >= 0 ? husnBigrams[bestIdx].length : -1,
      });
    }
  }

  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(records), encoding: utf8);

  stdout.writeln('\n--- SONUÇ (Faz 2) ---');
  stdout.writeln('Eşleşen: $matched / ${sunnahRecords.length}');
  stdout.writeln('Eşleşmeyen (${unmatched.length}):');
  for (final u in unmatched) {
    stdout.writeln(
        '  - ${u['id']}: "${u['title']}" (overlap: ${u['bestScore']}, jaccard: ${u['bestJaccard']}, hedefLen: ${u['targetLen']}, refLen: ${u['refLen']})');
  }
}
