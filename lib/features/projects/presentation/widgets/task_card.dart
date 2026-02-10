import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:focus/features/tasks/presentation/widgets/create_task_modal_content.dart';
import 'package:focus/features/tasks/presentation/widgets/edit_task_modal_content.dart';
import 'package:forui/forui.dart' as fu;

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

  bool get _isOverdue =>
      widget.task.endDate != null && widget.task.endDate!.isBefore(DateTime.now()) && !widget.task.isCompleted;

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final subtasks = widget.subtasks;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: fu.FCard(
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
              onAddSubtaskPressed: () => _openAddSubtaskModal(context),
              onEditPressed: () => _editTask(context, task),
              onDeletePressed: () => _confirmDeleteTask(context, task),
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
                          onEdit: () => _editTask(context, st),
                          onDelete: () => _confirmDeleteTask(context, st),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openAddSubtaskModal(BuildContext context) {
    fu.showFSheet(
      context: context,
      side: fu.FLayout.btt,
      builder: (context) => CreateTaskModalContent(
        projectId: widget.task.projectId,
        parentTaskId: widget.task.id,
        depth: widget.task.depth + 1,
      ),
    );
  }

  void _editTask(BuildContext context, Task task) {
    fu.showFSheet(
      context: context,
      side: fu.FLayout.btt,
      builder: (context) => EditTaskModalContent(task: task),
    );
  }

  void _confirmDeleteTask(BuildContext context, Task task) {
    showAdaptiveDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"? Subtasks will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (task.id != null) {
                ref.read(taskProvider(widget.projectIdString).notifier).deleteTask(task.id!, widget.projectIdString);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onExpandToggle;

  const _TaskMainRow({
    required this.task,
    required this.subtaskCount,
    required this.subtasksExpanded,
    required this.isOverdue,
    required this.onToggle,
    required this.onAddSubtaskPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
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
          fu.FCheckbox(value: task.isCompleted, onChange: (_) => onToggle()),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + priority + actions
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: context.typography.base.copyWith(
                          fontWeight: task.isCompleted ? FontWeight.w400 : FontWeight.w600,
                          color: task.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          decorationColor: context.colors.mutedForeground,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TaskPriorityBadge(priority: task.priority),
                    const SizedBox(width: 4),
                    _ActionPopup(
                      onEdit: onEditPressed,
                      onDelete: onDeletePressed,
                    ),
                  ],
                ),

                // Description
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    task.description!,
                    style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.4),
                  ),
                ],

                const SizedBox(height: 6),

                // Date row (always show start & end dates)
                TaskDateRow(startDate: task.startDate, deadline: task.endDate, isOverdue: isOverdue),

                const SizedBox(height: 6),

                // Action chips row
                Row(
                  children: [
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

// ── Private: action popup (edit/delete) ─────────────────────────────────────

class _ActionPopup extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ActionPopup({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(fu.FIcons.ellipsisVertical, size: 16, color: context.colors.mutedForeground),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
      ],
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
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
      child: Text('subtask', style: context.typography.xs),
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
      suffix: Icon(expanded ? fu.FIcons.chevronDown : fu.FIcons.chevronRight, size: 14),
      child: Text('$count', style: context.typography.xs),
    );
  }
}
