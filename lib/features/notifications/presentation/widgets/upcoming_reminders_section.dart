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

class UpcomingRemindersSection extends ConsumerWidget {
  const UpcomingRemindersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingTaskRemindersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Upcoming Reminders'),
        SizedBox(height: AppConstants.spacing.small),
        upcomingAsync.when(
          loading: () => const Center(child: fu.FCircularProgress()),
          error: (err, _) => fu.FCard(child: Text('Failed to load reminders: $err')),
          data: (items) {
            if (items.isEmpty) {
              return fu.FCard(child: const Text('No upcoming reminders yet.'));
            }

            return Column(children: [for (final item in items) _UpcomingReminderCard(item: item)]);
          },
        ),
      ],
    );
  }
}

class _UpcomingReminderCard extends StatelessWidget {
  final NotificationInboxItem item;

  const _UpcomingReminderCard({required this.item});

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
