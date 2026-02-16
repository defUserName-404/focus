import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../constants/audio_assets.dart';

class AudioService {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();

  /// Play an alarm sound. Uses [preset] or falls back to [AudioAssets.defaultAlarm].
  Future<void> playAlarm([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAlarm;
    await _alarmPlayer.stop();
    await _alarmPlayer.play(AssetSource('audio/${sound.assetPath}'));
  }

  /// Start looping an ambient/focus sound from a [SoundPreset].
  /// If no [preset] is given, uses the first available ambience or does nothing.
  Future<void> startAmbience([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAmbience;
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audio/${sound.assetPath}'));
    } catch (e) {
      debugPrint('AudioService: Failed to start ambience: $e');
    }
  }

  /// Pause the ambient sound (can be resumed later).
  Future<void> pauseAmbience() async {
    await _bgPlayer.pause();
  }

  /// Resume a previously paused ambient sound.
  Future<void> resumeAmbience() async {
    await _bgPlayer.resume();
  }

  /// Stop the ambient sound completely.
  Future<void> stopAmbience() async {
    await _bgPlayer.stop();
  }

  Future<void> setNoiseVolume(double volume) async {
    await _bgPlayer.setVolume(volume);
  }

  void dispose() {
    _alarmPlayer.dispose();
    _bgPlayer.dispose();
  }
}
