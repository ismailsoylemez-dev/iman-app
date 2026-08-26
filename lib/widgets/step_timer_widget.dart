import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class StepTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;

  const StepTimerWidget({super.key, required this.duration, this.onComplete});

  @override
  State<StepTimerWidget> createState() => _StepTimerWidgetState();
}

class _StepTimerWidgetState extends State<StepTimerWidget> {
  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color accentGold = AppColors.accentOrange;

  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    HapticFeedback.lightImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remaining -= const Duration(seconds: 1);
      });
      HapticFeedback.selectionClick();
      if (_remaining.inSeconds <= 0) {
        timer.cancel();
        HapticFeedback.mediumImpact();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant StepTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _timer?.cancel();
      _remaining = widget.duration;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.duration.inMilliseconds == 0 ? 1 : widget.duration.inMilliseconds;
    final progress = 1 - (_remaining.inMilliseconds.clamp(0, total) / total);

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: emeraldGreen.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(accentGold),
            ),
          ),
          Text(
            '${_remaining.inSeconds < 0 ? 0 : _remaining.inSeconds}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: emeraldGreen,
            ),
          ),
        ],
      ),
    );
  }
}
