import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Dua kategorisini küçük, renk kodlu bir rozet olarak gösterir.
/// Renk eşlemesi kategoriye özeldir; rozet zemini rengin %18 opaklığı,
/// metin rengi ise koyu temada rengin kendisi, açık temada %15 karartılmış
/// hali kullanılarak okunabilirlik sağlanır.
class CategoryBadge extends StatelessWidget {
  final String category;
  final double fontScale;

  const CategoryBadge({super.key, required this.category, this.fontScale = 1.0});

  static const Map<String, Color> _categoryColors = {
    'Sabah/Akşam': Color(0xFFE8B84B),
    'Huzur': Color(0xFF6BA98E),
    'Şifa': Color(0xFF7FA8D9),
    'Korunma': Color(0xFFC88A6B),
    'Rızık': Color(0xFFA8B76B),
    'Bağışlanma': Color(0xFFB08FC7),
    'Sıkıntı': Color(0xFFD98B8B),
    'Peygamber Duaları': Color(0xFF8FA6C4),
    'Kandil & Bayramlar': Color(0xFFD4AF6B),
  };

  /// VARSAYIM: Listede geçmeyen/tanınmayan bir kategori gelirse (veri
  /// hatası ya da ileride eklenecek yeni kategori), rozetin kırılmaması
  /// için nötr bir renk kullanılır.
  static const Color _fallbackColor = AppColors.lightTextSecondary;

  static Color colorFor(String category) => _categoryColors[category] ?? _fallbackColor;

  static Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = colorFor(category);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? baseColor : _darken(baseColor, 0.15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10.5 * fontScale,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
