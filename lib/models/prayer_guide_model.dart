enum Gender {
  erkek('Erkek', 'assets/images/erkek_'),
  kadin('Kadın', 'assets/images/kadin_');

  final String label;
  final String assetPrefix;
  const Gender(this.label, this.assetPrefix);
}

class PrayerStep {
  final String title;
  final String actionDescription;
  final String? maleDescription;
  final String? femaleDescription;
  final String? actionType; // 'iftitah', 'kiyam', 'ruku', 'secde', 'kade', 'selam', 'kunut'
  final String? anatomicalHintMale;
  final String? anatomicalHintFemale;
  final String? arabicText;
  final String? transliteration;
  final String? meaning;

  const PrayerStep({
    required this.title,
    required this.actionDescription,
    this.maleDescription,
    this.femaleDescription,
    this.actionType,
    this.anatomicalHintMale,
    this.anatomicalHintFemale,
    this.arabicText,
    this.transliteration,
    this.meaning,
  });

  String getDescription(Gender gender) {
    if (gender == Gender.kadin && femaleDescription != null) {
      return femaleDescription!;
    }
    if (gender == Gender.erkek && maleDescription != null) {
      return maleDescription!;
    }
    return actionDescription;
  }

  String? getAnatomicalHint(Gender gender) {
    if (gender == Gender.kadin) return anatomicalHintFemale;
    return anatomicalHintMale;
  }

  String? getImagePath(Gender gender, {int stepNumber = 1}) {
    if (actionType == null) return null;
    final genderStr = gender == Gender.erkek ? 'male' : 'female';
    return 'assets/images/prayer_${genderStr}_${stepNumber}_$actionType.webp';
  }
}

class RakatInfo {
  final int rakatNumber;
  final String title;
  final List<PrayerStep> steps;

  const RakatInfo({
    required this.rakatNumber,
    required this.title,
    required this.steps,
  });
}

class PrayerSection {
  final String name; // Örn: "2 Rekat Sünnet"
  final int rakatCount;
  final String type; // "Sünnet", "Farz", "İlk Sünnet", "Son Sünnet", "Vacip"
  final List<RakatInfo> rakats;

  const PrayerSection({
    required this.name,
    required this.rakatCount,
    required this.type,
    required this.rakats,
  });
}

class PrayerGuide {
  final String name; // "Sabah", "Öğle", "İkindi", "Akşam", "Yatsı", "Vitir"
  final int totalRakats;
  final String description;
  final List<PrayerSection> sections;

  const PrayerGuide({
    required this.name,
    required this.totalRakats,
    required this.description,
    required this.sections,
  });

  // Ortak Eylemler ve Dualar
  static const PrayerStep iftitahSabahSunnet = PrayerStep(
    title: 'Niyet & İftitah Tekbiri',
    actionType: 'iftitah',
    actionDescription: '"Niyet ettim Allah rızası için bugünkü sabah namazının iki rekat sünnetini kılmaya" diyerek "Allahu Ekber" ile tekbir alınır.',
    maleDescription: '"Niyet ettim Allah rızası için bugünkü sabah namazının iki rekat sünnetini kılmaya" denir. Eller başparmaklar kulak memelerine değecek şekilde kaldırılıp "Allahu Ekber" ile tekbir alınır. Avuç içleri kıbleye bakar.',
    femaleDescription: '"Niyet ettim Allah rızası için bugünkü sabah namazının iki rekat sünnetini kılmaya" denir. Eller omuz/göğüs hizasına kadar kaldırılıp "Allahu Ekber" ile tekbir alınır. Parmaklar bitişik ve eller örtü altında tutulur.',
    anatomicalHintMale: 'Eller kulak hizasında, başparmaklar kulak memesine değer.',
    anatomicalHintFemale: 'Eller omuz/göğüs hizasında kaldırılır, örtü altında tutulur.',
  );

  static const PrayerStep iftitahSabahFarz = PrayerStep(
    title: 'Niyet & İftitah Tekbiri',
    actionType: 'iftitah',
    actionDescription: '"Niyet ettim Allah rızası için bugünkü sabah namazının iki rekat farzını kılmaya" denir.',
    maleDescription: '"Niyet ettim Allah rızası için bugünkü sabah namazının iki rekat farzını kılmaya" denir. Başparmaklar kulak memelerine değdirilerek tekbir alınır.',
    femaleDescription: '"Niyet ettim Allah rızası için bugünkü sabah namazının iki rekat farzını kılmaya" denir. Eller omuz hizasında tekbir alınır.',
    anatomicalHintMale: 'Eller kulak hizasında, başparmak kulak memesine değer.',
    anatomicalHintFemale: 'Eller göğüs/omuz hizasında kaldırılır.',
  );

  static const PrayerStep kiyamGenel = PrayerStep(
    title: 'Kıyam & El Bağlama',
    actionType: 'kiyam',
    actionDescription: 'Ayakta düzgün durulur, gözler secde yerine bakar.',
    maleDescription: 'Ayakta durulur. Sağ elin baş ve serçe parmağıyla sol elin bileği kavranarak göbeğin altında bağlanır.',
    femaleDescription: 'Ayakta durulur. Sağ el sol elin üzerine konularak göğüs üzerinde bağlanır (bilek halkalanmaz).',
    anatomicalHintMale: 'Eller göbek altında; sağ el sol bileği halkalayarak kavrar.',
    anatomicalHintFemale: 'Eller göğüs üstünde; sağ el sol elin üzerine konur.',
  );

  static const PrayerStep subhaneke = PrayerStep(
    title: 'Sübhâneke Duası',
    actionType: 'kiyam',
    actionDescription: 'Kıyamda eller bağlandıktan sonra okunur.',
    maleDescription: 'Kıyamda eller göbek altında bağlıyken sessizce Sübhâneke okunur.',
    femaleDescription: 'Kıyamda eller göğüs üstünde bağlıyken sessizce Sübhâneke okunur.',
    anatomicalHintMale: 'Eller göbek altı bağlı.',
    anatomicalHintFemale: 'Eller göğüs üstü bağlı.',
    arabicText: 'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ وَتَبَارَكَ اسْمُكَ وَتَعَالَى جَدُّكَ وَلَا إِلَهَ غَيْرُكَ',
    transliteration: 'Sübhânekellâhümme ve bi hamdik ve tebârakesmük ve teâlâ ceddük ve lâ ilâhe ğayrük.',
    meaning: 'Allah\'ım! Sen her türlü eksiklikten uzaksın. Sana hamdederim. Senin ismin mübarektir. Senin şanın yücedir ve Senden başka ilâh yoktur.',
  );

  static const PrayerStep fatiha = PrayerStep(
    title: 'Fâtiha Suresi',
    actionType: 'kiyam',
    actionDescription: 'Eûzü-Besmele çekilerek okunur.',
    maleDescription: 'Kıyamda eûzü-besmele ile Fatiha Suresi okunur.',
    femaleDescription: 'Kıyamda eûzü-besmele ile Fatiha Suresi okunur.',
    anatomicalHintMale: 'Gözler secde yerine bakar, duruş dik.',
    anatomicalHintFemale: 'Gözler secde yerine bakar, duruş toplu.',
    arabicText: 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّح۪يمِ ﴿١﴾ اَلْحَمْدُ لِلّٰهِ رَبِّ الْعَالَم۪ينَ ﴿٢﴾ الرَّحْمٰنِ الرَّح۪يمِ ﴿٣﴾ مَالِكِ يَوْمِ الدّ۪ينِ ﴿٤﴾ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَع۪ينُ ﴿٥﴾ اِهْدِنَا الصِّرَاطَ الْمُسْتَق۪يمَ ﴿٦﴾ صِرَاطَ الَّذ۪ينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّٓالّ۪ينَ ﴿٧﴾',
    transliteration: 'Bismillâhirrahmânirrahîm. Elhamdü lillâhi rabbil\'âlemîn. Errahmânirrahîm. Mâliki yevmiddîn. İyyâke na\'büdü ve iyyâke neste\'în. İhdinessırâtal müstekîm. Sırâtallezîne en\'amte \'aleyhim ğayrilmağdûbi \'aleyhim veleddâllîn. (Âmîn)',
    meaning: 'Rahmân ve Rahîm olan Allah\'ın adıyla. Hamd, âlemlerin Rabbi, Rahmân, Rahîm ve hesap gününün mâliki olan Allah\'a mahsustur. Yalnız Sana ibadet eder, yalnız Senden yardım dileriz. Bizi doğru yola ilet.',
  );

  static const PrayerStep ihlas = PrayerStep(
    title: 'Zamm-ı Sure (Örn: İhlâs Suresi)',
    actionType: 'kiyam',
    actionDescription: 'Fatiha\'dan sonra zamm-ı sure okunur.',
    arabicText: 'قُلْ هُوَ اللّٰهُ اَحَدٌ ﴿١﴾ اَللّٰهُ الصَّمَدُ ﴿٢﴾ لَمْ يَلِدْ وَلَمْ يُولَدْ ﴿٣﴾ وَلَمْ يَكُنْ لَهُ كُفُوًا اَحَدٌ ﴿٤﴾',
    transliteration: 'Kul hüvellâhü ehad. Allâhüssamed. Lem yelid ve lem yûled. Ve lem yekün lehû küfüven ehad.',
    meaning: 'De ki: O Allah birdir. Allah Samed\'dir (her şey O\'na muhtaçtır). O doğurmamış ve doğmamıştır. O\'nun hiçbir dengi yoktur.',
  );

  static const PrayerStep ruku = PrayerStep(
    title: 'Rükû',
    actionType: 'ruku',
    actionDescription: '"Allahu Ekber" denilerek rükûa eğilinir. 3 defa tesbih okunur. "Semiallâhü limen hamideh" denilerek doğrulunur ve "Rabbenâ lekel hamd" denir.',
    maleDescription: '"Allahu Ekber" diyerek rükûa varılır. Sırt yere tam paralel (90°) düz tutulur. Parmaklar açık diz kapakları kavranır. 3 defa tesbih okunur. "Semiallâhü limen hamideh" ile doğrulunur.',
    femaleDescription: '"Allahu Ekber" diyerek rükûa varılır. Sırt hafifçe meyilli tutulur (yaklaşık 45-60°), tam düz eğilinmez. Dizler hafif bükük, parmaklar bitişik olarak dizlerin üzerine konur (kavranmaz). 3 defa tesbih okunur.',
    anatomicalHintMale: 'Sırt 90° düz, diz kapakları kavranır, kollar gergin.',
    anatomicalHintFemale: 'Sırt 45° hafif eğik, dizler hafif bükük, kollar vücuda yakın.',
    arabicText: 'سُبْحَانَ رَبِّيَ الْعَظِيمِ',
    transliteration: 'Sübhâne Rabbiye\'l-Azîm (3 Defa)',
    meaning: 'Pek yüce olan Rabbim her türlü noksandan uzaktır.',
  );

  static const PrayerStep secde = PrayerStep(
    title: 'Secde',
    actionType: 'secde',
    actionDescription: '"Allahu Ekber" denilerek secdeye varılır. 3 defa tesbih söylenir. Doğrulup kısa oturuştan sonra tekrar "Allahu Ekber" denilerek ikinci secde yapılır.',
    maleDescription: '"Allahu Ekber" diyerek secdeye varılır. Alın ve burun yere konur. Dirsekler yerden ve karından açık tutulur (yere yapıştırılmaz). Ayak parmak uçları kıbleye dikilir. 3 defa tesbih okunur.',
    femaleDescription: '"Allahu Ekber" diyerek secdeye varılır. Dirsekler yere yapışık ve kollar vücuda bitişik tutulur (toplu duruş). Karın uyluklara yaklaştırılır, ayaklar sağa yatırılır. 3 defa tesbih okunur.',
    anatomicalHintMale: 'Dirsekler yerden açık ve yukarıda, karın uyluktan uzak, ayak parmakları dik.',
    anatomicalHintFemale: 'Kollar ve dirsekler yere ve vücuda yapışık, karın uyluklara bitişik, ayaklar sağa yatık.',
    arabicText: 'سُبْحَانَ رَبِّيَ الْأَعْلَى',
    transliteration: 'Sübhâne Rabbiye\'l-A\'lâ (3 Defa)',
    meaning: 'En yüce olan Rabbim her türlü noksanlıktan münezzehtir.',
  );

  static const PrayerStep tahiyyat = PrayerStep(
    title: 'Ka\'de (Oturuş) & Ettehiyyâtü',
    actionType: 'kade',
    actionDescription: 'Oturuşta (Ka\'de) okunur.',
    maleDescription: 'İftiraş oturuşu: Sol ayak yere yatırılıp üzerine oturulur, sağ ayak parmakları kıbleye doğru dikilir. Eller dizlerin üzerine serbest konur ve Tahiyyat okunur.',
    femaleDescription: 'Teverrük oturuşu: Her iki ayak da sağ taraftan dışarı çıkarılarak kalça üzerine oturulur. Eller parmaklar bitişik olarak uylukların üzerine konur ve Tahiyyat okunur.',
    anatomicalHintMale: 'Sol ayak yatık üstüne oturulur, sağ ayak dik tutulur.',
    anatomicalHintFemale: 'Ayaklar sağa çıkarılır, kalça üzerine oturulur.',
    arabicText: 'التَّحِيَّاتُ لِلَّهِ وَالصَّلَوَاتُ وَالطَّيِّبَاتُ السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ السَّلَامُ عَلَيْنَا وَعَلَى عِبَادِ اللَّهِ الصَّالِحِينَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    transliteration: 'Ettehiyyâtü lillâhi vessalevâtü vettayyibât. Esselâmü \'aleyke eyyühen-nebiyyü ve rahmetullâhi ve berakâtüh. Esselâmü \'aleynâ ve \'alâ \'ibâdillâhis-sâlihîn. Eşhedü en lâ ilâhe illallâh ve eşhedü enne Muhammeden \'abdühû ve resûlüh.',
    meaning: 'Bütün dualar, övgüler, ibadetler ve iyilikler Allah içindir. Ey Peygamber! Selâm, Allah\'ın rahmet ve bereketi senin üzerine olsun. Selâm bizim ve salih kulların üzerine olsun. Şehadet ederim ki Allah\'tan başka ilâh yoktur ve Muhammed O\'nun kulu ve elçisidir.',
  );

  static const PrayerStep salliBarik = PrayerStep(
    title: 'Allâhümme Salli & Barik Duaları',
    actionType: 'kade',
    actionDescription: 'Son oturuşta Tahiyyat\'tan sonra okunur.',
    maleDescription: 'Oturuş pozisyonunda Tahiyyat\'ın hemen ardından Salli ve Barik duaları okunur.',
    femaleDescription: 'Oturuş pozisyonunda Tahiyyat\'ın hemen ardından Salli ve Barik duaları okunur.',
    anatomicalHintMale: 'Eller dizler üzerinde serbest.',
    anatomicalHintFemale: 'Eller uyluklar üzerinde bitişik.',
    arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ ... اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
    transliteration: 'Allâhümme salli alâ Muhammedin ve alâ âli Muhammed... Allâhümme bârik alâ Muhammedin ve alâ âli Muhammed...',
    meaning: 'Allah\'ım! Hz. İbrahim\'e ve ehline salât ve bereket verdiğin gibi, Efendimiz Hz. Muhammed\'e ve ehline de salât ve bereket eyle.',
  );

  static const PrayerStep rabbena = PrayerStep(
    title: 'Rabbenâ Duaları & Selâm',
    actionType: 'selam',
    actionDescription: 'Salli-Barik dualarından sonra okunur, ardından sağa ve sola selâm verilir.',
    maleDescription: 'Rabbenâ duaları okunduktan sonra önce sağ omuza "Esselâmü aleyküm ve rahmetullâh" denilerek selâm verilir, sonra sol omuza selâm verilir.',
    femaleDescription: 'Rabbenâ duaları okunduktan sonra önce sağ omuza "Esselâmü aleyküm ve rahmetullâh" denilerek selâm verilir, sonra sol omuza selâm verilir.',
    anatomicalHintMale: 'Önce sağa, sonra sola baş çevrilerek selâm verilir.',
    anatomicalHintFemale: 'Önce sağa, sonra sola baş çevrilerek selâm verilir.',
    arabicText: 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ ... رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
    transliteration: 'Rabbenâ âtinâ fiddünyâ haseneten ve fil âhirati haseneten ve kınâ azâbennâr. Rabbenâğfirlî ve livâlideyye ve lil mü\'minîne yevme yekûmül hisâb. -> Esselâmü aleyküm ve rahmetullâh.',
    meaning: 'Rabbimiz! Bize dünyada da ahirette de iyilik ver, bizi cehennem azabından koru. Rabbimiz! Hesap görülecek günde beni, ana-babamı ve inananları bağışla.',
  );

  static const PrayerStep kunut = PrayerStep(
    title: 'Kunut Duaları (Vitir Namazında)',
    actionType: 'kunut',
    actionDescription: 'Vitir namazının 3. rekatında Fatiha ve sureden sonra tekbir alınıp okunur.',
    maleDescription: 'Kunut tekbirinde eller kulak hizasına kaldırılıp tekrar göbek altında bağlanır ve Kunut duaları okunur.',
    femaleDescription: 'Kunut tekbirinde eller göğüs hizasına kaldırılıp tekrar göğüs üstünde bağlanır ve Kunut duaları okunur.',
    anatomicalHintMale: 'Tekbir kulak hizasından alınıp göbek altında bağlanır.',
    anatomicalHintFemale: 'Tekbir göğüs hizasından alınıp göğüs üstünde bağlanır.',
    arabicText: 'اَللَّهُمَّ إِنَّا نَسْتَعِينُكَ وَنَسْتَغْفِرُكَ وَنَسْتَهْدِيكَ ...',
    transliteration: 'Allâhümme innâ neste\'înüke ve nestağfirüke ve nestehdîk...',
    meaning: 'Allah\'ım! Senden yardım dileriz, günahlarımızı bağışlamanı isteriz, bizi hidayete erdirmemeni dileriz...',
  );

  // 6 Vakit / Namaz Listesi
  static List<PrayerGuide> get allPrayers => const [
    PrayerGuide(
      name: 'Sabah Namazı',
      totalRakats: 4,
      description: '2 Rekat Sünnet + 2 Rekat Farz olmak üzere toplam 4 rekattır.',
      sections: [
        PrayerSection(
          name: '2 Rekat Sünnet',
          rakatCount: 2,
          type: 'Sünnet',
          rakats: [
            RakatInfo(
              rakatNumber: 1,
              title: '1. Rekat',
              steps: [
                iftitahSabahSunnet,
                subhaneke,
                fatiha,
                ihlas,
                ruku,
                secde,
              ],
            ),
            RakatInfo(
              rakatNumber: 2,
              title: '2. Rekat & Son Oturuş',
              steps: [
                kiyamGenel,
                fatiha,
                ihlas,
                ruku,
                secde,
                tahiyyat,
                salliBarik,
                rabbena,
              ],
            ),
          ],
        ),
        PrayerSection(
          name: '2 Rekat Farz',
          rakatCount: 2,
          type: 'Farz',
          rakats: [
            RakatInfo(
              rakatNumber: 1,
              title: '1. Rekat',
              steps: [
                iftitahSabahFarz,
                subhaneke,
                fatiha,
                ihlas,
                ruku,
                secde,
              ],
            ),
            RakatInfo(
              rakatNumber: 2,
              title: '2. Rekat & Selâm',
              steps: [
                kiyamGenel,
                fatiha,
                ihlas,
                ruku,
                secde,
                tahiyyat,
                salliBarik,
                rabbena,
              ],
            ),
          ],
        ),
      ],
    ),
    PrayerGuide(
      name: 'Öğle Namazı',
      totalRakats: 10,
      description: '4 Rekat İlk Sünnet + 4 Rekat Farz + 2 Rekat Son Sünnet = 10 Rekat.',
      sections: [
        PrayerSection(
          name: '4 Rekat İlk Sünnet',
          rakatCount: 4,
          type: 'İlk Sünnet',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Öğle namazının 4 rekat ilk sünnetine niyet edilip tekbir alınır.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuş)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat', steps: [kiyamGenel, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 4, title: '4. Rekat & Selâm', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
        PrayerSection(
          name: '4 Rekat Farz',
          rakatCount: 4,
          type: 'Farz',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Öğle namazının 4 rekat farzına niyet edilip tekbir alınır.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuş)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat', steps: [kiyamGenel, PrayerStep(title: 'Kıraat', actionType: 'kiyam', actionDescription: 'Farzın 3. rekatında yalnızca Besmele ve Fatiha okunur (Zamm-ı sure okunmaz).'), fatiha, ruku, secde]),
            RakatInfo(rakatNumber: 4, title: '4. Rekat & Selâm', steps: [kiyamGenel, PrayerStep(title: 'Kıraat', actionType: 'kiyam', actionDescription: 'Yalnızca Besmele ve Fatiha okunur.'), fatiha, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
        PrayerSection(
          name: '2 Rekat Son Sünnet',
          rakatCount: 2,
          type: 'Son Sünnet',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Öğle namazının son sünnetine niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat & Selâm', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
      ],
    ),
    PrayerGuide(
      name: 'İkindi Namazı',
      totalRakats: 8,
      description: '4 Rekat Sünnet (Gayr-i Müekkede) + 4 Rekat Farz = 8 Rekat.',
      sections: [
        PrayerSection(
          name: '4 Rekat Sünnet',
          rakatCount: 4,
          type: 'Sünnet',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'İkindi namazının 4 rekat sünnetine niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuşta Salli-Barik de okunur)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat', steps: [kiyamGenel, subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 4, title: '4. Rekat & Selâm', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
        PrayerSection(
          name: '4 Rekat Farz',
          rakatCount: 4,
          type: 'Farz',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'İkindi namazının 4 rekat farzına niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuş)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat (Yalnız Fatiha)', steps: [kiyamGenel, fatiha, ruku, secde]),
            RakatInfo(rakatNumber: 4, title: '4. Rekat & Selâm', steps: [kiyamGenel, fatiha, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
      ],
    ),
    PrayerGuide(
      name: 'Akşam Namazı',
      totalRakats: 5,
      description: '3 Rekat Farz + 2 Rekat Sünnet = 5 Rekat.',
      sections: [
        PrayerSection(
          name: '3 Rekat Farz',
          rakatCount: 3,
          type: 'Farz',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Akşam namazının 3 rekat farzına niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuş)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat & Selâm (Yalnız Fatiha)', steps: [kiyamGenel, fatiha, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
        PrayerSection(
          name: '2 Rekat Sünnet',
          rakatCount: 2,
          type: 'Sünnet',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Akşam namazının 2 rekat sünnetine niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat & Selâm', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
      ],
    ),
    PrayerGuide(
      name: 'Yatsı Namazı',
      totalRakats: 10,
      description: '4 İlk Sünnet + 4 Farz + 2 Son Sünnet = 10 Rekat.',
      sections: [
        PrayerSection(
          name: '4 Rekat İlk Sünnet',
          rakatCount: 4,
          type: 'İlk Sünnet',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Yatsı namazının 4 rekat ilk sünnetine niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuş)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat', steps: [kiyamGenel, subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 4, title: '4. Rekat & Selâm', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
        PrayerSection(
          name: '4 Rekat Farz',
          rakatCount: 4,
          type: 'Farz',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Yatsı namazının 4 rekat farzına niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuş)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat', steps: [kiyamGenel, fatiha, ruku, secde]),
            RakatInfo(rakatNumber: 4, title: '4. Rekat & Selâm', steps: [kiyamGenel, fatiha, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
        PrayerSection(
          name: '2 Rekat Son Sünnet',
          rakatCount: 2,
          type: 'Son Sünnet',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Yatsı namazının son sünnetine niyet edilir.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat & Selâm', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
      ],
    ),
    PrayerGuide(
      name: 'Vitir Namazı',
      totalRakats: 3,
      description: '3 Rekat Vitir Vacip namazıdır.',
      sections: [
        PrayerSection(
          name: '3 Rekat Vitir Vacip',
          rakatCount: 3,
          type: 'Vacip',
          rakats: [
            RakatInfo(rakatNumber: 1, title: '1. Rekat', steps: [PrayerStep(title: 'Niyet & İftitah', actionType: 'iftitah', actionDescription: 'Vitir namazına niyet edilip tekbir alınır.'), subhaneke, fatiha, ihlas, ruku, secde]),
            RakatInfo(rakatNumber: 2, title: '2. Rekat (İlk Oturuş)', steps: [kiyamGenel, fatiha, ihlas, ruku, secde, tahiyyat]),
            RakatInfo(rakatNumber: 3, title: '3. Rekat & Kunut Duaları', steps: [kiyamGenel, fatiha, ihlas, kunut, ruku, secde, tahiyyat, salliBarik, rabbena]),
          ],
        ),
      ],
    ),
  ];
}

// Abdest Modelleri
class AblutionStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? maleDescription;
  final String? femaleDescription;
  final String? actionType; // 'eller', 'agiz', 'burun', 'yuz', 'kollar', 'bas', 'kulaklar', 'boyun', 'ayaklar'
  final String? anatomicalHintMale;
  final String? anatomicalHintFemale;

  const AblutionStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.maleDescription,
    this.femaleDescription,
    this.actionType,
    this.anatomicalHintMale,
    this.anatomicalHintFemale,
  });

  String getDescription(Gender gender) {
    if (gender == Gender.kadin && femaleDescription != null) {
      return femaleDescription!;
    }
    if (gender == Gender.erkek && maleDescription != null) {
      return maleDescription!;
    }
    return description;
  }

  String? getAnatomicalHint(Gender gender) {
    if (gender == Gender.kadin) return anatomicalHintFemale;
    return anatomicalHintMale;
  }

  String? getImagePath(Gender gender) {
    if (actionType == null) return null;
    final genderStr = gender == Gender.erkek ? 'male' : 'female';
    return 'assets/images/wudu_${genderStr}_${stepNumber}_$actionType.webp';
  }
}

class AblutionGuide {
  final String title;
  final String summary;
  final List<AblutionStep> steps;

  const AblutionGuide({
    required this.title,
    required this.summary,
    required this.steps,
  });

  static List<AblutionGuide> get allAblutions => allGuides;
  static List<AblutionGuide> get allGuides => [
    const AblutionGuide(
      title: 'Namaz Abdesti',
      summary: '4 Farzı: Yüzü yıkamak, kolları dirseklerle birlikte yıkamak, başın dörtte birini meshetmek, ayakları topuklarla birlikte yıkamak.',
      steps: [
        AblutionStep(
          stepNumber: 1,
          title: 'Niyet ve Besmele',
          actionType: 'niyet',
          description: '"Niyet ettim Allah rızası için abdest almaya" denir ve Eûzü-Besmele çekilir.',
          anatomicalHintMale: 'Niyet edilir, eller yıkanmaya hazırlanır.',
          anatomicalHintFemale: 'Niyet edilir, kollar sıvanır.',
        ),
        AblutionStep(
          stepNumber: 2,
          title: 'Elleri Yıkamak',
          actionType: 'eller',
          description: 'Eller bileklere kadar 3 defa parmak araları hilallenerek yıkanır.',
          anatomicalHintMale: 'Bileklere kadar parmak araları ve yüzük altı hilallenir.',
          anatomicalHintFemale: 'Bileklere kadar parmak araları ve yüzük altı hilallenir.',
        ),
        AblutionStep(
          stepNumber: 3,
          title: 'Ağza Su Vermek (Mazmaza)',
          actionType: 'agiz',
          description: 'Sağ el ile ağza 3 defa su alınıp çalkalanır.',
          anatomicalHintMale: 'Sağ avuçla ağza 3 kez su verilir ve gargara yapılır.',
          anatomicalHintFemale: 'Sağ avuçla ağza 3 kez su verilir.',
        ),
        AblutionStep(
          stepNumber: 4,
          title: 'Burna Su Vermek (İstinşak)',
          actionType: 'burun',
          description: 'Sağ el ile burna 3 defa su çekilir ve sol el ile sümkürülür.',
          anatomicalHintMale: 'Sağ elle su çekilir, sol elle burun temizlenir.',
          anatomicalHintFemale: 'Sağ elle su çekilir, sol elle burun temizlenir.',
        ),
        AblutionStep(
          stepNumber: 5,
          title: 'Yüzü Yıkamak (Farz)',
          actionType: 'yuz',
          description: 'Alın saç bitiminden çene altına ve kulak memelerine kadar yüz 3 defa yıkanır.',
          maleDescription: 'Alın saç bitiminden çene altına ve kulak memelerine kadar yüz 3 defa yıkanır. Sakal varsa hilallenir.',
          femaleDescription: 'Alın saç bitiminden çene altına ve kulak memelerine kadar yüz 3 defa yıkanır.',
          anatomicalHintMale: 'Saç bitiminden çene altına tüm yüz; sakal hilallenir.',
          anatomicalHintFemale: 'Saç bitiminden çene altına kadar yüzün tamamı yıkanır.',
        ),
        AblutionStep(
          stepNumber: 6,
          title: 'Kolları Yıkamak (Farz)',
          actionType: 'kollar',
          description: 'Önce sağ, sonra sol kol dirseklerle beraber 3 defa yıkanır.',
          anatomicalHintMale: 'Parmak uçlarından dirsekler dahil 3 kez yıkanır.',
          anatomicalHintFemale: 'Parmak uçlarından dirsekler dahil 3 kez yıkanır.',
        ),
        AblutionStep(
          stepNumber: 7,
          title: 'Başı Meshetmek (Farz)',
          actionType: 'bas',
          description: 'Sağ elin ıslak ayası ile başın en az dörtte biri meshedilir.',
          maleDescription: 'Eller ıslatılır ve başın en az dörtte biri veya kaplama olarak tamamı meshedilir.',
          femaleDescription: 'Eller ıslatılır, başörtüsünün altından veya başın ön kısmından en az dörtte biri meshedilir.',
          anatomicalHintMale: 'Islak el ayasıyla başın üstü ve önü meshedilir.',
          anatomicalHintFemale: 'Islak el ile başın ön/üst kısmı meshedilir.',
        ),
        AblutionStep(
          stepNumber: 8,
          title: 'Kulakları Meshetmek',
          actionType: 'kulaklar',
          description: 'İşaret parmaklarıyla kulakların içi, başparmaklarla arkası meshedilir.',
          anatomicalHintMale: 'İşaret parmağı ile iç, başparmak ile kulak arkası.',
          anatomicalHintFemale: 'İşaret parmağı ile iç, başparmak ile kulak arkası.',
        ),
        AblutionStep(
          stepNumber: 9,
          title: 'Boynu Meshetmek',
          actionType: 'boyun',
          description: 'Kalan üç parmağın dışıyla boyun arkası meshedilir.',
          anatomicalHintMale: 'Ellerin dış yüzeyiyle boynun arkası meshedilir.',
          anatomicalHintFemale: 'Ellerin dış yüzeyiyle boynun arkası meshedilir.',
        ),
        AblutionStep(
          stepNumber: 10,
          title: 'Ayakları Yıkamak (Farz)',
          actionType: 'ayaklar',
          description: 'Önce sağ, sonra sol ayak parmak uçlarından topuk ve aşık kemikleri dahil 3 defa yıkanır.',
          anatomicalHintMale: 'Topuklar ve aşık kemikleri dahil parmak araları hilallenir.',
          anatomicalHintFemale: 'Topuklar ve aşık kemikleri dahil parmak araları hilallenir.',
        ),
      ],
    ),
    const AblutionGuide(
      title: 'Gusül (Boy) Abdesti',
      summary: '3 Farzı: Ağza bolca su vermek, burna bolca su çekmek, bütün vücudu kuru yer kalmayacak şekilde yıkamak.',
      steps: [
        AblutionStep(
          stepNumber: 1,
          title: 'Niyet ve Temizlik',
          actionType: 'niyet',
          description: 'Besmele çekilir ve gusle niyet edilir. Avret yerleri ve varsa vücuttaki kirler temizlenir.',
          anatomicalHintMale: 'Niyet edilir, beden temizliği yapılır.',
          anatomicalHintFemale: 'Niyet edilir, beden temizliği yapılır.',
        ),
        AblutionStep(
          stepNumber: 2,
          title: 'Namaz Abdesti Almak',
          actionType: 'abdest',
          description: 'Tıpkı namaz abdesti gibi abdest alınır (Ayaklar biriken su varsa en sona bırakılabilir).',
          anatomicalHintMale: 'Namaz abdesti tam olarak alınır.',
          anatomicalHintFemale: 'Namaz abdesti tam olarak alınır.',
        ),
        AblutionStep(
          stepNumber: 3,
          title: 'Ağız ve Burun (Farz)',
          actionType: 'agiz_burun',
          description: 'Ağza ve burna bolca su verilir (oruçlu olunmadığında boğaza ve genze kadar ulaştırılır).',
          anatomicalHintMale: 'Ağız ve burun 3 defa bol su ile yıkanır.',
          anatomicalHintFemale: 'Ağız ve burun 3 defa bol su ile yıkanır.',
        ),
        AblutionStep(
          stepNumber: 4,
          title: 'Tüm Vücudu Yıkamak (Farz)',
          actionType: 'vucut',
          description: 'Önce başa, sonra sağ omuza, sonra sol omuza 3\'er defa su dökülerek tüm vücut iğne ucu kadar kuru yer kalmayacak şekilde yıkanır.',
          maleDescription: 'Başa, sağ ve sol omuza su dökülerek saç dipleri, sakal dipleri dahil tüm beden kuru yer kalmadan yıkanır.',
          femaleDescription: 'Başa, sağ ve sol omuza su dökülür; saç diplerine su ulaştırılmak kaydıyla örgülerin çözülmesi şart değildir, tüm vücut yıkanır.',
          anatomicalHintMale: 'Saç dipleri, sakal ve tüm vücut kuru yer kalmayacak şekilde yıkanır.',
          anatomicalHintFemale: 'Saç dipleri ve tüm vücut kuru yer kalmayacak şekilde yıkanır.',
        ),
      ],
    ),
    const AblutionGuide(
      title: 'Teyemmüm Abdesti',
      summary: 'Su bulunmadığında veya suyu kullanma imkanı olmadığında temiz toprak veya toprak cinsinden bir şeyle alınır.',
      steps: [
        AblutionStep(
          stepNumber: 1,
          title: 'Niyet Etmek (Farz)',
          actionType: 'niyet',
          description: 'Teyemmüm ile temizlenmeye ve namaz kılmaya niyet edilir, Besmele çekilir.',
          anatomicalHintMale: 'Teyemmüme niyet edilir.',
          anatomicalHintFemale: 'Teyemmüme niyet edilir.',
        ),
        AblutionStep(
          stepNumber: 2,
          title: 'Yüzü Meshetmek (Farz)',
          actionType: 'yuz',
          description: 'İki el temiz toprağa vurulup hafifçe silkelenir ve ellerle yüz tamamen meshedilir.',
          anatomicalHintMale: 'Toprağa vurulan ellerle yüzün tamamı meshedilir.',
          anatomicalHintFemale: 'Toprağa vurulan ellerle yüzün tamamı meshedilir.',
        ),
        AblutionStep(
          stepNumber: 3,
          title: 'Kolları Meshetmek (Farz)',
          actionType: 'kollar',
          description: 'Eller tekrar toprağa vurulup sol elle sağ kol, ardından sağ elle sol kol dirseklere kadar meshedilir.',
          anatomicalHintMale: 'Toprağa vurulan ellerle kollar dirseklere kadar meshedilir.',
          anatomicalHintFemale: 'Toprağa vurulan ellerle kollar dirseklere kadar meshedilir.',
        ),
      ],
    ),
  ];
}

class SpecialPrayerGuide {
  final String title;
  final String category;
  final String summary;
  final List<String> rules;
  final List<PrayerStep> steps;

  const SpecialPrayerGuide({
    required this.title,
    required this.category,
    required this.summary,
    required this.rules,
    required this.steps,
  });

  static const List<SpecialPrayerGuide> allSpecialPrayers = [
    SpecialPrayerGuide(
      title: 'Cuma Namazı',
      category: 'Farz-ı Ayn',
      summary: 'Cuma günü öğle vaktinde cemaatle kılınan, 2 rekat farz ve sünnetlerden oluşan haftalık bayram namazıdır.',
      rules: [
        'Akıllı, hür, mukim ve mazereti olmayan erkek müminlere farzdır.',
        'Öğle ezanıyla 4 rekat İlk Sünnet kılınır.',
        'İmam hutbeye çıkar, hutbe dinlenir.',
        'Kamet getirilerek 2 rekat Cuma Farzı cemaatle kılınır.',
        'Ardından 4 rekat Son Sünnet, 4 rekat Zühr-i Âhir ve 2 rekat Vaktin Sünneti eda edilir.',
      ],
      steps: [
        PrayerStep(
          title: 'Cuma İlk Sünneti (4 Rekat)',
          actionDescription: 'Tıpkı öğle namazının 4 rekat ilk sünneti gibi kılınır.',
          actionType: 'kiyam',
        ),
        PrayerStep(
          title: 'Cuma Farzı (2 Rekat - Cemaatle)',
          actionDescription: 'İmama uyularak niyet edilir: "Uydum hazır olan imama..." İmam kıraati aşikare okur, rüku ve secdeler cemaatle yapılır.',
          actionType: 'kiyam',
        ),
        PrayerStep(
          title: 'Cuma Son Sünneti (4 Rekat)',
          actionDescription: 'Farzdan sonra 4 rekat olarak öğlenin ilk sünneti gibi kılınır.',
          actionType: 'kiyam',
        ),
      ],
    ),
    SpecialPrayerGuide(
      title: 'Cenaze Namazı',
      category: 'Farz-ı Kifâye',
      summary: 'Rükusuz ve secdesiz, 4 tekbir ve kıyamdan ibaret bir dua namazıdır.',
      rules: [
        'Ayakta kılınır, rüku ve secde yoktur.',
        'Mevtaya ve Allah rızasına niyet edilir.',
        '4 tekbirden oluşur; eller yalnızca 1. tekbirde kaldırılır.',
      ],
      steps: [
        PrayerStep(
          title: '1. Tekbir (İftitah & Sübhâneke)',
          actionDescription: 'Eller kulak hizasına kaldırılıp "Allahu Ekber" denir ve eller bağlanır. Sübhâneke duası "ve celle senâük" ilavesiyle okunur.',
          actionType: 'iftitah',
        ),
        PrayerStep(
          title: '2. Tekbir (Salli & Bârik)',
          actionDescription: 'El kaldırmadan "Allahu Ekber" denir. Allâhümme Salli ve Allâhümme Bârik duaları okunur.',
          actionType: 'kiyam',
        ),
        PrayerStep(
          title: '3. Tekbir (Cenaze Duası / Rabbenâ)',
          actionDescription: 'El kaldırmadan 3. tekbir alınır. Cenaze duası veya bilmeyenler için Rabbenâ âtinâ okunur.',
          actionType: 'kiyam',
        ),
        PrayerStep(
          title: '4. Tekbir ve Selam',
          actionDescription: 'El kaldırmadan 4. tekbir alınır ve ardından önce sağa, sonra sola selam verilerek namaz tamamlanır.',
          actionType: 'selam',
        ),
      ],
    ),
    SpecialPrayerGuide(
      title: 'Bayram Namazı (Ramazan & Kurban)',
      category: 'Vacip',
      summary: 'Yılda iki defa bayram sabahları güneş doğup kerahet vakti çıktıktan sonra cemaatle kılınan 2 rekatlık namazdır.',
      rules: [
        'Toplam 2 rekattır ve her rekatında 3\'er ilave (zevaid) tekbir bulunur.',
        'Ezan ve kamet okunmaz.',
        'Namazdan sonra imam bayram hutbesi irad eder.',
      ],
      steps: [
        PrayerStep(
          title: '1. Rekat: Niyet, İftitah ve 3 Zevaid Tekbiri',
          actionDescription: 'Niyet edilip tekbir alınır. Sübhâneke okunur. Ardından eller kulaklara kaldırılıp 3 defa "Allahu Ekber" denir; 1. ve 2.\'de eller yana salınır, 3.\'de bağlanır. İmam Fatiha ve zamm-ı sure okur, rüku ve secdeye gidilir.',
          actionType: 'iftitah',
        ),
        PrayerStep(
          title: '2. Rekat: Kıraat ve 3 Zevaid Tekbiri + Rüku Tekbiri',
          actionDescription: 'Ayağa kalkılınca imam Fatiha ve sure okur. Rükudan önce eller kaldırılarak 3 defa tekbir alınıp eller yana salınır. 4. tekbirde eller kaldırılmadan rükuya varılır, secde ve selam ile bitirilir.',
          actionType: 'kiyam',
        ),
      ],
    ),
    SpecialPrayerGuide(
      title: 'Sehiv (Yanılma) Secdesi',
      category: 'Vacip',
      summary: 'Namazın vaciplerinden birinin unutularak terk edilmesi veya farzlarından birinin geciktirilmesi durumunda yapılan telafi secdesidir.',
      rules: [
        'Farzın kasten terki namazı bozar, sehiv secdesiyle telafi edilmez.',
        'Vaciplerin sehven (yanılarak) gecikmesi veya terkinde vaciptir.',
      ],
      steps: [
        PrayerStep(
          title: 'Uygulanışı',
          actionDescription: 'Son oturuşta yalnızca Tahiyyat okunur. Yalnızca sağ tarafa selam verilir. Ardından "Allahu Ekber" denilerek peş peşe iki defa secdeye varılır. Tekrar oturulur; Tahiyyat, Salli, Barik ve Rabbena duaları okunup her iki tarafa selam verilerek namaz tamamlanır.',
          actionType: 'secde',
        ),
      ],
    ),
    SpecialPrayerGuide(
      title: 'Tilavet Secdesi',
      category: 'Vacip',
      summary: 'Kur\'an-ı Kerim\'deki 14 secde ayetinden birini okuyan veya işiten kişinin yapması vacip olan secdedir.',
      rules: [
        'Abdestli olarak kıbleye dönülür.',
        'Rüku ve oturuş yoktur; yalnızca tek bir secdeden ibarettir.',
      ],
      steps: [
        PrayerStep(
          title: 'Uygulanışı',
          actionDescription: 'Ayakta iken eller kaldırılmaksızın "Niyet ettim Allah rızası için tilavet secdesi yapmaya" denilerek "Allahu Ekber" ile doğrudan secdeye varılır. Secdede 3 defa "Sübhâne Rabbiye\'l-A\'lâ" denir. "Allahu Ekber" diyerek ayağa kalkılır ve "Semi\'nâ ve ata\'nâ gufrâneke Rabbenâ ve ileyke\'l-masîr" denir.',
          actionType: 'secde',
        ),
      ],
    ),
  ];
}
