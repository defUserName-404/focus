import 'package:flutter/material.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';

class TaskPriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const TaskPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: priority == TaskPriority.medium ? const Color(0xFFB71C1C) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        priority.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: priority == TaskPriority.medium ? Colors.white : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
