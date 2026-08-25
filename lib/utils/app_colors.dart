import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan merkezi renk paleti.
/// Kartların arka planla aynı renkte görünmesini (white-on-white) önlemek için
/// background ve card renkleri kasıtlı olarak birbirinden ayrıştırılmıştır.
class AppColors {
  AppColors._();

  static const Color emeraldGreen = Color(0xFF1B4332);
  static const Color emeraldDark = Color(0xFF0F241C);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF9E8B2);

  // Light tema
  static const Color lightBackground = Color(0xFFFAFBFC);
  static const Color lightCard = Color(0xFFF5F7FA);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightText = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF4A5568);

  // Dark tema
  static const Color darkBackground = Color(0xFF0F1419);
  static const Color darkCard = Color(0xFF1A1F2E);
  static const Color darkBorder = Color(0xFF404854);
  static const Color darkText = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFB0B8C4);

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
