import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/domain/entities/task_reminder_mode.dart';
import 'package:focus/features/tasks/domain/entities/task_status.dart';

import 'recurrence_rule.dart';
import 'task.dart';

/// Sentinel object used in [TaskCopyWith.copyWith] to distinguish
/// "parameter not provided" from "explicitly set to null".
///
/// See [FocusSessionCopyWith] for the same pattern and rationale.
const _TaskCopyWithUnset _taskCopyWithUnset = _TaskCopyWithUnset();

class _TaskCopyWithUnset {
  const _TaskCopyWithUnset();
}

extension TaskCopyWith on Task {
  Task copyWith({
    int? id,
    String? uuid,
    int? projectId,
    Object? parentTaskId = _taskCopyWithUnset,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    TaskReminderMode? reminderMode,
    Object? customReminderMinutesBefore = _taskCopyWithUnset,
    Object? startDate = _taskCopyWithUnset,
    Object? endDate = _taskCopyWithUnset,
    int? depth,
    Object? estimatedMinutes = _taskCopyWithUnset,
    double? sortOrder,
    Object? milestoneId = _taskCopyWithUnset,
    Object? recurrenceRule = _taskCopyWithUnset,
    Object? recurrenceAnchorDate = _taskCopyWithUnset,
    bool? isHabit,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _taskCopyWithUnset,
  }) => Task(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    projectId: projectId ?? this.projectId,
    parentTaskId: parentTaskId == _taskCopyWithUnset ? this.parentTaskId : parentTaskId as int?,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    reminderMode: reminderMode ?? this.reminderMode,
    customReminderMinutesBefore: customReminderMinutesBefore == _taskCopyWithUnset
        ? this.customReminderMinutesBefore
        : customReminderMinutesBefore as int?,
    startDate: startDate == _taskCopyWithUnset ? this.startDate : startDate as DateTime?,
    endDate: endDate == _taskCopyWithUnset ? this.endDate : endDate as DateTime?,
    depth: depth ?? this.depth,
    estimatedMinutes: estimatedMinutes == _taskCopyWithUnset ? this.estimatedMinutes : estimatedMinutes as int?,
    sortOrder: sortOrder ?? this.sortOrder,
    milestoneId: milestoneId == _taskCopyWithUnset ? this.milestoneId : milestoneId as int?,
    recurrenceRule: recurrenceRule == _taskCopyWithUnset ? this.recurrenceRule : recurrenceRule as RecurrenceRule?,
    recurrenceAnchorDate: recurrenceAnchorDate == _taskCopyWithUnset
        ? this.recurrenceAnchorDate
        : recurrenceAnchorDate as DateTime?,
    isHabit: isHabit ?? this.isHabit,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt == _taskCopyWithUnset ? this.deletedAt : deletedAt as DateTime?,
  );
}
