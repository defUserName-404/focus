import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum NotificationInboxType { taskReminder }

enum NotificationInboxState { scheduled, opened, cancelled }

@immutable
class NotificationInboxItem extends Equatable {
  final int id;
  final int notificationId;
  final NotificationInboxType type;
  final NotificationInboxState state;
  final String title;
  final String? body;
  final String? payload;
  final int? taskId;
  final int? projectId;
  final DateTime? scheduledFor;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationInboxItem({
    required this.id,
    required this.notificationId,
    required this.type,
    required this.state,
    required this.title,
    this.body,
    this.payload,
    this.taskId,
    this.projectId,
    this.scheduledFor,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    notificationId,
    type,
    state,
    title,
    body,
    payload,
    taskId,
    projectId,
    scheduledFor,
    createdAt,
    updatedAt,
  ];
}
