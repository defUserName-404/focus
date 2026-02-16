import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/focus_session.dart';
import '../../domain/entities/session_state.dart';
import 'focus_session_provider.dart';

part 'focus_progress_provider.g.dart';

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
  final elapsedInPhase = isFocus ? session.elapsedSeconds : session.elapsedSeconds - totalFocusSeconds;

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
