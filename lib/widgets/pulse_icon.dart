import 'package:flutter/material.dart';

/// Ses çalarken hafifçe büyüyüp küçülen (pulse) ikon; sadece [pulsing] true
/// iken animasyon çalışır. Dinle düğmesi görünen her yerde (liste kartı,
/// detay görünümü, günün duası kartı) tekrar kullanılır.
class PulseIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool pulsing;

  const PulseIcon({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    required this.pulsing,
  });

  @override
  State<PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<PulseIcon> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant PulseIcon oldWidget) {
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
