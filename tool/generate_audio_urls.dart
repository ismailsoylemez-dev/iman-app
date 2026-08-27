// Build-time script — NOT part of the app bundle.
//
// Faz 1: Kur'an ayetlerinin ses URL'lerini (islamic.network CDN, global ayet
// numarasıyla) alquran.cloud API'sinden çekip assets/data/quran_prayers.json
// içine yazar.
//
// Çalıştırma: dart run tool/generate_audio_urls.dart
import 'dart:convert';
import 'dart:io';

const Map<String, int> surahNameToNumber = {
  "A'raf": 7,
  'Araf': 7,
  'Al-i İmran': 3,
  'Ankebut': 29,
  'Bakara': 2,
  'Cuma': 62,
  'Enbiya': 21,
  "Fatır": 35,
  'Felak': 113,
  'Haşr': 59,
  'Hud': 11,
  'Kadr': 97,
  'Kasas': 28,
  'Kehf': 18,
  'Maide': 5,
  "Mü'minun": 23,
  'Nahl': 16,
  'Nas': 114,
  'Neml': 27,
  'Nuh': 71,
  "Ra'd": 13,
  'Sad': 38,
  'Saffat': 37,
  'Taha': 20,
  'Talak': 65,
  'Tevbe': 9,
  'Yusuf': 12,
  'Zuhruf': 43,
  'İbrahim': 14,
  'İhlas': 112,
  'İnşirah': 94,
  'İsra': 17,
  'Şuara': 26,
};

const String jsonPath = 'assets/data/quran_prayers.json';

String audioUrlFor(int globalAyahNo) =>
    'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalAyahNo.mp3';

List<int> parseAyahNumbers(String ayahNo) {
  final trimmed = ayahNo.trim();
  if (trimmed.isEmpty || trimmed == '-') return const [];
  if (trimmed.contains('-')) {
    final parts = trimmed.split('-');
    final start = int.tryParse(parts[0].trim());
    final end = int.tryParse(parts[1].trim());
    if (start == null || end == null) return const [];
    return [for (var i = start; i <= end; i++) i];
  }
  final single = int.tryParse(trimmed);
  return single == null ? const [] : [single];
}

/// surahName Quran kaynaklı bir kayıt mı? ("Hadis-i Şerif" ve "Siyer" hariç)
bool isQuranSource(String surahName) {
  if (surahName == 'Hadis-i Şerif' || surahName == 'Siyer') return false;
  return true;
}

List<String> splitSurahNames(String surahName) {
  return surahName.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
}

Future<void> main() async {
  final file = File(jsonPath);
  if (!file.existsSync()) {
    stderr.writeln('HATA: $jsonPath bulunamadı.');
    exit(1);
  }

  final raw = await file.readAsString();
  final List<dynamic> records = jsonDecode(raw) as List<dynamic>;

  // Gerekli sure numaralarını topla.
  final Set<int> neededSurahs = {};
  final List<Map<String, dynamic>> quranRecords = [];
  final List<Map<String, dynamic>> unmatchedNames = [];

  for (final r in records) {
    final rec = r as Map<String, dynamic>;
    final surahName = (rec['surahName'] as String?) ?? '';
    if (!isQuranSource(surahName)) continue;

    quranRecords.add(rec);
    for (final part in splitSurahNames(surahName)) {
      final num = surahNameToNumber[part];
      if (num == null) {
        unmatchedNames.add(rec);
      } else {
        neededSurahs.add(num);
      }
    }
  }

  stdout.writeln('Kur\'an kaynaklı kayıt sayısı: ${quranRecords.length}');
  stdout.writeln('Çekilecek sure sayısı: ${neededSurahs.length}');

  // Her sureyi tek seferde çek ve önbelleğe al: sureNo -> {numberInSurah -> globalNumber}
  final Map<int, Map<int, int>> surahAyahGlobalMap = {};
  final client = HttpClient();
  try {
    for (final surahNo in neededSurahs) {
      final uri = Uri.parse('https://api.alquran.cloud/v1/surah/$surahNo/ar.alafasy');
      const maxAttempts = 5;
      for (var attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
          final req = await client.getUrl(uri);
          final res = await req.close();
          final body = await res.transform(utf8.decoder).join();
          if (res.statusCode == 429) {
            final wait = Duration(milliseconds: 1000 * attempt);
            stderr.writeln('  Sure $surahNo: HTTP 429, ${wait.inMilliseconds}ms bekleyip tekrar denenecek (deneme $attempt/$maxAttempts)');
            await Future.delayed(wait);
            continue;
          }
          if (res.statusCode != 200) {
            stderr.writeln('UYARI: Sure $surahNo çekilemedi (HTTP ${res.statusCode})');
            break;
          }
          final decoded = jsonDecode(body) as Map<String, dynamic>;
          final data = decoded['data'] as Map<String, dynamic>;
          final ayahs = data['ayahs'] as List<dynamic>;
          final map = <int, int>{};
          for (final a in ayahs) {
            final ayah = a as Map<String, dynamic>;
            map[ayah['numberInSurah'] as int] = ayah['number'] as int;
          }
          surahAyahGlobalMap[surahNo] = map;
          stdout.writeln('  Sure $surahNo: ${map.length} ayet alındı.');
          break;
        } catch (e) {
          stderr.writeln('UYARI: Sure $surahNo çekilirken hata: $e');
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
  } finally {
    client.close();
  }

  // Kayıtları doldur.
  int filled = 0;
  final List<Map<String, dynamic>> unresolved = [];

  for (final rec in quranRecords) {
    final surahName = (rec['surahName'] as String?) ?? '';
    final ayahNoRaw = (rec['ayahNo'] as String?) ?? '-';
    final surahParts = splitSurahNames(surahName);

    final List<String> urls = [];

    if (surahParts.length > 1) {
      // "İhlas, Felak, Nas" gibi çoklu sure: her surenin AYNI ayahNo'suna karşılık gelen ayeti sırayla ekle.
      final ayahNums = parseAyahNumbers(ayahNoRaw);
      if (ayahNums.isEmpty) {
        unresolved.add(rec);
      } else {
        for (final part in surahParts) {
          final surahNo = surahNameToNumber[part];
          if (surahNo == null) {
            unresolved.add(rec);
            continue;
          }
          final ayahMap = surahAyahGlobalMap[surahNo];
          for (final n in ayahNums) {
            final global = ayahMap?[n];
            if (global != null) urls.add(audioUrlFor(global));
          }
        }
      }
    } else {
      final surahNo = surahParts.isEmpty ? null : surahNameToNumber[surahParts.first];
      final ayahNums = parseAyahNumbers(ayahNoRaw);
      if (surahNo == null || ayahNums.isEmpty) {
        unresolved.add(rec);
      } else {
        final ayahMap = surahAyahGlobalMap[surahNo];
        for (final n in ayahNums) {
          final global = ayahMap?[n];
          if (global != null) urls.add(audioUrlFor(global));
        }
      }
    }

    if (urls.isNotEmpty) {
      rec['audioUrl'] = urls.first;
      rec['audioUrls'] = urls;
      filled++;
    } else {
      unresolved.add(rec);
    }
  }

  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(records), encoding: utf8);

  stdout.writeln('\n--- SONUÇ ---');
  stdout.writeln('Doldurulan Kur\'an kaydı: $filled / ${quranRecords.length}');
  if (unresolved.isNotEmpty) {
    stdout.writeln('Eşleşmeyen kayıtlar (${unresolved.length}):');
    for (final r in unresolved) {
      stdout.writeln('  - ${r['id']}: surahName="${r['surahName']}" ayahNo="${r['ayahNo']}"');
    }
  }
  if (unmatchedNames.isNotEmpty) {
    stdout.writeln('Tanınmayan sure adları (${unmatchedNames.length}):');
    for (final r in unmatchedNames) {
      stdout.writeln('  - ${r['id']}: surahName="${r['surahName']}"');
    }
  }
}
