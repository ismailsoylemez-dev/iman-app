import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

import '../models/dua_model.dart';
import '../services/dua_service.dart';
import '../services/dua_audio_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import 'category_badge.dart';
import 'pulse_icon.dart';

/// Dua detay görünümü — karta dokununca açılan tam ekran modal bottom sheet.
/// Liste kartında yer almayan tüm uzun içerik (Arapça metin, okunuş, meal,
/// fazilet, etiketler) ve eylem çubuğu burada gösterilir.
class DuaDetailSheet extends StatefulWidget {
  final DuaModel dua;
  final DuaAudioService audioService;
  final DuaService duaService;
  final double fontScale;
  final bool initialIsFavorite;
  final bool initialIsRead;
  final int initialCount;
  final ValueChanged<bool> onFavoriteChanged;
  final ValueChanged<bool> onReadChanged;
  final ValueChanged<int> onCounterChanged;
  final VoidCallback onShowStory;

  const DuaDetailSheet({
    super.key,
    required this.dua,
    required this.audioService,
    required this.duaService,
    required this.fontScale,
    required this.initialIsFavorite,
    required this.initialIsRead,
    required this.initialCount,
    required this.onFavoriteChanged,
    required this.onReadChanged,
    required this.onCounterChanged,
    required this.onShowStory,
  });

  /// Detay görünümünü açar.
  static Future<void> show(
    BuildContext context, {
    required DuaModel dua,
    required DuaAudioService audioService,
    required DuaService duaService,
    required double fontScale,
    required bool initialIsFavorite,
    required bool initialIsRead,
    required int initialCount,
    required ValueChanged<bool> onFavoriteChanged,
    required ValueChanged<bool> onReadChanged,
    required ValueChanged<int> onCounterChanged,
    required VoidCallback onShowStory,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DuaDetailSheet(
        dua: dua,
        audioService: audioService,
        duaService: duaService,
        fontScale: fontScale,
        initialIsFavorite: initialIsFavorite,
        initialIsRead: initialIsRead,
        initialCount: initialCount,
        onFavoriteChanged: onFavoriteChanged,
        onReadChanged: onReadChanged,
        onCounterChanged: onCounterChanged,
        onShowStory: onShowStory,
      ),
    );
  }

  @override
  State<DuaDetailSheet> createState() => _DuaDetailSheetState();
}

class _DuaDetailSheetState extends State<DuaDetailSheet> {
  late bool _isFavorite = widget.initialIsFavorite;
  late bool _isRead = widget.initialIsRead;
  late int _count = widget.initialCount;

  void Function()? _previousAudioCallback;

  @override
  void initState() {
    super.initState();
    // Ses servisinin tek dinleyicisi var; ekrandaki mevcut dinleyiciyi
    // koruyup üstüne kendi güncellememizi ekliyoruz, kapanınca geri veriyoruz.
    _previousAudioCallback = widget.audioService.onStateChanged;
    widget.audioService.onStateChanged = () {
      _previousAudioCallback?.call();
      if (mounted) setState(() {});
    };
  }

  @override
  void dispose() {
    widget.audioService.onStateChanged = _previousAudioCallback;
    super.dispose();
  }

  Future<void> _handlePlayPause() async {
    if (!widget.dua.hasAudio) return;
    await widget.audioService.playOrToggle(widget.dua);
  }

  Future<void> _handleToggleFavorite() async {
    final newValue = await widget.duaService.toggleFavorite(widget.dua.id);
    if (!mounted) return;
    setState(() => _isFavorite = newValue);
    widget.onFavoriteChanged(newValue);
  }

  Future<void> _handleToggleRead() async {
    final newValue = await widget.duaService.toggleReadStatus(widget.dua.id, DateTime.now());
    if (!mounted) return;
    setState(() => _isRead = newValue);
    widget.onReadChanged(newValue);
  }

  Future<void> _handleIncrement() async {
    final nextVal = await widget.duaService.incrementCounter(widget.dua.id, widget.dua.defaultTarget);
    HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() => _count = nextVal);
    widget.onCounterChanged(nextVal);

    if (nextVal == widget.dua.defaultTarget) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tebrikler! "${widget.dua.title}" vird hedefinize (${widget.dua.defaultTarget}) ulaştınız.'),
          backgroundColor: AppColors.primary(context),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleReset() async {
    await widget.duaService.resetCounter(widget.dua.id);
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _count = 0);
    widget.onCounterChanged(0);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sayaç sıfırlandı.'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.dua.formattedShareText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${widget.dua.title}" panoya kopyalandı.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShare() {
    SharePlus.instance.share(
      ShareParams(text: widget.dua.formattedShareText, subject: widget.dua.title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dua = widget.dua;
    final fontScale = widget.fontScale;
    final isQuranSource = dua.source == 'Quran';
    final isPlaying = widget.audioService.currentlyPlayingId == dua.id &&
        widget.audioService.playerState == PlayerState.playing;
    final isBuffering = widget.audioService.currentlyPlayingId == dua.id && widget.audioService.isBuffering;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.card(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Başlık + kategori rozeti + kaynak
                    Text(
                      dua.title,
                      style: AppTypography.screenTitle(context, fontScale: fontScale),
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
                    const SizedBox(height: 16),

                    // Arapça metin
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border(context)),
                      ),
                      child: Text(
                        dua.arabic,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: AppTypography.arabic(context, fontScale: fontScale, color: AppColors.primary(context)),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Okunuş
                    Text(
                      dua.transliteration,
                      style: AppTypography.transliteration(context, fontScale: fontScale),
                    ),
                    const SizedBox(height: 16),

                    // Meal
                    Text('Meali:', style: AppTypography.label(context, fontScale: fontScale, color: AppColors.accent(context))),
                    const SizedBox(height: 8),
                    Text(
                      dua.meaning,
                      style: AppTypography.body(context, fontScale: fontScale),
                    ),

                    // Fazilet / bağlam
                    if (dua.context.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Fazileti & Tefsiri:', style: AppTypography.label(context, fontScale: fontScale, color: AppColors.primary(context))),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dua.context,
                          style: AppTypography.body(context, fontScale: fontScale, color: AppColors.textSecondary(context)),
                        ),
                      ),
                    ],

                    // Etiketler
                    if (dua.tags.isNotEmpty || dua.source.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (dua.source.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary(context).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary(context).withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                dua.source == 'Quran' ? 'Kur\'an' : (dua.source == 'Sunnah' ? 'Sünnet' : dua.source),
                                style: TextStyle(fontSize: 10.5 * fontScale, fontWeight: FontWeight.bold, color: AppColors.primary(context)),
                              ),
                            ),
                          for (final tag in dua.tags)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt(context),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border(context)),
                              ),
                              child: Text('#$tag', style: TextStyle(fontSize: 10.5 * fontScale, color: AppColors.textSecondary(context))),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Günlük takip (okundu işareti)
                    InkWell(
                      onTap: _handleToggleRead,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isRead ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                              color: _isRead ? AppColors.primary(context) : AppColors.textSecondary(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isRead ? 'Bugün Okundu' : 'Günlük Takibe Ekle',
                              style: TextStyle(
                                fontSize: 12.5 * fontScale,
                                fontWeight: _isRead ? FontWeight.bold : FontWeight.normal,
                                color: _isRead ? AppColors.primary(context) : AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isPlaying || isBuffering) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: isBuffering || widget.audioService.duration.inMilliseconds == 0
                              ? null
                              : (widget.audioService.position.inMilliseconds / widget.audioService.duration.inMilliseconds)
                                  .clamp(0.0, 1.0),
                          minHeight: 3,
                          backgroundColor: AppColors.border(context),
                          color: AppColors.accent(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Eylem çubuğu: Dinle · Favori · Paylaş · Sayaç (+ Hikaye · Kopyala)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  border: Border(top: BorderSide(color: AppColors.border(context))),
                ),
                child: Row(
                  children: [
                    if (dua.hasAudio)
                      IconButton(
                        tooltip: isPlaying ? 'Durdur' : 'Dinle',
                        icon: isBuffering
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent(context)),
                              )
                            : PulseIcon(
                                icon: isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                size: 26,
                                color: isPlaying ? AppColors.accent(context) : AppColors.primary(context),
                                pulsing: isPlaying,
                              ),
                        onPressed: _handlePlayPause,
                      ),
                    IconButton(
                      tooltip: _isFavorite ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                      icon: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _isFavorite ? Colors.red.shade600 : AppColors.textSecondary(context),
                      ),
                      onPressed: _handleToggleFavorite,
                    ),
                    IconButton(
                      tooltip: 'Hikaye Olarak Paylaş',
                      icon: Icon(Icons.amp_stories_outlined, color: AppColors.accent(context)),
                      onPressed: widget.onShowStory,
                    ),
                    IconButton(
                      tooltip: 'Kopyala',
                      icon: Icon(Icons.copy_rounded, color: AppColors.textSecondary(context)),
                      onPressed: _handleCopy,
                    ),
                    IconButton(
                      tooltip: 'Paylaş',
                      icon: Icon(Icons.share_outlined, color: AppColors.textSecondary(context)),
                      onPressed: _handleShare,
                    ),
                    const Spacer(),
                    Tooltip(
                      message: 'Tıkla: Artır | Basılı Tut: Sıfırla',
                      child: InkWell(
                        onTap: _handleIncrement,
                        onLongPress: _handleReset,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _count >= dua.defaultTarget ? AppColors.primary(context) : AppColors.surfaceAlt(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _count >= dua.defaultTarget ? AppColors.accent(context) : AppColors.border(context),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 14,
                                color: _count >= dua.defaultTarget ? AppColors.accent(context) : AppColors.primary(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_count / ${dua.defaultTarget}',
                                style: TextStyle(
                                  fontSize: 12 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  color: _count >= dua.defaultTarget ? AppColors.onPrimary : AppColors.text(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
