import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:focus/core/widgets/confirmation_dialog.dart';
import 'package:focus/core/di/injection.dart';
import 'package:focus/core/routing/routes.dart';
import 'package:focus/core/utils/result.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/domain/entities/today_agenda_item.dart';
import 'package:focus/features/tasks/domain/services/task_service.dart';
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

  /// Completes a one-shot task or logs a habit/recurring occurrence.
  ///
  /// Uses [TaskService] directly so home (and other global surfaces) do not
  /// depend on a project-scoped [TaskNotifier] being mounted.
  static Future<Result<void>> completeAgendaItem(TodayAgendaItem item) async {
    final service = getIt<TaskService>();
    final task = item.task;
    if (task.id == null) {
      return const Failure(NotFoundFailure('Task has no id'));
    }

    if (item.kind == TodayAgendaKind.habitOccurrence || task.isRecurring) {
      final result = await service.completeOccurrence(task.id!, item.occurrenceDate);
      return switch (result) {
        Success() => const Success(null),
        Failure(:final failure) => Failure(failure),
      };
    }

    if (item.isCompleted) return const Success(null);
    return service.toggleTaskCompletion(task);
  }

  /// Logs today's completion for a habit from the habits strip.
  static Future<Result<void>> completeHabitOccurrence(Task task, DateTime occurrenceDate) async {
    if (task.id == null) {
      return const Failure(NotFoundFailure('Task has no id'));
    }
    final result = await getIt<TaskService>().completeOccurrence(task.id!, occurrenceDate);
    return switch (result) {
      Success() => const Success(null),
      Failure(:final failure) => Failure(failure),
    };
  }
}
