import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/session/domain/entities/focus_session.dart';
import 'package:focus/features/session/domain/entities/session_state.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/domain/entities/task_reminder_mode.dart';

/// Shared fixed clock for deterministic domain tests.
final testNow = DateTime.utc(2026, 8, 2, 12);

Task buildTask({
  int? id = 1,
  int projectId = 1,
  String title = 'Write tests',
  TaskPriority priority = TaskPriority.medium,
  TaskReminderMode reminderMode = TaskReminderMode.dayBefore,
  int? customReminderMinutesBefore,
  DateTime? startDate,
  Object? endDate = _sentinel,
  int depth = 0,
  bool isCompleted = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final created = createdAt ?? testNow.subtract(const Duration(days: 3));
  final resolvedEndDate = identical(endDate, _sentinel) ? testNow.add(const Duration(days: 2)) : endDate as DateTime?;
  return Task(
    id: id,
    projectId: projectId,
    title: title,
    priority: priority,
    reminderMode: reminderMode,
    customReminderMinutesBefore: customReminderMinutesBefore,
    startDate: startDate,
    endDate: resolvedEndDate,
    depth: depth,
    isCompleted: isCompleted,
    createdAt: created,
    updatedAt: updatedAt ?? created,
  );
}

const _sentinel = Object();

Project buildProject({
  int? id = 1,
  String title = 'Focus',
  String? description,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final created = createdAt ?? testNow.subtract(const Duration(days: 7));
  return Project(id: id, title: title, description: description, createdAt: created, updatedAt: updatedAt ?? created);
}

FocusSession buildSession({
  int? id = 1,
  int? taskId = 1,
  int focusDurationMinutes = 25,
  int breakDurationMinutes = 5,
  SessionState state = SessionState.running,
  int elapsedSeconds = 0,
  int? focusPhaseEndedAt,
  DateTime? startTime,
  DateTime? endTime,
}) {
  return FocusSession(
    id: id,
    taskId: taskId,
    focusDurationMinutes: focusDurationMinutes,
    breakDurationMinutes: breakDurationMinutes,
    startTime: startTime ?? testNow,
    endTime: endTime,
    state: state,
    elapsedSeconds: elapsedSeconds,
    focusPhaseEndedAt: focusPhaseEndedAt,
  );
}
