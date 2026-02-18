import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/notification_constants.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/focus_session_extensions.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/services/focus_audio_coordinator.dart';
import '../../domain/services/focus_media_session_coordinator.dart';
import '../../domain/services/focus_notification_coordinator.dart';
import '../../domain/services/focus_session_service.dart';
import 'ambience_mute_provider.dart';
import 'focus_providers.dart';

part 'focus_session_provider.g.dart';

@Riverpod(keepAlive: true)
class FocusTimer extends _$FocusTimer {
  late final FocusSessionService _sessionService;
  late final FocusAudioCoordinator _audioCoordinator;
  FocusNotificationCoordinator? _notificationCoordinator;
  FocusMediaSessionCoordinator? _mediaCoordinator;
  Timer? _timer;
  StreamSubscription<String>? _notificationActionSub;

  @override
  FocusSession? build() {
    _sessionService = ref.watch(focusSessionServiceProvider);
    _audioCoordinator = ref.watch(focusAudioCoordinatorProvider);
    _notificationCoordinator = ref.watch(focusNotificationCoordinatorProvider);
    _mediaCoordinator = ref.watch(focusMediaSessionCoordinatorProvider);

    // Wire media-button & lock-screen controls → our actions (mobile only).
    _mediaCoordinator?.wireCallbacks(
      onAction: _handleNotificationAction,
      onBecomingNoisy: () => pauseSession(),
      onInterruption: (shouldPause) {
        if (shouldPause) {
          pauseSession();
        } else {
          resumeSession();
        }
      },
    );

    // Listen for notification action taps (pause/resume/stop/skip).
    _notificationActionSub?.cancel();
    _notificationActionSub = _notificationCoordinator?.listenForActions(_handleNotificationAction);

    ref.onDispose(() {
      _notificationActionSub?.cancel();
      _mediaCoordinator?.clearCallbacks();
      _stopTicking();
    });

    // Mark abandoned sessions as incomplete on startup.
    _sessionService.cleanupAbandonedSessions();

    // React to audio settings changes (sound, volume, enabled) while a
    // session is actively playing. Without this, the user would need to
    // pause+resume to hear the new noise sound.
    ref.listen(audioPreferencesProvider, (prev, next) {
      final current = state;
      if (current == null) return;
      if (current.state != SessionState.running && current.state != SessionState.onBreak) return;

      // Only reload when the data actually changed and we have valid data.
      final newData = next.asData?.value;
      if (newData != null && prev?.asData?.value != newData) {
        _audioCoordinator.reloadAmbience(newData);
      }
    });

    return null;
  }

  void _handleNotificationAction(String actionId) {
    switch (actionId) {
      case NotificationConstants.actionPause:
        pauseSession();
      case NotificationConstants.actionResume:
        resumeSession();
      case NotificationConstants.actionStop:
        stopCycle();
      case NotificationConstants.actionSkip:
        skipToNextPhase();
    }
  }

  /// Create a new session in [idle] state.
  ///
  /// **Does NOT persist to DB** — the session is only held in-memory until
  /// the user actually starts the timer, at which point it gets saved.
  ///
  /// If [taskId] is `null`, this is a **quick session** with no task attached.
  Future<void> createSession({BigInt? taskId, required int focusMinutes, required int breakMinutes}) async {
    _stopTicking();

    final session = FocusSession(
      taskId: taskId,
      focusDurationMinutes: focusMinutes,
      breakDurationMinutes: breakMinutes,
      startTime: DateTime.now(),
      state: SessionState.idle,
      elapsedSeconds: 0,
    );

    // Only hold in-memory — no DB write for idle sessions.
    state = session;
  }

  /// User taps play → idle→running (persists to DB), paused→running.
  Future<void> startTimer() async {
    final current = state;
    if (current == null) return;

    if (current.state == SessionState.idle) {
      // Acquire audio focus from the OS.
      await _mediaCoordinator?.activateAudioSession();

      // Now persist the session for the first time.
      final running = current.copyWith(state: SessionState.running, startTime: DateTime.now());
      final saved = await _sessionService.startSession(running);
      state = saved;
      _startTicking();
      _mediaCoordinator?.updateMediaSession(saved);
      _audioCoordinator.startConfiguredAmbience();
    } else if (current.state == SessionState.paused) {
      // Resume into the correct phase based on elapsed time.
      final totalFocusSeconds = current.focusDurationMinutes * 60;
      final wasOnBreak = current.elapsedSeconds >= totalFocusSeconds;
      final resumeState = wasOnBreak ? SessionState.onBreak : SessionState.running;

      final updated = current.copyWith(state: resumeState);
      state = updated;
      _sessionService.updateSession(updated);
      _startTicking();
      _mediaCoordinator?.updateMediaSession(updated);
      _audioCoordinator.resumeAmbience();
    }
  }

  void pauseSession() {
    final current = state;
    if (current == null || (current.state != SessionState.running && current.state != SessionState.onBreak)) {
      return;
    }

    _stopTicking();
    _audioCoordinator.pauseAmbience();
    final updated = current.copyWith(state: SessionState.paused);
    state = updated;
    _sessionService.updateSession(updated);
    _mediaCoordinator?.updateMediaSession(updated);
  }

  void resumeSession() {
    final current = state;
    if (current == null || current.state != SessionState.paused) return;

    // Determine the correct phase to resume into based on elapsed time.
    final totalFocusSeconds = current.focusDurationMinutes * 60;
    final wasOnBreak = current.elapsedSeconds >= totalFocusSeconds;
    final resumeState = wasOnBreak ? SessionState.onBreak : SessionState.running;

    final updated = current.copyWith(state: resumeState);
    state = updated;
    _sessionService.updateSession(updated);
    _startTicking();
    _mediaCoordinator?.updateMediaSession(updated);
    _audioCoordinator.resumeAmbience();
  }

  /// Toggle play/pause from ring tap.
  void togglePlayPause() {
    final current = state;
    if (current == null) return;

    switch (current.state) {
      case SessionState.idle:
      case SessionState.paused:
        startTimer();
      case SessionState.running:
      case SessionState.onBreak:
        pauseSession();
      default:
        break;
    }
  }

  /// Skip to the next phase (focus→break or break→next cycle).
  /// Works in running, onBreak, AND paused states.
  void skipToNextPhase() {
    final current = state;
    if (current == null) return;

    // Determine the phase — when paused, infer from elapsed seconds.
    final totalFocusSeconds = current.focusDurationMinutes * 60;
    final bool isInFocusPhase;

    switch (current.state) {
      case SessionState.running:
        isInFocusPhase = true;
      case SessionState.onBreak:
        isInFocusPhase = false;
      case SessionState.paused:
        isInFocusPhase = current.elapsedSeconds < totalFocusSeconds;
      default:
        return; // idle / completed / cancelled / incomplete
    }

    if (isInFocusPhase) {
      _handleFocusCompleted();
    } else {
      _handleSessionCompleted();
    }
  }

  /// Premature end: save as cancelled (not deleted).
  /// Only persists if the session was already saved to DB (has an id).
  void cancelSession() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    _audioCoordinator.stopAmbience();
    _resetMute();

    if (current.id != null) {
      final updated = current.copyWith(state: SessionState.cancelled, endTime: DateTime.now());
      _sessionService.updateSession(updated);
    }
    state = null;
    _notificationCoordinator?.cancelFocusNotification();
    _mediaCoordinator?.clearMediaSession();
  }

  /// Clear the in-memory session once the UI has finished showing
  /// the completion animation or any other post-session UI.
  void clearCompletedSession() {
    state = null;
  }

  /// Complete the current focus session early.
  ///
  /// Saves the session as completed and clears the in-memory state
  /// so the UI immediately leaves the session screen.
  void completeSessionEarly() {
    final current = state;
    if (current == null) return;
    if (current.state == SessionState.completed || current.state == SessionState.cancelled) {
      return;
    }

    _stopTicking();
    _audioCoordinator.stopAmbience();
    _resetMute();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());

    if (current.id != null) {
      _sessionService.updateSession(updated);
    } else {
      _sessionService.startSession(updated);
    }
    // Clear state so the session screen reacts immediately.
    state = null;

    _audioCoordinator.playConfiguredAlarm();
    _notificationCoordinator?.cancelFocusNotification();
    _mediaCoordinator?.clearMediaSession();
    _notificationCoordinator?.showEarlyCompleteNotification();
  }

  /// Complete the session AND mark the associated task as completed.
  Future<void> completeTaskAndSession() async {
    final current = state;
    if (current == null) return;
    if (current.state == SessionState.completed || current.state == SessionState.cancelled) {
      return;
    }

    _stopTicking();
    _audioCoordinator.stopAmbience();
    _resetMute();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());

    if (current.id != null) {
      _sessionService.updateSession(updated);
    } else {
      await _sessionService.startSession(updated);
    }
    state = updated;

    // Mark the task as completed (skip for quick sessions).
    if (current.taskId != null) {
      await _sessionService.completeTask(current.taskId!);
    }

    _audioCoordinator.playConfiguredAlarm();
    _notificationCoordinator?.cancelFocusNotification();
    _mediaCoordinator?.clearMediaSession();
    _notificationCoordinator?.showTaskCompleteNotification();
  }

  //  Internal tick logic

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicking() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final current = state;
    if (current == null) {
      _stopTicking();
      return;
    }

    final newElapsed = current.elapsedSeconds + 1;
    final totalFocusSeconds = current.focusDurationMinutes * 60;

    if (current.state == SessionState.running) {
      if (newElapsed >= totalFocusSeconds) {
        _handleFocusCompleted();
      } else {
        state = current.copyWith(elapsedSeconds: newElapsed);
        if (newElapsed % 10 == 0) _sessionService.updateSession(state!);
        _mediaCoordinator?.updateMediaSession(state!);
      }
    } else if (current.state == SessionState.onBreak) {
      final totalBreakSeconds = current.breakDurationMinutes * 60;
      if (newElapsed >= (totalFocusSeconds + totalBreakSeconds)) {
        _handleSessionCompleted();
      } else {
        state = current.copyWith(elapsedSeconds: newElapsed);
        if (newElapsed % 10 == 0) _sessionService.updateSession(state!);
        _mediaCoordinator?.updateMediaSession(state!);
      }
    }
  }

  void _handleFocusCompleted() {
    final current = state;
    if (current == null) return;

    _audioCoordinator.stopAmbience();

    // All sessions (including quick) transition to break phase.
    // Set elapsed to exactly the focus total so break phase counting starts correctly.
    final totalFocusSeconds = current.focusDurationMinutes * 60;
    final updated = current.copyWith(state: SessionState.onBreak, elapsedSeconds: totalFocusSeconds);
    state = updated;
    _sessionService.updateSession(updated);

    // Restart the timer for the break phase.
    _stopTicking();
    _startTicking();
    _mediaCoordinator?.updateMediaSession(updated);

    _audioCoordinator.playConfiguredAlarm();
    _notificationCoordinator?.showBreakNotification(current.breakDurationMinutes);
  }

  void _handleSessionCompleted() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    _resetMute();
    final completed = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
    _sessionService.updateSession(completed);

    _audioCoordinator.playConfiguredAlarm();
    _notificationCoordinator?.showNextCycleNotification();

    _startNextCycle(current.taskId, current.focusDurationMinutes, current.breakDurationMinutes);
  }

  Future<void> _startNextCycle(BigInt? taskId, int focusMinutes, int breakMinutes) async {
    final session = FocusSession(
      taskId: taskId,
      focusDurationMinutes: focusMinutes,
      breakDurationMinutes: breakMinutes,
      startTime: DateTime.now(),
      state: SessionState.running,
      elapsedSeconds: 0,
    );

    final saved = await _sessionService.startSession(session);
    state = saved;
    _startTicking();
    _mediaCoordinator?.updateMediaSession(saved);
    _audioCoordinator.startConfiguredAmbience();
  }

  /// Manually stop the Pomodoro cycle.
  void stopCycle() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    _audioCoordinator.stopAmbience();
    _resetMute();

    if (current.id != null) {
      final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
      _sessionService.updateSession(updated);
    }
    state = null;

    _notificationCoordinator?.cancelFocusNotification();
    _mediaCoordinator?.clearMediaSession();
    _notificationCoordinator?.showCycleStoppedNotification();
  }

  //  Mute helper

  void _resetMute() {
    try {
      ref.read(ambienceMuteProvider.notifier).reset();
    } catch (_) {
      // Provider may not be initialised yet — safe to ignore.
    }
  }
}
