import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  Future<void> init() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
    // Set background music volume to be cozy and low
    await _bgPlayer.setVolume(0.3);
    await _ambientPlayer.setVolume(0.4);
    // SFX can be slightly louder
    await _sfxPlayer.setVolume(0.7);
  }

  Future<void> playBackgroundMusic() async {
    try {
      await _bgPlayer.play(AssetSource('audio/bg_music.mp3'));
    } catch (e) {
      // Fail gracefully if audio cannot be loaded/played
    }
  }

  Future<void> playAmbientSound(String weatherType) async {
    String assetPath;
    switch (weatherType) {
      case 'rainy':
        assetPath = 'audio/rain.mp3';
        break;
      case 'sunny':
        assetPath = 'audio/birds.mp3';
        break;
      case 'cloudy':
      default:
        assetPath = 'audio/wind.mp3';
        break;
    }
    try {
      await _ambientPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Fail gracefully
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _bgPlayer.stop();
    await _ambientPlayer.stop();
  }

  Future<void> pauseBackgroundMusic() async {
    await _bgPlayer.pause();
    await _ambientPlayer.pause();
  }

  Future<void> resumeBackgroundMusic() async {
    await _bgPlayer.resume();
    await _ambientPlayer.resume();
  }

  Future<void> playSfx(String type) async {
    String assetPath;
    switch (type) {
      case 'water':
        assetPath = 'audio/water_pour.wav';
        break;
      case 'wipe':
        assetPath = 'audio/wipe.wav';
        break;
      case 'press':
        assetPath = 'audio/press.wav';
        break;
      default:
        return;
    }
    try {
      // Stop current SFX to restart if triggered rapidly
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(assetPath));
    } catch (e) {
      // Fail gracefully
    }
  }

  void dispose() {
    _bgPlayer.dispose();
    _ambientPlayer.dispose();
    _sfxPlayer.dispose();
  }
}

