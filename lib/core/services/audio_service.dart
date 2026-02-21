import 'package:audioplayers/audioplayers.dart';

import '../constants/audio_assets.dart';
import 'log_service.dart';

class AudioService {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);
  final AudioPlayer _previewPlayer = AudioPlayer();
  final _log = LogService.instance;

  AudioService() {
    _log.info("AudioService: Initializing...");
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

  Future<void> playAlarm([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAlarm;
    try {
      _log.info("AudioService: Playing alarm: ${sound.assetPath}");
      await _alarmPlayer.stop();
      await _alarmPlayer.play(AssetSource('audio/${sound.assetPath}'));
    } catch (e, stack) {
      _log.error("AudioService: playAlarm failed", error: e, stackTrace: stack);
    }
  }

  Future<void> startAmbience([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAmbience;
    try {
      _log.info("AudioService: Starting ambience: ${sound.assetPath}");
      // stop() before play() ensures the buffer is cleared for the new asset
      await _bgPlayer.stop();
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audio/${sound.assetPath}'));
    } catch (e, stack) {
      _log.error("AudioService: startAmbience failed", error: e, stackTrace: stack);
    }
  }

  Future<void> pauseAmbience() {
    _log.info("AudioService: Pausing ambience");
    return _bgPlayer.pause();
  }

  Future<void> resumeAmbience() {
    _log.info("AudioService: Resuming ambience");
    return _bgPlayer.resume();
  }

  Future<void> stopAmbience() {
    _log.info("AudioService: Stopping ambience");
    return _bgPlayer.stop();
  }

  Future<void> setAmbienceVolume(double volume) => _bgPlayer.setVolume(volume);

  // ---------------------------------------------------------------------------
  // Preview audio (settings screen)
  // ---------------------------------------------------------------------------

  Future<void> startPreview(SoundPreset preset) async {
    try {
      _log.info("AudioService: Starting preview: ${preset.assetPath}");
      await _previewPlayer.stop();
      await _previewPlayer.setReleaseMode(ReleaseMode.release);
      await _previewPlayer.play(AssetSource('audio/${preset.assetPath}'));
    } catch (e, stack) {
      _log.error("AudioService: startPreview failed", error: e, stackTrace: stack);
    }
  }

  Future<void> stopPreview() {
    _log.info("AudioService: Stopping preview");
    return _previewPlayer.stop();
  }

  Future<void> setNoiseVolume(double volume) async {
    await _bgPlayer.setVolume(volume);
  }

  void dispose() {
    _log.info("AudioService: Disposing players");
    _alarmPlayer.dispose();
    _bgPlayer.dispose();
    _previewPlayer.dispose();
  }
}
