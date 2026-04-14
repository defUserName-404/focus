import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../domain/entities/notification_inbox_item.dart';
import '../providers/notifications_provider.dart';
import 'notification_item_card.dart';

class RecentNotificationsSection extends ConsumerWidget {
  const RecentNotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentNotificationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recent Notifications'),
        SizedBox(height: AppConstants.spacing.small),
        recentAsync.when(
          loading: () => const Center(child: fu.FCircularProgress()),
          error: (err, _) => fu.FCard(child: Text('Failed to load notifications: $err')),
          data: (items) {
            if (items.isEmpty) {
              return fu.FCard(child: const Text('No recent notification activity.'));
            }

            return Column(children: [for (final item in items) _RecentNotificationCard(item: item)]);
          },
        ),
      ],
    );
  }
}

class _RecentNotificationCard extends StatelessWidget {
  final NotificationInboxItem item;

  const _RecentNotificationCard({required this.item});

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
