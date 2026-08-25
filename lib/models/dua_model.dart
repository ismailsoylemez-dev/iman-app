class DuaModel {
  final String id;
  final String title;
  final String surahName;
  final String ayahNo;
  final String transliteration;
  final String arabic;
  final String meaning;
  final String context;
  final String category;
  final String audioUrl;
  final int defaultTarget;
  final List<String> tags;
  final String source; // 'Quran' | 'Sunnah' | 'Tradition'

  const DuaModel({
    required this.id,
    required this.title,
    required this.surahName,
    required this.ayahNo,
    required this.transliteration,
    required this.arabic,
    required this.meaning,
    required this.context,
    required this.category,
    required this.audioUrl,
    required this.defaultTarget,
    this.tags = const [],
    this.source = 'Quran',
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      surahName: json['surahName'] as String? ?? '',
      ayahNo: json['ayahNo'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      context: json['context'] as String? ?? '',
      category: json['category'] as String? ?? '',
      audioUrl: json['audioUrl'] as String? ?? '',
      defaultTarget: (json['defaultTarget'] as num?)?.toInt() ?? 1,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      source: json['source'] as String? ?? 'Quran',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'surahName': surahName,
      'ayahNo': ayahNo,
      'transliteration': transliteration,
      'arabic': arabic,
      'meaning': meaning,
      'context': context,
      'category': category,
      'audioUrl': audioUrl,
      'defaultTarget': defaultTarget,
      'tags': tags,
      'source': source,
    };
  }

  DuaModel copyWith({
    String? id,
    String? title,
    String? surahName,
    String? ayahNo,
    String? transliteration,
    String? arabic,
    String? meaning,
    String? context,
    String? category,
    String? audioUrl,
    int? defaultTarget,
    List<String>? tags,
    String? source,
  }) {
    return DuaModel(
      id: id ?? this.id,
      title: title ?? this.title,
      surahName: surahName ?? this.surahName,
      ayahNo: ayahNo ?? this.ayahNo,
      transliteration: transliteration ?? this.transliteration,
      arabic: arabic ?? this.arabic,
      meaning: meaning ?? this.meaning,
      context: context ?? this.context,
      category: category ?? this.category,
      audioUrl: audioUrl ?? this.audioUrl,
      defaultTarget: defaultTarget ?? this.defaultTarget,
      tags: tags ?? this.tags,
      source: source ?? this.source,
    );
  }

  /// Paylaşım veya panoya kopyalama için biçimlendirilmiş metin
  String get formattedShareText {
    return '''✨ $title
📖 $surahName Suresi, $ayahNo. Ayet

📜 Arapça:
$arabic

🔤 Okunuşu:
$transliteration

🤍 Meali:
$meaning

💡 Fazileti:
$context

İman Uygulaması''';
  }
}
