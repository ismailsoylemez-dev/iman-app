import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prayer_guide_model.dart';
import '../widgets/prayer_step_animator.dart';
import '../widgets/step_timer_widget.dart';

class _FlatStep {
  final PrayerStep step;
  final String sectionLabel;

  const _FlatStep(this.step, this.sectionLabel);
}

class PrayerStepsDetailScreen extends StatefulWidget {
  final PrayerGuide guide;

  const PrayerStepsDetailScreen({super.key, required this.guide});

  @override
  State<PrayerStepsDetailScreen> createState() => _PrayerStepsDetailScreenState();
}

class _PrayerStepsDetailScreenState extends State<PrayerStepsDetailScreen> {
  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color emeraldDark = Color(0xFF0F241C);
  static const Color accentGold = Color(0xFFD4AF37);

  Gender _gender = Gender.erkek;
  int _currentIndex = 0;
  late final List<_FlatStep> _flatSteps;

  @override
  void initState() {
    super.initState();
    _flatSteps = [
      for (final section in widget.guide.sections)
        for (final rakat in section.rakats)
          for (final step in rakat.steps) _FlatStep(step, '${section.name} • ${rakat.title}'),
    ];
  }

  String get _riveAssetPath {
    final genderSlug = _gender == Gender.erkek ? 'male' : 'female';
    final prayerSlug = widget.guide.name.toLowerCase().replaceAll(' namazı', '').replaceAll(' ', '_');
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
      setState(() => _currentIndex++);
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flat = _flatSteps[_currentIndex];
    final step = flat.step;
    final timerDuration = _timerDurationForCurrentStep;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.guide.name),
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
              child: SingleChildScrollView(
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
                        key: ValueKey(_currentIndex),
                        duration: timerDuration,
                        onComplete: _goNext,
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
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
