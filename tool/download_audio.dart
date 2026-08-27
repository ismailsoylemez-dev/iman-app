// Build-time script — NOT part of the app bundle.
//
// Faz 3.1: Faz 1 ve Faz 2'de üretilen tüm audioUrl/audioUrls değerlerini
// indirir ve assets/audio/{quran,dua}/ altına yerleştirir. Ardından her
// kayda yerel dosya yolunu (audioAsset / audioAssets) ekler. audioUrl
// alanları SİLİNMEZ (internet yedeği olarak kalır).
//
// Çalıştırma: dart run tool/download_audio.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

const String jsonPath = 'assets/data/quran_prayers.json';
const String quranDir = 'assets/audio/quran';
const String duaDir = 'assets/audio/dua';

Future<bool> downloadIfMissing(HttpClient client, String url, String outPath) async {
  final file = File(outPath);
  if (await file.exists() && await file.length() > 0) return true;
  try {
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close();
    if (res.statusCode != 200) {
      stderr.writeln('  BAŞARISIZ (HTTP ${res.statusCode}): $url');
      await res.drain();
      return false;
    }
    final bytes = await res.fold<BytesBuilder>(BytesBuilder(), (b, d) => b..add(d));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes.takeBytes());
    return true;
  } catch (e) {
    stderr.writeln('  BAŞARISIZ ($e): $url');
    return false;
  }
}

/// Quran CDN URL'inden global ayet numarasını çıkarır: .../ar.alafasy/262.mp3 -> 262
int? quranNumberFrom(String url) {
  final m = RegExp(r'/(\d+)\.mp3$').firstMatch(url);
  return m == null ? null : int.parse(m.group(1)!);
}

/// archive.org URL'inden n{N}.mp3 numarasını çıkarır.
int? duaNumberFrom(String url) {
  final m = RegExp(r'/n(\d+)\.mp3$').firstMatch(url);
  return m == null ? null : int.parse(m.group(1)!);
}

Future<void> main() async {
  final file = File(jsonPath);
  final raw = await file.readAsString();
  final List<dynamic> records = jsonDecode(raw) as List<dynamic>;

  await Directory(quranDir).create(recursive: true);
  await Directory(duaDir).create(recursive: true);

  final client = HttpClient();
  int okCount = 0;
  int failCount = 0;
  int quranAssetsSet = 0;
  int duaAssetsSet = 0;

  try {
    for (final r in records) {
      final rec = r as Map<String, dynamic>;
      final surahName = (rec['surahName'] as String?) ?? '';
      final isQuran = surahName != 'Hadis-i Şerif' && surahName != 'Siyer';

      if (isQuran) {
        final urls = (rec['audioUrls'] as List<dynamic>?)?.cast<String>() ?? const [];
        if (urls.isEmpty) continue;
        final assets = <String>[];
        for (final url in urls) {
          final num = quranNumberFrom(url);
          if (num == null) continue;
          final outPath = '$quranDir/$num.mp3';
          stdout.writeln('İndiriliyor: $url');
          final ok = await downloadIfMissing(client, url, outPath);
          if (ok) {
            okCount++;
            assets.add(outPath);
          } else {
            failCount++;
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }
        if (assets.isNotEmpty) {
          rec['audioAsset'] = assets.first;
          rec['audioAssets'] = assets;
          quranAssetsSet++;
        }
      } else {
        final url = rec['audioUrl'] as String?;
        if (url == null || url.isEmpty) continue;
        final num = duaNumberFrom(url);
        if (num == null) continue;
        final outPath = '$duaDir/n$num.mp3';
        stdout.writeln('İndiriliyor: $url');
        final ok = await downloadIfMissing(client, url, outPath);
        if (ok) {
          okCount++;
          rec['audioAsset'] = outPath;
          duaAssetsSet++;
        } else {
          failCount++;
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  } finally {
    client.close();
  }

  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString(encoder.convert(records), encoding: utf8);

  stdout.writeln('\n--- SONUÇ (Faz 3.1) ---');
  stdout.writeln('Başarılı indirme: $okCount');
  stdout.writeln('Başarısız indirme: $failCount');
  stdout.writeln('audioAsset atanan Kur\'an kaydı: $quranAssetsSet');
  stdout.writeln('audioAsset atanan Sünnet kaydı: $duaAssetsSet');
}
