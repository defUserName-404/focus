import 'focus_session.dart';
import 'session_state.dart';

const _FocusSessionCopyWithUnset _unset = _FocusSessionCopyWithUnset();

class _FocusSessionCopyWithUnset {
  const _FocusSessionCopyWithUnset();
}

extension FocusSessionCopyWith on FocusSession {
  FocusSession copyWith({
    BigInt? id,
    BigInt? taskId,
    int? focusDurationMinutes,
    int? breakDurationMinutes,
    DateTime? startTime,
    Object? endTime = _unset,
    SessionState? state,
    int? elapsedSeconds,
  }) => FocusSession(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
    breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
    startTime: startTime ?? this.startTime,
    endTime: endTime == _unset ? this.endTime : endTime as DateTime?,
    state: state ?? this.state,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
  );
}
