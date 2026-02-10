import 'package:flutter/material.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';

import 'task_date_row.dart';
import 'task_priority_badge.dart';

class SubtaskRow extends StatelessWidget {
  final Task subtask;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const SubtaskRow({super.key, required this.subtask, required this.onToggle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indent thread line
            SizedBox(
              width: 40,
              child: Center(child: Container(width: 1, color: const Color(0xFF333333))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SubtaskCheckbox(checked: subtask.isCompleted, onToggle: onToggle),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  subtask.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: subtask.isCompleted ? FontWeight.w400 : FontWeight.w500,
                                    color: subtask.isCompleted ? const Color(0xFF666666) : const Color(0xFFD0D0D0),
                                    decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                    decorationColor: const Color(0xFF666666),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TaskPriorityBadge(priority: subtask.priority),
                            ],
                          ),
                          if (subtask.endDate != null || subtask.startDate != null) ...[
                            const SizedBox(height: 4),
                            TaskDateRow(startDate: subtask.startDate, deadline: subtask.endDate),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onTap,
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF555555)),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtaskCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback onToggle;

  const _SubtaskCheckbox({required this.checked, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 18,
        height: 18,
        margin: const EdgeInsets.only(top: 1),
        decoration: BoxDecoration(
          color: checked ? Colors.white : Colors.transparent,
          border: checked ? null : Border.all(color: const Color(0xFF555555), width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: checked ? const Icon(Icons.check, size: 12, color: Color(0xFF111111)) : null,
      ),
    );
  }
}
