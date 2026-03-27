import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:focus/core/widgets/confirmation_dialog.dart';
import 'package:focus/core/routing/routes.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/presentation/providers/task_provider.dart';

class TaskCommands {
  static void create(BuildContext context, {required int projectId, int? parentTaskId, int depth = 0}) {
    var path = AppRoutes.createTaskPath(projectId);
    final queryParams = <String, String>{};
    if (parentTaskId != null) queryParams['parentTaskId'] = parentTaskId.toString();
    if (depth > 0) queryParams['depth'] = depth.toString();

    if (queryParams.isNotEmpty) {
      path = Uri.parse(path).replace(queryParameters: queryParams).toString();
    }

    context.push(path);
  }

  static void edit(BuildContext context, Task task) {
    if (task.id == null) return;
    context.push(AppRoutes.editTaskPath(task.id!), extra: task);
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
