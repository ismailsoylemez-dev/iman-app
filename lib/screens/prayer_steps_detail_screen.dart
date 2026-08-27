import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prayer_guide_model.dart';
import '../widgets/prayer_step_animator.dart';
import '../widgets/prayer_video_panel.dart';
import '../widgets/step_timer_widget.dart';
import '../services/tts_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';

class _FlatStep {
  final PrayerStep step;
  final String sectionLabel;
  final int sectionIndex;
  final int rakatNumber;

  const _FlatStep(this.step, this.sectionLabel, this.sectionIndex, this.rakatNumber);
}

class PrayerStepsDetailScreen extends StatefulWidget {
  final PrayerGuide guide;
  final List<PrayerGuide>? allPrayers;

  const PrayerStepsDetailScreen({super.key, required this.guide, this.allPrayers});

  @override
  State<PrayerStepsDetailScreen> createState() => _PrayerStepsDetailScreenState();
}

class _PrayerStepsDetailScreenState extends State<PrayerStepsDetailScreen> with SingleTickerProviderStateMixin {
  Gender _gender = Gender.erkek;
  int _currentIndex = 0;
  bool _ttsEnabled = true;
  late List<_FlatStep> _flatSteps;
  late final PageController _pageController;
  TabController? _prayerTabController;
  late List<PrayerGuide> _prayers;
  late int _prayerIndex;

  @override
  void initState() {
    super.initState();
    _prayers = widget.allPrayers ?? [widget.guide];
    _prayerIndex = _prayers.indexWhere((p) => p.name == widget.guide.name).clamp(0, _prayers.length - 1);
    _flatSteps = _buildFlatSteps(_prayers[_prayerIndex]);
    _pageController = PageController();

    if (_prayers.length > 1) {
      _prayerTabController = TabController(length: _prayers.length, vsync: this, initialIndex: _prayerIndex);
      _prayerTabController!.addListener(_onPrayerTabChanged);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrentStep());
  }

  List<_FlatStep> _buildFlatSteps(PrayerGuide guide) {
    final result = <_FlatStep>[];
    for (var si = 0; si < guide.sections.length; si++) {
      final section = guide.sections[si];
      for (final rakat in section.rakats) {
        for (final step in rakat.steps) {
          result.add(_FlatStep(step, '${section.name} • ${rakat.title}', si, rakat.rakatNumber));
        }
      }
    }
    return result;
  }

  void _onPrayerTabChanged() {
    if (_prayerTabController == null || _prayerTabController!.indexIsChanging) return;
    final newIndex = _prayerTabController!.index;
    if (newIndex == _prayerIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _prayerIndex = newIndex;
      _flatSteps = _buildFlatSteps(_prayers[_prayerIndex]);
      _currentIndex = 0;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }
    _speakCurrentStep();
  }

  String get _riveAssetPath {
    final genderSlug = _gender == Gender.erkek ? 'male' : 'female';
    final prayerSlug = _prayers[_prayerIndex].name.toLowerCase().replaceAll(' namazı', '').replaceAll(' ', '_');
    return 'assets/animations/prayer_${genderSlug}_$prayerSlug.riv';
  }

  /// Namaz rehberi adımları için deneysel CDN video URL'i. Gerçek çalışan bir
  /// endpoint garanti edilmediği için PrayerVideoPanel yükleme hatasında
  /// otomatik olarak placeholder'a düşer.
  String get _videoUrl {
    final actionType = _flatSteps[_currentIndex].step.actionType ?? 'kiyam';
    return 'https://cdn.islamic.network/prayer/videos/$actionType.mp4';
  }

  Duration? get _timerDurationForCurrentStep {
    final actionType = _flatSteps[_currentIndex].step.actionType;
    if (actionType == 'ruku') return const Duration(seconds: 3);
    if (actionType == 'secde') return const Duration(seconds: 4);
    return null;
  }

  int get _currentSectionIndex => _flatSteps[_currentIndex].sectionIndex;

  int get _currentSectionRakatCount => _prayers[_prayerIndex].sections[_currentSectionIndex].rakats.length;

  int get _currentRakatNumber => _flatSteps[_currentIndex].rakatNumber;

  int _flatIndexForRakat(int sectionIndex, int rakatNumber) {
    return _flatSteps.indexWhere((f) => f.sectionIndex == sectionIndex && f.rakatNumber == rakatNumber);
  }

  void _goToRakat(int rakatNumber) {
    final target = _flatIndexForRakat(_currentSectionIndex, rakatNumber);
    if (target == -1 || target == _currentIndex) return;
    HapticFeedback.selectionClick();
    _pageController.animateToPage(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  void _speakCurrentStep() {
    if (!_ttsEnabled) return;
    final step = _flatSteps[_currentIndex].step;
    TtsService.instance.speak('${step.title}. ${step.getDescription(_gender)}');
  }

  void _goNext() {
    if (_currentIndex < _flatSteps.length - 1) {
      HapticFeedback.selectionClick();
      _pageController.animateToPage(
        _currentIndex + 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      HapticFeedback.selectionClick();
      _pageController.animateToPage(
        _currentIndex - 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _prayerTabController?.dispose();
    TtsService.instance.stop();
    super.dispose();
  }

  Widget _buildStepPage(_FlatStep flat) {
    final step = flat.step;
    final timerDuration = _timerDurationForCurrentStep;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          PrayerStepAnimator(rivAssetPath: _riveAssetPath, height: 220),
          const SizedBox(height: 10),
          PrayerVideoPanel(videoUrl: _videoUrl, height: 160),
          const SizedBox(height: 16),
          Text(step.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text(context))),
          const SizedBox(height: 8),
          Text(
            step.getDescription(_gender),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary(context)),
          ),
          if (step.arabicText != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.card(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Text(
                step.arabicText!,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 21, height: 1.9, fontFamily: AppTypography.arabicFontFamily, color: AppColors.text(context)),
              ),
            ),
          ],
          if (step.meaning != null) ...[
            const SizedBox(height: 10),
            Text(
              step.meaning!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic, color: AppColors.textSecondary(context)),
            ),
          ],
          if (timerDuration != null) ...[
            const SizedBox(height: 16),
            StepTimerWidget(
              key: ValueKey('${_prayerIndex}_$_currentIndex'),
              duration: timerDuration,
              onComplete: _goNext,
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flat = _flatSteps[_currentIndex];
    final accent = AppColors.accent(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(_prayers[_prayerIndex].name),
        actions: [
          IconButton(
            tooltip: _ttsEnabled ? 'Sesli rehberi kapat' : 'Sesli rehberi aç',
            icon: Icon(_ttsEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
            onPressed: () {
              setState(() => _ttsEnabled = !_ttsEnabled);
              if (_ttsEnabled) {
                _speakCurrentStep();
              } else {
                TtsService.instance.stop();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: SegmentedButton<Gender>(
                segments: const [
                  ButtonSegment(value: Gender.erkek, label: Text('Erkek')),
                  ButtonSegment(value: Gender.kadin, label: Text('Kadın')),
                ],
                selected: {_gender},
                onSelectionChanged: (selection) => setState(() => _gender = selection.first),
              ),
            ),
          ),
        ],
        bottom: _prayerTabController != null
            ? TabBar(
                controller: _prayerTabController,
                isScrollable: true,
                indicatorColor: accent,
                indicatorWeight: 3,
                labelColor: AppColors.onPrimary,
                unselectedLabelColor: AppColors.onPrimarySecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                tabs: _prayers.map((p) => Tab(text: p.name)).toList(),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _flatSteps.length,
                    color: accent,
                    backgroundColor: AppColors.border(context),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adım ${_currentIndex + 1}/${_flatSteps.length} — ${flat.sectionLabel}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text(context)),
                  ),
                  if (_currentSectionRakatCount > 1) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('Rekat', style: TextStyle(fontSize: 12, color: AppColors.textSecondary(context))),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: _currentSectionRakatCount.toDouble(),
                            divisions: _currentSectionRakatCount - 1,
                            value: _currentRakatNumber.toDouble().clamp(1, _currentSectionRakatCount.toDouble()),
                            label: '$_currentRakatNumber. Rekat',
                            activeColor: accent,
                            onChanged: (v) => _goToRakat(v.round()),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _flatSteps.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  _speakCurrentStep();
                },
                itemBuilder: (context, index) => _buildStepPage(_flatSteps[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _currentIndex > 0 ? _goBack : null,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Geri'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentIndex < _flatSteps.length - 1 ? _goNext : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(_currentIndex < _flatSteps.length - 1 ? 'İleri' : 'Tamamlandı'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary(context), foregroundColor: AppColors.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
