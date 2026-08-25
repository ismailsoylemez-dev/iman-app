import 'package:hive/hive.dart';

/// 1. Dua Favorileri Modeli
class DuaFavorite {
  final String id;
  final DateTime savedAt;
  final int readCount;

  DuaFavorite({
    required this.id,
    required this.savedAt,
    this.readCount = 0,
  });

  DuaFavorite copyWith({
    String? id,
    DateTime? savedAt,
    int? readCount,
  }) {
    return DuaFavorite(
      id: id ?? this.id,
      savedAt: savedAt ?? this.savedAt,
      readCount: readCount ?? this.readCount,
    );
  }
}

class DuaFavoriteAdapter extends TypeAdapter<DuaFavorite> {
  @override
  final int typeId = 0;

  @override
  DuaFavorite read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DuaFavorite(
      id: fields[0] as String,
      savedAt: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      readCount: fields[2] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, DuaFavorite obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.savedAt.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.readCount);
  }
}

/// 2. Zikir ve Hedef Kaydı Modeli
class ZikirRecord {
  final String id;
  final String title;
  final int count;
  final int target;
  final int lap;
  final DateTime lastUpdated;

  ZikirRecord({
    required this.id,
    required this.title,
    this.count = 0,
    this.target = 33,
    this.lap = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  ZikirRecord copyWith({
    String? id,
    String? title,
    int? count,
    int? target,
    int? lap,
    DateTime? lastUpdated,
  }) {
    return ZikirRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      count: count ?? this.count,
      target: target ?? this.target,
      lap: lap ?? this.lap,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

class ZikirRecordAdapter extends TypeAdapter<ZikirRecord> {
  @override
  final int typeId = 1;

  @override
  ZikirRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ZikirRecord(
      id: fields[0] as String,
      title: fields[1] as String,
      count: fields[2] as int,
      target: fields[3] as int,
      lap: fields[4] as int,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
    );
  }

  @override
  void write(BinaryWriter writer, ZikirRecord obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.target)
      ..writeByte(4)
      ..write(obj.lap)
      ..writeByte(5)
      ..write(obj.lastUpdated.millisecondsSinceEpoch);
  }
}

/// 3. Kaza Namazı Borç Modeli
class KazaRecord {
  final String vakit;
  final int debtCount;
  final DateTime lastUpdated;

  KazaRecord({
    required this.vakit,
    this.debtCount = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();
}

class KazaRecordAdapter extends TypeAdapter<KazaRecord> {
  @override
  final int typeId = 2;

  @override
  KazaRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KazaRecord(
      vakit: fields[0] as String,
      debtCount: fields[1] as int,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(fields[2] as int),
    );
  }

  @override
  void write(BinaryWriter writer, KazaRecord obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.vakit)
      ..writeByte(1)
      ..write(obj.debtCount)
      ..writeByte(2)
      ..write(obj.lastUpdated.millisecondsSinceEpoch);
  }
}
