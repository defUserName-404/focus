import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:forui/forui.dart' as fu;

import 'inline_add_subtask.dart';
import 'subtask_row.dart';
import 'task_date_row.dart';
import 'task_priority_badge.dart';

class TaskCard extends ConsumerStatefulWidget {
  final Task task;
  final List<Task> subtasks;
  final String projectIdString;
  final VoidCallback? onTaskTap;
  final ValueChanged<Task>? onSubtaskTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.subtasks,
    required this.projectIdString,
    this.onTaskTap,
    this.onSubtaskTap,
  });

  @override
  ConsumerState<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends ConsumerState<TaskCard> {
  bool _subtasksExpanded = true;
  bool _addingSubtask = false;

  bool get _isOverdue =>
      widget.task.endDate != null && widget.task.endDate!.isBefore(DateTime.now()) && !widget.task.isCompleted;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final subtasks = widget.subtasks;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: fu.FCard(
        child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Main task row ──
            _TaskMainRow(
              task: task,
              subtaskCount: subtasks.length,
              subtasksExpanded: _subtasksExpanded,
              isOverdue: _isOverdue,
              onToggle: () => ref.read(taskProvider(widget.projectIdString).notifier).toggleTaskCompletion(task),
              onTap: widget.onTaskTap,
              onAddSubtaskPressed: () => setState(() => _addingSubtask = true),
              onExpandToggle: subtasks.isNotEmpty ? () => setState(() => _subtasksExpanded = !_subtasksExpanded) : null,
            ),

            // ── Subtasks ──
            if (_subtasksExpanded && subtasks.isNotEmpty)
              ColoredBox(
                color: const Color(0xFF0D0D0D),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: subtasks
                      .map(
                        (st) => SubtaskRow(
                          subtask: st,
                          onToggle: () =>
                              ref.read(taskProvider(widget.projectIdString).notifier).toggleTaskCompletion(st),
                          onTap: widget.onSubtaskTap != null ? () => widget.onSubtaskTap!(st) : null,
                        ),
                      )
                      .toList(),
                ),
              ),

            // ── Inline add subtask ──
            if (_addingSubtask)
              ColoredBox(
                color: const Color(0xFF0D0D0D),
                child: InlineAddSubtask(
                  onCancel: () => setState(() => _addingSubtask = false),
                  onSubmit: (title) {
                    ref
                        .read(taskProvider(widget.projectIdString).notifier)
                        .createTask(
                          projectId: widget.projectIdString,
                          parentTaskId: widget.task.id,
                          title: title,
                          depth: widget.task.depth + 1,
                        );
                    setState(() {
                      _addingSubtask = false;
                      _subtasksExpanded = true;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}

// ── Private: main task row ───────────────────────────────────────────────────

class _TaskMainRow extends StatelessWidget {
  final Task task;
  final int subtaskCount;
  final bool subtasksExpanded;
  final bool isOverdue;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final VoidCallback onAddSubtaskPressed;
  final VoidCallback? onExpandToggle;

  const _TaskMainRow({
    required this.task,
    required this.subtaskCount,
    required this.subtasksExpanded,
    required this.isOverdue,
    required this.onToggle,
    required this.onAddSubtaskPressed,
    this.onTap,
    this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          fu.FCheckbox(
            value: task.isCompleted,
            onChange: (_) => onToggle(),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + priority + arrow
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: context.typography.base.copyWith(
                          fontWeight: task.isCompleted ? FontWeight.w400 : FontWeight.w600,
                          color: task.isCompleted
                              ? context.colors.mutedForeground
                              : context.colors.foreground,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: context.colors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TaskPriorityBadge(priority: task.priority),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: onTap,
                      child: Icon(fu.FIcons.chevronRight, size: 14, color: context.colors.mutedForeground),
                    ),
                  ],
                ),

                // Description
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    task.description!,
                    style: context.typography.sm.copyWith(
                      color: context.colors.mutedForeground,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                // Date row + action chips
                Row(
                  children: [
                    TaskDateRow(startDate: task.startDate, deadline: task.endDate, isOverdue: isOverdue),
                    const Spacer(),
                    _AddSubtaskChip(onPressed: onAddSubtaskPressed),
                    if (subtaskCount > 0) ...[
                      const SizedBox(width: 4),
                      _SubtaskCountChip(count: subtaskCount, expanded: subtasksExpanded, onToggle: onExpandToggle!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private: "+ subtask" chip ────────────────────────────────────────────────

class _AddSubtaskChip extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddSubtaskChip({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return fu.FButton(
      style: fu.FButtonStyle.outline(),
      onPress: onPressed,
      prefix: const Icon(fu.FIcons.plus, size: 13),
      child: Text(
        'subtask',
        style: context.typography.xs,
      ),
    );
  }
}

// ── Private: subtask count + expand chip ────────────────────────────────────

class _SubtaskCountChip extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  const _SubtaskCountChip({required this.count, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return fu.FButton(
      style: fu.FButtonStyle.outline(),
      onPress: onToggle,
      suffix: Icon(
        expanded ? fu.FIcons.chevronDown : fu.FIcons.chevronRight,
        size: 14,
      ),
      child: Text(
        '$count',
        style: context.typography.xs,
      ),
    );
  }
}
