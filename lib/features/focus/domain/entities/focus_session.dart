import 'session_state.dart';

class FocusSession {
  final String id;
  final String taskId;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionState state;
  final int elapsedSeconds;

  FocusSession({
    required this.id,
    required this.taskId,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.startTime,
    this.endTime,
    required this.state,
    this.elapsedSeconds = 0,
  });
}
