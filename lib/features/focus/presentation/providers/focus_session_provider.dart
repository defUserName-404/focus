import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/notification_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../tasks/domain/entities/task_extensions.dart';
import '../../../tasks/domain/repositories/i_task_repository.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/focus_session_extensions.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/i_focus_session_repository.dart';

part 'focus_session_provider.g.dart';

@Riverpod(keepAlive: true)
class FocusTimer extends _$FocusTimer {
  late final IFocusSessionRepository _repository;
  late final AudioService _audioService;
  late final NotificationService _notificationService;
  Timer? _timer;
  StreamSubscription<String>? _notificationActionSub;

  @override
  FocusSession? build() {
    _repository = ref.watch(focusSessionRepositoryProvider);
    _audioService = getIt<AudioService>();
    _notificationService = getIt<NotificationService>();

    // Listen for notification action taps (pause/resume/stop).
    _notificationActionSub?.cancel();
    _notificationActionSub = NotificationService.actionStream.listen(_handleNotificationAction);

    ref.onDispose(() {
      _notificationActionSub?.cancel();
      _stopTicking();
    });

    // Fire-and-forget cleanup. Do NOT await this, as we want to start null.
    _cleanupAbandonedSessions();
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
    }
  }

  /// Finds any session that was left running/paused from a previous app run
  /// and marks it as cancelled.
  ///
  /// This is race-condition safe: if the user starts a NEW session while this
  /// is querying, we check [state] to ensure we don't cancel the new session.
  Future<void> _cleanupAbandonedSessions() async {
    try {
      final active = await _repository.getActiveSession();
      if (active == null) return;

      // If the user has already started a session in this instance, [state] will be non-null.
      final currentUserSession = state;

      // If the active session in DB matches our current user session, DO NOT cancel it.
      if (currentUserSession != null && currentUserSession.id == active.id) {
        return;
      }

      // If the found session is running, paused, or on break, it's abandoned.
      if (active.state == SessionState.running ||
          active.state == SessionState.onBreak ||
          active.state == SessionState.paused) {
        final updated = active.copyWith(state: SessionState.cancelled, endTime: DateTime.now());
        await _repository.updateSession(updated);
      }
    } catch (e) {
      debugPrint('Error cleaning up abandoned session: $e');
    }
  }

  /// Create a new session in [idle] state (timer not started yet).
  Future<void> createSession({required BigInt taskId, required int focusMinutes, required int breakMinutes}) async {
    _stopTicking();

    final session = FocusSession(
      taskId: taskId,
      focusDurationMinutes: focusMinutes,
      breakDurationMinutes: breakMinutes,
      startTime: DateTime.now(),
      state: SessionState.idle,
      elapsedSeconds: 0,
    );

    final saved = await _repository.startSession(session);
    state = saved;
  }

  /// User taps the ring / presses play → transition idle→running or paused→running.
  void startTimer() {
    final current = state;
    if (current == null) return;

    if (current.state == SessionState.idle || current.state == SessionState.paused) {
      final updated = current.copyWith(state: SessionState.running);
      state = updated;
      _repository.updateSession(updated);
      _startTicking();
      _updateSessionNotification();

      // Start ambient sound when session begins.
      if (current.state == SessionState.idle) {
        _audioService.startAmbience();
      } else {
        _audioService.resumeAmbience();
      }
    }
  }

  void pauseSession() {
    final current = state;
    if (current == null || current.state != SessionState.running) return;

    _stopTicking();
    _audioService.pauseAmbience();
    final updated = current.copyWith(state: SessionState.paused);
    state = updated;
    _repository.updateSession(updated);
    _notificationService.showFocusNotification(
      title: 'Focus Session (Paused)',
      body: 'Tap Resume to continue.',
      isRunning: false,
    );
  }

  void resumeSession() {
    final current = state;
    if (current == null || current.state != SessionState.paused) return;

    final updated = current.copyWith(state: SessionState.running);
    state = updated;
    _repository.updateSession(updated);
    _startTicking();
    _updateSessionNotification();
    _audioService.resumeAmbience();
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

  /// Premature end: save as cancelled (not deleted).
  void cancelSession() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    _audioService.stopAmbience();
    final updated = current.copyWith(state: SessionState.cancelled, endTime: DateTime.now());
    _repository.updateSession(updated);
    state = null;
    _notificationService.cancelFocusNotification();
  }

  /// Complete the current focus session early (before the timer runs out).
  /// Saves actual elapsed time and marks the session as completed.
  void completeSessionEarly() {
    final current = state;
    if (current == null) return;
    if (current.state == SessionState.completed || current.state == SessionState.cancelled) {
      return;
    }

    _stopTicking();
    _audioService.stopAmbience();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
    _repository.updateSession(updated);
    state = updated;

    _audioService.playAlarm();
    _notificationService.cancelFocusNotification();
    _notificationService.showAlarmNotification(title: 'Session Complete!', body: 'Completed early — great focus!');
  }

  /// Complete the session AND mark the associated task as completed.
  /// This is the primary action from the focus screen.
  Future<void> completeTaskAndSession() async {
    final current = state;
    if (current == null) return;
    if (current.state == SessionState.completed || current.state == SessionState.cancelled) {
      return;
    }

    _stopTicking();
    _audioService.stopAmbience();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
    _repository.updateSession(updated);
    state = updated;

    // Mark the task as completed.
    try {
      final taskRepo = getIt<ITaskRepository>();
      final task = await taskRepo.getTaskById(current.taskId);
      if (task != null && !task.isCompleted) {
        final completedTask = task.copyWith(isCompleted: true, updatedAt: DateTime.now());
        await taskRepo.updateTask(completedTask);
      }
    } catch (e) {
      debugPrint('Error completing task: $e');
    }

    _audioService.playAlarm();
    _notificationService.cancelFocusNotification();
    _notificationService.showAlarmNotification(
      title: 'Task Complete!',
      body: 'Great work — session and task both done.',
    );
  }

  /// Update focus/break duration while paused or idle.
  void updateDuration({int? focusMinutes, int? breakMinutes}) {
    final current = state;
    if (current == null) return;
    if (current.state != SessionState.paused && current.state != SessionState.idle) {
      return;
    }

    final updated = current.copyWith(focusDurationMinutes: focusMinutes, breakDurationMinutes: breakMinutes);
    state = updated;
    _repository.updateSession(updated);
  }

  // ── Internal tick logic ───────────────────────────────────────────────────

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
        if (newElapsed % 10 == 0) _repository.updateSession(state!);
        if (newElapsed % 5 == 0) _updateSessionNotification();
      }
    } else if (current.state == SessionState.onBreak) {
      final totalBreakSeconds = current.breakDurationMinutes * 60;
      if (newElapsed >= (totalFocusSeconds + totalBreakSeconds)) {
        _handleSessionCompleted();
      } else {
        state = current.copyWith(elapsedSeconds: newElapsed);
        if (newElapsed % 10 == 0) _repository.updateSession(state!);
        if (newElapsed % 5 == 0) _updateSessionNotification();
      }
    }
  }

  void _handleFocusCompleted() {
    final current = state;
    if (current == null) return;

    _audioService.stopAmbience();
    final updated = current.copyWith(state: SessionState.onBreak);
    state = updated;
    _repository.updateSession(updated);

    // Play alarm and notify the user that focus phase ended.
    _audioService.playAlarm();
    _notificationService.showAlarmNotification(
      title: 'Break Time!',
      body: 'Focus complete. Take a ${current.breakDurationMinutes}min break.',
    );
  }

  void _handleSessionCompleted() {
    final current = state;
    if (current == null) return;

    // Save the completed session.
    final completed = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
    _repository.updateSession(completed);

    // Play alarm and notify the user that break is over.
    _audioService.playAlarm();
    _notificationService.showAlarmNotification(
      title: 'Break Over!',
      body: 'Starting next focus session automatically.',
    );

    // Auto-start the next Pomodoro cycle: create a new session and begin.
    _startNextCycle(current.taskId, current.focusDurationMinutes, current.breakDurationMinutes);
  }

  /// Automatically begin the next focus cycle for Pomodoro auto-resume.
  Future<void> _startNextCycle(BigInt taskId, int focusMinutes, int breakMinutes) async {
    final session = FocusSession(
      taskId: taskId,
      focusDurationMinutes: focusMinutes,
      breakDurationMinutes: breakMinutes,
      startTime: DateTime.now(),
      state: SessionState.running,
      elapsedSeconds: 0,
    );

    final saved = await _repository.startSession(session);
    state = saved;
    _startTicking();
    _updateSessionNotification();
    _audioService.startAmbience();
  }

  /// Manually stop the Pomodoro cycle after the current session.
  /// Completes the session and does NOT auto-cycle.
  void stopCycle() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    _audioService.stopAmbience();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
    _repository.updateSession(updated);
    state = null;

    _notificationService.cancelFocusNotification();
    _notificationService.showAlarmNotification(
      title: 'Focus Cycle Ended',
      body: 'Nice work! You stopped the Pomodoro cycle.',
    );
  }

  // ── Notification helpers ────────────────────────────────────────────────

  /// Update the persistent background notification with current progress.
  void _updateSessionNotification() {
    final current = state;
    if (current == null) return;

    final isFocusPhase = current.state == SessionState.running || current.state == SessionState.paused;
    final totalFocusSeconds = current.focusDurationMinutes * 60;

    int remaining;
    String phase;

    if (isFocusPhase) {
      remaining = totalFocusSeconds - current.elapsedSeconds;
      phase = 'Focus';
    } else {
      final totalBreakSeconds = current.breakDurationMinutes * 60;
      remaining = (totalFocusSeconds + totalBreakSeconds) - current.elapsedSeconds;
      phase = 'Break';
    }

    remaining = remaining.clamp(0, 99999);
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;

    _notificationService.showFocusNotification(
      title: '$phase Session',
      body: '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} remaining',
      isRunning: current.state == SessionState.running || current.state == SessionState.onBreak,
    );
  }
}

@riverpod
IFocusSessionRepository focusSessionRepository(Ref ref) {
  return getIt<IFocusSessionRepository>();
}

// ── Progress Logic (Merged) ────────────────────────────────────────────────

/// Data class to hold parameters for progress calculation in an isolate.
class _ProgressParams {
  final SessionState state;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final int elapsedSeconds;

  _ProgressParams({
    required this.state,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.elapsedSeconds,
  });
}

/// Computed progress data derived from the raw [FocusSession].
/// Holds all display-ready values.
class FocusProgress {
  final double progress;
  final int remainingMinutes;
  final int remainingSeconds;
  final bool isFocusPhase;
  final bool isIdle;
  final bool isPaused;
  final bool isRunning;
  final bool isCompleted;

  const FocusProgress({
    required this.progress,
    required this.remainingMinutes,
    required this.remainingSeconds,
    required this.isFocusPhase,
    required this.isIdle,
    required this.isPaused,
    required this.isRunning,
    required this.isCompleted,
  });

  String get formattedTime =>
      '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}

/// Top-level function for [compute] to perform mathematical derivation.
FocusProgress _calculateProgress(_ProgressParams params) {
  final isFocus =
      params.state == SessionState.running || params.state == SessionState.paused || params.state == SessionState.idle;

  final totalSeconds = isFocus ? params.focusDurationMinutes * 60 : params.breakDurationMinutes * 60;

  final elapsedInPhase = isFocus ? params.elapsedSeconds : params.elapsedSeconds - (params.focusDurationMinutes * 60);

  final remaining = (totalSeconds - elapsedInPhase).clamp(0, totalSeconds);
  final progress = totalSeconds > 0 ? (elapsedInPhase / totalSeconds).clamp(0.0, 1.0) : 0.0;

  return FocusProgress(
    progress: progress,
    remainingMinutes: (remaining / 60).floor(),
    remainingSeconds: remaining % 60,
    isFocusPhase: isFocus,
    isIdle: params.state == SessionState.idle,
    isPaused: params.state == SessionState.paused,
    isRunning: params.state == SessionState.running || params.state == SessionState.onBreak,
    isCompleted: params.state == SessionState.completed,
  );
}

@riverpod
Future<FocusProgress?> focusProgress(Ref ref) async {
  final session = ref.watch(focusTimerProvider);
  if (session == null) return null;

  // Use compute to offload math from the main thread
  return compute(
    _calculateProgress,
    _ProgressParams(
      state: session.state,
      focusDurationMinutes: session.focusDurationMinutes,
      breakDurationMinutes: session.breakDurationMinutes,
      elapsedSeconds: session.elapsedSeconds,
    ),
  );
}
