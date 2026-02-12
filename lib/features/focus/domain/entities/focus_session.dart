import 'session_state.dart';

class FocusSession {
  final BigInt? id;
  final BigInt taskId;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionState state;
  final int elapsedSeconds;

  FocusSession({
    this.id,
    required this.taskId,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.startTime,
    this.endTime,
    required this.state,
    this.elapsedSeconds = 0,
  });
}
