import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/common/widgets/confirmation_dialog.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';

import '../../../../core/constants/route_constants.dart';

class TaskCommands {
  static void create(
    BuildContext context, {
    required BigInt projectId,
    BigInt? parentTaskId,
    int depth = 0,
  }) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      RouteConstants.createTaskRoute,
      arguments: {
        'projectId': projectId,
        'parentTaskId': parentTaskId,
        'depth': depth,
      },
    );
  }

  static void edit(BuildContext context, Task task) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      RouteConstants.editTaskRoute,
      arguments: task,
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
