import 'package:focus/features/tasks/domain/entities/task_priority.dart';

import 'task.dart';

const _TaskCopyWithUnset _taskCopyWithUnset = _TaskCopyWithUnset();

class _TaskCopyWithUnset {
  const _TaskCopyWithUnset();
}

extension TaskCopyWith on Task {
  Task copyWith({
    BigInt? id,
    BigInt? projectId,
    Object? parentTaskId = _taskCopyWithUnset,
    String? title,
    String? description,
    TaskPriority? priority,
    Object? startDate = _taskCopyWithUnset,
    Object? endDate = _taskCopyWithUnset,
    int? depth,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Task(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    parentTaskId: parentTaskId == _taskCopyWithUnset ? this.parentTaskId : parentTaskId as BigInt?,
    title: title ?? this.title,
    description: description ?? this.description,
    priority: priority ?? this.priority,
    startDate: startDate == _taskCopyWithUnset ? this.startDate : startDate as DateTime?,
    endDate: endDate == _taskCopyWithUnset ? this.endDate : endDate as DateTime?,
    depth: depth ?? this.depth,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
