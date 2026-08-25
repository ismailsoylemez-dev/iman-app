class ZikirModel {
  final String id;
  final String title;
  final String arabic;
  final String transliteration;
  final String meaning;
  final int defaultTarget;
  final bool isCustom;

  const ZikirModel({
    required this.id,
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    this.defaultTarget = 33,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabic': arabic,
      'transliteration': transliteration,
      'meaning': meaning,
      'defaultTarget': defaultTarget,
      'isCustom': isCustom,
    };
  }

  factory ZikirModel.fromJson(Map<String, dynamic> json) {
    return ZikirModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      defaultTarget: (json['defaultTarget'] as num?)?.toInt() ?? 33,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  static const List<ZikirModel> defaultZikirler = [
    ZikirModel(
      id: 'tesbih',
      title: 'Tesbih (Sübhanallah)',
      arabic: 'سُبْحَانَ اللهِ',
      transliteration: 'Sübhânallâh',
      meaning: 'Allah her türlü eksiklik ve noksanlıktan uzaktır.',
      defaultTarget: 33,
    ),
    ZikirModel(
      id: 'tahmid',
      title: 'Tahmîd (Elhamdülillah)',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'El-hamdü lillâh',
      meaning: 'Hamd ve övgü yalnızca Allah\'a aittir.',
      defaultTarget: 33,
    ),
    ZikirModel(
      id: 'tekbir',
      title: 'Tekbîr (Allahu Ekber)',
      arabic: 'اللهُ أَكْبَرُ',
      transliteration: 'Allâhu Ekber',
      meaning: 'Allah en büyüktür, her şeyden yücedir.',
      defaultTarget: 33,
    ),
    ZikirModel(
      id: 'tehlil',
      title: 'Tehlîl (Lâ ilâhe illallâh)',
      arabic: 'لَا إِلٰهَ إِلَّا اللهُ',
      transliteration: 'Lâ ilâhe illallâh',
      meaning: 'Allah\'tan başka hiçbir ilâh yoktur.',
      defaultTarget: 100,
    ),
    ZikirModel(
      id: 'istigfar',
      title: 'İstiğfâr (Estağfirullah)',
      arabic: 'أَسْتَغْفِرُ اللهَ الْعَظِيمَ',
      transliteration: 'Estağfirullâhe\'l-Azîm',
      meaning: 'Yüce Allah\'tan bağışlanma ve mağfiret dilerim.',
      defaultTarget: 100,
    ),
    ZikirModel(
      id: 'salavat',
      title: 'Salavât-ı Şerîfe',
      arabic: 'اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ',
      transliteration: 'Allâhümme salli alâ seyyidinâ Muhammed',
      meaning: 'Allah\'ım! Efendimiz Hz. Muhammed\'e ve ehline salât ve selâm eyle.',
      defaultTarget: 100,
    ),
    ZikirModel(
      id: 'havkale',
      title: 'Havkale (Lâ havle)',
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللهِ الْعَلِيِّ الْعَظِيمِ',
      transliteration: 'Lâ havle ve lâ kuvvete illâ billâhi\'l-Aliyyi\'l-Azîm',
      meaning: 'Güç ve kuvvet ancak pek yüce ve ulu olan Allah\'ındır.',
      defaultTarget: 33,
    ),
    ZikirModel(
      id: 'subhanallahi_ve_bihamdihi',
      title: 'Tesbîhât-ı Câmia',
      arabic: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ سُبْحَانَ اللهِ الْعَظِيمِ',
      transliteration: 'Sübhânallâhi ve bi-hamdihî, Sübhânallâhi\'l-Azîm',
      meaning: 'Allah\'ı hamdiyle tesbih ederim, yüce Allah\'ı noksanlıklardan tenzih ederim.',
      defaultTarget: 100,
    ),
    ZikirModel(
      id: 'hasbiyallah',
      title: 'Hasbiyallâh',
      arabic: 'حَسْبُنَا اللهُ وَنِعْمَ الْوَكِيلُ',
      transliteration: 'Hasbünallâhu ve ni\'me\'l-vekîl',
      meaning: 'Allah bize yeter, O ne güzel vekildir.',
      defaultTarget: 33,
    ),
  ];
}
