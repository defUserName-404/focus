import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'recurrence_rule.dart';
import 'task_priority.dart';
import 'task_reminder_mode.dart';
import 'task_status.dart';

/// Immutable representation of a user task.
///
/// [depth] encodes nesting: 0 = root task, 1 = subtask, 2 = sub-subtask, etc.
/// [isCompleted] is derived from [status] == [TaskStatus.done].
///
/// Recurring tasks keep a single row; occurrences are expanded via
/// [RecurrenceExpander] and completions are logged separately.
@immutable
class Task extends Equatable {
  final int? id;
  final String uuid;
  final int projectId;
  final int? parentTaskId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskReminderMode reminderMode;
  final int? customReminderMinutesBefore;
  final DateTime? startDate;
  final DateTime? endDate;
  final int depth;
  final int? estimatedMinutes;
  final double sortOrder;
  final int? milestoneId;
  final RecurrenceRule? recurrenceRule;
  final DateTime? recurrenceAnchorDate;
  final bool isHabit;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Task({
    this.id,
    required this.uuid,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    this.description,
    required this.priority,
    this.status = TaskStatus.todo,
    this.reminderMode = TaskReminderMode.smart,
    this.customReminderMinutesBefore,
    this.startDate,
    this.endDate,
    required this.depth,
    this.estimatedMinutes,
    this.sortOrder = 0,
    this.milestoneId,
    this.recurrenceRule,
    this.recurrenceAnchorDate,
    this.isHabit = false,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// Compatibility getter — true when [status] is [TaskStatus.done].
  bool get isCompleted => status == TaskStatus.done;

  /// Whether this task expands into multiple occurrences.
  bool get isRecurring => recurrenceRule != null;

  @override
  List<Object?> get props => [
    id,
    uuid,
    projectId,
    parentTaskId,
    title,
    description,
    priority,
    status,
    reminderMode,
    customReminderMinutesBefore,
    startDate,
    endDate,
    depth,
    estimatedMinutes,
    sortOrder,
    milestoneId,
    recurrenceRule,
    recurrenceAnchorDate,
    isHabit,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}
