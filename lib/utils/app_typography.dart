import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Uygulama genelinde kullanılan merkezi tipografi ölçeği.
///
/// Latin metinler Manrope, Arapça metinler Amiri fontuyla çizilir.
/// Tüm boyutlar `fontScale` çarpanıyla ölçeklenir (kullanıcının ayarlardan
/// seçtiği yazı büyüklüğü — ekran başlıkları dahil, yalnızca gövde metni değil).
class AppTypography {
  AppTypography._();

  static const String latinFontFamily = 'Manrope';
  static const String arabicFontFamily = 'Amiri';

  /// Ekran başlığı (AppBar vb.) — 22 sp, Manrope SemiBold.
  static TextStyle screenTitle(BuildContext context, {double fontScale = 1.0, Color? color}) {
    return TextStyle(
      fontFamily: latinFontFamily,
      fontSize: 22 * fontScale,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.text(context),
    );
  }

  /// Kart başlığı — 17 sp, Manrope SemiBold.
  static TextStyle cardTitle(BuildContext context, {double fontScale = 1.0, Color? color}) {
    return TextStyle(
      fontFamily: latinFontFamily,
      fontSize: 17 * fontScale,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.text(context),
    );
  }

  /// Gövde metni — 15 sp, Manrope Regular.
  static TextStyle body(BuildContext context, {double fontScale = 1.0, Color? color}) {
    return TextStyle(
      fontFamily: latinFontFamily,
      fontSize: 15 * fontScale,
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.text(context),
    );
  }

  /// Yardımcı/etiket metni — 12.5 sp, Manrope Medium, letterSpacing 0.3.
  static TextStyle label(BuildContext context, {double fontScale = 1.0, Color? color}) {
    return TextStyle(
      fontFamily: latinFontFamily,
      fontSize: 12.5 * fontScale,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.3,
      color: color ?? AppColors.textSecondary(context),
    );
  }

  /// Arapça metin — 21 sp, Amiri Regular, height 1.9, sağa hizalı/RTL.
  /// Kullanım: Text(arabicText, textAlign: TextAlign.right, textDirection: TextDirection.rtl,
  /// style: AppTypography.arabic(context, fontScale: fontScale)).
  static TextStyle arabic(BuildContext context, {double fontScale = 1.0, Color? color}) {
    return TextStyle(
      fontFamily: arabicFontFamily,
      fontSize: 21 * fontScale,
      fontWeight: FontWeight.w400,
      height: 1.9,
      color: color ?? AppColors.text(context),
    );
  }

  /// Okunuş (transliterasyon) — 14 sp, Manrope Regular italik.
  static TextStyle transliteration(BuildContext context, {double fontScale = 1.0, Color? color}) {
    return TextStyle(
      fontFamily: latinFontFamily,
      fontSize: 14 * fontScale,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: color ?? AppColors.textSecondary(context),
    );
  }
}
