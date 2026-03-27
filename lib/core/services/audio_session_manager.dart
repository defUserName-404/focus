import 'dart:async';

import 'package:audio_session/audio_session.dart';

import 'log_service.dart';

/// Callback signature for audio interruption events.
typedef InterruptionCallback = void Function(bool shouldPause);

/// Callback signature for the "becoming noisy" event (headphone unplug).
typedef BecomingNoisyCallback = void Function();

/// Manages the [AudioSession] to handle system-level audio interactions.
class AudioSessionManager {
  AudioSession? _session;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;
  StreamSubscription<void>? _noisySub;

  InterruptionCallback? onInterruption;
  BecomingNoisyCallback? onBecomingNoisy;

  Future<void> init() async {
    try {
      _session = await AudioSession.instance;
      await _session!.configure(const AudioSessionConfiguration.music());

      _listenForInterruptions();
      _listenForBecomingNoisy();
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'AudioSessionManager.init failed',
        tag: 'AudioSessionManager',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _listenForInterruptions() {
    _interruptionSub?.cancel();
    _interruptionSub = _session?.interruptionEventStream.listen((event) {
      if (event.begin) {
        // Only pause for actual interruptions, not ducking (e.g. notifications).
        if (event.type == AudioInterruptionType.duck) return;
        onInterruption?.call(true);
      } else {
        // Interruption ended — resume if it was a pause/unknown type.
        if (event.type == AudioInterruptionType.pause || event.type == AudioInterruptionType.unknown) {
          onInterruption?.call(false);
        }
      }
    });
  }

  void _listenForBecomingNoisy() {
    _noisySub?.cancel();
    _noisySub = _session?.becomingNoisyEventStream.listen((_) {
      onBecomingNoisy?.call();
    });
  }

  Future<bool> activate() async {
    try {
      return await _session?.setActive(true) ?? false;
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'AudioSessionManager.activate failed',
        tag: 'AudioSessionManager',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> deactivate() async {
    try {
      await _session?.setActive(false);
    } catch (e, stackTrace) {
      LogService.instance.warning(
        'AudioSessionManager.deactivate failed',
        tag: 'AudioSessionManager',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _interruptionSub?.cancel();
    _noisySub?.cancel();
  }
}
