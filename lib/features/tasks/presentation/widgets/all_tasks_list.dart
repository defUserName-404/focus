import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../models/task_selection.dart';
import '../providers/all_tasks_provider.dart';
import 'all_task_card.dart';

class AllTasksList extends ConsumerWidget {
  final int? selectedTaskId;
  final ValueChanged<TaskSelection>? onTaskSelected;

  const AllTasksList({super.key, required this.selectedTaskId, required this.onTaskSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredAllTasksProvider);

    return filteredAsync.when(
      loading: () => const Center(child: fu.FCircularProgress()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (tasks) {
        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppConstants.spacing.regular,
              children: [
                Icon(
                  fu.FIcons.squareCheck,
                  size: AppConstants.size.icon.extraExtraLarge,
                  color: Theme.of(context).disabledColor,
                ),
                Text('No tasks found', style: context.typography.sm.copyWith(color: context.colors.mutedForeground)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return AllTaskCard(
              task: task,
              isSelected: selectedTaskId != null && selectedTaskId == task.id,
              onTap: () {
                if (task.id == null) return;
                if (onTaskSelected != null) {
                  final selection = TaskSelection(taskId: task.id!, projectId: task.projectId);
                  onTaskSelected!(selection);
                  return;
                }
                context.push(AppRoutes.taskDetailPath(task.id!), extra: {'projectId': task.projectId});
              },
            );
          },
        );
      },
    );
  }
}
