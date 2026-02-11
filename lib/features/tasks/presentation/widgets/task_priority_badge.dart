import 'package:flutter/material.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:forui/forui.dart' as fu;

class TaskPriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const TaskPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final fu.FBadgeStyle Function() style;
    // switch (priority) {
    //   case TaskPriority.critical:
    //     style = fu.FBadgeStyle.destructive as fu.FBadgeStyle Function();
    //   case TaskPriority.high:
    //     style = fu.FBadgeStyle.primary as fu.FBadgeStyle Function();
    //   case TaskPriority.medium:
    //     style = fu.FBadgeStyle.secondary as fu.FBadgeStyle Function();
    //   case TaskPriority.low:
    //     style = fu.FBadgeStyle.outline as fu.FBadgeStyle Function();
    // }

    return fu.FBadge(child: Text(priority.label));
  }
}
