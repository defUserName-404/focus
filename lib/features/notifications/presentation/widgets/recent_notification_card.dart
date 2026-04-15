import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../domain/entities/notification_inbox_item.dart';
import 'notification_item_card.dart';

class RecentNotificationCard extends StatelessWidget {
  final NotificationInboxItem item;

  const RecentNotificationCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final label = switch (item.state) {
      NotificationInboxState.opened => 'Opened ${item.updatedAt.toDateTimeString()}',
      NotificationInboxState.cancelled => 'Cleared ${item.updatedAt.toDateTimeString()}',
      NotificationInboxState.scheduled =>
        'Due ${item.scheduledFor?.toDateTimeString() ?? item.updatedAt.toDateTimeString()}',
    };

    return NotificationItemCard(
      title: item.title,
      primaryText: label,
      secondaryText: item.body,
      onTap: () {
        final taskId = item.taskId;
        if (taskId == null) return;

        final path = Uri(
          path: AppRoutes.taskDetailPath(taskId),
          queryParameters: item.projectId == null ? null : {'projectId': item.projectId.toString()},
        ).toString();
        context.push(path);
      },
    );
  }
}
