import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/common/widgets/confirmation_dialog.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';
import 'package:focus/features/tasks/presentation/widgets/create_task_modal_content.dart';
import 'package:focus/features/tasks/presentation/widgets/edit_task_modal_content.dart';
import 'package:forui/forui.dart' as fu;

class TaskCommands {
  static Future<void> create(
    BuildContext context,
    WidgetRef ref, {
    required BigInt projectId,
    BigInt? parentTaskId,
    int depth = 0,
  }) async {
    await fu.showFSheet(
      context: context,
      side: fu.FLayout.btt,
      builder: (context) => CreateTaskModalContent(
        projectId: projectId,
        parentTaskId: parentTaskId,
        depth: depth,
      ),
    );
  }

  static Future<void> edit(BuildContext context, Task task) async {
    await fu.showFSheet(
      context: context,
      side: fu.FLayout.btt,
      builder: (context) => EditTaskModalContent(task: task),
    );
  }

  static Future<void> delete(
    BuildContext context,
    WidgetRef ref,
    Task task,
    String projectIdString, {
    VoidCallback? onDeleted,
  }) async {
    if (task.id == null) return;

    await ConfirmationDialog.show(
      context,
      title: 'Delete Task',
      body: 'Are you sure you want to delete "${task.title}"? Subtasks will also be deleted.',
      onConfirm: () {
        ref.read(taskProvider(projectIdString).notifier).deleteTask(task.id!, projectIdString);
        onDeleted?.call();
      },
    );
  }
}
