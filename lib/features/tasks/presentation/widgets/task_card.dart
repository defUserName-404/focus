import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/providers/expansion_provider.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/widgets/action_menu_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/task.dart';
import '../commands/task_commands.dart';
import '../providers/task_provider.dart';
import 'add_subtask_chip.dart';
import 'subtask_row.dart';
import 'subtask_count_chip.dart';
import 'task_date_row.dart';
import 'task_priority_badge.dart';

/// Shared task tile for flat (all-tasks) and hierarchical (project detail) lists.
///
/// Flat mode (`showHierarchy: false`): checkbox, dates, priority, optional
/// selection highlight. Hierarchical mode adds subtask expand/add and edit/delete.
class TaskCard extends ConsumerWidget {
  final Task task;
  final List<Task> subtasks;
  final String projectIdString;
  final VoidCallback? onTaskTap;
  final ValueChanged<Task>? onSubtaskTap;
  final bool showHierarchy;
  final bool isSelected;

  const TaskCard({
    super.key,
    required this.task,
    this.subtasks = const [],
    required this.projectIdString,
    this.onTaskTap,
    this.onSubtaskTap,
    this.showHierarchy = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskId = task.id!.toString();
    final isExpanded = showHierarchy ? ref.watch(expansionProvider.select((map) => map[taskId] ?? true)) : false;
    final isOverdue = task.endDate?.isOverdue ?? false;

    final card = AppCard(
      onTap: onTaskTap ?? () => context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId}),
      isCompleted: task.isCompleted,
      leading: fu.FCheckbox(
        value: task.isCompleted,
        onChange: (_) {
          if (task.isRecurring && task.id != null) {
            ref.read(taskProvider(projectIdString).notifier).completeOccurrence(task, DateTime.now());
          } else {
            ref.read(taskProvider(projectIdString).notifier).toggleTaskCompletion(task);
          }
        },
      ),
      title: Text(task.title),
      trailing: showHierarchy
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TaskPriorityBadge(priority: task.priority),
                SizedBox(width: AppConstants.spacing.extraSmall),
                ActionMenuButton(
                  onEdit: () => TaskCommands.edit(context, task),
                  onDelete: () => TaskCommands.delete(context, ref, task, projectIdString),
                ),
              ],
            )
          : TaskPriorityBadge(priority: task.priority),
      subtitle: (task.description != null && task.description!.isNotEmpty)
          ? Text(
              task.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground, height: 1.4),
            )
          : null,
      content: TaskDateRow(
        startDate: task.startDate,
        deadline: task.endDate,
        isOverdue: isOverdue && !task.isCompleted,
      ),
      footerActions: showHierarchy
          ? [
              AddSubtaskChip(
                onPressed: () => TaskCommands.create(
                  context,
                  projectId: task.projectId,
                  parentTaskId: task.id,
                  depth: task.depth + 1,
                ),
              ),
              SizedBox(width: AppConstants.spacing.regular),
              if (subtasks.isNotEmpty)
                SubtaskCountChip(
                  count: subtasks.length,
                  expanded: isExpanded,
                  onToggle: () => ref.read(expansionProvider.notifier).toggle(task.id!.toString(), defaultValue: true),
                ),
            ]
          : null,
      children: [
        if (showHierarchy && isExpanded && subtasks.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: subtasks
                .map(
                  (st) => SubtaskRow(
                    subtask: st,
                    onToggle: () {
                      if (st.isRecurring && st.id != null) {
                        ref.read(taskProvider(projectIdString).notifier).completeOccurrence(st, DateTime.now());
                      } else {
                        ref.read(taskProvider(projectIdString).notifier).toggleTaskCompletion(st);
                      }
                    },
                    onTap: () {
                      context.push(AppRoutes.taskDetailPath(st.id!), extra: {'projectId': st.projectId});
                      if (onSubtaskTap != null) onSubtaskTap!(st);
                    },
                    onEdit: () => TaskCommands.edit(context, st),
                    onDelete: () => TaskCommands.delete(context, ref, st, projectIdString),
                  ),
                )
                .toList(),
          ),
      ],
    );

    if (!isSelected) return card;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(color: context.colors.primary, width: 1.5),
      ),
      child: card,
    );
  }
}
