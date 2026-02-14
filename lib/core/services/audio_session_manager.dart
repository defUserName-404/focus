import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

/// Callback signature for audio interruption events.
typedef InterruptionCallback = void Function(bool shouldPause);

/// Callback signature for the "becoming noisy" event (headphone unplug).
typedef BecomingNoisyCallback = void Function();

/// Manages the [AudioSession] to handle system-level audio interactions:
///
/// - **Becoming noisy**: Headphone unplug → auto-pause playback.
/// - **Interruptions**: Phone calls, other media apps → pause/resume.
/// - **Audio focus**: Requests & releases focus so the OS knows the app
///   is an active audio source.
///
/// This service is a thin wrapper around the [audio_session] package.
/// Register callbacks via [onInterruption] and [onBecomingNoisy], then
/// call [activate] when the focus session starts and [deactivate] when
/// it ends.
class AudioSessionManager {
  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _noisySub;

  InterruptionCallback? onInterruption;
  BecomingNoisyCallback? onBecomingNoisy;

  /// Configure and prepare the audio session.
  ///
  /// Should be called once during app startup (from [setupDependencyInjection]).
  Future<void> init() async {
    try {
      _session = await AudioSession.instance;

      // Configure as a speech session (long-form audio focus, like a podcast).
      // This prevents other media from interrupting and lets the OS know
      // we want to keep audio focus for an extended period.
      await _session!.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      _listenForInterruptions();
      _listenForBecomingNoisy();
    } catch (e) {
      debugPrint('AudioSessionManager.init failed: $e');
    }
  }

  void _listenForInterruptions() {
    _interruptionSub?.cancel();
    _interruptionSub = _session?.interruptionEventStream.listen((event) {
      if (event.begin) {
        // Another app took audio focus — pause.
        onInterruption?.call(true);
      } else {
        // Interruption ended — resume if the system says we may.
        if (event.type == AudioInterruptionType.pause ||
            event.type == AudioInterruptionType.unknown) {
          onInterruption?.call(false);
        }
      }
    });
  }

  void _listenForBecomingNoisy() {
    _noisySub?.cancel();
    _noisySub = _session?.becomingNoisyEventStream.listen((_) {
      // Headphones were unplugged → pause playback.
      onBecomingNoisy?.call();
    });
  }

  /// Request audio focus from the system. Call when a focus session starts.
  Future<bool> activate() async {
    try {
      return await _session?.setActive(true) ?? false;
    } catch (e) {
      debugPrint('AudioSessionManager.activate failed: $e');
      return false;
    }
  }

  /// Release audio focus. Call when a focus session ends.
  Future<void> deactivate() async {
    try {
      await _session?.setActive(false);
    } catch (e) {
      debugPrint('AudioSessionManager.deactivate failed: $e');
    }
  }

  void dispose() {
    _interruptionSub?.cancel();
    _noisySub?.cancel();
    _interruptionSub = null;
    _noisySub = null;
  }
}
