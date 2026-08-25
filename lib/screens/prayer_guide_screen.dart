import 'package:flutter/material.dart';
import '../models/prayer_guide_model.dart';
import '../services/kaza_storage_service.dart';

class PrayerGuideScreen extends StatefulWidget {
  const PrayerGuideScreen({super.key});

  @override
  State<PrayerGuideScreen> createState() => _PrayerGuideScreenState();
}

class _PrayerGuideScreenState extends State<PrayerGuideScreen> with SingleTickerProviderStateMixin {
  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color emeraldDark = Color(0xFF0F241C);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF212529);

  late TabController _tabController;
  int _selectedPrayerIndex = 0;
  Gender _selectedGender = Gender.erkek;

  Map<String, int> _kazaDebts = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadKazaDebts();
  }

  Future<void> _loadKazaDebts() async {
    final debts = await KazaStorageService.getAllKazaDebts();
    if (mounted) {
      setState(() {
        _kazaDebts = debts;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showKazaTrackerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int totalDebts = _kazaDebts.values.fold(0, (sum, val) => sum + val);

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history_edu_rounded, color: emeraldGreen, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Kaza Namazı Takipçisi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: emeraldGreen,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [emeraldDark, emeraldGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accentGold.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Toplam Kaza Borcu:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: accentGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$totalDebts Vakit',
                            style: const TextStyle(color: emeraldDark, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...KazaStorageService.kazaVakitleri.map((vakit) {
                    final count = _kazaDebts[vakit] ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE9ECEF)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              vakit,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: darkText,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                            visualDensity: VisualDensity.compact,
                            onPressed: count > 0
                                ? () async {
                                    final next = await KazaStorageService.changeKazaDebt(vakit, -1);
                                    setModalState(() {
                                      _kazaDebts[vakit] = next;
                                    });
                                    setState(() {
                                      _kazaDebts[vakit] = next;
                                    });
                                  }
                                : null,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 40),
                            alignment: Alignment.center,
                            child: Text(
                              '$count',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: emeraldGreen),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: emeraldGreen, size: 22),
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              final next = await KazaStorageService.changeKazaDebt(vakit, 1);
                              setModalState(() {
                                _kazaDebts[vakit] = next;
                              });
                              setState(() {
                                _kazaDebts[vakit] = next;
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: const BorderSide(color: accentGold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              final next = await KazaStorageService.changeKazaDebt(vakit, 5);
                              setModalState(() {
                                _kazaDebts[vakit] = next;
                              });
                              setState(() {
                                _kazaDebts[vakit] = next;
                              });
                            },
                            child: const Text('+5', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8C6D0F))),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPrayers = PrayerGuide.allPrayers;
    final currentPrayer = allPrayers[_selectedPrayerIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Namaz & Abdest Rehberi'),
        actions: [
          IconButton(
            tooltip: 'Kaza Namazı Borç Takipçisi',
            icon: const Icon(Icons.history_edu_rounded, color: accentGold),
            onPressed: _showKazaTrackerModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded, size: 18), text: '5 Vakit'),
            Tab(icon: Icon(Icons.stars_rounded, size: 18), text: 'Özel Namazlar'),
            Tab(icon: Icon(Icons.water_drop_outlined, size: 18), text: 'Abdest'),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Sekme: 5 Vakit Namaz Kılınışı
                _buildFivePrayersTab(allPrayers, currentPrayer),

                // 2. Sekme: Özel Namazlar (Cuma, Cenaze, Bayram, Secdeler)
                _buildSpecialPrayersTab(),

                // 3. Sekme: Abdest Rehberi
                _buildAblutionTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 18, color: emeraldGreen.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          const Text(
            'Görsel Hazırlanıyor',
            style: TextStyle(
              fontSize: 11.5,
              color: darkText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFivePrayersTab(List<PrayerGuide> allPrayers, PrayerGuide currentPrayer) {
    return Column(
      children: [
        // Cinsiyet Seçimi & Vakit Değiştirici Barı
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _selectedGender == Gender.erkek ? Icons.man : Icons.woman,
                    color: emeraldGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Kılınış Şekli:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: darkText),
                  ),
                ],
              ),
              SegmentedButton<Gender>(
                segments: const [
                  ButtonSegment<Gender>(
                    value: Gender.erkek,
                    label: Text('Erkek'),
                    icon: Icon(Icons.male, size: 16),
                  ),
                  ButtonSegment<Gender>(
                    value: Gender.kadin,
                    label: Text('Kadın'),
                    icon: Icon(Icons.female, size: 16),
                  ),
                ],
                selected: {_selectedGender},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedGender = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return emeraldGreen;
                    }
                    return Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return emeraldGreen;
                  }),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 5 Vakit Yatay Kaydırılabilir Seçim Listesi
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: allPrayers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final prayer = allPrayers[index];
              final isSelected = index == _selectedPrayerIndex;

              return ChoiceChip(
                showCheckmark: false,
                label: Text('${prayer.name} (${prayer.totalRakats} Rekat)'),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : darkText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 12,
                ),
                backgroundColor: Colors.white,
                selectedColor: emeraldGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? accentGold : const Color(0xFFCED4DA),
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedPrayerIndex = index;
                    });
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 6),

        // Namaz Rekatları & Adımları Listesi
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: currentPrayer.sections.length,
            itemBuilder: (context, sectionIndex) {
              final section = currentPrayer.sections[sectionIndex];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE9ECEF)),
                ),
                elevation: 2,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: sectionIndex == 0,
                    leading: CircleAvatar(
                      backgroundColor: emeraldGreen.withValues(alpha: 0.1),
                      foregroundColor: emeraldGreen,
                      child: Text(
                        '${section.rakatCount}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      section.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: emeraldGreen),
                    ),
                    subtitle: Text(
                      '${section.type} • ${section.rakatCount} Rekat',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    children: section.rakats.map((rakat) {
                      return Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: accentGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: accentGold.withValues(alpha: 0.6)),
                                  ),
                                  child: Text(
                                    '${rakat.rakatNumber}. Rekat: ${rakat.title}',
                                    style: const TextStyle(
                                      color: Color(0xFF8C6D0F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...rakat.steps.map((step) {
                              final desc = step.getDescription(_selectedGender);
                              final hint = step.getAnatomicalHint(_selectedGender);
                              final imgPath = step.getImagePath(_selectedGender, stepNumber: rakat.rakatNumber);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.arrow_right, color: emeraldGreen, size: 20),
                                        Expanded(
                                          child: Text(
                                            step.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: emeraldGreen),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text(
                                        desc,
                                        style: const TextStyle(fontSize: 13, color: darkText, height: 1.4),
                                      ),
                                    ),
                                    if (hint != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20, top: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.tips_and_updates_outlined, size: 14, color: accentGold),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                hint,
                                                style: const TextStyle(fontSize: 11.5, color: Color(0xFF8C6D0F), fontStyle: FontStyle.italic),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (imgPath != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20, top: 6),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.asset(
                                            imgPath,
                                            height: 100,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialPrayersTab() {
    const specials = SpecialPrayerGuide.allSpecialPrayers;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: specials.length,
      itemBuilder: (context, index) {
        final item = specials[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: index == 0,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.star_rounded, color: Color(0xFF8C6D0F), size: 22),
              ),
              title: Text(
                item.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: emeraldGreen),
              ),
              subtitle: Text(
                '${item.category} • ${item.summary}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 12),
                      const Text(
                        'Önemli Şartlar & Hükümler:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: emeraldGreen),
                      ),
                      const SizedBox(height: 4),
                      ...item.rules.map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: accentGold, fontWeight: FontWeight.bold)),
                                Expanded(child: Text(r, style: const TextStyle(fontSize: 13, color: darkText))),
                              ],
                            ),
                          )),
                      const SizedBox(height: 10),
                      const Text(
                        'Kılınış Adımları:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: emeraldGreen),
                      ),
                      const SizedBox(height: 4),
                      ...item.steps.map((s) => Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE9ECEF)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: emeraldGreen)),
                                const SizedBox(height: 3),
                                Text(s.actionDescription, style: const TextStyle(fontSize: 12.5, color: darkText, height: 1.35)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAblutionTab() {
    final ablutions = AblutionGuide.allAblutions;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ablutions.length,
      itemBuilder: (context, index) {
        final ab = ablutions[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE9ECEF)),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: index == 0,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: emeraldGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water_drop_rounded, color: emeraldGreen, size: 22),
              ),
              title: Text(
                ab.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5, color: emeraldGreen),
              ),
              subtitle: Text(
                ab.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: ab.steps.map((st) {
                      final imgPath = st.getImagePath(_selectedGender);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE9ECEF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: emeraldGreen,
                                  foregroundColor: Colors.white,
                                  child: Text('${st.stepNumber}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(st.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: emeraldGreen)),
                                      const SizedBox(height: 2),
                                      Text(st.description, style: const TextStyle(fontSize: 12.5, color: darkText, height: 1.35)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (imgPath != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 34, top: 6),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    imgPath,
                                    height: 80,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
