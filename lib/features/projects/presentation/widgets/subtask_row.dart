import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:forui/forui.dart' as fu;

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
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indent thread line
            SizedBox(
              width: 40,
              child: Center(child: Container(width: 1, color: context.colors.border)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fu.FCheckbox(value: subtask.isCompleted, onChange: (_) => onToggle()),
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
                                  style: context.typography.sm.copyWith(
                                    fontWeight: subtask.isCompleted ? FontWeight.w400 : FontWeight.w500,
                                    color: subtask.isCompleted
                                        ? context.colors.mutedForeground
                                        : context.colors.foreground,
                                    decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                                    decorationColor: context.colors.mutedForeground,
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
                      child: Icon(fu.FIcons.chevronRight, size: 14, color: context.colors.mutedForeground),
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
