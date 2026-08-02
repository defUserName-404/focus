import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';
import 'package:focus/features/tasks/domain/entities/task_status.dart';

import '../../domain/entities/task.dart';

extension DbTaskToDomain on TaskTableData {
  Task toDomain() => Task(
    id: id,
    uuid: uuid,
    projectId: projectId,
    parentTaskId: parentTaskId,
    title: title,
    description: description,
    priority: priority,
    status: status,
    reminderMode: reminderMode,
    customReminderMinutesBefore: customReminderMinutesBefore,
    startDate: startDate,
    endDate: endDate,
    depth: depth,
    estimatedMinutes: estimatedMinutes,
    sortOrder: sortOrder,
    milestoneId: milestoneId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

extension DomainTaskToCompanion on Task {
  /// Returns an insert companion (no id) for new rows,
  /// or a full companion (with id) for updates.
  ///
  /// Writes both [status] and legacy [isCompleted] so they stay in sync
  /// during the v7 compatibility window.
  TaskTableCompanion toCompanion() {
    final completed = status == TaskStatus.done;
    if (id != null) {
      return TaskTableCompanion(
        id: Value(id!),
        uuid: Value(uuid),
        projectId: Value(projectId),
        parentTaskId: Value(parentTaskId),
        title: Value(title),
        description: Value(description),
        priority: Value(priority),
        status: Value(status),
        reminderMode: Value(reminderMode),
        customReminderMinutesBefore: Value(customReminderMinutesBefore),
        startDate: Value(startDate),
        endDate: Value(endDate),
        depth: Value(depth),
        estimatedMinutes: Value(estimatedMinutes),
        sortOrder: Value(sortOrder),
        milestoneId: Value(milestoneId),
        isCompleted: Value(completed),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
      );
    }
    return TaskTableCompanion.insert(
      uuid: uuid,
      projectId: projectId,
      parentTaskId: Value(parentTaskId),
      title: title,
      description: Value(description),
      priority: priority,
      status: Value(status),
      reminderMode: Value(reminderMode),
      customReminderMinutesBefore: Value(customReminderMinutesBefore),
      startDate: Value(startDate),
      endDate: Value(endDate),
      depth: depth,
      estimatedMinutes: Value(estimatedMinutes),
      sortOrder: Value(sortOrder),
      milestoneId: Value(milestoneId),
      isCompleted: Value(completed),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: Value(deletedAt),
    );
  }
}
