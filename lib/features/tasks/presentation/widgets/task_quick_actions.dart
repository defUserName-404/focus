import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../focus/presentation/commands/focus_commands.dart';
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
          spacing: AppConstants.spacing.regular,
          runSpacing: AppConstants.spacing.regular,
          children: [
            if (!task.isCompleted)
              fu.FButton(
                onPress: () => FocusCommands.start(context, ref, taskId: task.id!),
                prefix: const Icon(fu.FIcons.play, size: 14),
                child: const Text('Start Focus'),
              ),
            fu.FButton(
              style: fu.FButtonStyle.outline(),
              onPress: () =>
                  TaskCommands.create(context, projectId: projectId, parentTaskId: task.id, depth: task.depth + 1),
              prefix: const Icon(fu.FIcons.plus, size: 14),
              child: const Text('Add Subtask'),
            ),
            fu.FButton(
              style: fu.FButtonStyle.outline(),
              onPress: () => ref.read(taskProvider(projectId.toString()).notifier).toggleTaskCompletion(task),
              prefix: Icon(task.isCompleted ? fu.FIcons.rotateCcw : fu.FIcons.check, size: 14),
              child: Text(task.isCompleted ? 'Reopen' : 'Complete'),
            ),
            fu.FButton(
              style: fu.FButtonStyle.outline(),
              onPress: () => TaskCommands.edit(context, task),
              prefix: const Icon(fu.FIcons.pencil, size: 14),
              child: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }
}
