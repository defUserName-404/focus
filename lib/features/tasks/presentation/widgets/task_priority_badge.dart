import 'package:flutter/material.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:forui/forui.dart' as fu;

class TaskPriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const TaskPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return fu.FBadge(
      style: switch (priority) {
        TaskPriority.critical => fu.FBadgeStyle.destructive(),
        TaskPriority.high => fu.FBadgeStyle.primary(),
        TaskPriority.medium => fu.FBadgeStyle.secondary(),
        TaskPriority.low => fu.FBadgeStyle.outline(),
      },
      child: Text(priority.label),
    );
  }
}
