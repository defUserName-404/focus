import 'package:audioplayers/audioplayers.dart';

import '../constants/audio_assets.dart';
import 'log_service.dart';

/// Audio service for focus sessions.
///
/// Ambience uses a single looping player ([ReleaseMode.loop]) to avoid
/// dual-player crossfade artifacts (e.g. headphone static on macOS).
class AudioService {
  final AudioPlayer _alarmPlayer = AudioPlayer();
  final AudioPlayer _ambiencePlayer = AudioPlayer();
  final AudioPlayer _previewPlayer = AudioPlayer();
  final _log = LogService.instance;

  double _ambienceVolume = 1.0;
  bool _isAmbiencePlaying = false;

  AudioService() {
    _log.info('AudioService: Initializing...', tag: 'AudioService');

    // Configure global audio context.
    // We set audioFocus to 'none' on Android because we manage focus
    // manually via the AudioSessionManager to avoid race conditions
    // between the player and the OS session listeners.
    AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: {AVAudioSessionOptions.mixWithOthers}),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
      ),
    );

    _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
  }

  // ---------------------------------------------------------------------------
  // Session audio - Alarm
  // ---------------------------------------------------------------------------

  Future<void> playAlarm([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAlarm;
    try {
      _log.info('Playing alarm: ${sound.assetPath}', tag: 'AudioService');
      await _alarmPlayer.stop();
      await _alarmPlayer.play(AssetSource('audio/${sound.assetPath}'));
    } catch (e, stack) {
      _log.error('playAlarm failed', tag: 'AudioService', error: e, stackTrace: stack);
    }
  }

  // ---------------------------------------------------------------------------
  // Session audio - Ambience (single-player loop)
  // ---------------------------------------------------------------------------

  /// Starts ambient audio with native looping.
  Future<void> startAmbience([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAmbience;

    try {
      _log.info('Starting ambience: ${sound.assetPath}', tag: 'AudioService');

      await _stopAmbienceInternal();

      _isAmbiencePlaying = true;
      await _ambiencePlayer.setReleaseMode(ReleaseMode.loop);
      await _ambiencePlayer.setVolume(_ambienceVolume);
      await _ambiencePlayer.play(AssetSource('audio/${sound.assetPath}'));
    } catch (e, stack) {
      _log.error('startAmbience failed', tag: 'AudioService', error: e, stackTrace: stack);
      _isAmbiencePlaying = false;
    }
  }

  Future<void> pauseAmbience() async {
    _log.info('Pausing ambience', tag: 'AudioService');
    await _ambiencePlayer.pause();
  }

  Future<void> resumeAmbience() async {
    if (!_isAmbiencePlaying) return;

    _log.info('Resuming ambience', tag: 'AudioService');
    await _ambiencePlayer.resume();
  }

  Future<void> stopAmbience() async {
    _log.info('Stopping ambience', tag: 'AudioService');
    await _stopAmbienceInternal();
  }

  Future<void> _stopAmbienceInternal() async {
    _isAmbiencePlaying = false;
    await _ambiencePlayer.stop();
  }

  Future<void> setAmbienceVolume(double volume) async {
    _ambienceVolume = volume;
    await _ambiencePlayer.setVolume(volume);
  }

  // Legacy method name - forwards to setAmbienceVolume
  Future<void> setNoiseVolume(double volume) => setAmbienceVolume(volume);

  // ---------------------------------------------------------------------------
  // Preview audio (settings screen) - no looping needed
  // ---------------------------------------------------------------------------

  Future<void> startPreview(SoundPreset preset) async {
    try {
      _log.info('Starting preview: ${preset.assetPath}', tag: 'AudioService');
      await _previewPlayer.stop();
      await _previewPlayer.setReleaseMode(ReleaseMode.release);
      await _previewPlayer.play(AssetSource('audio/${preset.assetPath}'));
    } catch (e, stack) {
      _log.error('startPreview failed', tag: 'AudioService', error: e, stackTrace: stack);
    }
  }

  Future<void> stopPreview() {
    _log.info('Stopping preview', tag: 'AudioService');
    return _previewPlayer.stop();
  }

  void dispose() {
    _log.info('Disposing players', tag: 'AudioService');
    _alarmPlayer.dispose();
    _ambiencePlayer.dispose();
    _previewPlayer.dispose();
  }
}
