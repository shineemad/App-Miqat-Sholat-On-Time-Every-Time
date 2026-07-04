import 'package:audioplayers/audioplayers.dart';

/// Pemutar adzan penuh di dalam aplikasi.
///
/// Melengkapi notifikasi: notifikasi sistem memberi peringatan (dengan
/// batas durasi, mis. 30 dtk di iOS), sedangkan pemutar ini dapat
/// memainkan adzan **penuh** saat aplikasi terbuka atau untuk pratinjau
/// di Pengaturan. Berfungsi lintas platform termasuk web.
class AdhanPlayer {
  AdhanPlayer([AudioPlayer? player]) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  static final _source = AssetSource('audio/adzan.mp3');

  /// Stream status pemutaran (playing/paused/stopped/completed).
  Stream<PlayerState> get onStateChanged => _player.onPlayerStateChanged;

  bool get isPlaying => _player.state == PlayerState.playing;

  /// Memutar adzan penuh dari awal.
  Future<void> play() async {
    await _player.stop();
    await _player.play(_source);
  }

  Future<void> stop() => _player.stop();

  Future<void> dispose() => _player.dispose();
}
