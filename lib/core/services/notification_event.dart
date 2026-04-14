import 'package:meta/meta.dart';

enum NotificationEventType { focus, alarm, taskReminderScheduled, reminderScheduled, opened, action, cancelled }

@immutable
class NotificationEvent {
  final NotificationEventType type;
  final DateTime occurredAt;
  final int? notificationId;
  final String title;
  final String? body;
  final String? payload;
  final DateTime? scheduledFor;
  final String? actionId;

  const NotificationEvent({
    required this.type,
    required this.occurredAt,
    this.notificationId,
    required this.title,
    this.body,
    this.payload,
    this.scheduledFor,
    this.actionId,
  });
}
