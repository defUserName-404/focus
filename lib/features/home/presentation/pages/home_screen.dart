import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/utils/date_time_utils.dart';
import 'package:focus/core/utils/datetime_formatter.dart';
import 'package:focus/features/home/presentation/widgets/streak_badge.dart';

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

    final showOnboarding =
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
            children: const [QuickSessionButton(), TodayAgendaSection(), HabitsStripSection(), UpcomingCalendarCard()],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppConstants.spacing.regular,
            children: [
              const QuickSessionButton(),
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
          if (context.isCompact)
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
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppConstants.spacing.extraSmall,
              children: [
                Text('Focus', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  DateTimeUtils.now().toDateString(),
                  style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                ),
              ],
            ),
          ],
        ),
      ),
      child: ConstrainedContent(child: SingleChildScrollView(child: body)),
    );
  }
}
