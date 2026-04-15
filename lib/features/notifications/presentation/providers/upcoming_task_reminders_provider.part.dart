part of 'notifications_provider.dart';

final upcomingTaskRemindersProvider = StreamProvider<List<NotificationInboxItem>>((ref) {
  final repository = ref.watch(_notificationInboxRepositoryProvider);
  return repository.watchUpcomingTaskReminders(limit: 12);
});
