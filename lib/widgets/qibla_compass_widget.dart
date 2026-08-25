import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';

class QiblaCompassWidget extends StatelessWidget {
  final double qiblaDirection;

  const QiblaCompassWidget({super.key, required this.qiblaDirection});

  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF212529);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final double? heading = snapshot.hasData ? snapshot.data?.heading : null;
        final bool hasSensor = !snapshot.hasError && heading != null;
        final double relativeAngle = hasSensor ? (qiblaDirection - heading) * (math.pi / 180) : 0;

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
                        border: Border.all(color: accentGold.withValues(alpha: 0.8), width: 2),
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
              Text(
                hasSensor ? 'Kıble yönü canlı takip ediliyor' : 'Sabit açı gösteriliyor (sensör yok)',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      },
    );
  }
}
