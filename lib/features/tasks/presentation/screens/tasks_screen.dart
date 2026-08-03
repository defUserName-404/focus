import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/master_detail_layout.dart';
import '../models/task_selection.dart';
import '../providers/selected_task_selection.dart';
import '../providers/tasks_master_pane_width_provider.dart';
import '../providers/tasks_pane_form_provider.dart';
import 'all_tasks_screen.dart';
import 'create_task_screen.dart';
import 'create_task_with_project_screen.dart';
import 'edit_task_screen.dart';
import 'task_detail_screen.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isCompact) {
      return const AllTasksScreen();
    }
    final selected = ref.watch(selectedTaskSelectionProvider);
    final form = ref.watch(tasksPaneFormProvider);
    final masterWidth = ref.watch(tasksMasterPaneWidthProvider).value ?? kDefaultTasksMasterPaneWidth;

    return MasterDetailLayout(
      masterWidth: masterWidth,
      onMasterWidthChanged: (width) => ref.read(tasksMasterPaneWidthProvider.notifier).setWidth(width),
      master: AllTasksScreen(
        selectedTaskId: selected?.taskId,
        onTaskSelected: (selection) {
          ref.read(tasksPaneFormProvider.notifier).clear();
          ref.read(selectedTaskSelectionProvider.notifier).select(selection);
        },
      ),
      detail: _detail(ref, form, selected),
      emptyDetail: const Center(child: Text('Select a task to view details')),
    );
  }

  Widget? _detail(WidgetRef ref, TasksPaneForm? form, TaskSelection? selected) {
    if (form is CreateTaskPaneForm) {
      final projectId = form.projectId;
      if (projectId == null) {
        return CreateTaskWithProjectScreen(
          isEmbedded: true,
          onDismiss: () => ref.read(tasksPaneFormProvider.notifier).clear(),
          onCreated: (task) {
            ref.read(tasksPaneFormProvider.notifier).clear();
            if (task.id != null) {
              ref
                  .read(selectedTaskSelectionProvider.notifier)
                  .select(TaskSelection(taskId: task.id!, projectId: task.projectId));
            }
          },
        );
      }
      return CreateTaskScreen(
        projectId: projectId,
        parentTaskId: form.parentTaskId,
        depth: form.depth,
        isEmbedded: true,
        onDismiss: () => ref.read(tasksPaneFormProvider.notifier).clear(),
        onCreated: (task) {
          ref.read(tasksPaneFormProvider.notifier).clear();
          if (task.id != null) {
            ref
                .read(selectedTaskSelectionProvider.notifier)
                .select(TaskSelection(taskId: task.id!, projectId: task.projectId));
          }
        },
      );
    }
    if (form is EditTaskPaneForm) {
      return EditTaskScreen(
        task: form.task,
        isEmbedded: true,
        onDismiss: () => ref.read(tasksPaneFormProvider.notifier).clear(),
        onSaved: (task) {
          ref.read(tasksPaneFormProvider.notifier).clear();
          if (task.id != null) {
            ref
                .read(selectedTaskSelectionProvider.notifier)
                .select(TaskSelection(taskId: task.id!, projectId: task.projectId));
          }
        },
      );
    }
    if (selected != null) {
      return TaskDetailScreen(
        taskId: selected.taskId,
        projectId: selected.projectId,
        isEmbedded: true,
        onClose: () => ref.read(selectedTaskSelectionProvider.notifier).clear(),
      );
    }
    return null;
  }
}
