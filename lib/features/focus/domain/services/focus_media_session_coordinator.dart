import '../../../../core/services/audio_session_manager.dart';
import '../../../../core/services/focus_audio_handler.dart';
import '../entities/focus_session.dart';
import '../entities/session_state.dart';

/// Coordinates the OS media session (lock-screen controls, MediaStyle
/// notification) for focus sessions.
///
/// Wraps [FocusAudioHandler] and [AudioSessionManager] so the
/// [FocusTimer] doesn't interact with them directly.
class FocusMediaSessionCoordinator {
  final FocusAudioHandler _audioHandler;
  final AudioSessionManager _audioSessionManager;

  FocusMediaSessionCoordinator(this._audioHandler, this._audioSessionManager);

  /// Request audio focus from the OS. Call when a session starts.
  Future<void> activateAudioSession() => _audioSessionManager.activate();

  /// Sync the OS MediaSession / lock-screen controls with the current state.
  void updateMediaSession(FocusSession session) {
    final totalFocusSeconds = session.focusDurationMinutes * 60;
    final totalBreakSeconds = session.breakDurationMinutes * 60;
    final isPlaying =
        session.state == SessionState.running || session.state == SessionState.onBreak;

    final bool isFocusPhase;
    if (session.state == SessionState.paused) {
      isFocusPhase = session.elapsedSeconds < totalFocusSeconds;
    } else {
      isFocusPhase = session.state == SessionState.running;
    }

    final phaseDuration = isFocusPhase ? totalFocusSeconds : totalBreakSeconds;
    final elapsedInPhase =
        isFocusPhase ? session.elapsedSeconds : session.elapsedSeconds - totalFocusSeconds;

    _audioHandler.updateSessionMediaItem(
      title: isFocusPhase ? 'Focus Session' : 'Break Time',
      artist: session.state == SessionState.paused ? 'Paused' : 'Stay Focused',
      duration: Duration(seconds: phaseDuration),
    );

    _audioHandler.updateSessionPlaybackState(
      isPlaying: isPlaying,
      position: Duration(seconds: elapsedInPhase.clamp(0, phaseDuration)),
      bufferedPosition: Duration(seconds: phaseDuration),
      duration: Duration(seconds: phaseDuration),
    );
  }

  /// Clear the media session when no session is active.
  Future<void> clearMediaSession() async {
    await _audioHandler.clearSession();
    await _audioSessionManager.deactivate();
  }

  /// Wire media-button & headphone-unplug callbacks.
  ///
  /// - [onAction] handles play/pause/stop/skip from lock-screen controls.
  /// - [onBecomingNoisy] handles headphone unplug → auto-pause.
  /// - [onInterruption] handles phone calls / other media → pause/resume.
  void wireCallbacks({
    required void Function(String) onAction,
    required void Function() onBecomingNoisy,
    required void Function(bool shouldPause) onInterruption,
  }) {
    _audioHandler.onAction = onAction;
    _audioSessionManager.onBecomingNoisy = onBecomingNoisy;
    _audioSessionManager.onInterruption = onInterruption;
  }

  /// Clear all callbacks (e.g. on dispose).
  void clearCallbacks() {
    _audioHandler.onAction = null;
    _audioSessionManager.onBecomingNoisy = null;
    _audioSessionManager.onInterruption = null;
  }
}
