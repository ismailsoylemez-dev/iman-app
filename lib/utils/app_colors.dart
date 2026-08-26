import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan merkezi renk paleti.
/// Kartların arka planla aynı renkte görünmesini (white-on-white) önlemek için
/// background ve card renkleri kasıtlı olarak birbirinden ayrıştırılmıştır.
class AppColors {
  AppColors._();

  // Ana renkler — koyu turkuaz/petrol
  static const Color primaryTeal = Color(0xFF1B5E6E);
  static const Color primaryTealLight = Color(0xFF2C5F7F);
  static const Color primaryTealDark = Color(0xFF123B46);
  static const Color emeraldGreen = primaryTeal;
  static const Color emeraldDark = primaryTealDark;

  // İkincil renkler — yumuşak krem/bej
  static const Color secondaryCream = Color(0xFFE8DCC8);
  static const Color secondaryCreamLight = Color(0xFFF5F1E8);
  static const Color accentGold = accentOrange;
  static const Color goldLight = secondaryCreamLight;

  // Vurgu — turuncu (uyarı/highlight)
  static const Color accentOrange = Color(0xFFD97706);
  static const Color accentOrangeLight = Color(0xFFF3D9B8);

  // Light tema
  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE0DCD3);
  static const Color lightText = Color(0xFF2C2C2C);
  static const Color lightTextSecondary = Color(0xFF5C5C5C);

  // Dark tema
  static const Color darkBackground = Color(0xFF141414);
  static const Color darkCard = Color(0xFF1F1F1F);
  static const Color darkBorder = Color(0xFF3A3A3A);
  static const Color darkText = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  /// Mevcut temaya göre sayfa arka plan rengi.
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  /// Mevcut temaya göre kart arka plan rengi.
  static Color card(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  }

  /// Mevcut temaya göre kart kenarlık rengi.
  static Color border(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;
  }

  /// Mevcut temaya göre birincil metin rengi.
  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkText : lightText;
  }

  /// Mevcut temaya göre ikincil (soluk) metin rengi.
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }
}
