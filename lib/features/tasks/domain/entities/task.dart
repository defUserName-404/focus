import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'task_priority.dart';

/// Immutable representation of a user task.
///
/// [depth] encodes nesting: 0 = root task, 1 = subtask, 2 = sub-subtask, etc.
@immutable
class Task extends Equatable {
  final int? id;
  final int projectId;
  final int? parentTaskId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final int depth;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    this.id,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    this.description,
    required this.priority,
    this.startDate,
    this.endDate,
    required this.depth,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, projectId, parentTaskId, title, description,
    priority, startDate, endDate, depth, isCompleted,
    createdAt, updatedAt,
  ];
}
