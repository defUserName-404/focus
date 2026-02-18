import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../commands/task_commands.dart';
import '../providers/task_provider.dart';
import 'task_priority_badge.dart';

/// Displays a progress bar and list of subtasks for a parent task.
class SubtasksSection extends ConsumerWidget {
  final List<Task> subtasks;
  final Task parentTask;
  final String projectIdString;

  const SubtasksSection({super.key, required this.subtasks, required this.parentTask, required this.projectIdString});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = subtasks.where((t) => t.isCompleted).length;
    final total = subtasks.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppConstants.spacing.regular,
      children: [
        //  Header
        Row(
          children: [
            Text(
              'Subtasks',
              style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
            ),
            SizedBox(width: AppConstants.spacing.regular),
            Text('$completed / $total', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
            const Spacer(),
            fu.FButton(
              style: fu.FButtonStyle.outline(),
              onPress: () => TaskCommands.create(
                context,
                projectId: parentTask.projectId,
                parentTaskId: parentTask.id,
                depth: parentTask.depth + 1,
              ),
              prefix: Icon(fu.FIcons.plus, size: AppConstants.size.icon.extraSmall),
              child: Text('Add', style: context.typography.xs),
            ),
          ],
        ),

        //  Progress bar
        fu.FDeterminateProgress(value: progress),

        //  Subtask list
        ...subtasks.map((subtask) => SubtaskTile(subtask: subtask, projectIdString: projectIdString)),
      ],
    );
  }
}

/// A single subtask tile with checkbox, title, and priority badge.
class SubtaskTile extends ConsumerWidget {
  final Task subtask;
  final String projectIdString;

  const SubtaskTile({super.key, required this.subtask, required this.projectIdString});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return fu.FCard(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.regular),
        child: Row(
          children: [
            fu.FCheckbox(
              value: subtask.isCompleted,
              onChange: (_) => ref.read(taskProvider(projectIdString).notifier).toggleTaskCompletion(subtask),
            ),
            SizedBox(width: AppConstants.spacing.regular),
            Expanded(
              child: Text(
                subtask.title,
                style: context.typography.sm.copyWith(
                  color: subtask.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                  decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            TaskPriorityBadge(priority: subtask.priority),
          ],
        ),
      ),
    );
  }
}
