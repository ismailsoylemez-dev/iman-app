import 'package:flutter/material.dart';

import '../models/dua_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import 'category_badge.dart';
import 'pulse_icon.dart';

/// Dua listesindeki sade kart. Yalnızca başlık, kategori rozeti, kaynak
/// satırı (Kur'an duasında), dinle düğmesi ve favori düğmesini gösterir.
/// Arapça metin, meal, fazilet ve etiketler burada RENDER EDİLMEZ —
/// bunlar dokununca açılan [DuaDetailSheet]'te gösterilir.
class DuaListCard extends StatelessWidget {
  final DuaModel dua;
  final bool isFavorite;
  final bool isPlaying;
  final bool isBuffering;
  final double fontScale;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback onPlayPause;

  const DuaListCard({
    super.key,
    required this.dua,
    required this.isFavorite,
    required this.isPlaying,
    required this.isBuffering,
    required this.fontScale,
    required this.onTap,
    required this.onToggleFavorite,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final isQuranSource = dua.source == 'Quran';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border(context)),
      ),
      color: AppColors.card(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      dua.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle(context, fontScale: fontScale),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? Colors.red.shade600 : AppColors.textSecondary(context),
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    visualDensity: VisualDensity.compact,
                    tooltip: isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                    onPressed: onToggleFavorite,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  CategoryBadge(category: dua.category, fontScale: fontScale),
                  if (isQuranSource)
                    Text(
                      '${dua.surahName} ${dua.ayahNo}',
                      style: AppTypography.label(context, fontScale: fontScale),
                    ),
                ],
              ),
              if (dua.hasAudio) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: onPlayPause,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isBuffering)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent(context)),
                          )
                        else
                          PulseIcon(
                            icon: isPlaying ? Icons.pause_circle_filled_rounded : Icons.volume_up_rounded,
                            size: 20,
                            color: isPlaying ? AppColors.accent(context) : AppColors.primary(context),
                            pulsing: isPlaying,
                          ),
                        const SizedBox(width: 4),
                        Text(
                          isBuffering ? 'Yükleniyor...' : (isPlaying ? 'Durdur' : 'Dinle'),
                          style: TextStyle(
                            fontSize: 12.5 * fontScale,
                            fontWeight: FontWeight.w600,
                            color: isPlaying || isBuffering ? AppColors.accent(context) : AppColors.primary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
