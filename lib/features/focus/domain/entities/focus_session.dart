import 'session_state.dart';

class FocusSession {
  final BigInt? id;
  final BigInt? taskId;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionState state;
  final int elapsedSeconds;

  /// Whether this is a quick session (no associated task).
  bool get isQuickSession => taskId == null;

  FocusSession({
    this.id,
    this.taskId,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.startTime,
    this.endTime,
    required this.state,
    this.elapsedSeconds = 0,
  });
}
