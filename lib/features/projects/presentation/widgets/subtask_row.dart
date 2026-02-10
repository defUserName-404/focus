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
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubtaskRow({super.key, required this.subtask, required this.onToggle, this.onTap, this.onEdit, this.onDelete});

  bool get _isOverdue =>
      subtask.endDate != null && subtask.endDate!.isBefore(DateTime.now()) && !subtask.isCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pipe indicator
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '|',
                style: context.typography.sm.copyWith(
                  color: context.colors.border,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row: checkbox + title + priority + menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    fu.FCheckbox(value: subtask.isCompleted, onChange: (_) => onToggle()),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        subtask.title,
                        style: context.typography.sm.copyWith(
                          fontWeight: subtask.isCompleted ? FontWeight.w400 : FontWeight.w500,
                          color: subtask.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: context.colors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TaskPriorityBadge(priority: subtask.priority),
                    const SizedBox(width: 2),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(fu.FIcons.ellipsisVertical, size: 14, color: context.colors.mutedForeground),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        itemBuilder: (_) => [
                          if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          if (onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') onEdit?.call();
                          if (value == 'delete') onDelete?.call();
                        },
                      ),
                  ],
                ),

                // Description (max 2 lines)
                if (subtask.description != null && subtask.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text(
                      subtask.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground, height: 1.3),
                    ),
                  ),
                ],

                // Date row with overdue / approaching
                if (subtask.endDate != null || subtask.startDate != null) ...[
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: TaskDateRow(startDate: subtask.startDate, deadline: subtask.endDate, isOverdue: _isOverdue),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
