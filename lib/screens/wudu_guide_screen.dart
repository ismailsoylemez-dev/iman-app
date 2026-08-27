import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prayer_guide_model.dart';
import '../widgets/prayer_step_animator.dart';
import '../widgets/step_timer_widget.dart';
import '../services/tts_service.dart';
import '../utils/app_colors.dart';

class WuduGuideScreen extends StatefulWidget {
  final AblutionGuide guide;

  const WuduGuideScreen({super.key, required this.guide});

  @override
  State<WuduGuideScreen> createState() => _WuduGuideScreenState();
}

/// actionType'a göre önerilen adım süresi. Listelenmeyen adımlar için
/// varsayılan olarak 10 saniye kullanılır.
const Map<String, Duration> _kStepDurations = {
  'niyet': Duration(seconds: 5),
  'eller': Duration(seconds: 10),
  'agiz': Duration(seconds: 10),
  'burun': Duration(seconds: 10),
  'yuz': Duration(seconds: 20),
  'kollar': Duration(seconds: 20),
  'bas': Duration(seconds: 10),
  'kulaklar': Duration(seconds: 10),
  'boyun': Duration(seconds: 10),
  'ayaklar': Duration(seconds: 20),
};

class _WuduGuideScreenState extends State<WuduGuideScreen> {
  Gender _gender = Gender.erkek;
  int _currentIndex = 0;

  String get _riveAssetPath {
    final genderSlug = _gender == Gender.erkek ? 'male' : 'female';
    return 'assets/animations/wudu_$genderSlug.riv';
  }

  Duration _durationForStep(AblutionStep step) {
    return _kStepDurations[step.actionType] ?? const Duration(seconds: 10);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakCurrentStep());
  }

  void _speakCurrentStep() {
    final step = widget.guide.steps[_currentIndex];
    TtsService.instance.speak('Şimdi ${step.title}. ${step.getDescription(_gender)}');
  }

  void _goNext() {
    if (_currentIndex < widget.guide.steps.length - 1) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex++);
      _speakCurrentStep();
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex--);
      _speakCurrentStep();
    }
  }

  void _restart() {
    HapticFeedback.mediumImpact();
    setState(() => _currentIndex = 0);
    _speakCurrentStep();
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.guide.steps[_currentIndex];
    final isLast = _currentIndex == widget.guide.steps.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(widget.guide.title),
        actions: [
          IconButton(
            tooltip: 'Tekrar Et',
            icon: const Icon(Icons.replay_rounded),
            onPressed: _restart,
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / widget.guide.steps.length,
                    color: AppColors.accent(context),
                    backgroundColor: AppColors.border(context),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adım ${_currentIndex + 1}/${widget.guide.steps.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text(context)),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text(context)),
                        ),
                        const SizedBox(width: 12),
                        StepTimerWidget(
                          key: ValueKey(_currentIndex),
                          duration: _durationForStep(step),
                          onComplete: isLast ? null : _goNext,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step.getDescription(_gender),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, height: 1.4, color: AppColors.textSecondary(context)),
                    ),
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
                      onPressed: !isLast ? _goNext : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(!isLast ? 'İleri' : 'Tamamlandı'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: AppColors.onPrimary,
                      ),
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
