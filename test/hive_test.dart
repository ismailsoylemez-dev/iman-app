import 'package:flutter_test/flutter_test.dart';
import 'package:iman_uygulamasi/models/hive_adapters.dart';

void main() {
  group('Hive Adapters & Models Tests', () {
    test('DuaFavorite model and copyWith', () {
      final now = DateTime.now();
      final fav = DuaFavorite(id: 'fatiha_1_7', savedAt: now, readCount: 5);

      expect(fav.id, 'fatiha_1_7');
      expect(fav.readCount, 5);

      final updated = fav.copyWith(readCount: 6);
      expect(updated.readCount, 6);
      expect(updated.id, 'fatiha_1_7');
    });

    test('ZikirRecord model and copyWith', () {
      final record = ZikirRecord(id: 'tesbih', title: 'Tesbih', count: 33, target: 99, lap: 1);

      expect(record.id, 'tesbih');
      expect(record.count, 33);
      expect(record.target, 99);
      expect(record.lap, 1);

      final updated = record.copyWith(count: 34);
      expect(updated.count, 34);
    });

    test('KazaRecord model test', () {
      final kaza = KazaRecord(vakit: 'Sabah', debtCount: 12);
      expect(kaza.vakit, 'Sabah');
      expect(kaza.debtCount, 12);
    });
  });
}
