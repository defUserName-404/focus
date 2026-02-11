import 'package:dart_mappable/dart_mappable.dart';

import 'session_state.dart';

part 'focus_session.mapper.dart';

@MappableClass()
class FocusSession with FocusSessionMappable {
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
