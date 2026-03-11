import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/notification_constants.dart';
import '../../../../core/services/log_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/focus_session_extensions.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/services/focus_audio_coordinator.dart';
import '../../domain/services/focus_media_session_coordinator.dart';
import '../../domain/services/focus_notification_coordinator.dart';
import '../../domain/services/focus_session_service.dart';
import '../../domain/services/focus_session_state_machine.dart';
import 'ambience_mute_provider.dart';
import 'focus_providers.dart';

part 'focus_session_provider.g.dart';

final _log = LogService.instance;

@Riverpod(keepAlive: true)
class FocusTimer extends _$FocusTimer {
  late final FocusSessionService _sessionService;
  late final FocusAudioCoordinator _audioCoordinator;
  FocusNotificationCoordinator? _notificationCoordinator;
  FocusMediaSessionCoordinator? _mediaCoordinator;
  final FocusSessionStateMachine _sm = const FocusSessionStateMachine();
  Timer? _timer;
  StreamSubscription<String>? _notificationActionSub;

  /// Guard to prevent auto-pausing due to race conditions during startup.
  bool _isStarting = false;

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
        // Ignore interruptions during the boot-up phase to prevent auto-pausing.
        if (_isStarting) return;
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
    unawaited(_sessionService.cleanupAbandonedSessions());

    // React to audio settings changes.
    ref.listen(audioPreferencesProvider, (prev, next) {
      final current = state;
      if (current == null) return;
      if (current.state != SessionState.running && current.state != SessionState.onBreak) return;

      final newData = next.asData?.value;
      if (newData != null && prev?.asData?.value != newData) {
        unawaited(_audioCoordinator.reloadAmbience(newData));
      }
    });

    return null;
  }

  void _handleNotificationAction(String actionId) {
    switch (actionId) {
      case NotificationConstants.actionPause:
        pauseSession();
      case NotificationConstants.actionResume:
        // Use startTimer to correctly handle transitions from both IDLE and PAUSED.
        startTimer();
      case NotificationConstants.actionStop:
        stopCycle();
      case NotificationConstants.actionSkip:
        skipToNextPhase();
    }
  }

  Future<void> createSession({int? taskId, required int focusMinutes, required int breakMinutes}) async {
    _stopTicking();

    final session = FocusSession(
      taskId: taskId,
      focusDurationMinutes: focusMinutes,
      breakDurationMinutes: breakMinutes,
      startTime: DateTime.now(),
      state: SessionState.idle,
      elapsedSeconds: 0,
    );

    state = session;
  }

  Future<void> startTimer() async {
    final current = state;
    if (current == null) return;

    if (current.state == SessionState.idle) {
      _isStarting = true;
      // Acquire audio focus from the OS.
      await _mediaCoordinator?.activateAudioSession();

      final running = current.copyWith(state: SessionState.running, startTime: DateTime.now());
      final result = await _sessionService.startSession(running);
      final saved = result.getOrNull();
      if (saved == null) {
        _isStarting = false;
        _log.error('Failed to persist new session', tag: 'FocusTimer');
        return;
      }
      state = saved;
      _startTicking();

      // Start audio FIRST, then update media session to prevent "pause" feedback loops.
      await _audioCoordinator.startConfiguredAmbience();
      _mediaCoordinator?.updateMediaSession(saved);

      // Release guard after a short delay.
      Future.delayed(const Duration(milliseconds: 500), () => _isStarting = false);
    } else if (current.state == SessionState.paused) {
      resumeSession();
    }
  }

  void pauseSession() {
    final current = state;
    if (current == null) return;

    final paused = _sm.pause(current);
    if (paused == null) return;

    _stopTicking();
    unawaited(_audioCoordinator.pauseAmbience());
    state = paused;
    unawaited(_sessionService.updateSession(paused));
    _mediaCoordinator?.updateMediaSession(paused);
  }

  void resumeSession() {
    final current = state;
    if (current == null || current.state != SessionState.paused) return;

    final resumed = _sm.resume(current);
    if (resumed == null) return;

    _isStarting = true;
    state = resumed;
    unawaited(_sessionService.updateSession(resumed));
    _startTicking();

    // Resume audio before updating media session to avoid race condition.
    unawaited(_audioCoordinator.resumeAmbience());
    _mediaCoordinator?.updateMediaSession(resumed);

    Future.delayed(const Duration(milliseconds: 500), () => _isStarting = false);
  }

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

    final transition = _sm.skip(current);
    if (transition == null) return;

    _applyTransition(transition);
  }

  /// Premature end: save as cancelled (not deleted).
  /// Only persists if the session was already saved to DB (has an id).
  void cancelSession() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    unawaited(_audioCoordinator.stopAmbience());
    _resetMute();

    if (current.id != null) {
      final updated = current.copyWith(state: SessionState.cancelled, endTime: DateTime.now());
      unawaited(_sessionService.updateSession(updated));
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
    unawaited(_audioCoordinator.stopAmbience());
    _resetMute();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());

    if (current.id != null) {
      unawaited(_sessionService.updateSession(updated));
    } else {
      unawaited(_sessionService.startSession(updated));
    }
    // Clear state so the session screen reacts immediately.
    state = null;

    unawaited(_audioCoordinator.playConfiguredAlarm());
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
    unawaited(_audioCoordinator.stopAmbience());
    _resetMute();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());

    if (current.id != null) {
      await _sessionService.updateSession(updated);
    } else {
      await _sessionService.startSession(updated);
    }
    state = updated;

    // Mark the task as completed (skip for quick sessions).
    if (current.taskId != null) {
      await _sessionService.completeTask(current.taskId!);
    }

    unawaited(_audioCoordinator.playConfiguredAlarm());
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
    _applyTransition(_sm.tick(current));
  }

  /// Centralised handler for all [SessionTransition] outcomes.
  ///
  /// Keeps the side-effect logic in one place so [_tick], [skipToNextPhase],
  /// etc. don't duplicate audio/notification/persistence calls.
  void _applyTransition(SessionTransition transition) {
    switch (transition) {
      case TickUpdate(:final session, :final shouldPersist):
        state = session;
        if (shouldPersist) unawaited(_sessionService.updateSession(session));
        _mediaCoordinator?.updateMediaSession(session);

      case FocusPhaseCompleted(:final session):
        unawaited(_audioCoordinator.stopAmbience());
        state = session;
        unawaited(_sessionService.updateSession(session));
        _stopTicking();
        _startTicking();
        _mediaCoordinator?.updateMediaSession(session);
        unawaited(_audioCoordinator.playConfiguredAlarm());
        _notificationCoordinator?.showBreakNotification(session.breakDurationMinutes);

      case CycleCompleted(:final session):
        _stopTicking();
        _resetMute();
        _handleCycleCompleted(session);
    }
  }

  /// Persist the completed session and auto-start the next cycle.
  ///
  /// Awaited so the daily stats table is fully in sync before a new
  /// session row is inserted — preventing the today / overall mismatch.
  Future<void> _handleCycleCompleted(FocusSession completed) async {
    await _sessionService.updateSession(completed);

    unawaited(_audioCoordinator.playConfiguredAlarm());
    _notificationCoordinator?.showNextCycleNotification();

    await _startNextCycle(
      completed.taskId,
      completed.focusDurationMinutes,
      completed.breakDurationMinutes,
    );
  }

  Future<void> _startNextCycle(int? taskId, int focusMinutes, int breakMinutes) async {
    final session = FocusSession(
      taskId: taskId,
      focusDurationMinutes: focusMinutes,
      breakDurationMinutes: breakMinutes,
      startTime: DateTime.now(),
      state: SessionState.running,
      elapsedSeconds: 0,
    );

    final result = await _sessionService.startSession(session);
    final saved = result.getOrNull();
    if (saved == null) {
      _log.error('Failed to persist next-cycle session', tag: 'FocusTimer');
      return;
    }
    state = saved;
    _startTicking();
    _mediaCoordinator?.updateMediaSession(saved);
    unawaited(_audioCoordinator.startConfiguredAmbience());
  }

  /// Manually stop the Pomodoro cycle.
  ///
  /// The session is saved as **cancelled** — not completed — so it
  /// doesn't inflate the "sessions completed" stat.
  void stopCycle() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    unawaited(_audioCoordinator.stopAmbience());
    _resetMute();

    if (current.id != null) {
      final updated = current.copyWith(state: SessionState.cancelled, endTime: DateTime.now());
      unawaited(_sessionService.updateSession(updated));
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
