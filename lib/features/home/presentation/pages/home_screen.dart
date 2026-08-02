import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/utils/date_time_utils.dart';
import 'package:focus/core/utils/datetime_formatter.dart';
import 'package:focus/core/utils/greeting.dart';
import 'package:focus/features/home/presentation/widgets/streak_badge.dart';
import 'package:focus/features/settings/presentation/providers/settings_provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/utils/platform_utils.dart';
import '../../../../core/widgets/constrained_content.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../tasks/domain/entities/global_stats.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';
import '../providers/habits_strip_provider.dart';
import '../providers/today_agenda_provider.dart';
import '../widgets/habits_strip_section.dart';
import '../widgets/home_onboarding_card.dart';
import '../widgets/quick_session_button.dart';
import '../widgets/today_agenda_section.dart';
import '../widgets/upcoming_calendar_card.dart';
import '../widgets/year_activity_graph.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectListProvider);
    final globalStatsAsync = ref.watch(globalStatsProvider);
    final agendaAsync = ref.watch(todayAgendaProvider);
    final habitsAsync = ref.watch(habitsStripProvider);

    final stats = globalStatsAsync.value ?? GlobalStats.empty;
    final projects = projectsAsync.value ?? const [];
    final agenda = agendaAsync.value ?? const [];
    final habits = habitsAsync.value ?? const [];

    final userPrefsAsync = ref.watch(userPreferencesProvider);
    final onboardingCompleted = userPrefsAsync.value?.onboardingCompleted ?? true;

    final showOnboarding =
        onboardingCompleted &&
        projectsAsync.hasValue &&
        agendaAsync.hasValue &&
        habitsAsync.hasValue &&
        projects.isEmpty &&
        agenda.isEmpty &&
        habits.isEmpty;

    final body = showOnboarding
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppConstants.spacing.regular,
            children: const [QuickSessionButton(), HomeOnboardingCard()],
          )
        : context.isCompact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppConstants.spacing.regular,
            children: [
              const QuickSessionButton(),
              _StatsSummaryRow(stats: stats),
              const TodayAgendaSection(),
              const HabitsStripSection(),
              const UpcomingCalendarCard(),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppConstants.spacing.regular,
            children: [
              const QuickSessionButton(),
              _StatsSummaryRow(stats: stats),
              const YearActivityGraph(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 3, child: TodayAgendaSection()),
                  SizedBox(width: AppConstants.spacing.large),
                  const Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [HabitsStripSection(), SizedBox(height: 16), UpcomingCalendarCard()],
                    ),
                  ),
                ],
              ),
            ],
          );

    return fu.FScaffold(
      header: fu.FHeader(
        suffixes: [
          if (stats.currentStreak > 0) StreakBadge(streak: stats.currentStreak),
          if (context.isCompact) ...[
            fu.FTooltip(
              tipBuilder: (context, _) => const Text('Reports'),
              child: fu.FHeaderAction(
                icon: Icon(fu.FLucideIcons.chartBar, size: AppConstants.size.icon.regular),
                semanticsLabel: 'Reports',
                onPress: () => context.push(AppRoutes.reports.path),
              ),
            ),
            fu.FTooltip(
              tipBuilder: (context, _) => const Text('Settings'),
              child: fu.FHeaderAction(
                icon: Icon(fu.FLucideIcons.settings, size: AppConstants.size.icon.regular),
                semanticsLabel: 'Settings',
                onPress: () => context.push(AppRoutes.settings.path),
              ),
            ),
          ],
        ],
        title: _DashboardTitle(),
      ),
      child: ConstrainedContent(child: SingleChildScrollView(child: body)),
    );
  }
}

class _DashboardTitle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(userPreferencesProvider).value?.displayName;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppConstants.spacing.extraSmall,
          children: [
            Text(
              greetingFor(name: name),
              style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              DateTimeUtils.now().toDateString(),
              style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatsSummaryRow extends StatelessWidget {
  final GlobalStats stats;

  const _StatsSummaryRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: fu.FLucideIcons.flame,
            value: stats.currentStreak > 0 ? '${stats.currentStreak}' : '—',
            label: stats.currentStreak > 0 ? 'day streak' : 'No streak',
            iconColor: stats.currentStreak > 0 ? context.colors.primary : context.colors.mutedForeground,
          ),
        ),
        SizedBox(width: AppConstants.spacing.small),
        Expanded(
          child: _StatCard(
            icon: fu.FLucideIcons.timer,
            value: stats.todayFocusMinutes > 0 ? stats.todayFocusMinutes.toHourMinuteString() : '—',
            label: 'focus today',
            iconColor: context.colors.primary,
          ),
        ),
        SizedBox(width: AppConstants.spacing.small),
        Expanded(
          child: _StatCard(
            icon: fu.FLucideIcons.checkCircle,
            value: stats.completedTasks > 0 ? '${stats.completedTasks}' : '—',
            label: 'tasks done',
            iconColor: context.colors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatCard({required this.icon, required this.value, required this.label, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return fu.FCard(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular, vertical: AppConstants.spacing.small),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            SizedBox(width: AppConstants.spacing.small),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: context.typography.lg.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
