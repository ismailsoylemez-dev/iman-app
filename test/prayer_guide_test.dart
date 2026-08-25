import 'package:flutter_test/flutter_test.dart';
import 'package:iman_uygulamasi/main.dart';
import 'package:iman_uygulamasi/models/prayer_guide_model.dart';

void main() {
  test('PrayerGuide model gender specific texts', () {
    expect(PrayerGuide.allPrayers.length, 6);
    final sabah = PrayerGuide.allPrayers.first;
    expect(sabah.name, 'Sabah Namazı');

    const iftitah = PrayerGuide.iftitahSabahSunnet;
    expect(iftitah.getDescription(Gender.erkek), contains('kulak memelerine'));
    expect(iftitah.getDescription(Gender.kadin), contains('omuz/göğüs'));

    const kiyam = PrayerGuide.kiyamGenel;
    expect(kiyam.getDescription(Gender.erkek), contains('göbeğin altında'));
    expect(kiyam.getDescription(Gender.kadin), contains('göğüs üzerinde'));

    const ruku = PrayerGuide.ruku;
    expect(ruku.getDescription(Gender.erkek), contains('90°'));
    expect(ruku.getDescription(Gender.kadin), contains('45-60°'));

    const secde = PrayerGuide.secde;
    expect(secde.getDescription(Gender.erkek), contains('Dirsekler yerden'));
    expect(secde.getDescription(Gender.kadin), contains('Dirsekler yere yapışık'));

    const kade = PrayerGuide.tahiyyat;
    expect(kade.getDescription(Gender.erkek), contains('İftiraş'));
    expect(kade.getDescription(Gender.kadin), contains('Teverrük'));
  });

  testWidgets('PrayerGuideScreen cinsiyet ve vakit değiştirme testi', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Namaz Rehberi sekmesine geç
    await tester.tap(find.text('Rehber'));
    await tester.pumpAndSettle();

    // Erkek ve Kadın butonları görünür
    expect(find.text('Erkek'), findsWidgets);
    expect(find.text('Kadın'), findsWidgets);
    expect(find.textContaining('kulak memesine'), findsWidgets);

    // Kadın butonuna dokun ve cinsiyeti değiştir
    await tester.tap(find.text('Kadın'));
    await tester.pumpAndSettle();

    // Kadın açıklamaları ve ipuçları görünmeli
    expect(find.textContaining('omuz/göğüs'), findsWidgets);

    // Özel Namazlar sekmesine geç
    await tester.tap(find.text('Özel Namazlar'));
    await tester.pumpAndSettle();
    expect(find.text('Cuma Namazı'), findsWidgets);
    expect(find.text('Cenaze Namazı'), findsWidgets);
    expect(find.text('Bayram Namazı (Ramazan & Kurban)'), findsWidgets);
  });
}
