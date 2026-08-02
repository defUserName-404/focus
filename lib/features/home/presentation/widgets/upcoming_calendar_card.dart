import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../providers/upcoming_tasks_provider.dart';
import 'calendar_content.dart';
import 'section_header.dart';

/// Home "Next 7 Days" section — week strip only (month grid is on Tasks).
class UpcomingCalendarCard extends ConsumerWidget {
  const UpcomingCalendarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppConstants.spacing.small,
      children: [
        const SectionHeader(title: 'Next 7 Days'),
        upcomingAsync.when(
          loading: () => const Center(child: fu.FCircularProgress()),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2),
            child: Text('Error loading calendar: $err'),
          ),
          data: (tasks) => CalendarContent(tasks: tasks),
        ),
      ],
    );
  }
}
