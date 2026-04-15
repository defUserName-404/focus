import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import 'task_priority_badge.dart';

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
