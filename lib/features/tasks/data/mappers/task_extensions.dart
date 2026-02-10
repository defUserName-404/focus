import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/task.dart';

extension DbTaskToDomain on TaskTableData {
  Task toDomain() => Task(
    id: id,
    projectId: projectId,
    parentTaskId: parentTaskId,
    title: title,
    description: description,
    priority: priority,
    startDate: startDate,
    endDate: endDate,
    depth: depth,
    isCompleted: isCompleted,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension DomainTaskToCompanion on Task {
  /// Returns an insert companion (no id) for new rows,
  /// or a full companion (with id) for updates.
  TaskTableCompanion toCompanion() {
    if (id != null) {
      return TaskTableCompanion(
        id: Value(id!),
        projectId: Value(projectId),
        parentTaskId: Value(parentTaskId),
        title: Value(title),
        description: Value(description),
        priority: Value(priority),
        startDate: Value(startDate),
        endDate: Value(endDate),
        depth: Value(depth),
        isCompleted: Value(isCompleted),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      );
    }
    return TaskTableCompanion.insert(
      projectId: projectId,
      parentTaskId: Value(parentTaskId),
      title: title,
      description: Value(description),
      priority: priority,
      startDate: Value(startDate),
      endDate: Value(endDate),
      depth: depth,
      isCompleted: Value(isCompleted),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
