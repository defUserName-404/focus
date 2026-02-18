import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/common/providers/expansion_provider.dart';
import '../../../../core/common/utils/datetime_formatter.dart';
import '../../../../core/common/widgets/action_menu_button.dart';
import '../../../../core/common/widgets/app_card.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart'; // Added import
import '../../domain/entities/task.dart';
import '../commands/task_commands.dart';
import '../providers/task_provider.dart';

// Removed unused import: TaskDetailScreen
import 'subtask_row.dart';
import 'task_date_row.dart';
import 'task_priority_badge.dart';

class TaskCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final taskId = task.id!.toString();
    final isExpanded = ref.watch(
      expansionProvider.select((map) => map[taskId] ?? true),
    );
    final isOverdue = task.endDate?.isOverdue ?? false;

    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(
        RouteConstants.taskDetailRoute,
        arguments: {'taskId': task.id!, 'projectId': task.projectId},
      ),
      isCompleted: task.isCompleted,
      leading: fu.FCheckbox(
        value: task.isCompleted,
        onChange: (_) => ref
            .read(taskProvider(projectIdString).notifier)
            .toggleTaskCompletion(task),
      ),
      title: Text(task.title),
      trailing: Row(
        mainAxisSize: .min,
        children: [
          TaskPriorityBadge(priority: task.priority),
          SizedBox(width: AppConstants.spacing.extraSmall),
          ActionMenuButton(
            onEdit: () => TaskCommands.edit(context, task),
            onDelete: () =>
                TaskCommands.delete(context, ref, task, projectIdString),
          ),
        ],
      ),
      subtitle: (task.description != null && task.description!.isNotEmpty)
          ? Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.sm.copyWith(
                color: context.colors.mutedForeground,
                height: 1.4,
              ),
            )
          : null,
      content: TaskDateRow(
        startDate: task.startDate,
        deadline: task.endDate,
        isOverdue: isOverdue && !task.isCompleted,
      ),
      footerActions: [
        _AddSubtaskChip(
          onPressed: () => TaskCommands.create(
            context,
            projectId: task.projectId,
            parentTaskId: task.id,
            depth: task.depth + 1,
          ),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        if (subtasks.isNotEmpty)
          _SubtaskCountChip(
            count: subtasks.length,
            expanded: isExpanded,
            onToggle: () => ref
                .read(expansionProvider.notifier)
                .toggle(task.id!.toString(), defaultValue: true),
          ),
      ],
      children: [
        if (isExpanded && subtasks.isNotEmpty)
          Column(
            mainAxisSize: .min,
            children: subtasks
                .map(
                  (st) => SubtaskRow(
                    subtask: st,
                    onToggle: () => ref
                        .read(taskProvider(projectIdString).notifier)
                        .toggleTaskCompletion(st),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        RouteConstants.taskDetailRoute,
                        arguments: {
                          'taskId': st.id!,
                          'projectId': st.projectId,
                        },
                      );
                      if (onSubtaskTap != null) onSubtaskTap!(st);
                    },
                    onEdit: () => TaskCommands.edit(context, st),
                    onDelete: () =>
                        TaskCommands.delete(context, ref, st, projectIdString),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _AddSubtaskChip extends StatelessWidget {
  final VoidCallback onPressed;

  const _AddSubtaskChip({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return fu.FButton(
      style: fu.FButtonStyle.outline(),
      onPress: onPressed,
      prefix: Icon(fu.FIcons.plus, size: AppConstants.size.icon.small),
      child: Text('subtask', style: context.typography.xs),
    );
  }
}

class _SubtaskCountChip extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  const _SubtaskCountChip({
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return fu.FButton(
      style: fu.FButtonStyle.outline(),
      onPress: onToggle,
      suffix: Icon(
        expanded ? fu.FIcons.chevronDown : fu.FIcons.chevronRight,
        size: AppConstants.size.icon.small,
      ),
      child: Text('$count', style: context.typography.xs),
    );
  }
}
