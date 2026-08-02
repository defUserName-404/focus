import 'task_completion.dart';

const _TaskCompletionCopyWithUnset _unset = _TaskCompletionCopyWithUnset();

class _TaskCompletionCopyWithUnset {
  const _TaskCompletionCopyWithUnset();
}

extension TaskCompletionCopyWith on TaskCompletion {
  TaskCompletion copyWith({
    int? id,
    String? uuid,
    int? taskId,
    DateTime? occurrenceDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = _unset,
  }) => TaskCompletion(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    taskId: taskId ?? this.taskId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    completedAt: completedAt ?? this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt == _unset ? this.deletedAt : deletedAt as DateTime?,
  );
}
