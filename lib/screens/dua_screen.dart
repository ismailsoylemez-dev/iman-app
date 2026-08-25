import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dua_model.dart';
import '../services/dua_service.dart';
import '../utils/error_handler.dart';
import '../utils/app_colors.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> with SingleTickerProviderStateMixin {
  final DuaService _duaService = DuaService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();

  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color emeraldDark = Color(0xFF0F241C);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF9E8B2);

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

  String? _currentlyPlayingId;
  PlayerState _audioPlayerState = PlayerState.stopped;

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
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _audioPlayerState = state;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentlyPlayingId = null;
          _audioPlayerState = PlayerState.stopped;
        });
      }
    });
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
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _playOrPauseAudio(DuaModel dua) async {
    if (dua.audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu dua için ses tilaveti henüz mevcut değil.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (_currentlyPlayingId == dua.id) {
        if (_audioPlayerState == PlayerState.playing) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      } else {
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlayingId = dua.id;
        });
        await _audioPlayer.play(UrlSource(dua.audioUrl));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ses çalınırken hata oluştu: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

  Future<void> _toggleReadStatus(String duaId) async {
    final isRead = await _duaService.toggleReadStatus(duaId, DateTime.now());
    setState(() {
      if (isRead) {
        _readTodayIds.add(duaId);
      } else {
        _readTodayIds.remove(duaId);
      }
    });
  }

  Future<void> _incrementCounter(DuaModel dua) async {
    final nextVal = await _duaService.incrementCounter(dua.id, dua.defaultTarget);
    HapticFeedback.lightImpact();
    setState(() {
      _counters[dua.id] = nextVal;
    });

    if (nextVal == dua.defaultTarget && mounted) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tebrikler! "${dua.title}" vird hedefinize (${dua.defaultTarget}) ulaştınız.'),
          backgroundColor: emeraldGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _resetCounter(String duaId) async {
    await _duaService.resetCounter(duaId);
    HapticFeedback.mediumImpact();
    setState(() {
      _counters[duaId] = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sayaç sıfırlandı.'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            color: Color(0xFF121212),
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
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
                              color: Colors.white,
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
                                fontFamily: 'serif',
                                height: 1.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            dua.transliteration,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            dua.meaning,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
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
          hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
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
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: emeraldGreen, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['name'];
          return FilterChip(
            showCheckmark: false,
            label: Text('${cat['icon']} ${cat['name']}'),
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
            return _buildDuaCard(pagedDuas[duaIndex]);
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
                color: Colors.white,
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
                fontSize: 18 * _fontScale,
                fontFamily: 'serif',
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dua.meaning,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 13.5 * _fontScale,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _playOrPauseAudio(dua),
                  icon: _PulseIcon(
                    icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: accentGold,
                    size: 18,
                    pulsing: isPlaying,
                  ),
                  label: Text(
                    isPlaying ? 'Durdur' : 'Dinle',
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: accentGold),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(width: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildDuaCard(DuaModel dua) {
    final isFav = _favoriteIds.contains(dua.id);
    final isRead = _readTodayIds.contains(dua.id);
    final currentCount = _counters[dua.id] ?? 0;
    final isPlaying = _currentlyPlayingId == dua.id && _audioPlayerState == PlayerState.playing;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? emeraldGreen.withValues(alpha: 0.6) : AppColors.border(context),
          width: isRead ? 1.5 : 1.0,
        ),
      ),
      elevation: 3,
      color: isRead ? emeraldGreen.withValues(alpha: 0.06) : AppColors.card(context),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleReadStatus(dua.id),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isRead ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          color: isRead ? emeraldGreen : Colors.grey.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isRead ? 'Okundu' : 'Günlük Takip',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isRead ? FontWeight.bold : FontWeight.normal,
                            color: isRead ? emeraldGreen : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: goldLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: accentGold.withValues(alpha: 0.7)),
                  ),
                  child: Text(
                    '${dua.surahName} ${dua.ayahNo}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8C6D0F),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFav ? Colors.red.shade600 : Colors.grey.shade400,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                  tooltip: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                  onPressed: () => _toggleFavorite(dua.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dua.title,
              style: TextStyle(
                fontSize: 15.5 * _fontScale,
                fontWeight: FontWeight.bold,
                color: emeraldGreen,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Text(
                dua.arabic,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 18 * _fontScale,
                  fontFamily: 'serif',
                  fontWeight: FontWeight.bold,
                  color: emeraldGreen,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            if (dua.tags.isNotEmpty || dua.source.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (dua.source.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: emeraldGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: emeraldGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        dua.source == 'Quran' ? 'Kur\'an' : (dua.source == 'Sunnah' ? 'Sünnet' : dua.source),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: emeraldGreen),
                      ),
                    ),
                  for (final tag in dua.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text('#$tag', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade700)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            const Text(
              'Okunuşu:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: emeraldGreen,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dua.transliteration,
              style: TextStyle(
                fontSize: 15 * _fontScale,
                fontWeight: FontWeight.w500,
                color: AppColors.text(context),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Meali:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8C6D0F),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dua.meaning,
              style: TextStyle(
                fontSize: 14 * _fontScale,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary(context),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            if (dua.context.isNotEmpty)
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(bottom: 8),
                  dense: true,
                  title: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 16, color: emeraldGreen),
                      SizedBox(width: 6),
                      Text(
                        'Fazileti & Tefsiri',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: emeraldGreen,
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: emeraldGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: emeraldGreen.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        dua.context,
                        style: TextStyle(
                          fontSize: 12.5 * _fontScale,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 16),
            Row(
              children: [
                InkWell(
                  key: const ValueKey('dua_listen_button'),
                  onTap: () => _playOrPauseAudio(dua),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulseIcon(
                          icon: isPlaying ? Icons.pause_circle_filled_rounded : Icons.volume_up_rounded,
                          size: 20,
                          color: isPlaying ? const Color(0xFFD97706) : emeraldGreen,
                          pulsing: isPlaying,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPlaying ? 'Durdur' : 'Dinle',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isPlaying ? const Color(0xFFD97706) : emeraldGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey('dua_story_share_button'),
                  tooltip: 'Hikaye Olarak Paylaş',
                  icon: const Icon(Icons.amp_stories_outlined, size: 18),
                  visualDensity: VisualDensity.compact,
                  color: accentGold,
                  onPressed: () => _showStoryShareModal(dua),
                ),
                IconButton(
                  tooltip: 'Kopyala',
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                  color: Colors.grey.shade700,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: dua.formattedShareText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${dua.title}" panoya kopyalandı.'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Paylaş',
                  icon: const Icon(Icons.share_outlined, size: 18),
                  visualDensity: VisualDensity.compact,
                  color: Colors.grey.shade700,
                  onPressed: () => SharePlus.instance.share(
                    ShareParams(
                      text: dua.formattedShareText,
                      subject: dua.title,
                    ),
                  ),
                ),
                const Spacer(),
                Tooltip(
                  message: 'Tıkla: Artır | Basılı Tut: Sıfırla',
                  child: InkWell(
                    onTap: () => _incrementCounter(dua),
                    onLongPress: () => _resetCounter(dua.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: currentCount >= dua.defaultTarget
                              ? [emeraldGreen, const Color(0xFF2D6A4F)]
                              : [const Color(0xFFF1F3F5), const Color(0xFFE9ECEF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: currentCount >= dua.defaultTarget
                              ? accentGold
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            size: 14,
                            color: currentCount >= dua.defaultTarget ? accentGold : emeraldGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$currentCount / ${dua.defaultTarget}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: currentCount >= dua.defaultTarget ? Colors.white : Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ses çalarken hafifçe büyüyüp küçülen (pulse) ikon; sadece [pulsing] true iken animasyon çalışır.
class _PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool pulsing;

  const _PulseIcon({
    required this.icon,
    required this.color,
    required this.size,
    required this.pulsing,
  });

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulseIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.25).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Icon(widget.icon, color: widget.color, size: widget.size),
    );
  }
}
