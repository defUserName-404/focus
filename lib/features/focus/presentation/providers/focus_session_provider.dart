import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show StreamProvider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/audio_assets.dart';
import '../../../../core/constants/notification_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/audio_session_manager.dart';
import '../../../../core/services/focus_audio_handler.dart';
import '../../../../core/services/notification_service.dart';
import '../../../settings/domain/entities/setting.dart';
import '../../../settings/domain/repositories/i_settings_repository.dart';
import '../../../tasks/domain/entities/task_extensions.dart';
import '../../../tasks/domain/repositories/i_task_repository.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/focus_session_extensions.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/i_focus_session_repository.dart';
import 'ambience_mute_provider.dart';

part 'focus_session_provider.g.dart';

@Riverpod(keepAlive: true)
class FocusTimer extends _$FocusTimer {
  late final IFocusSessionRepository _repository;
  late final AudioService _audioService;
  late final NotificationService _notificationService;
  late final ISettingsRepository _settingsRepository;
  late final FocusAudioHandler _audioHandler;
  late final AudioSessionManager _audioSessionManager;
  Timer? _timer;
  StreamSubscription<String>? _notificationActionSub;

  @override
  FocusSession? build() {
    _repository = ref.watch(focusSessionRepositoryProvider);
    _audioService = getIt<AudioService>();
    _notificationService = getIt<NotificationService>();
    _settingsRepository = getIt<ISettingsRepository>();
    _audioHandler = getIt<FocusAudioHandler>();
    _audioSessionManager = getIt<AudioSessionManager>();

    // Wire media-button & lock-screen controls → our actions.
    _audioHandler.onAction = _handleNotificationAction;

    // Wire headphone unplug → auto-pause.
    _audioSessionManager.onBecomingNoisy = () => pauseSession();
    _audioSessionManager.onInterruption = (shouldPause) {
      if (shouldPause) {
        pauseSession();
      } else {
        resumeSession();
      }
    };

    // Listen for notification action taps (pause/resume/stop/skip).
    _notificationActionSub?.cancel();
    _notificationActionSub = NotificationService.actionStream.listen(_handleNotificationAction);

    ref.onDispose(() {
      _notificationActionSub?.cancel();
      _audioHandler.onAction = null;
      _audioSessionManager.onBecomingNoisy = null;
      _audioSessionManager.onInterruption = null;
      _stopTicking();
    });

    // Mark abandoned sessions as incomplete on startup.
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
      case NotificationConstants.actionSkip:
        skipToNextPhase();
    }
  }

  /// Finds any session that was left running / paused from a previous app run
  /// and marks it as **incomplete** (not "cancelled" — that's user-initiated).
  Future<void> _cleanupAbandonedSessions() async {
    try {
      final active = await _repository.getActiveSession();
      if (active == null) return;

      final currentUserSession = state;
      if (currentUserSession != null && currentUserSession.id == active.id) {
        return;
      }

      if (active.state == SessionState.running ||
          active.state == SessionState.onBreak ||
          active.state == SessionState.paused) {
        final updated = active.copyWith(
          state: SessionState.incomplete,
          endTime: DateTime.now(),
        );
        await _repository.updateSession(updated);
      }
    } catch (e) {
      debugPrint('Error cleaning up abandoned session: $e');
    }
  }

  /// Create a new session in [idle] state.
  ///
  /// **Does NOT persist to DB** — the session is only held in-memory until
  /// the user actually starts the timer, at which point it gets saved.
  ///
  /// If [taskId] is `null`, this is a **quick session** with no task attached.
  Future<void> createSession({
    BigInt? taskId,
    required int focusMinutes,
    required int breakMinutes,
  }) async {
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
      await _audioSessionManager.activate();

      // Now persist the session for the first time.
      final running = current.copyWith(
        state: SessionState.running,
        startTime: DateTime.now(),
      );
      final saved = await _repository.startSession(running);
      state = saved;
      _startTicking();
      _updateMediaSession();
      _startConfiguredAmbience();
    } else if (current.state == SessionState.paused) {
      // Resume into the correct phase based on elapsed time.
      final totalFocusSeconds = current.focusDurationMinutes * 60;
      final wasOnBreak = current.elapsedSeconds >= totalFocusSeconds;
      final resumeState = wasOnBreak ? SessionState.onBreak : SessionState.running;

      final updated = current.copyWith(state: resumeState);
      state = updated;
      _repository.updateSession(updated);
      _startTicking();
      _updateMediaSession();
      _audioService.resumeAmbience();
    }
  }

  void pauseSession() {
    final current = state;
    if (current == null ||
        (current.state != SessionState.running && current.state != SessionState.onBreak)) {
      return;
    }

    _stopTicking();
    _audioService.pauseAmbience();
    final updated = current.copyWith(state: SessionState.paused);
    state = updated;
    _repository.updateSession(updated);
    _updateMediaSession();
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
    _repository.updateSession(updated);
    _startTicking();
    _updateMediaSession();
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
    _audioService.stopAmbience();
    _resetMute();

    if (current.id != null) {
      final updated = current.copyWith(
        state: SessionState.cancelled,
        endTime: DateTime.now(),
      );
      _repository.updateSession(updated);
    }
    state = null;
    _notificationService.cancelFocusNotification();
    _clearMediaSession();
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
    _audioService.stopAmbience();
    _resetMute();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());

    if (current.id != null) {
      _repository.updateSession(updated);
    } else {
      _repository.startSession(updated);
    }
    // Clear state so the session screen reacts immediately.
    state = null;

    _playConfiguredAlarm();
    _notificationService.cancelFocusNotification();
    _clearMediaSession();
    _notificationService.showAlarmNotification(
      title: 'Session Complete!',
      body: 'Completed early — great focus!',
    );
  }

  /// Complete the session AND mark the associated task as completed.
  Future<void> completeTaskAndSession() async {
    final current = state;
    if (current == null) return;
    if (current.state == SessionState.completed || current.state == SessionState.cancelled) {
      return;
    }

    _stopTicking();
    _audioService.stopAmbience();
    _resetMute();
    final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());

    if (current.id != null) {
      _repository.updateSession(updated);
    } else {
      await _repository.startSession(updated);
    }
    state = updated;

    // Mark the task as completed (skip for quick sessions).
    if (current.taskId != null) {
      try {
        final taskRepo = getIt<ITaskRepository>();
        final task = await taskRepo.getTaskById(current.taskId!);
        if (task != null && !task.isCompleted) {
          final completedTask = task.copyWith(isCompleted: true, updatedAt: DateTime.now());
          await taskRepo.updateTask(completedTask);
        }
      } catch (e) {
        debugPrint('Error completing task: $e');
      }
    }

    _playConfiguredAlarm();
    _notificationService.cancelFocusNotification();
    _clearMediaSession();
    _notificationService.showAlarmNotification(
      title: 'Task Complete!',
      body: 'Great work — session and task both done.',
    );
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
        _updateMediaSession();
      }
    } else if (current.state == SessionState.onBreak) {
      final totalBreakSeconds = current.breakDurationMinutes * 60;
      if (newElapsed >= (totalFocusSeconds + totalBreakSeconds)) {
        _handleSessionCompleted();
      } else {
        state = current.copyWith(elapsedSeconds: newElapsed);
        if (newElapsed % 10 == 0) _repository.updateSession(state!);
        _updateMediaSession();
      }
    }
  }

  void _handleFocusCompleted() {
    final current = state;
    if (current == null) return;

    try {
      _audioService.stopAmbience();
    } catch (e) {
      debugPrint('Error stopping ambience on focus complete: $e');
    }

    // All sessions (including quick) transition to break phase.
    // Set elapsed to exactly the focus total so break phase counting starts correctly.
    final totalFocusSeconds = current.focusDurationMinutes * 60;
    final updated = current.copyWith(
      state: SessionState.onBreak,
      elapsedSeconds: totalFocusSeconds,
    );
    state = updated;
    _repository.updateSession(updated);

    // Restart the timer for the break phase.
    _stopTicking();
    _startTicking();
    _updateMediaSession();

    _playConfiguredAlarm();
    _notificationService.showAlarmNotification(
      title: 'Break Time!',
      body: 'Focus complete. Take a ${current.breakDurationMinutes}min break.',
    );
  }

  void _handleSessionCompleted() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    _resetMute();
    final completed = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
    _repository.updateSession(completed);
    // Keep the completed session in state momentarily — _startNextCycle
    // will replace it with a fresh running session so the UI never sees
    // state == null (which would trigger an auto-pop).

    _playConfiguredAlarm();
    _notificationService.showAlarmNotification(
      title: 'Break Over!',
      body: 'Starting next focus session automatically.',
    );

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

    final saved = await _repository.startSession(session);
    state = saved;
    _startTicking();
    _updateMediaSession();
    _startConfiguredAmbience();
  }

  // ── Configured audio helpers ──────────────────────────────────────────────

  Future<void> _startConfiguredAmbience() async {
    try {
      final prefs = await _settingsRepository.getAudioPreferences();
      if (!prefs.ambienceEnabled) return;

      SoundPreset? preset;
      if (prefs.ambienceSoundId != null) {
        preset = AudioAssets.findById(prefs.ambienceSoundId!);
      }
      preset ??= AudioAssets.defaultAmbience;

      await _audioService.setNoiseVolume(prefs.ambienceVolume);
      await _audioService.startAmbience(preset);
    } catch (e) {
      debugPrint('Error starting configured ambience: $e');
    }
  }

  Future<void> _playConfiguredAlarm() async {
    try {
      final prefs = await _settingsRepository.getAudioPreferences();
      SoundPreset? preset;
      if (prefs.alarmSoundId != null) {
        preset = AudioAssets.findById(prefs.alarmSoundId!);
      }
      preset ??= AudioAssets.defaultAlarm;
      await _audioService.playAlarm(preset);
    } catch (e) {
      debugPrint('Error playing configured alarm: $e');
      await _audioService.playAlarm();
    }
  }

  /// Manually stop the Pomodoro cycle.
  void stopCycle() {
    final current = state;
    if (current == null) return;

    _stopTicking();
    _audioService.stopAmbience();
    _resetMute();

    if (current.id != null) {
      final updated = current.copyWith(state: SessionState.completed, endTime: DateTime.now());
      _repository.updateSession(updated);
    }
    state = null;

    _notificationService.cancelFocusNotification();
    _clearMediaSession();
    _notificationService.showAlarmNotification(
      title: 'Focus Cycle Ended',
      body: 'Nice work! You stopped the Pomodoro cycle.',
    );
  }

  // ── Mute helper ──────────────────────────────────────────────────────────

  void _resetMute() {
    try {
      ref.read(ambienceMuteProvider.notifier).reset();
    } catch (_) {
      // Provider may not be initialised yet — safe to ignore.
    }
  }

  // ── Media session helpers (audio_service) ─────────────────────────────

  /// Sync the OS MediaSession / lock-screen controls with the current state.
  void _updateMediaSession() {
    final current = state;
    if (current == null) return;

    final totalFocusSeconds = current.focusDurationMinutes * 60;
    final totalBreakSeconds = current.breakDurationMinutes * 60;
    final isPlaying =
        current.state == SessionState.running || current.state == SessionState.onBreak;

    final bool isFocusPhase;
    if (current.state == SessionState.paused) {
      isFocusPhase = current.elapsedSeconds < totalFocusSeconds;
    } else {
      isFocusPhase = current.state == SessionState.running;
    }

    final phaseDuration = isFocusPhase ? totalFocusSeconds : totalBreakSeconds;
    final elapsedInPhase =
        isFocusPhase ? current.elapsedSeconds : current.elapsedSeconds - totalFocusSeconds;

    _audioHandler.updateSessionMediaItem(
      title: isFocusPhase ? 'Focus Session' : 'Break Time',
      artist: current.state == SessionState.paused ? 'Paused' : 'Focus App',
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
  Future<void> _clearMediaSession() async {
    await _audioHandler.clearSession();
    await _audioSessionManager.deactivate();
  }
}

@riverpod
IFocusSessionRepository focusSessionRepository(Ref ref) {
  return getIt<IFocusSessionRepository>();
}

/// Watches timer preferences (focus / break duration) from settings.
final timerPreferencesProvider = StreamProvider<TimerPreferences>((ref) {
  final repository = getIt<ISettingsRepository>();
  return repository.watchTimerPreferences();
});

// ── Progress Logic ─────────────────────────────────────────────────────────

/// Computed progress data derived from the raw [FocusSession].
///
/// This is a **synchronous** provider — no isolate, no async.
/// The calculation is trivially cheap (a handful of int ops) and
/// making it sync eliminates the `AsyncValue.loading` flicker that
/// caused the ambience marquee / badge to blink on every tick.
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

@riverpod
FocusProgress? focusProgress(Ref ref) {
  final session = ref.watch(focusTimerProvider);
  if (session == null) return null;

  final totalFocusSeconds = session.focusDurationMinutes * 60;

  // Determine phase: when paused, infer from elapsed time.
  final bool isFocus;
  if (session.state == SessionState.paused) {
    isFocus = session.elapsedSeconds < totalFocusSeconds;
  } else {
    isFocus = session.state == SessionState.running || session.state == SessionState.idle;
  }

  final totalSeconds = isFocus ? totalFocusSeconds : session.breakDurationMinutes * 60;
  final elapsedInPhase = isFocus
      ? session.elapsedSeconds
      : session.elapsedSeconds - totalFocusSeconds;

  final remaining = (totalSeconds - elapsedInPhase).clamp(0, totalSeconds);
  final progress = totalSeconds > 0 ? (elapsedInPhase / totalSeconds).clamp(0.0, 1.0) : 0.0;

  return FocusProgress(
    progress: progress,
    remainingMinutes: (remaining / 60).floor(),
    remainingSeconds: remaining % 60,
    isFocusPhase: isFocus,
    isIdle: session.state == SessionState.idle,
    isPaused: session.state == SessionState.paused,
    isRunning: session.state == SessionState.running || session.state == SessionState.onBreak,
    isCompleted: session.state == SessionState.completed,
  );
}
