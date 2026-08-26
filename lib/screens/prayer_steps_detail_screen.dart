import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prayer_guide_model.dart';
import '../widgets/prayer_step_animator.dart';
import '../widgets/step_timer_widget.dart';
import '../utils/app_colors.dart';

class _FlatStep {
  final PrayerStep step;
  final String sectionLabel;

  const _FlatStep(this.step, this.sectionLabel);
}

class PrayerStepsDetailScreen extends StatefulWidget {
  final PrayerGuide guide;
  final List<PrayerGuide>? allPrayers;

  const PrayerStepsDetailScreen({super.key, required this.guide, this.allPrayers});

  @override
  State<PrayerStepsDetailScreen> createState() => _PrayerStepsDetailScreenState();
}

class _PrayerStepsDetailScreenState extends State<PrayerStepsDetailScreen> with SingleTickerProviderStateMixin {
  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color emeraldDark = AppColors.primaryTealDark;
  static const Color accentGold = AppColors.accentOrange;

  Gender _gender = Gender.erkek;
  int _currentIndex = 0;
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
  }

  List<_FlatStep> _buildFlatSteps(PrayerGuide guide) {
    return [
      for (final section in guide.sections)
        for (final rakat in section.rakats)
          for (final step in rakat.steps) _FlatStep(step, '${section.name} • ${rakat.title}'),
    ];
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
  }

  String get _riveAssetPath {
    final genderSlug = _gender == Gender.erkek ? 'male' : 'female';
    final prayerSlug = _prayers[_prayerIndex].name.toLowerCase().replaceAll(' namazı', '').replaceAll(' ', '_');
    return 'assets/animations/prayer_${genderSlug}_$prayerSlug.riv';
  }

  Duration? get _timerDurationForCurrentStep {
    final actionType = _flatSteps[_currentIndex].step.actionType;
    if (actionType == 'ruku') return const Duration(seconds: 3);
    if (actionType == 'secde') return const Duration(seconds: 4);
    return null;
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
          const SizedBox(height: 16),
          Text(step.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: emeraldGreen)),
          const SizedBox(height: 8),
          Text(
            step.getDescription(_gender),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
          if (step.arabicText != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Text(
                step.arabicText!,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 19, height: 1.7, fontFamily: 'serif', color: emeraldDark),
              ),
            ),
          ],
          if (step.meaning != null) ...[
            const SizedBox(height: 10),
            Text(step.meaning!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(_prayers[_prayerIndex].name),
        actions: [
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
                indicatorColor: accentGold,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
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
                    color: accentGold,
                    backgroundColor: emeraldGreen.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adım ${_currentIndex + 1}/${_flatSteps.length} — ${flat.sectionLabel}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: emeraldGreen),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _flatSteps.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
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
                      style: ElevatedButton.styleFrom(backgroundColor: emeraldGreen, foregroundColor: Colors.white),
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
