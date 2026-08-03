import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../commands/task_commands.dart';
import '../providers/task_provider.dart';

/// Quick action buttons for the task detail screen.
class TaskQuickActions extends ConsumerWidget {
  final Task task;
  final int projectId;

  const TaskQuickActions({super.key, required this.task, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        Wrap(
          spacing: AppConstants.spacing.small,
          runSpacing: AppConstants.spacing.small,
          children: [
            fu.FButton(
              size: .sm,
              mainAxisSize: .min,
              variant: .outline,
              onPress: () =>
                  TaskCommands.create(context, projectId: projectId, parentTaskId: task.id, depth: task.depth + 1),
              prefix: const Icon(fu.FLucideIcons.plus, size: 14),
              child: const Text('Add Subtask'),
            ),
            fu.FButton(
              size: .sm,
              mainAxisSize: .min,
              variant: .outline,
              onPress: () {
                if (task.isRecurring && task.id != null) {
                  ref.read(taskProvider(projectId.toString()).notifier).completeOccurrence(task, DateTime.now());
                } else {
                  ref.read(taskProvider(projectId.toString()).notifier).toggleTaskCompletion(task);
                }
              },
              prefix: Icon(task.isCompleted ? fu.FLucideIcons.rotateCcw : fu.FLucideIcons.check, size: 14),
              child: Text(task.isCompleted ? 'Reopen' : 'Complete'),
            ),
            fu.FButton(
              size: .sm,
              mainAxisSize: .min,
              variant: .outline,
              onPress: () => TaskCommands.edit(context, task),
              prefix: const Icon(fu.FLucideIcons.pencil, size: 14),
              child: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }
}
