import 'package:flutter_test/flutter_test.dart';
import 'package:iman_uygulamasi/models/dua_model.dart';

void main() {
  group('DuaModel Tests', () {
    const jsonSample = {
      'id': 'test_01',
      'title': 'Test Duası',
      'surahName': 'Bakara',
      'ayahNo': '255',
      'transliteration': 'Allâhu lâ ilâhe illâ hû',
      'arabic': 'اَللّٰهُ لَٓا اِلٰهَ اِلَّا هُوَ',
      'meaning': 'Allah, O\'ndan başka ilah yoktur.',
      'context': 'Ayetel Kürsi fazileti.',
      'category': 'Korunma',
      'audioUrl': 'https://example.com/audio.mp3',
      'defaultTarget': 7,
    };

    test('fromJson creates a valid DuaModel', () {
      final model = DuaModel.fromJson(jsonSample);

      expect(model.id, 'test_01');
      expect(model.title, 'Test Duası');
      expect(model.surahName, 'Bakara');
      expect(model.ayahNo, '255');
      expect(model.category, 'Korunma');
      expect(model.defaultTarget, 7);
      expect(model.audioUrl, 'https://example.com/audio.mp3');
    });

    test('toJson produces correct map structure', () {
      final model = DuaModel.fromJson(jsonSample);
      final json = model.toJson();

      expect(json['id'], 'test_01');
      expect(json['title'], 'Test Duası');
      expect(json['defaultTarget'], 7);
      expect(json['category'], 'Korunma');
    });

    test('formattedShareText contains all key prayer components', () {
      final model = DuaModel.fromJson(jsonSample);
      final shareText = model.formattedShareText;

      expect(shareText, contains('Test Duası'));
      expect(shareText, contains('Bakara Suresi, 255. Ayet'));
      expect(shareText, contains('Allâhu lâ ilâhe illâ hû'));
      expect(shareText, contains('Ayetel Kürsi fazileti.'));
    });

    test('copyWith updates properties correctly', () {
      final model = DuaModel.fromJson(jsonSample);
      final updated = model.copyWith(title: 'Yeni Başlık', defaultTarget: 33);

      expect(updated.title, 'Yeni Başlık');
      expect(updated.defaultTarget, 33);
      expect(updated.id, 'test_01');
    });
  });
}
