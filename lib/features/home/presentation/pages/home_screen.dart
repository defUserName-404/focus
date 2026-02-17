import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/common/utils/date_formatter.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/features/home/presentation/widgets/empty_section.dart';
import 'package:focus/features/home/presentation/widgets/global_stats_row.dart';
import 'package:focus/features/home/presentation/widgets/recent_project_tile.dart';
import 'package:focus/features/home/presentation/widgets/recent_task_tile.dart';
import 'package:focus/features/home/presentation/widgets/section_header.dart';
import 'package:focus/features/home/presentation/widgets/streak_badge.dart';
import 'package:focus/features/home/presentation/widgets/today_summary_card.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../tasks/domain/entities/global_stats.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';
import '../widgets/quick_session_button.dart';
import '../widgets/year_activity_graph.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final globalStatsAsync = ref.watch(globalStatsProvider);
    final recentTasksAsync = ref.watch(recentTasksProvider);

    final stats = globalStatsAsync.value ?? GlobalStats.empty;

    return fu.FScaffold(
      header: fu.FHeader(
        suffixes: [if (stats.currentStreak > 0) StreakBadge(streak: stats.currentStreak)],
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppConstants.spacing.extraSmall,
              children: [
                Text('Focus', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  DateTime.now().toDateString(),
                  style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                ),
              ],
            ),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppConstants.spacing.regular,
          children: [
            QuickSessionButton(),
            SizedBox(height: AppConstants.spacing.regular),
            TodaySummaryCard(stats: stats),
            SizedBox(height: AppConstants.spacing.regular),
            SectionHeader(title: 'Overall Stats'),
            GlobalStatsRow(stats: stats),
            SizedBox(height: AppConstants.spacing.regular),
            const YearActivityGraph(),
            SizedBox(height: AppConstants.spacing.regular),
            SectionHeader(
              title: 'Recent Tasks',
              onViewAll: () {
                final projects = projectsAsync.value;
                if (projects != null && projects.isNotEmpty) {
                  Navigator.pushNamed(context, RouteConstants.projectDetailRoute, arguments: projects.first.id!);
                }
              },
            ),
            recentTasksAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2),
                child: Text('Error: $err'),
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const EmptySection(icon: fu.FIcons.squareCheck, message: 'No tasks yet');
                }
                return Column(children: tasks.map((task) => RecentTaskTile(task: task)).toList());
              },
            ),
            SizedBox(height: AppConstants.spacing.regular),
            SectionHeader(
              title: 'Projects',
              onViewAll: () => Navigator.pushNamed(context, RouteConstants.projectListRoute),
            ),
            projectsAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraLarge2),
                child: Text('Error: $err'),
              ),
              data: (projects) {
                if (projects.isEmpty) {
                  return const EmptySection(icon: fu.FIcons.folderOpen, message: 'No projects yet');
                }
                return Column(
                  children: projects.take(3).map((project) => RecentProjectTile(project: project)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
