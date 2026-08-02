import 'package:drift/drift.dart' show Value;
import 'package:focus/core/services/db_service.dart';

import '../../domain/entities/task_completion.dart';
import 'task_extensions.dart';

extension DbTaskCompletionToDomain on TaskCompletionTableData {
  TaskCompletion toDomain() => TaskCompletion(
    id: id,
    uuid: uuid,
    taskId: taskId,
    occurrenceDate: parseOccurrenceDateKey(occurrenceDate),
    completedAt: completedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}

extension DomainTaskCompletionToCompanion on TaskCompletion {
  TaskCompletionTableCompanion toCompanion() {
    final dateKey = occurrenceDateKey(occurrenceDate);
    if (id != null) {
      return TaskCompletionTableCompanion(
        id: Value(id!),
        uuid: Value(uuid),
        taskId: Value(taskId),
        occurrenceDate: Value(dateKey),
        completedAt: Value(completedAt),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
      );
    }
    return TaskCompletionTableCompanion.insert(
      uuid: uuid,
      taskId: taskId,
      occurrenceDate: dateKey,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: Value(deletedAt),
    );
  }
}
