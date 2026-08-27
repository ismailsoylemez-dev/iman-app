import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan merkezi renk paleti.
/// Kartların arka planla aynı renkte görünmesini (white-on-white) önlemek için
/// background ve surface (kart) renkleri kasıtlı olarak birbirinden ayrıştırılmıştır:
/// açık temada zemin hafif yeşilimsi bir nötr, kart ise saf beyazdır; koyu temada
/// da aralarında belirgin bir fark vardır. Değerler WCAG AA kontrastı için seçilmiştir.
class AppColors {
  AppColors._();

  // ---- Açık tema ----
  static const Color lightBackground = Color(0xFFF1F4F1);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFE9EEEA);
  static const Color lightBorder = Color(0xFFD7E0D9);
  static const Color lightText = Color(0xFF1A2420);
  static const Color lightTextSecondary = Color(0xFF5A6B63);
  static const Color lightPrimary = Color(0xFF2D6A4F);
  static const Color lightPrimaryDark = Color(0xFF1B4332);
  static const Color lightAccent = Color(0xFFC9A227);

  // ---- Koyu tema ----
  static const Color darkBackground = Color(0xFF0E1512);
  static const Color darkSurface = Color(0xFF1A2420);
  static const Color darkSurfaceAlt = Color(0xFF23302A);
  static const Color darkBorder = Color(0xFF2E3E36);
  static const Color darkText = Color(0xFFE6EDE8);
  static const Color darkTextSecondary = Color(0xFF9BAAA2);
  static const Color darkPrimary = Color(0xFF52B788);
  static const Color darkPrimaryDark = Color(0xFF14201A);
  static const Color darkAccent = Color(0xFFE0BC4A);

  /// Gradyan/koyu renkli (primary tonlu) zeminler üzerindeki birincil metin/ikon rengi.
  /// Tema fark etmeksizin sabittir; çünkü bu zeminler (örn. "Günün Duası" kartı,
  /// hikaye paylaşım modalı) kasıtlı olarak her iki temada da koyu/renkli kalır.
  static const Color onPrimary = Colors.white;

  /// Aynı zeminler üzerindeki ikincil (soluk) metin rengi.
  static const Color onPrimarySecondary = Color(0xB3FFFFFF); // ~%70 opak beyaz

  // ---- Ekrana özgü, ana paletin parçası olmayan sabit renkler ----
  // VARSAYIM: Bu tonlar yeni palette dahil edilmedi; görünümü bozmamak için
  // önceki tasarımdaki değerleriyle korunup merkezi hale getirildi.
  static const Color streakOrange = Color(0xFFE67E22);
  static const Color statusGood = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFC107);
  static const Color statusCritical = Color(0xFFEF5350);
  static const Color badgeGoldText = Color(0xFF8C6D0F);
  static const Color storyBackground = Color(0xFF121212);

  // ---- Eski isimler (geriye dönük uyumluluk) — yeni değerlere yönlendirilir ----
  static const Color primaryTeal = lightPrimary;
  static const Color primaryTealLight = lightPrimary;
  static const Color primaryTealDark = lightPrimaryDark;
  static const Color emeraldGreen = lightPrimary;
  static const Color emeraldDark = lightPrimaryDark;

  static const Color secondaryCream = lightSurfaceAlt;
  static const Color secondaryCreamLight = lightSurfaceAlt;
  static const Color accentGold = lightAccent;
  static const Color goldLight = lightSurfaceAlt;

  static const Color accentOrange = lightAccent;
  static const Color accentOrangeLight = lightSurfaceAlt;
  static const Color accentOrangeDark = darkAccent;

  static const Color lightCard = lightSurface;
  static const Color darkCard = darkSurface;

  /// Mevcut temaya göre sayfa arka plan rengi.
  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  /// Mevcut temaya göre kart/yüzey rengi.
  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  /// Mevcut temaya göre kart arka plan rengi (surface ile aynı; eski isim korunuyor).
  static Color card(BuildContext context) => surface(context);

  /// Mevcut temaya göre ikincil yüzey rengi (seçili durum, vurgulu satır vb.).
  static Color surfaceAlt(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSurfaceAlt : lightSurfaceAlt;
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

  /// Mevcut temaya göre birincil (yeşil) marka rengi.
  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkPrimary : lightPrimary;
  }

  /// Mevcut temaya göre koyu vurgulu birincil renk (AppBar, koyu bloklar).
  static Color primaryDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkPrimaryDark : lightPrimaryDark;
  }

  /// Mevcut temaya göre vurgu (accent/altın) rengi — dark modda daha parlak.
  static Color accent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkAccent : lightAccent;
  }

  /// Hata/kritik uyarı arka plan tonu (açık ve koyu temada uyumlu).
  static Color statusCriticalSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF3B1F1E) 
        : const Color(0xFFFFEBEE);
  }

  /// Buton/chip seçilmemiş arka plan.
  static Color chipBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF26332D) 
        : const Color(0xFFE0E5E2);
  }
}
