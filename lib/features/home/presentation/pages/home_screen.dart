import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;
import 'package:focus/core/common/utils/date_formatter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../projects/presentation/screens/project_detail_screen.dart';
import '../../../projects/presentation/screens/project_list_screen.dart';
import '../../../tasks/domain/entities/global_stats.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';
import '../../../tasks/presentation/screens/task_detail_screen.dart';
import '../../../tasks/presentation/widgets/task_activity_graph.dart';
import '../../../tasks/presentation/widgets/task_priority_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final dailySessionsAsync = ref.watch(globalDailyCompletedSessionsProvider);
    final globalStatsAsync = ref.watch(globalStatsProvider);
    final recentTasksAsync = ref.watch(recentTasksProvider);

    final stats = globalStatsAsync.value ?? GlobalStats.empty;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: AppConstants.spacing.extraLarge * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        DateTime.now().toDateString(),
                        style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                if (stats.currentStreak > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(fu.FIcons.flame, size: 14, color: context.colors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.currentStreak}d streak',
                          style: context.typography.xs.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: AppConstants.spacing.extraLarge),

          // ── Today's Summary ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TodaySummaryCard(stats: stats),
          ),

          SizedBox(height: AppConstants.spacing.extraLarge),

          // ── Stats Row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _GlobalStatsRow(stats: stats),
          ),

          SizedBox(height: AppConstants.spacing.extraLarge),

          // ── Activity Graph ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TaskActivityGraph(dailyCompletedSessions: dailySessionsAsync.value ?? {}),
          ),

          SizedBox(height: AppConstants.spacing.extraLarge),

          // ── Recent Tasks ──
          _SectionHeader(title: 'Recent Tasks', onViewAll: () => _navigateToFirstProject(context, projectsAsync.value)),
          SizedBox(height: AppConstants.spacing.regular),
          recentTasksAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(child: fu.FCircularProgress()),
            ),
            error: (err, _) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Error: $err')),
            data: (tasks) {
              if (tasks.isEmpty) {
                return _EmptySection(icon: fu.FIcons.squareCheck, message: 'No tasks yet');
              }
              return Column(children: tasks.map((task) => _RecentTaskTile(task: task)).toList());
            },
          ),

          SizedBox(height: AppConstants.spacing.extraLarge),

          // ── Recent Projects ──
          _SectionHeader(
            title: 'Projects',
            onViewAll: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectListScreen())),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          projectsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(child: fu.FCircularProgress()),
            ),
            error: (err, _) => Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Error: $err')),
            data: (projects) {
              if (projects.isEmpty) {
                return _EmptySection(icon: fu.FIcons.folderOpen, message: 'No projects yet');
              }
              return Column(children: projects.take(3).map((project) => _RecentProjectTile(project: project)).toList());
            },
          ),
        ],
      ),
    );
  }

  void _navigateToFirstProject(BuildContext context, List<Project>? projects) {
    if (projects != null && projects.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: projects.first.id!)));
    }
  }
}

// ── Today's Summary Card ────────────────────────────────────────────────────

class _TodaySummaryCard extends StatelessWidget {
  final GlobalStats stats;

  const _TodaySummaryCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppConstants.spacing.large),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.primary.withValues(alpha: 0.10), context.colors.primary.withValues(alpha: 0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.15),
          width: AppConstants.border.width.small,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: context.typography.xs.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.primary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppConstants.spacing.regular),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stats.formattedTodayTime, style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('focus time', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: context.colors.mutedForeground.withValues(alpha: 0.15)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: AppConstants.spacing.large),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stats.todaySessions}',
                        style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'sessions completed',
                        style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Global Stats Row ────────────────────────────────────────────────────────

class _GlobalStatsRow extends StatelessWidget {
  final GlobalStats stats;

  const _GlobalStatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: fu.FIcons.timer,
            value: stats.formattedTotalTime,
            label: 'Total Focus',
            context: context,
          ),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: _MiniStatCard(
            icon: fu.FIcons.chartBar,
            value: '${stats.completedSessions}',
            label: 'Sessions',
            context: context,
          ),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: _MiniStatCard(
            icon: fu.FIcons.circleCheck,
            value: '${stats.completedTasks}/${stats.totalTasks}',
            label: 'Tasks Done',
            context: context,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final BuildContext context;

  const _MiniStatCard({required this.icon, required this.value, required this.label, required this.context});

  @override
  Widget build(BuildContext outerContext) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular, vertical: AppConstants.spacing.large),
      decoration: BoxDecoration(
        color: outerContext.colors.mutedForeground.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
        border: Border.all(
          color: outerContext.colors.mutedForeground.withValues(alpha: 0.12),
          width: AppConstants.border.width.small,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: AppConstants.size.icon.regular, color: outerContext.colors.mutedForeground),
          SizedBox(height: AppConstants.spacing.small),
          Text(value, style: outerContext.typography.lg.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: AppConstants.spacing.extraSmall),
          Text(
            label,
            style: outerContext.typography.xs.copyWith(color: outerContext.colors.mutedForeground),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _SectionHeader({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: context.typography.sm.copyWith(fontWeight: FontWeight.w600, color: context.colors.foreground),
          ),
          const Spacer(),
          if (onViewAll != null)
            fu.FButton(
              style: fu.FButtonStyle.ghost(),
              onPress: onViewAll,
              child: Text('View All', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
            ),
        ],
      ),
    );
  }
}

// ── Empty Section ───────────────────────────────────────────────────────────

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptySection({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 32, color: context.colors.mutedForeground.withValues(alpha: 0.4)),
            SizedBox(height: AppConstants.spacing.regular),
            Text(message, style: context.typography.sm.copyWith(color: context.colors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

// ── Recent Task Tile ────────────────────────────────────────────────────────

class _RecentTaskTile extends StatelessWidget {
  final Task task;

  const _RecentTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.only(bottom: AppConstants.spacing.regular),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailScreen(taskId: task.id!, projectId: task.projectId),
            ),
          ),
          child: fu.FCard(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacing.regular),
              child: Row(
                children: [
                  // Status icon
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? context.colors.primary.withValues(alpha: 0.15)
                          : context.colors.mutedForeground.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                    ),
                    child: Icon(
                      task.isCompleted ? fu.FIcons.check : fu.FIcons.circle,
                      size: 14,
                      color: task.isCompleted ? context.colors.primary : context.colors.mutedForeground,
                    ),
                  ),
                  SizedBox(width: AppConstants.spacing.regular),
                  // Title + date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: context.typography.sm.copyWith(
                            fontWeight: FontWeight.w500,
                            color: task.isCompleted ? context.colors.mutedForeground : context.colors.foreground,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.updatedAt.toRelativeDueString().replaceFirst('Due ', ''),
                          style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                  TaskPriorityBadge(priority: task.priority),
                  SizedBox(width: AppConstants.spacing.small),
                  Icon(fu.FIcons.chevronRight, size: 14, color: context.colors.mutedForeground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recent Project Tile ─────────────────────────────────────────────────────

class _RecentProjectTile extends StatelessWidget {
  final Project project;

  const _RecentProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: EdgeInsets.only(bottom: AppConstants.spacing.regular),
        child: GestureDetector(
          onTap: () {
            if (project.id != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailScreen(projectId: project.id!)));
            }
          },
          child: fu.FCard(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacing.regular),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                    ),
                    child: Icon(fu.FIcons.folder, size: 14, color: context.colors.primary),
                  ),
                  SizedBox(width: AppConstants.spacing.regular),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: context.typography.sm.copyWith(fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (project.description != null && project.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            project.description!,
                            style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (project.deadline != null) ...[
                    Text(
                      project.deadline!.toShortDateString(),
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                    SizedBox(width: AppConstants.spacing.small),
                  ],
                  Icon(fu.FIcons.chevronRight, size: 14, color: context.colors.mutedForeground),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
