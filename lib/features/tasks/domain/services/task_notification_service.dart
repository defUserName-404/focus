import '../../../../core/constants/notification_constants.dart';
import '../../../../core/services/i_notification_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../entities/task.dart';
import '../repositories/i_task_repository.dart';
import 'task_reminder_planner.dart';

final _log = LogService.instance;

class TaskNotificationService {
  final INotificationService _notificationService;
  final ITaskRepository _taskRepository;

  const TaskNotificationService(this._notificationService, this._taskRepository);

  Future<Result<void>> scheduleTaskReminder(Task task) async {
    try {
      if (task.id == null) return const Success(null);

      await cancelTaskReminder(task.id!);

      if (!task.isRecurring && (task.endDate == null || task.isCompleted)) {
        return const Success(null);
      }

      final now = DateTime.now();
      if (!task.isRecurring && task.endDate != null && !task.endDate!.isAfter(now)) {
        return const Success(null);
      }

      final scheduledTimes = TaskReminderPlanner.computeReminderTimes(task, now: now);
      if (scheduledTimes.isEmpty) {
        return const Success(null);
      }

      for (var i = 0; i < scheduledTimes.length; i++) {
        await _notificationService.scheduleNotification(
          id: NotificationConstants.taskReminderNotificationId(task.id!, i),
          title: 'Task Reminder',
          body: task.title,
          scheduledTime: scheduledTimes[i],
          payload: NotificationConstants.taskPayload(taskId: task.id!, projectId: task.projectId),
        );
      }

      return const Success(null);
    } catch (e, st) {
      _log.warning(
        'Failed to schedule reminder for task ${task.id}',
        tag: 'TaskNotificationService',
        error: e,
        stackTrace: st,
      );
      return Failure(NotificationFailure('Failed to schedule task reminder', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> cancelTaskReminder(int taskId) async {
    try {
      for (var slot = 0; slot < NotificationConstants.taskReminderSlotStride; slot++) {
        await _notificationService.cancelNotification(NotificationConstants.taskReminderNotificationId(taskId, slot));
      }
      return const Success(null);
    } catch (e, st) {
      _log.warning(
        'Failed to cancel reminder for task $taskId',
        tag: 'TaskNotificationService',
        error: e,
        stackTrace: st,
      );
      return Failure(NotificationFailure('Failed to cancel task reminder', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> rescheduleAllReminders() async {
    try {
      final tasks = await _taskRepository.getTasksWithDeadlines();
      for (final task in tasks) {
        await scheduleTaskReminder(task);
      }
      return const Success(null);
    } catch (e, st) {
      _log.warning('Failed to reschedule task reminders', tag: 'TaskNotificationService', error: e, stackTrace: st);
      return Failure(NotificationFailure('Failed to reschedule task reminders', error: e, stackTrace: st));
    }
  }
}
