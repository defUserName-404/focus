import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/master_detail_layout.dart';
import '../providers/selected_task_selection.dart';
import 'all_tasks_screen.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isCompact) {
      return const AllTasksScreen();
    }
    final selected = ref.watch(selectedTaskSelectionProvider);
    return MasterDetailLayout(
      masterWidth: 460,
      master: AllTasksScreen(
        selectedTaskId: selected?.taskId,
        onTaskSelected: (selection) {
          ref.read(selectedTaskSelectionProvider.notifier).select(selection);
        },
      ),
      detail: selected != null ? TaskDetailScreen(taskId: selected.taskId, projectId: selected.projectId) : null,
      emptyDetail: const Center(child: Text('Select a task to view details')),
    );
  }
}
