import '../../../../core/constants/notification_constants.dart';
import '../../../../core/services/i_notification_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../entities/task.dart';
import '../repositories/i_task_repository.dart';

final _log = LogService.instance;

class TaskNotificationService {
  final INotificationService _notificationService;
  final ITaskRepository _taskRepository;

  const TaskNotificationService(this._notificationService, this._taskRepository);

  Future<Result<void>> scheduleTaskReminder(Task task) async {
    try {
      if (task.id == null) return const Success(null);
      if (task.endDate == null) return const Success(null);
      if (task.isCompleted) {
        await cancelTaskReminder(task.id!);
        return const Success(null);
      }

      final now = DateTime.now();
      if (!task.endDate!.isAfter(now)) {
        await cancelTaskReminder(task.id!);
        return const Success(null);
      }

      final reminderTime = task.endDate!.subtract(const Duration(minutes: 15));
      final scheduledTime = reminderTime.isAfter(now) ? reminderTime : now.add(const Duration(seconds: 2));

      await _notificationService.scheduleNotification(
        id: _taskNotificationId(task.id!),
        title: 'Task Reminder',
        body: task.title,
        scheduledTime: scheduledTime,
        payload: '${NotificationConstants.taskPayloadPrefix}${task.id}',
      );

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
      await _notificationService.cancelNotification(_taskNotificationId(taskId));
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

  int _taskNotificationId(int taskId) => NotificationConstants.taskReminderIdOffset + taskId;
}
