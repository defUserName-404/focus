import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/notification_inbox_item.dart';
import '../../domain/repositories/i_notification_inbox_repository.dart';

final _notificationInboxRepositoryProvider = Provider<INotificationInboxRepository>(
  (ref) => getIt<INotificationInboxRepository>(),
);

final upcomingTaskRemindersProvider = StreamProvider<List<NotificationInboxItem>>((ref) {
  final repository = ref.watch(_notificationInboxRepositoryProvider);
  return repository.watchUpcomingTaskReminders(limit: 12);
});

final recentNotificationsProvider = StreamProvider<List<NotificationInboxItem>>((ref) {
  final repository = ref.watch(_notificationInboxRepositoryProvider);
  return repository.watchRecentNotifications(limit: 30);
});
