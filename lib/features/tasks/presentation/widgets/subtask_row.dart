import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/action_menu_button.dart';
import 'task_date_row.dart';
import 'task_priority_badge.dart';

class SubtaskRow extends StatelessWidget {
  final Task subtask;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubtaskRow({
    super.key,
    required this.subtask,
    required this.onToggle,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  bool get _isOverdue =>
      subtask.endDate != null &&
      subtask.endDate!.isBefore(DateTime.now()) &&
      !subtask.isCompleted;

  @override
  Widget build(BuildContext context) {
    const double leadingWidth = 32.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // vertical line indicator
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Container(
                width: 1.5,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),

            // Content
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Row: Checkbox + Title + Priority + Menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: leadingWidth,
                          child: fu.FCheckbox(
                            value: subtask.isCompleted,
                            onChange: (_) => onToggle(),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            subtask.title,
                            style: context.typography.sm.copyWith(
                              fontWeight: subtask.isCompleted
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                              color: subtask.isCompleted
                                  ? context.colors.mutedForeground
                                  : context.colors.foreground,
                              decoration: subtask.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: context.colors.mutedForeground,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        TaskPriorityBadge(priority: subtask.priority),
                        const SizedBox(width: 2),
                        if (onEdit != null || onDelete != null)
                          ActionMenuButton(onEdit: onEdit, onDelete: onDelete),
                      ],
                    ),
                    // ... rest of the content (indented below Title)
                    Padding(
                      padding: const EdgeInsets.only(left: leadingWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Description (max 2 lines)
                          if (subtask.description != null &&
                              subtask.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtask.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.typography.xs.copyWith(
                                color: context.colors.mutedForeground,
                                height: 1.3,
                              ),
                            ),
                          ],

                          // Date row
                          if (subtask.endDate != null ||
                              subtask.startDate != null) ...[
                            const SizedBox(height: 4),
                            TaskDateRow(
                              startDate: subtask.startDate,
                              deadline: subtask.endDate,
                              isOverdue: _isOverdue,
                            ),
                          ],
                        ],
                      ),
                    ),
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
