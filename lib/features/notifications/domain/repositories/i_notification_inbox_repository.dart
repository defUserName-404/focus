import '../entities/notification_inbox_item.dart';

abstract class INotificationInboxRepository {
  Stream<List<NotificationInboxItem>> watchUpcomingTaskReminders({int limit = 12});

  Stream<List<NotificationInboxItem>> watchRecentNotifications({int limit = 30});

  Future<void> upsertScheduledTaskReminder({
    required int notificationId,
    required String title,
    String? body,
    String? payload,
    int? taskId,
    int? projectId,
    DateTime? scheduledFor,
    required DateTime occurredAt,
  });

  Future<void> markTaskReminderOpened({required int notificationId, required DateTime openedAt});

  Future<void> markTaskReminderCancelled({required int notificationId, required DateTime cancelledAt});

  Future<void> pruneOldNotifications({Duration retention});
}
