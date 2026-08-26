import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../utils/app_colors.dart';

class QiblaCompassWidget extends StatelessWidget {
  final double qiblaDirection;

  const QiblaCompassWidget({super.key, required this.qiblaDirection});

  static const Color emeraldGreen = AppColors.primaryTeal;
  static const Color accentGold = AppColors.accentOrange;
  static const Color darkText = AppColors.lightText;
  static const Color accuracyGood = Color(0xFF4CAF50);
  static const Color accuracyMedium = Color(0xFFFFC107);
  static const Color accuracyPoor = Color(0xFFEF5350);
  static const Color accuracyUnknown = Color(0xFF9E9E9E);

  ({Color color, String label}) _accuracyInfo(double? accuracyRadians, bool hasSensor) {
    if (!hasSensor) return (color: accuracyUnknown, label: 'Sensör yok');
    if (accuracyRadians == null) return (color: accuracyMedium, label: 'Doğruluk bilinmiyor');
    final accuracyDegrees = accuracyRadians.abs() * (180 / math.pi);
    if (accuracyDegrees <= 15) return (color: accuracyGood, label: 'Yüksek doğruluk');
    if (accuracyDegrees <= 40) return (color: accuracyMedium, label: 'Orta doğruluk');
    return (color: accuracyPoor, label: 'Düşük doğruluk (kalibre edin)');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final double? heading = snapshot.hasData ? snapshot.data?.heading : null;
        final bool hasSensor = !snapshot.hasError && heading != null;
        final double relativeAngle = hasSensor ? (qiblaDirection - heading) * (math.pi / 180) : 0;
        final accuracy = _accuracyInfo(snapshot.data?.accuracy, hasSensor);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9ECEF)),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF8F9FA),
                        border: Border.all(color: accuracy.color, width: 3),
                      ),
                    ),
                    AnimatedRotation(
                      turns: relativeAngle / (2 * math.pi),
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(Icons.navigation_rounded, size: 48, color: emeraldGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${qiblaDirection.toStringAsFixed(0)}°',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: emeraldGreen),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: accuracy.color),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    accuracy.label,
                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                hasSensor ? 'Kıble yönü canlı takip ediliyor' : 'Sabit açı gösteriliyor (sensör yok)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }
}
