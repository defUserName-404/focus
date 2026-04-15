import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../domain/entities/notification_inbox_item.dart';
import 'notification_item_card.dart';

class UpcomingReminderCard extends StatelessWidget {
  final NotificationInboxItem item;

  const UpcomingReminderCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final scheduledFor = item.scheduledFor;

    return NotificationItemCard(
      title: item.title,
      primaryText: scheduledFor == null ? 'Reminder scheduled' : 'Reminds ${scheduledFor.toDateTimeString()}',
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
