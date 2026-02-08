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
  TaskTableCompanion toCompanion() => TaskTableCompanion.insert(
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
