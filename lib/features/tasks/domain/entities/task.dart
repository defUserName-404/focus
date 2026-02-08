import 'task_priority.dart';

class Task {
  final String id;
  final BigInt projectId;
  final String? parentTaskId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime startDate;
  final DateTime endDate;
  final int depth; // 0 = root, 1 = subtask, 2 = sub-subtask, etc.
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    this.description,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.depth,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });
}
