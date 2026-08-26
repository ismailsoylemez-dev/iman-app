import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prayer_guide_model.dart';
import '../widgets/prayer_step_animator.dart';
import '../utils/app_colors.dart';

class WuduGuideScreen extends StatefulWidget {
  final AblutionGuide guide;

  const WuduGuideScreen({super.key, required this.guide});

  @override
  State<WuduGuideScreen> createState() => _WuduGuideScreenState();
}

class _WuduGuideScreenState extends State<WuduGuideScreen> {
  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color accentGold = AppColors.accentOrange;

  Gender _gender = Gender.erkek;
  int _currentIndex = 0;

  String get _riveAssetPath {
    final genderSlug = _gender == Gender.erkek ? 'male' : 'female';
    return 'assets/animations/wudu_$genderSlug.riv';
  }

  void _goNext() {
    if (_currentIndex < widget.guide.steps.length - 1) {
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
    final step = widget.guide.steps[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(widget.guide.title),
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
                    value: (_currentIndex + 1) / widget.guide.steps.length,
                    color: accentGold,
                    backgroundColor: emeraldGreen.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adım ${_currentIndex + 1}/${widget.guide.steps.length}',
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
                      onPressed: _currentIndex < widget.guide.steps.length - 1 ? _goNext : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(_currentIndex < widget.guide.steps.length - 1 ? 'İleri' : 'Tamamlandı'),
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
