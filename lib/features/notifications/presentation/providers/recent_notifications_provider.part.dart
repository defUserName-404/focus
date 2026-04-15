part of 'notifications_provider.dart';

final recentNotificationsProvider = StreamProvider<List<NotificationInboxItem>>((ref) {
  final repository = ref.watch(_notificationInboxRepositoryProvider);
  return repository.watchRecentNotifications(limit: 30);
});
