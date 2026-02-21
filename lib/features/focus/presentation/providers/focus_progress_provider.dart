import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/session_state.dart';
import '../models/focus_progress.dart';
import 'focus_session_provider.dart';

part 'focus_progress_provider.g.dart';

@riverpod
FocusProgress? focusProgress(Ref ref) {
  final session = ref.watch(focusTimerProvider);
  if (session == null) return null;

  // Use focusEndElapsed (not the raw configured duration) so that
  // skipped focus phases are reflected correctly in the progress ring.
  final focusEnd = session.focusEndElapsed;

  // Determine phase: when paused, infer from elapsed time.
  final bool isFocus;
  if (session.state == SessionState.paused) {
    isFocus = session.elapsedSeconds < focusEnd;
  } else {
    isFocus = session.state == SessionState.running || session.state == SessionState.idle;
  }

  final totalSeconds = isFocus ? session.focusDurationMinutes * 60 : session.breakDurationMinutes * 60;
  final elapsedInPhase = isFocus ? session.elapsedSeconds : session.elapsedSeconds - focusEnd;

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
