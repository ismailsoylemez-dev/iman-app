import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

/// Rive animasyonunu oynatır; henüz eklenmemiş .riv dosyaları için
/// (tasarımcı tarafından sonradan eklenecekleri için) zarif bir yer tutucuya düşer.
class PrayerStepAnimator extends StatelessWidget {
  final String rivAssetPath;
  final double? width;
  final double? height;

  const PrayerStepAnimator({
    super.key,
    required this.rivAssetPath,
    this.width,
    this.height,
  });

  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color goldLight = Color(0xFFF9E8B2);

  Future<bool> _assetExists() async {
    try {
      await rootBundle.load(rivAssetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder<bool>(
        future: _assetExists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: emeraldGreen, strokeWidth: 2));
          }

          if (snapshot.data != true) {
            return _buildPlaceholder();
          }

          return RiveAnimation.asset(
            rivAssetPath,
            fit: BoxFit.contain,
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: goldLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.self_improvement_rounded, size: 64, color: emeraldGreen),
    );
  }
}
