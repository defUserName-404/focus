import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/notification_inbox_item.dart';
import '../../domain/repositories/i_notification_inbox_repository.dart';

part 'recent_notifications_provider.part.dart';
part 'upcoming_task_reminders_provider.part.dart';

final _notificationInboxRepositoryProvider = Provider<INotificationInboxRepository>(
  (ref) => getIt<INotificationInboxRepository>(),
);
