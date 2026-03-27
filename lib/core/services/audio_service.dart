import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import '../constants/audio_assets.dart';
import 'log_service.dart';

/// Audio service for focus sessions with seamless looping via crossfade.
///
/// Uses two alternating players for ambient audio to eliminate the click/pop
/// sound that occurs when a single player loops back to the start. When one
/// player approaches the end of the track, the other player starts with a
/// crossfade transition.
class AudioService {
  final AudioPlayer _alarmPlayer = AudioPlayer();

  // Two players for crossfade looping of ambient audio
  final AudioPlayer _bgPlayerA = AudioPlayer();
  final AudioPlayer _bgPlayerB = AudioPlayer();
  bool _usePlayerA = true;

  final AudioPlayer _previewPlayer = AudioPlayer();
  final _log = LogService.instance;

  // Crossfade management
  Timer? _crossfadeTimer;
  StreamSubscription<Duration>? _positionSubscription;
  SoundPreset? _currentAmbience;
  Duration? _trackDuration;
  double _ambienceVolume = 1.0;
  bool _isAmbiencePlaying = false;
  bool _isPaused = false;

  /// Duration of the crossfade transition between players.
  static const _crossfadeDuration = Duration(milliseconds: 800);

  /// How many steps to use for the crossfade volume transition.
  static const _crossfadeSteps = 16;

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

    // Both background players use release mode (not loop) since we handle looping manually
    _bgPlayerA.setReleaseMode(ReleaseMode.release);
    _bgPlayerB.setReleaseMode(ReleaseMode.release);
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
  // Session audio - Ambience with crossfade looping
  // ---------------------------------------------------------------------------

  /// Starts ambient audio with seamless looping via crossfade.
  Future<void> startAmbience([SoundPreset? preset]) async {
    final sound = preset ?? AudioAssets.defaultAmbience;
    _currentAmbience = sound;

    try {
      _log.info('Starting ambience: ${sound.assetPath}', tag: 'AudioService');

      // Stop any existing playback
      await _stopAmbienceInternal();

      _isAmbiencePlaying = true;
      _isPaused = false;
      _usePlayerA = true;

      // Start the first player
      final activePlayer = _bgPlayerA;
      await activePlayer.setVolume(_ambienceVolume);
      await activePlayer.play(AssetSource('audio/${sound.assetPath}'));

      // Get track duration for scheduling crossfade
      _trackDuration = await activePlayer.getDuration();

      if (_trackDuration != null && _trackDuration!.inMilliseconds > 0) {
        _scheduleCrossfade();
      } else {
        // Fallback: monitor position if duration unknown
        _log.warning('Track duration unknown, using position monitoring', tag: 'AudioService');
        _startPositionMonitoring(activePlayer);
      }
    } catch (e, stack) {
      _log.error('startAmbience failed', tag: 'AudioService', error: e, stackTrace: stack);
      _isAmbiencePlaying = false;
    }
  }

  /// Schedules the next crossfade based on track duration.
  void _scheduleCrossfade() {
    _crossfadeTimer?.cancel();

    if (!_isAmbiencePlaying || _isPaused || _trackDuration == null) return;

    // Schedule crossfade to start before the track ends
    final timeUntilCrossfade = _trackDuration! - _crossfadeDuration;
    if (timeUntilCrossfade.isNegative) {
      _log.warning('Track too short for crossfade', tag: 'AudioService');
      return;
    }

    _crossfadeTimer = Timer(timeUntilCrossfade, _performCrossfade);
  }

  /// Starts position monitoring as fallback when duration is unknown.
  void _startPositionMonitoring(AudioPlayer player) {
    _positionSubscription?.cancel();
    _positionSubscription = player.onPositionChanged.listen((position) {
      // Try to get duration again
      player.getDuration().then((duration) {
        if (duration != null && duration.inMilliseconds > 0) {
          _trackDuration = duration;
          _positionSubscription?.cancel();
          _scheduleCrossfade();
        }
      });
    });
  }

  /// Performs the crossfade transition from one player to the other.
  Future<void> _performCrossfade() async {
    if (!_isAmbiencePlaying || _isPaused || _currentAmbience == null) return;

    _log.debug('Performing crossfade', tag: 'AudioService');

    final outgoingPlayer = _usePlayerA ? _bgPlayerA : _bgPlayerB;
    final incomingPlayer = _usePlayerA ? _bgPlayerB : _bgPlayerA;
    _usePlayerA = !_usePlayerA;

    try {
      // Start incoming player at zero volume
      await incomingPlayer.setVolume(0);
      await incomingPlayer.play(AssetSource('audio/${_currentAmbience!.assetPath}'));

      // Perform crossfade over multiple steps
      final stepDuration = _crossfadeDuration ~/ _crossfadeSteps;

      for (int i = 1; i <= _crossfadeSteps; i++) {
        if (!_isAmbiencePlaying || _isPaused) break;

        await Future.delayed(stepDuration);
        final progress = i / _crossfadeSteps;

        // Fade out outgoing, fade in incoming
        await outgoingPlayer.setVolume(_ambienceVolume * (1 - progress));
        await incomingPlayer.setVolume(_ambienceVolume * progress);
      }

      // Stop the outgoing player completely
      await outgoingPlayer.stop();

      // Schedule next crossfade
      if (_isAmbiencePlaying && !_isPaused) {
        _scheduleCrossfade();
      }
    } catch (e, stack) {
      _log.error('Crossfade failed', tag: 'AudioService', error: e, stackTrace: stack);
    }
  }

  Future<void> pauseAmbience() async {
    _log.info('Pausing ambience', tag: 'AudioService');
    _isPaused = true;
    _crossfadeTimer?.cancel();
    _positionSubscription?.cancel();

    final activePlayer = _usePlayerA ? _bgPlayerA : _bgPlayerB;
    await activePlayer.pause();
  }

  Future<void> resumeAmbience() async {
    if (!_isAmbiencePlaying) return;

    _log.info('Resuming ambience', tag: 'AudioService');
    _isPaused = false;

    final activePlayer = _usePlayerA ? _bgPlayerA : _bgPlayerB;
    await activePlayer.resume();

    // Reschedule crossfade based on current position
    final position = await activePlayer.getCurrentPosition();
    if (_trackDuration != null && position != null) {
      final remaining = _trackDuration! - position;
      if (remaining > _crossfadeDuration) {
        _crossfadeTimer?.cancel();
        _crossfadeTimer = Timer(remaining - _crossfadeDuration, _performCrossfade);
      } else {
        // Already close to end, crossfade soon
        _performCrossfade();
      }
    }
  }

  Future<void> stopAmbience() async {
    _log.info('Stopping ambience', tag: 'AudioService');
    await _stopAmbienceInternal();
  }

  Future<void> _stopAmbienceInternal() async {
    _isAmbiencePlaying = false;
    _isPaused = false;
    _crossfadeTimer?.cancel();
    _positionSubscription?.cancel();

    await _bgPlayerA.stop();
    await _bgPlayerB.stop();
  }

  Future<void> setAmbienceVolume(double volume) async {
    _ambienceVolume = volume;
    final activePlayer = _usePlayerA ? _bgPlayerA : _bgPlayerB;
    await activePlayer.setVolume(volume);
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
    _crossfadeTimer?.cancel();
    _positionSubscription?.cancel();
    _alarmPlayer.dispose();
    _bgPlayerA.dispose();
    _bgPlayerB.dispose();
    _previewPlayer.dispose();
  }
}
