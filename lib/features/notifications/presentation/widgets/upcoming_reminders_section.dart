import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../providers/notifications_provider.dart';
import 'upcoming_reminder_card.dart';

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

            return Column(children: [for (final item in items) UpcomingReminderCard(item: item)]);
          },
        ),
      ],
    );
  }
}
