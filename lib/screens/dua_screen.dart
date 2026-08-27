import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dua_model.dart';
import '../services/dua_service.dart';
import '../services/dua_audio_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../widgets/dua_list_card.dart';
import '../widgets/dua_detail_sheet.dart';
import '../widgets/pulse_icon.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> with SingleTickerProviderStateMixin {
  final DuaService _duaService = DuaService();
  final DuaAudioService _audioService = DuaAudioService();
  final TextEditingController _searchController = TextEditingController();

  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color emeraldDark = AppColors.primaryTealDark;
  static const Color accentGold = AppColors.accentOrange;
  static const Color goldLight = AppColors.secondaryCreamLight;

  late TabController _tabController;

  List<DuaModel> _allDuas = [];
  Set<String> _favoriteIds = {};
  Set<String> _readTodayIds = {};
  final Map<String, int> _counters = {};

  bool _isLoading = true;
  double _fontScale = 1.0;
  String _selectedCategory = 'Tümü';
  String _searchQuery = '';
  String _readFilter = 'Tümü'; // Tümü | Okundu | Okunmadı
  bool _targetExceededOnly = false;

  static const int _pageSize = 20;
  int _visibleAllCount = _pageSize;
  int _visibleFavCount = _pageSize;

  String? get _currentlyPlayingId => _audioService.currentlyPlayingId;
  PlayerState get _audioPlayerState => _audioService.playerState;
  Duration get _playbackPosition => _audioService.position;
  Duration get _playbackDuration => _audioService.duration;
  bool get _isBuffering => _audioService.isBuffering;

  final List<Map<String, String>> _categories = const [
    {'name': 'Tümü', 'icon': '✨'},
    {'name': 'Huzur', 'icon': '😌'},
    {'name': 'Sıkıntı', 'icon': '😔'},
    {'name': 'Şifa', 'icon': '🩺'},
    {'name': 'Rızık', 'icon': '💼'},
    {'name': 'Korunma', 'icon': '🛡️'},
    {'name': 'Bağışlanma', 'icon': '🤲'},
    {'name': 'Peygamber Duaları', 'icon': '📖'},
    {'name': 'Kandil & Bayramlar', 'icon': '🕌'},
    {'name': 'Sabah/Akşam', 'icon': '🌅'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initAudioListeners();
    _loadInitialData();
  }

  void _initAudioListeners() {
    _audioService.onStateChanged = () {
      if (mounted) setState(() {});
    };
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final duas = await _duaService.getAllDuas();
      final favs = await _duaService.getFavorites();
      final reads = await _duaService.getReadDuaIds(DateTime.now());
      final scale = await _duaService.getFontScale();

      for (final dua in duas) {
        final count = await _duaService.getCounter(dua.id);
        _counters[dua.id] = count;
      }

      if (mounted) {
        setState(() {
          _allDuas = duas;
          _favoriteIds = favs;
          _readTodayIds = reads;
          _fontScale = scale;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        await ErrorHandler.showError(context, e is Exception ? e : Exception(e.toString()));
      }
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _playOrPauseAudio(DuaModel dua) async {
    if (!dua.hasAudio) return;
    await _audioService.playOrToggle(dua);
  }

  Future<void> _toggleFavorite(String duaId) async {
    final isFav = await _duaService.toggleFavorite(duaId);
    setState(() {
      if (isFav) {
        _favoriteIds.add(duaId);
      } else {
        _favoriteIds.remove(duaId);
      }
    });
  }

  /// Detay görünümü (DuaDetailSheet) okundu durumunu kendi içinde
  /// [DuaService] üzerinden değiştirir; bu yalnızca ekrandaki listeyi
  /// sonucuyla senkronize eder.
  void _syncReadStatus(String duaId, bool isRead) {
    setState(() {
      if (isRead) {
        _readTodayIds.add(duaId);
      } else {
        _readTodayIds.remove(duaId);
      }
    });
  }

  /// Detay görünümü sayaç değerini kendi içinde değiştirir; bu yalnızca
  /// ekrandaki listeyi sonucuyla senkronize eder.
  void _syncCounter(String duaId, int count) {
    setState(() => _counters[duaId] = count);
  }

  /// Karta dokununca açılan detay görünümünü gösterir.
  void _openDuaDetail(DuaModel dua) {
    DuaDetailSheet.show(
      context,
      dua: dua,
      audioService: _audioService,
      duaService: _duaService,
      fontScale: _fontScale,
      initialIsFavorite: _favoriteIds.contains(dua.id),
      initialIsRead: _readTodayIds.contains(dua.id),
      initialCount: _counters[dua.id] ?? 0,
      onFavoriteChanged: (isFav) => _syncFavoriteStatus(dua.id, isFav),
      onReadChanged: (isRead) => _syncReadStatus(dua.id, isRead),
      onCounterChanged: (count) => _syncCounter(dua.id, count),
      onShowStory: () => _showStoryShareModal(dua),
    );
  }

  /// [_toggleFavorite] ile aynı işi yapar; detay görünümü favori durumunu
  /// kendi içinde değiştirdiğinde ekrandaki listeyi sonucuyla senkronize eder.
  void _syncFavoriteStatus(String duaId, bool isFav) {
    setState(() {
      if (isFav) {
        _favoriteIds.add(duaId);
      } else {
        _favoriteIds.remove(duaId);
      }
    });
  }

  void _changeFontScale(double delta) {
    final newScale = (_fontScale + delta).clamp(0.85, 1.45);
    setState(() {
      _fontScale = double.parse(newScale.toStringAsFixed(2));
    });
    _duaService.setFontScale(_fontScale);
  }

  DuaModel? get _dailyDua {
    if (_allDuas.isEmpty) return null;
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return _allDuas[dayOfYear % _allDuas.length];
  }

  List<DuaModel> _filterDuas(List<DuaModel> source) {
    return source.where((dua) {
      final matchesCategory = _selectedCategory == 'Tümü' || dua.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          dua.title.toLowerCase().contains(query) ||
          dua.surahName.toLowerCase().contains(query) ||
          dua.meaning.toLowerCase().contains(query) ||
          dua.transliteration.toLowerCase().contains(query) ||
          dua.arabic.contains(query) ||
          dua.tags.any((tag) => tag.toLowerCase().contains(query));

      final isRead = _readTodayIds.contains(dua.id);
      final matchesRead = _readFilter == 'Tümü' ||
          (_readFilter == 'Okundu' && isRead) ||
          (_readFilter == 'Okunmadı' && !isRead);

      final matchesTarget = !_targetExceededOnly || (_counters[dua.id] ?? 0) >= dua.defaultTarget;

      return matchesCategory && matchesSearch && matchesRead && matchesTarget;
    }).toList();
  }

  /// 9:16 Altın Çerçeveli Hikaye / Durum Paylaşım Modalı
  void _showStoryShareModal(DuaModel dua) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.90,
          decoration: const BoxDecoration(
            color: AppColors.storyBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hikaye Olarak Paylaş',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.onPrimarySecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [emeraldDark, emeraldGreen],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accentGold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: accentGold.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: accentGold.withValues(alpha: 0.6)),
                            ),
                            child: Text(
                              '${dua.surahName} Suresi • ${dua.ayahNo}. Ayet',
                              style: const TextStyle(
                                color: accentGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            dua.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dua.arabic,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                color: goldLight,
                                fontSize: 18,
                                fontFamily: AppTypography.arabicFontFamily,
                                height: 1.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            dua.transliteration,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.onPrimarySecondary,
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            dua.meaning,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.onPrimary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_stories_rounded, color: accentGold, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'İman Uygulaması',
                                style: TextStyle(
                                  color: accentGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    SharePlus.instance.share(
                      ShareParams(
                        text: dua.formattedShareText,
                        subject: '${dua.title} (Kur\'an Duası)',
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, color: emeraldDark),
                  label: const Text(
                    'Durum / Hikaye Metnini Paylaş',
                    style: TextStyle(color: emeraldDark, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGold,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredAll = _filterDuas(_allDuas);
    final filteredFavorites = _filterDuas(_allDuas.where((d) => _favoriteIds.contains(d.id)).toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kur\'an Duaları'),
        actions: [
          _buildFontSizeControls(),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: [
            Tab(
              icon: const Icon(Icons.menu_book_rounded, size: 20),
              text: 'Tüm Dualar (${_allDuas.length})',
            ),
            Tab(
              icon: const Icon(Icons.favorite_rounded, size: 20),
              text: 'Favorilerim (${_favoriteIds.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: emeraldGreen))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    _buildSearchBar(),
                    _buildCategoryChips(),
                    _buildExtraFilterChips(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDuaList(filteredAll, isFavoriteTab: false),
                          _buildDuaList(filteredFavorites, isFavoriteTab: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFontSizeControls() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentGold.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Metin Boyutunu Küçült',
            icon: const Text(
              'A-',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            visualDensity: VisualDensity.compact,
            onPressed: () => _changeFontScale(-0.10),
          ),
          Container(
            width: 1,
            height: 16,
            color: Colors.white38,
          ),
          IconButton(
            tooltip: 'Metin Boyutunu Büyüt',
            icon: const Text(
              'A+',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            visualDensity: VisualDensity.compact,
            onPressed: () => _changeFontScale(0.10),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Dua, sure adı, okunuş veya mealde ara...',
          hintStyle: TextStyle(fontSize: 13.5, color: AppColors.textSecondary(context)),
          prefixIcon: const Icon(Icons.search, color: emeraldGreen),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border(context)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: emeraldGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  int _categoryCount(String category) {
    if (category == 'Tümü') return _allDuas.length;
    return _allDuas.where((d) => d.category == category).length;
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['name'];
          final count = _categoryCount(cat['name']!);
          return FilterChip(
            showCheckmark: false,
            label: Text('${cat['icon']} ${cat['name']} ($count)'),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade800,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12.5,
            ),
            backgroundColor: Colors.white,
            selectedColor: emeraldGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? accentGold : Colors.grey.shade300,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = cat['name']!;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildExtraFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        scrollDirection: Axis.horizontal,
        children: [
          for (final option in const ['Tümü', 'Okundu', 'Okunmadı'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                showCheckmark: false,
                label: Text(option),
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  color: _readFilter == option ? Colors.white : Colors.grey.shade800,
                  fontWeight: _readFilter == option ? FontWeight.bold : FontWeight.w500,
                ),
                selectedColor: emeraldGreen,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: _readFilter == option ? accentGold : Colors.grey.shade300),
                ),
                selected: _readFilter == option,
                onSelected: (_) => setState(() => _readFilter = option),
              ),
            ),
          FilterChip(
            showCheckmark: false,
            label: const Text('Hedef Aşıldı'),
            labelStyle: TextStyle(
              fontSize: 11.5,
              color: _targetExceededOnly ? Colors.white : Colors.grey.shade800,
              fontWeight: _targetExceededOnly ? FontWeight.bold : FontWeight.w500,
            ),
            selectedColor: emeraldGreen,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _targetExceededOnly ? accentGold : Colors.grey.shade300),
            ),
            selected: _targetExceededOnly,
            onSelected: (selected) => setState(() => _targetExceededOnly = selected),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaList(List<DuaModel> duas, {required bool isFavoriteTab}) {
    if (duas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFavoriteTab ? Icons.favorite_border_rounded : Icons.search_off_rounded,
                size: 56,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 14),
              Text(
                isFavoriteTab ? 'Henüz favori dua eklemediniz.' : 'Aramanıza uygun dua bulunamadı.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isFavoriteTab
                    ? 'Duaların yanındaki kalp butonuna tıklayarak favorilerinize ekleyebilirsiniz.'
                    : 'Farklı bir arama kelimesi veya kategori deneyebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    final visibleCount = isFavoriteTab ? _visibleFavCount : _visibleAllCount;
    final pagedDuas = duas.take(visibleCount).toList();
    final hasMore = duas.length > pagedDuas.length;
    final showDailyCard = !isFavoriteTab && _dailyDua != null && _selectedCategory == 'Tümü' && _searchQuery.isEmpty;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200 && hasMore) {
          setState(() {
            if (isFavoriteTab) {
              _visibleFavCount += _pageSize;
            } else {
              _visibleAllCount += _pageSize;
            }
          });
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
        itemCount: (showDailyCard ? pagedDuas.length + 1 : pagedDuas.length) + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          final offset = showDailyCard ? 1 : 0;

          if (showDailyCard && index == 0) {
            return _buildDailyDuaCard(_dailyDua!);
          }

          final duaIndex = index - offset;
          if (duaIndex < pagedDuas.length) {
            final dua = pagedDuas[duaIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: DuaListCard(
                dua: dua,
                isFavorite: _favoriteIds.contains(dua.id),
                isPlaying: _currentlyPlayingId == dua.id && _audioPlayerState == PlayerState.playing,
                isBuffering: _currentlyPlayingId == dua.id && _isBuffering,
                fontScale: _fontScale,
                onTap: () => _openDuaDetail(dua),
                onToggleFavorite: () => _toggleFavorite(dua.id),
                onPlayPause: () => _playOrPauseAudio(dua),
              ),
            );
          }

          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(color: emeraldGreen, strokeWidth: 2)),
          );
        },
      ),
    );
  }

  Widget _buildDailyDuaCard(DuaModel dua) {
    final isPlaying = _currentlyPlayingId == dua.id && _audioPlayerState == PlayerState.playing;
    final isBuffering = _currentlyPlayingId == dua.id && _isBuffering;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [emeraldDark, emeraldGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentGold.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 14, color: emeraldDark),
                      SizedBox(width: 4),
                      Text(
                        'GÜNÜN DUASI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: emeraldDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dua.surahName} ${dua.ayahNo}',
                    style: const TextStyle(
                      color: goldLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              dua.title,
              style: TextStyle(
                color: AppColors.onPrimary,
                fontSize: 16 * _fontScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dua.arabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: goldLight,
                fontSize: 21 * _fontScale,
                fontFamily: AppTypography.arabicFontFamily,
                height: 1.9,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dua.meaning,
              style: TextStyle(
                color: AppColors.onPrimarySecondary,
                fontSize: 13.5 * _fontScale,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (dua.hasAudio) ...[
                  OutlinedButton.icon(
                    onPressed: () => _playOrPauseAudio(dua),
                    icon: isBuffering
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: accentGold),
                          )
                        : PulseIcon(
                            icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: accentGold,
                            size: 18,
                            pulsing: isPlaying,
                          ),
                    label: Text(
                      isBuffering ? 'Yükleniyor...' : (isPlaying ? 'Durdur' : 'Dinle'),
                      style: const TextStyle(color: AppColors.onPrimary, fontSize: 12.5),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: accentGold),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton.icon(
                  onPressed: () => _showStoryShareModal(dua),
                  icon: const Icon(Icons.amp_stories_rounded, size: 16, color: emeraldDark),
                  label: const Text('Hikaye', style: TextStyle(color: emeraldDark, fontSize: 12.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGold,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            if (isPlaying || isBuffering)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: isBuffering || _playbackDuration.inMilliseconds == 0
                        ? null
                        : (_playbackPosition.inMilliseconds / _playbackDuration.inMilliseconds).clamp(0.0, 1.0),
                    minHeight: 3,
                    backgroundColor: Colors.white24,
                    color: accentGold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}
