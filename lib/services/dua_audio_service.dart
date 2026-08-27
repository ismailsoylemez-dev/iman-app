import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../models/dua_model.dart';

/// Dua sesi çalma servisi.
///
/// Öncelik sırası: yerel asset (offline, anında) -> internet URL'i (yedek).
/// Aralıklı ayetler / çoklu sureler için sırayla çalan bir oynatma listesini
/// (playlist) destekler. Aynı anda yalnızca tek bir dua çalar.
class DuaAudioService {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Durum değiştiğinde çağrılır (UI'ı yeniden çizmek için).
  void Function()? onStateChanged;

  String? currentlyPlayingId;
  PlayerState playerState = PlayerState.stopped;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isBuffering = false;

  List<String> _playlist = const [];
  bool _playlistIsAsset = false;
  int _playlistIndex = 0;

  DuaAudioService() {
    _subscriptions.add(_player.onPlayerStateChanged.listen((state) {
      playerState = state;
      if (state == PlayerState.playing || state == PlayerState.stopped) {
        isBuffering = false;
      }
      onStateChanged?.call();
    }));

    _subscriptions.add(_player.onPlayerComplete.listen((_) => _onTrackComplete()));

    _subscriptions.add(_player.onDurationChanged.listen((d) {
      duration = d;
      onStateChanged?.call();
    }));

    _subscriptions.add(_player.onPositionChanged.listen((p) {
      position = p;
      onStateChanged?.call();
    }));
  }

  /// audioplayers'ın AudioCache'i asset yollarının başına otomatik olarak
  /// 'assets/' ekler; JSON'daki yol zaten bu öneki içerdiği için burada temizlenir.
  String _stripAssetsPrefix(String path) {
    return path.startsWith('assets/') ? path.substring('assets/'.length) : path;
  }

  Future<void> _onTrackComplete() async {
    if (_playlistIndex < _playlist.length - 1) {
      _playlistIndex++;
      await _playCurrentPlaylistItem();
    } else {
      currentlyPlayingId = null;
      playerState = PlayerState.stopped;
      position = Duration.zero;
      _playlist = const [];
      _playlistIndex = 0;
      onStateChanged?.call();
    }
  }

  Future<void> _playCurrentPlaylistItem() async {
    if (_playlistIndex >= _playlist.length) return;
    final src = _playlist[_playlistIndex];
    try {
      if (_playlistIsAsset) {
        await _player.play(AssetSource(_stripAssetsPrefix(src)));
      } else {
        await _player.play(UrlSource(src));
      }
    } catch (_) {
      // Ses çalma hatası kullanıcıya kırmızı hata olarak gösterilmez, sessizce yutulur.
      isBuffering = false;
      onStateChanged?.call();
    }
  }

  /// Verilen duayı çalar; zaten çalıyorsa duraklatır/devam ettirir.
  /// Sesi olmayan bir dua için hiçbir şey yapmaz.
  Future<void> playOrToggle(DuaModel dua) async {
    if (!dua.hasAudio) return;

    try {
      if (currentlyPlayingId == dua.id) {
        if (playerState == PlayerState.playing) {
          await _player.pause();
        } else {
          await _player.resume();
        }
        return;
      }

      await _player.stop();

      final useAsset = dua.audioAsset.isNotEmpty;
      _playlistIsAsset = useAsset;
      _playlist = useAsset
          ? (dua.audioAssets.isNotEmpty ? dua.audioAssets : [dua.audioAsset])
          : (dua.audioUrls.isNotEmpty ? dua.audioUrls : [dua.audioUrl]);
      _playlistIndex = 0;

      currentlyPlayingId = dua.id;
      isBuffering = true;
      position = Duration.zero;
      duration = Duration.zero;
      onStateChanged?.call();

      await _playCurrentPlaylistItem();
    } catch (_) {
      isBuffering = false;
      onStateChanged?.call();
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {
      // yut
    }
    currentlyPlayingId = null;
    playerState = PlayerState.stopped;
    position = Duration.zero;
    duration = Duration.zero;
    _playlist = const [];
    _playlistIndex = 0;
    onStateChanged?.call();
  }

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    _player.dispose();
  }
}
