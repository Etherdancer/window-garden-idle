import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();

  Future<void> init() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playBackgroundMusic() async {
    await _bgPlayer.play(AssetSource('audio/bg_music.mp3'));
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    await _bgPlayer.resume();
  }

  void dispose() {
    _bgPlayer.dispose();
  }
}
