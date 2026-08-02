import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../models/task_selection.dart';
import '../providers/all_tasks_provider.dart';
import 'task_card.dart';

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
          return const AppEmptyState(icon: fu.FLucideIcons.squareCheck, message: 'No tasks found');
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.regular),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              projectIdString: task.projectId.toString(),
              showHierarchy: false,
              isSelected: selectedTaskId != null && selectedTaskId == task.id,
              onTaskTap: () {
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
