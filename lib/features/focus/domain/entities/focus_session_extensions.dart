import 'focus_session.dart';
import 'session_state.dart';

/// Sentinel object used in [FocusSessionCopyWith.copyWith] to distinguish
/// "parameter not provided" from "explicitly set to null".
///
/// Dart's `null` is a valid value for nullable fields like [FocusSession.taskId].
/// Without this sentinel, `copyWith(taskId: null)` would be indistinguishable
/// from `copyWith()` (i.e. "keep the old value"). The sentinel pattern uses
/// `Object?` as the parameter type and checks identity against [_unset] to
/// tell the two cases apart.
const _FocusSessionCopyWithUnset _unset = _FocusSessionCopyWithUnset();

class _FocusSessionCopyWithUnset {
  const _FocusSessionCopyWithUnset();
}

extension FocusSessionCopyWith on FocusSession {
  FocusSession copyWith({
    int? id,
    Object? taskId = _unset,
    int? focusDurationMinutes,
    int? breakDurationMinutes,
    DateTime? startTime,
    Object? endTime = _unset,
    SessionState? state,
    int? elapsedSeconds,
    Object? focusPhaseEndedAt = _unset,
  }) => FocusSession(
    id: id ?? this.id,
    taskId: taskId == _unset ? this.taskId : taskId as int?,
    focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
    breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
    startTime: startTime ?? this.startTime,
    endTime: endTime == _unset ? this.endTime : endTime as DateTime?,
    state: state ?? this.state,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    focusPhaseEndedAt: focusPhaseEndedAt == _unset
        ? this.focusPhaseEndedAt
        : focusPhaseEndedAt as int?,
  );
}
