import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../providers/upcoming_tasks_provider.dart';
import 'calendar_content.dart';

/// A calendar-style view that shows upcoming task deadlines on the home screen.
///
/// Supports month and week views, highlighting days with upcoming deadlines.
/// Tapping a day shows an overlay popup with that day's tasks.
class UpcomingCalendarCard extends ConsumerWidget {
  const UpcomingCalendarCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingTasksProvider);

    return upcomingAsync.when(
      loading: () => const Center(child: fu.FCircularProgress()),
      error: (err, _) => Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2),
        child: Text('Error loading calendar: $err'),
      ),
      data: (tasks) => CalendarContent(tasks: tasks),
    );
  }
}
