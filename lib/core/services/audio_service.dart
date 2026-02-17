import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../constants/audio_assets.dart';

class AudioService {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();

  /// Dedicated player for short sound previews in the settings screen.
  /// Kept separate so previews never touch the session ambience player.
  final AudioPlayer _previewPlayer = AudioPlayer();

  AudioService() {
    AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: {AVAudioSessionOptions.mixWithOthers}),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Session audio
  // ---------------------------------------------------------------------------

  /// Play an alarm sound, falling back to [AudioAssets.defaultAlarm].
  Future<void> playAlarm([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAlarm;
    await _alarmPlayer.stop();
    await _alarmPlayer.play(AssetSource('audio/${sound.assetPath}'));
  }

  /// Start looping an ambient/focus sound, falling back to [AudioAssets.defaultAmbience].
  Future<void> startAmbience([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAmbience;
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audio/${sound.assetPath}'));
    } catch (e) {
      debugPrint('AudioService.startAmbience: $e');
    }
  }

  Future<void> pauseAmbience() => _bgPlayer.pause();

  Future<void> resumeAmbience() => _bgPlayer.resume();

  Future<void> stopAmbience() => _bgPlayer.stop();

  Future<void> setAmbienceVolume(double volume) => _bgPlayer.setVolume(volume);

  // ---------------------------------------------------------------------------
  // Preview audio (settings screen)
  //
  // Uses a completely separate player so session ambience is unaffected.
  // The caller is responsible for calling stopPreview() when done or when a
  // new preview starts (to avoid overlap).
  // ---------------------------------------------------------------------------

  /// Play [preset] once on the preview player.
  /// Stops any in-progress preview before starting the new one.
  Future<void> startPreview(SoundPreset preset) async {
    await _previewPlayer.stop();
    // One-shot, no looping — we just want a short listen.
    await _previewPlayer.setReleaseMode(ReleaseMode.release);
    await _previewPlayer.play(AssetSource('audio/${preset.assetPath}'));
  }

  Future<void> stopPreview() => _previewPlayer.stop();

  Future<void> setNoiseVolume(double volume) async {
    await _bgPlayer.setVolume(volume);
  }

  void dispose() {
    _alarmPlayer.dispose();
    _bgPlayer.dispose();
    _previewPlayer.dispose();
  }
}
