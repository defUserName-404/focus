import 'task_priority.dart';

class Task {
  final BigInt? id;
  final BigInt projectId;
  final BigInt? parentTaskId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? startDate;
  final DateTime? endDate;
  final int depth; // 0 = root, 1 = subtask, 2 = sub-subtask, etc.
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
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
}
