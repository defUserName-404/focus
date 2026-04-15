import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../providers/notifications_provider.dart';
import 'recent_notification_card.dart';

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

            return Column(children: [for (final item in items) RecentNotificationCard(item: item)]);
          },
        ),
      ],
    );
  }
}
