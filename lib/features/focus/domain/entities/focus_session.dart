import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'session_state.dart';

/// Immutable snapshot of a single focus session.
///
/// All fields are `final`. Mutations produce new instances via `copyWith`.
/// [elapsedSeconds] is a running counter that spans both the focus *and*
/// break phases of a Pomodoro cycle. The boundary between the two phases
/// is recorded in [focusPhaseEndedAt] (set when focus completes).
@immutable
class FocusSession extends Equatable {
  final int? id;
  final int? taskId;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionState state;
  final int elapsedSeconds;

  /// The actual elapsed seconds when the focus phase ended.
  ///
  /// `null` while focus is still running (idle / running states).
  /// Set to the real elapsed value when focus completes — whether
  /// the timer ran out naturally or the user skipped the phase.
  /// This lets the break timer and stats use the *real* focus time
  /// instead of always assuming the full configured duration.
  ///
  /// Not persisted to the database; defaults to
  /// [focusDurationMinutes] * 60 when loaded from storage.
  final int? focusPhaseEndedAt;

  /// Elapsed seconds at which the focus phase ended.
  /// Falls back to [focusDurationMinutes] * 60 when not explicitly set
  /// (e.g. session loaded from DB after an app restart).
  int get focusEndElapsed => focusPhaseEndedAt ?? focusDurationMinutes * 60;

  /// Whether this is a quick session (no associated task).
  bool get isQuickSession => taskId == null;

  const FocusSession({
    this.id,
    this.taskId,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.startTime,
    this.endTime,
    required this.state,
    this.elapsedSeconds = 0,
    this.focusPhaseEndedAt,
  });

  @override
  List<Object?> get props => [
    id, taskId, focusDurationMinutes, breakDurationMinutes,
    startTime, endTime, state, elapsedSeconds, focusPhaseEndedAt,
  ];
}
