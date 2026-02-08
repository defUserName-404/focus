import 'package:focus/features/tasks/domain/entities/task_priority.dart';

import 'task.dart';

const _TaskCopyWithUnset _taskCopyWithUnset = _TaskCopyWithUnset();

class _TaskCopyWithUnset {
  const _TaskCopyWithUnset();
}

extension TaskCopyWith on Task {
  Task copyWith({
    String? id,
    BigInt? projectId,
    Object? parentTaskId = _taskCopyWithUnset,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    int? depth,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    parentTaskId: parentTaskId == _taskCopyWithUnset ? this.parentTaskId : parentTaskId as String?,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    depth: depth ?? this.depth,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
