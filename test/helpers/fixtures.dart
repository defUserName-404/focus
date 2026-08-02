import 'package:focus/core/utils/id_utils.dart';
import 'package:focus/features/milestones/domain/entities/milestone.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/projects/domain/entities/project_status.dart';
import 'package:focus/features/session/domain/entities/focus_session.dart';
import 'package:focus/features/session/domain/entities/session_state.dart';
import 'package:focus/features/tags/domain/entities/tag.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/domain/entities/task_reminder_mode.dart';
import 'package:focus/features/tasks/domain/entities/task_status.dart';

/// Shared fixed clock for deterministic domain tests.
final testNow = DateTime.utc(2026, 8, 2, 12);

Task buildTask({
  int? id = 1,
  String? uuid,
  int projectId = 1,
  String title = 'Write tests',
  TaskPriority priority = TaskPriority.medium,
  TaskStatus? status,
  TaskReminderMode reminderMode = TaskReminderMode.dayBefore,
  int? customReminderMinutesBefore,
  DateTime? startDate,
  Object? endDate = _sentinel,
  int depth = 0,
  int? estimatedMinutes,
  double sortOrder = 0,
  int? milestoneId,
  bool isCompleted = false,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final created = createdAt ?? testNow.subtract(const Duration(days: 3));
  final resolvedEndDate = identical(endDate, _sentinel) ? testNow.add(const Duration(days: 2)) : endDate as DateTime?;
  return Task(
    id: id,
    uuid: uuid ?? 'task-uuid-${id ?? 0}',
    projectId: projectId,
    title: title,
    priority: priority,
    status: status ?? (isCompleted ? TaskStatus.done : TaskStatus.todo),
    reminderMode: reminderMode,
    customReminderMinutesBefore: customReminderMinutesBefore,
    startDate: startDate,
    endDate: resolvedEndDate,
    depth: depth,
    estimatedMinutes: estimatedMinutes,
    sortOrder: sortOrder,
    milestoneId: milestoneId,
    createdAt: created,
    updatedAt: updatedAt ?? created,
    deletedAt: deletedAt,
  );
}

const _sentinel = Object();

Project buildProject({
  int? id = 1,
  String? uuid,
  String title = 'Focus',
  String? description,
  ProjectStatus status = ProjectStatus.active,
  int? color,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final created = createdAt ?? testNow.subtract(const Duration(days: 7));
  return Project(
    id: id,
    uuid: uuid ?? 'project-uuid-${id ?? 0}',
    title: title,
    description: description,
    status: status,
    color: color,
    createdAt: created,
    updatedAt: updatedAt ?? created,
    deletedAt: deletedAt,
  );
}

Tag buildTag({
  int? id = 1,
  String? uuid,
  String name = 'focus',
  int? color,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final created = createdAt ?? testNow.subtract(const Duration(days: 1));
  return Tag(
    id: id,
    uuid: uuid ?? 'tag-uuid-${id ?? 0}',
    name: name,
    color: color,
    createdAt: created,
    updatedAt: updatedAt ?? created,
    deletedAt: deletedAt,
  );
}

Milestone buildMilestone({
  int? id = 1,
  String? uuid,
  int projectId = 1,
  String title = 'MVP',
  DateTime? targetDate,
  DateTime? createdAt,
  DateTime? updatedAt,
  DateTime? deletedAt,
}) {
  final created = createdAt ?? testNow.subtract(const Duration(days: 2));
  return Milestone(
    id: id,
    uuid: uuid ?? 'milestone-uuid-${id ?? 0}',
    projectId: projectId,
    title: title,
    targetDate: targetDate,
    createdAt: created,
    updatedAt: updatedAt ?? created,
    deletedAt: deletedAt,
  );
}

FocusSession buildSession({
  int? id = 1,
  String? uuid,
  int? taskId = 1,
  int focusDurationMinutes = 25,
  int breakDurationMinutes = 5,
  SessionState state = SessionState.running,
  int elapsedSeconds = 0,
  int? focusPhaseEndedAt,
  DateTime? startTime,
  DateTime? endTime,
  DateTime? deletedAt,
}) {
  return FocusSession(
    id: id,
    uuid: uuid ?? 'session-uuid-${id ?? 0}',
    taskId: taskId,
    focusDurationMinutes: focusDurationMinutes,
    breakDurationMinutes: breakDurationMinutes,
    startTime: startTime ?? testNow,
    endTime: endTime,
    state: state,
    elapsedSeconds: elapsedSeconds,
    focusPhaseEndedAt: focusPhaseEndedAt,
    deletedAt: deletedAt,
  );
}

/// Convenience for tests that need a real random UUID.
String testUuid() => generateUuid();
