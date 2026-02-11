import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/widgets/action_menu_button.dart';
import '../../../../core/common/widgets/app_card.dart';
import '../../../tasks/presentation/commands/task_commands.dart';
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

    return AppCard(
      onTap: widget.onTaskTap,
      isCompleted: task.isCompleted,
      leading: fu.FCheckbox(
        value: task.isCompleted,
        onChange: (_) => ref.read(taskProvider(widget.projectIdString).notifier).toggleTaskCompletion(task),
      ),
      title: Text(task.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TaskPriorityBadge(priority: task.priority),
          const SizedBox(width: 2),
          ActionMenuButton(
            onEdit: () => TaskCommands.edit(context, task),
            onDelete: () => TaskCommands.delete(context, ref, task, widget.projectIdString),
          ),
        ],
      ),
      subtitle: (task.description != null && task.description!.isNotEmpty)
          ? Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.4),
            )
          : null,
      content: TaskDateRow(startDate: task.startDate, deadline: task.endDate, isOverdue: _isOverdue),
      footerActions: [
        _AddSubtaskChip(
          onPressed: () => TaskCommands.create(
            context,
            ref,
            projectId: widget.task.projectId,
            parentTaskId: widget.task.id,
            depth: widget.task.depth + 1,
          ),
        ),
        const SizedBox(width: 8),
        if (subtasks.isNotEmpty)
          _SubtaskCountChip(
            count: subtasks.length,
            expanded: _subtasksExpanded,
            onToggle: () => setState(() => _subtasksExpanded = !_subtasksExpanded),
          ),
      ],
      children: [
        if (_subtasksExpanded && subtasks.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: subtasks
                .map(
                  (st) => SubtaskRow(
                    subtask: st,
                    onToggle: () => ref.read(taskProvider(widget.projectIdString).notifier).toggleTaskCompletion(st),
                    onTap: widget.onSubtaskTap != null ? () => widget.onSubtaskTap!(st) : null,
                    onEdit: () => TaskCommands.edit(context, st),
                    onDelete: () => TaskCommands.delete(context, ref, st, widget.projectIdString),
                  ),
                )
                .toList(),
          ),
      ],
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
      prefix: Icon(fu.FIcons.plus, size: 14),
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
