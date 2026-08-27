import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/app_colors.dart';

/// Namaz rehberi adımları için deneysel CDN video oynatıcısı.
///
/// [videoUrl] her zaman oynatılabilir olacağı garanti edilmediğinden
/// (dış CDN içeriği doğrulanamaz), yükleme/oynatma hatası durumunda
/// sessizce ikon tabanlı bir placeholder'a düşer — [PrayerStepAnimator]
/// ile aynı graceful-degrade deseni.
class PrayerVideoPanel extends StatefulWidget {
  const PrayerVideoPanel({super.key, required this.videoUrl, this.height = 200});

  final String videoUrl;
  final double height;

  @override
  State<PrayerVideoPanel> createState() => _PrayerVideoPanelState();
}

class _PrayerVideoPanelState extends State<PrayerVideoPanel> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void didUpdateWidget(covariant PrayerVideoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _failed = false;
      _initialize();
    }
  }

  void _initialize() {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      controller.setLooping(true);
      controller.play();
    }).catchError((_) {
      if (!mounted) return;
      setState(() => _failed = true);
    });
    _controller = controller;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || controller == null || !controller.value.isInitialized) {
      return _buildPlaceholder(context);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.size.width,
            height: controller.value.size.height,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Center(
        child: Icon(
          Icons.videocam_off_rounded,
          size: 48,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }
}
