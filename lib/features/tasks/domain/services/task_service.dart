import '../../../../core/services/log_service.dart';
import '../../../../core/utils/id_utils.dart';
import '../../../../core/utils/result.dart';
import '../entities/recurrence_rule.dart';
import '../entities/task.dart';
import '../entities/task_completion.dart';
import '../entities/task_extensions.dart';
import '../entities/task_priority.dart';
import '../entities/task_reminder_mode.dart';
import '../entities/task_status.dart';
import '../repositories/i_task_repository.dart';
import 'task_notification_service.dart';

final _log = LogService.instance;

/// Domain service for task operations.
///
/// Sits between the presentation layer (providers/commands) and the
/// repository. Encapsulates business logic such as timestamping,
/// completion toggling, occurrence logging, and depth management.
class TaskService {
  final ITaskRepository _repository;
  final TaskNotificationService _taskNotificationService;

  TaskService(this._repository, this._taskNotificationService);

  //  Read

  Future<List<Task>> getTasksByProjectId(int projectId) => _repository.getTasksByProjectId(projectId);

  Future<Task?> getTaskById(int id) => _repository.getTaskById(id);

  Stream<List<Task>> watchTasksByProjectId(int projectId) => _repository.watchTasksByProjectId(projectId);

  Future<List<TaskCompletion>> getCompletionsForTask(int taskId) => _repository.getCompletionsForTask(taskId);

  Stream<List<TaskCompletion>> watchCompletionsForTask(int taskId) =>
      _repository.watchCompletionsForTask(taskId);

  //  Write

  Future<Result<Task>> createTask({
    required int projectId,
    int? parentTaskId,
    required String title,
    String? description,
    TaskPriority priority = TaskPriority.medium,
    TaskStatus status = TaskStatus.todo,
    TaskReminderMode reminderMode = TaskReminderMode.smart,
    int? customReminderMinutesBefore,
    DateTime? startDate,
    DateTime? endDate,
    int? estimatedMinutes,
    double sortOrder = 0,
    int? milestoneId,
    RecurrenceRule? recurrenceRule,
    DateTime? recurrenceAnchorDate,
    bool isHabit = false,
    required int depth,
  }) async {
    try {
      final now = DateTime.now();
      final task = Task(
        uuid: generateUuid(),
        projectId: projectId,
        parentTaskId: parentTaskId,
        title: title,
        description: description,
        priority: priority,
        status: status,
        reminderMode: reminderMode,
        customReminderMinutesBefore: customReminderMinutesBefore,
        startDate: startDate,
        endDate: endDate,
        estimatedMinutes: estimatedMinutes,
        sortOrder: sortOrder,
        milestoneId: milestoneId,
        recurrenceRule: recurrenceRule,
        recurrenceAnchorDate: recurrenceAnchorDate ?? (recurrenceRule != null ? (startDate ?? now) : null),
        isHabit: isHabit,
        depth: depth,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _repository.createTask(task);
      await _taskNotificationService.scheduleTaskReminder(created);
      _log.info('Task created: "$title" (id=${created.id})', tag: 'TaskService');
      return Success(created);
    } catch (e, st) {
      _log.error('Failed to create task "$title"', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to create task', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> updateTask(Task task) async {
    try {
      if (task.id != null) {
        await _taskNotificationService.cancelTaskReminder(task.id!);
      }
      final updated = task.copyWith(updatedAt: DateTime.now());
      await _repository.updateTask(updated);
      await _taskNotificationService.scheduleTaskReminder(updated);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to update task ${task.id}', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to update task', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> deleteTask(int id) async {
    try {
      await _taskNotificationService.cancelTaskReminder(id);
      await _repository.deleteTask(id);
      _log.info('Task $id soft-deleted', tag: 'TaskService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to delete task $id', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to delete task', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> toggleTaskCompletion(Task task) async {
    try {
      final nextStatus = task.isCompleted ? TaskStatus.todo : TaskStatus.done;
      final updated = task.copyWith(status: nextStatus, updatedAt: DateTime.now());
      await _repository.updateTask(updated);
      if (updated.isCompleted && updated.id != null) {
        await _taskNotificationService.cancelTaskReminder(updated.id!);
      } else {
        await _taskNotificationService.scheduleTaskReminder(updated);
      }
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to toggle task ${task.id}', tag: 'TaskService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to toggle task', error: e, stackTrace: st));
    }
  }

  /// Records completion of a single occurrence for a recurring task.
  ///
  /// For non-recurring tasks, marks the task [TaskStatus.done] (same as
  /// completing via [toggleTaskCompletion]) and returns `null` completion.
  Future<Result<TaskCompletion?>> completeOccurrence(int taskId, DateTime occurrenceDate) async {
    try {
      final task = await _repository.getTaskById(taskId);
      if (task == null) {
        return const Failure(NotFoundFailure('Task not found'));
      }

      if (!task.isRecurring) {
        if (!task.isCompleted) {
          final updated = task.copyWith(status: TaskStatus.done, updatedAt: DateTime.now());
          await _repository.updateTask(updated);
          await _taskNotificationService.cancelTaskReminder(taskId);
        }
        return const Success(null);
      }

      final now = DateTime.now();
      final dateOnly = DateTime(occurrenceDate.year, occurrenceDate.month, occurrenceDate.day);
      final completion = TaskCompletion(
        uuid: generateUuid(),
        taskId: taskId,
        occurrenceDate: dateOnly,
        completedAt: now,
        createdAt: now,
        updatedAt: now,
      );
      final saved = await _repository.upsertCompletion(completion);
      await _taskNotificationService.scheduleTaskReminder(task);
      _log.info(
        'Occurrence completed for task $taskId on ${dateOnly.toIso8601String()}',
        tag: 'TaskService',
      );
      return Success(saved);
    } catch (e, st) {
      _log.error(
        'Failed to complete occurrence for task $taskId',
        tag: 'TaskService',
        error: e,
        stackTrace: st,
      );
      return Failure(DatabaseFailure('Failed to complete occurrence', error: e, stackTrace: st));
    }
  }
}
