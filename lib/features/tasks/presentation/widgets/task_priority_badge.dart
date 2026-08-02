import 'package:flutter/material.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:forui/forui.dart' as fu;

class TaskPriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const TaskPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return fu.FBadge(
      variant: switch (priority) {
        TaskPriority.critical => .destructive,
        TaskPriority.high => .primary,
        TaskPriority.medium => .secondary,
        TaskPriority.low => .outline,
      },
      child: Text(priority.label),
    );
  }
}
