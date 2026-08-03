import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;
import 'package:go_router/go_router.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/constrained_content.dart';
import '../../../home/presentation/widgets/global_stats_row.dart';
import '../../../home/presentation/widgets/section_header.dart';
import '../../../home/presentation/widgets/today_summary_card.dart';
import '../../../home/presentation/widgets/year_activity_graph.dart';
import '../../../tasks/domain/entities/global_stats.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';
import '../widgets/estimate_accuracy_section.dart';
import '../widgets/habit_consistency_section.dart';
import '../widgets/productivity_insights_section.dart';
import '../widgets/reports_csv_export_button.dart';
import '../widgets/task_throughput_section.dart';
import '../widgets/time_breakdown_section.dart';

/// Dedicated Reports screen that houses overall stats, activity heatmap,
/// productivity insights, and Phase 6 report expansions.
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalStatsAsync = ref.watch(globalStatsProvider);
    final stats = globalStatsAsync.value ?? GlobalStats.empty;

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [
          fu.FHeaderAction.back(
            onPress: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home.path);
              }
            },
          ),
        ],
        title: Text('Reports', style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700)),
        suffixes: const [ReportsCsvExportButton()],
      ),
      child: ConstrainedContent(
        maxWidth: 840,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppConstants.spacing.regular,
            children: [
              TodaySummaryCard(stats: stats),
              SizedBox(height: AppConstants.spacing.regular),
              SectionHeader(title: 'Overall Stats'),
              GlobalStatsRow(stats: stats),
              SizedBox(height: AppConstants.spacing.regular),
              const YearActivityGraph(),
              SizedBox(height: AppConstants.spacing.regular),
              const ProductivityInsightsSection(),
              SizedBox(height: AppConstants.spacing.large),
              const HabitConsistencySection(),
              SizedBox(height: AppConstants.spacing.large),
              const EstimateAccuracySection(),
              SizedBox(height: AppConstants.spacing.large),
              const TimeBreakdownSection(),
              SizedBox(height: AppConstants.spacing.large),
              const TaskThroughputSection(),
              SizedBox(height: AppConstants.spacing.regular),
            ],
          ),
        ),
      ),
    );
  }
}
