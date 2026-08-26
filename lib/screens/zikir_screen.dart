import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/zikir_model.dart';
import '../services/zikir_storage_service.dart';
import '../utils/app_colors.dart';

class ZikirScreen extends StatefulWidget {
  const ZikirScreen({super.key});

  @override
  State<ZikirScreen> createState() => _ZikirScreenState();
}

class _ZikirScreenState extends State<ZikirScreen> {
  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color emeraldDark = AppColors.primaryTealDark;
  static const Color accentGold = AppColors.accentOrange;
  static const Color goldLight = AppColors.secondaryCreamLight;

  ZikirModel _currentZikir = ZikirModel.defaultZikirler[0];
  List<ZikirModel> _customZikirler = [];

  int _count = 0;
  int _target = 33;
  int _lap = 0;

  int _todayTotal = 0;
  int _weeklyTotal = 0;

  bool _isVibrationEnabled = true;

  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final customList = await ZikirStorageService.getCustomZikirler();
    final activeId = await ZikirStorageService.getActiveZikirId();
    final vibration = await ZikirStorageService.isVibrationEnabled();
    final today = await ZikirStorageService.getTodayTotalCount();
    final weekly = await ZikirStorageService.getWeeklyTotalCount();

    final allAvailable = [...ZikirModel.defaultZikirler, ...customList];

    ZikirModel initialZikir = allAvailable[0];
    if (activeId != null) {
      initialZikir = allAvailable.firstWhere(
        (z) => z.id == activeId,
        orElse: () => allAvailable[0],
      );
    }

    final count = await ZikirStorageService.getCount(initialZikir.id);
    final lap = await ZikirStorageService.getLap(initialZikir.id);
    final target = await ZikirStorageService.getTarget(
      initialZikir.id,
      initialZikir.defaultTarget,
    );

    if (mounted) {
      setState(() {
        _customZikirler = customList;
        _currentZikir = initialZikir;
        _count = count;
        _lap = lap;
        _target = target;
        _isVibrationEnabled = vibration;
        _todayTotal = today;
        _weeklyTotal = weekly;
      });
    }
  }

  void _incrementCount() {
    if (_isVibrationEnabled) {
      HapticFeedback.lightImpact();
    }

    ZikirStorageService.recordDhikrIncrement();

    setState(() {
      _count++;
      _todayTotal++;
      _weeklyTotal++;

      if (_target > 0 && _count >= _target) {
        _count = 0;
        _lap++;
        if (_isVibrationEnabled) {
          HapticFeedback.heavyImpact();
        }
        _showTargetCompletedSnackBar();
      }
    });

    ZikirStorageService.saveCount(_currentZikir.id, _count);
    ZikirStorageService.saveLap(_currentZikir.id, _lap);
  }

  void _decrementCount() {
    if (_count > 0) {
      if (_isVibrationEnabled) {
        HapticFeedback.selectionClick();
      }
      setState(() {
        _count--;
      });
      ZikirStorageService.saveCount(_currentZikir.id, _count);
    }
  }

  void _resetCount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Sayacı Sıfırla'),
        content: Text('"${_currentZikir.title}" için çekilen zikir ve tur sayısını sıfırlamak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _count = 0;
                _lap = 0;
              });
              ZikirStorageService.resetZikir(_currentZikir.id);
            },
            child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTargetCompletedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tebrikler! "${_currentZikir.title}" hedefinizi ($_target) tamamladınız.'),
        backgroundColor: emeraldGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _switchZikir(ZikirModel zikir) async {
    final count = await ZikirStorageService.getCount(zikir.id);
    final lap = await ZikirStorageService.getLap(zikir.id);
    final target = await ZikirStorageService.getTarget(zikir.id, zikir.defaultTarget);

    setState(() {
      _currentZikir = zikir;
      _count = count;
      _lap = lap;
      _target = target;
    });

    ZikirStorageService.saveActiveZikirId(zikir.id);
  }

  void _showAddCustomZikirBottomSheet() {
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: '33');
    final meaningController = TextEditingController();
    final arabicController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Özel Zikir Ekle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: emeraldGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Zikir Başlığı *',
                  hintText: 'Örn: Salât-ı Tefriciye',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Hedef Sayı *',
                  hintText: '33, 100, 4444 vb.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: meaningController,
                decoration: InputDecoration(
                  labelText: 'Anlamı / Niyeti',
                  hintText: 'Dilek, hacet, şifa duası vb.',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: arabicController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'Arapça Metin (İsteğe Bağlı)',
                  hintText: 'اللّٰهُمَّ...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: emeraldGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final title = titleController.text.trim();
                  final target = int.tryParse(targetController.text.trim()) ?? 33;
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lütfen zikir başlığını giriniz.')),
                    );
                    return;
                  }

                  final newZikir = ZikirModel(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    arabic: arabicController.text.trim().isEmpty ? 'بِسْمِ اللّٰهِ' : arabicController.text.trim(),
                    transliteration: title,
                    meaning: meaningController.text.trim().isEmpty ? 'Özel niyet zikri' : meaningController.text.trim(),
                    defaultTarget: target,
                    isCustom: true,
                  );

                  await ZikirStorageService.saveCustomZikir(newZikir);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  _loadSavedData();
                  _switchZikir(newZikir);

                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text('"$title" başarıyla eklendi.'),
                        backgroundColor: emeraldGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text(
                  'Zikri Kaydet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showZikirListBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final allZikirler = [...ZikirModel.defaultZikirler, ..._customZikirler];

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Zikir Listesi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: emeraldGreen,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddCustomZikirBottomSheet();
                        },
                        icon: const Icon(Icons.add, size: 16, color: Colors.white),
                        label: const Text('Özel Ekle', style: TextStyle(color: Colors.white, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGold,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: allZikirler.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final zikir = allZikirler[index];
                      final isSelected = zikir.id == _currentZikir.id;

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? accentGold : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        tileColor: isSelected ? emeraldGreen.withValues(alpha: 0.08) : Colors.grey.shade50,
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? emeraldGreen : Colors.grey.shade200,
                          foregroundColor: isSelected ? Colors.white : Colors.black87,
                          child: Text(
                            '${zikir.defaultTarget}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          zikir.title,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? emeraldGreen : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          zikir.meaning,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: zikir.isCustom
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () async {
                                  await ZikirStorageService.deleteCustomZikir(zikir.id);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                  _loadSavedData();
                                },
                              )
                            : (isSelected ? const Icon(Icons.check_circle, color: emeraldGreen) : null),
                        onTap: () {
                          _switchZikir(zikir);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSetTargetDialog() {
    final controller = TextEditingController(text: _target.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hedef Sayı Belirle'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Örn: 33, 99, 100, 500...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: emeraldGreen),
            onPressed: () {
              final newTarget = int.tryParse(controller.text) ?? _target;
              setState(() {
                _target = newTarget;
              });
              ZikirStorageService.saveTarget(_currentZikir.id, newTarget);
              Navigator.pop(context);
            },
            child: const Text('Kaydet', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _target > 0 ? (_count / _target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zikirmatik'),
        actions: [
          IconButton(
            tooltip: 'Özel Zikir Ekle',
            icon: const Icon(Icons.add_circle_outline, color: accentGold),
            onPressed: _showAddCustomZikirBottomSheet,
          ),
          IconButton(
            tooltip: 'Zikir Listesi',
            icon: const Icon(Icons.format_list_bulleted_rounded),
            onPressed: _showZikirListBottomSheet,
          ),
          IconButton(
            tooltip: _isVibrationEnabled ? 'Titreşimi Kapat' : 'Titreşimi Aç',
            icon: Icon(_isVibrationEnabled ? Icons.vibration : Icons.mobile_off_outlined),
            onPressed: () {
              setState(() {
                _isVibrationEnabled = !_isVibrationEnabled;
              });
              ZikirStorageService.setVibrationEnabled(_isVibrationEnabled);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // İstatistik Rozetleri (Bugün & Bu Hafta)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: emeraldGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.today_rounded, color: emeraldGreen, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Bugün Toplam', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                                  Text(
                                    '$_todayTotal Zikir',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: emeraldGreen),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: accentGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.calendar_view_week_rounded, color: accentGold, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Bu Hafta Toplam', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                                  Text(
                                    '$_weeklyTotal Zikir',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8C6D0F)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Aktif Zikir Kartı
                InkWell(
                  onTap: _showZikirListBottomSheet,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [emeraldDark, emeraldGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: accentGold.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.swap_horiz, size: 14, color: accentGold),
                                  SizedBox(width: 4),
                                  Text(
                                    'Zikri Değiştir',
                                    style: TextStyle(color: accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: _showSetTargetDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Hedef: $_target',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _currentZikir.arabic,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: goldLight,
                            fontSize: 24,
                            fontFamily: 'serif',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentZikir.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentZikir.meaning,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Dairesel İlerleme ve Zikirmatik Butonu
                GestureDetector(
                  onTapDown: (_) => setState(() => _buttonScale = 0.94),
                  onTapUp: (_) {
                    setState(() => _buttonScale = 1.0);
                    _incrementCount();
                  },
                  onTapCancel: () => setState(() => _buttonScale = 1.0),
                  child: AnimatedScale(
                    scale: _buttonScale,
                    duration: const Duration(milliseconds: 90),
                    child: SizedBox(
                      width: 230,
                      height: 230,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Arka plan dairesi
                          SizedBox(
                            width: 230,
                            height: 230,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 10,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(accentGold),
                            ),
                          ),
                          // Ana Dokunma Diski
                          Container(
                            width: 195,
                            height: 195,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFF2D6A4F), emeraldGreen],
                                radius: 0.85,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: emeraldGreen.withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_count',
                                  style: const TextStyle(
                                    fontSize: 54,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Hedef: $_target  |  Tur: $_lap',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: goldLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Alt Hızlı Kontrol Butonları (-1, Sıfırla, Tam Ekran Dokunma)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // -1 Geri Al
                      IconButton.filledTonal(
                        tooltip: '1 Geri Al',
                        icon: const Icon(Icons.undo_rounded),
                        onPressed: _count > 0 ? _decrementCount : null,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                      // Sıfırla Butonu
                      ElevatedButton.icon(
                        onPressed: _resetCount,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Sıfırla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red.shade700,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.red.shade100),
                          ),
                        ),
                      ),
                      // Hedef Ayarı
                      IconButton.filledTonal(
                        tooltip: 'Hedef Değiştir',
                        icon: const Icon(Icons.tune_rounded),
                        onPressed: _showSetTargetDialog,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
