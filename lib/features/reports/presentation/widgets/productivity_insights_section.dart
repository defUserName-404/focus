import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/presentation/providers/task_stats_provider.dart';
import '../providers/reports_insights_window_provider.dart';
import '../utils/productivity_insights_utils.dart';
import 'insights_content.dart';
import 'insights_window_toggle.dart';

class ProductivityInsightsSection extends ConsumerWidget {
  const ProductivityInsightsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windowAsync = ref.watch(reportsInsightsWindowProvider);
    final window = windowAsync.value ?? InsightsWindowMode.weekly;
    final range = ProductivityInsightsUtils.dateRangeForWindow(window);
    final rangeKey = '${range.start.toShortDateKey()}|${range.end.toShortDateKey()}';
    final statsAsync = ref.watch(dailyStatsForRangeProvider(rangeKey));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Productivity Insights', style: context.typography.base.copyWith(fontWeight: FontWeight.w700)),
            InsightsWindowToggle(
              window: window,
              onChanged: (value) {
                ref.read(reportsInsightsWindowProvider.notifier).setWindow(value);
              },
            ),
          ],
        ),
        SizedBox(height: AppConstants.spacing.regular),
        statsAsync.when(
          loading: () => const SizedBox(height: 160, child: Center(child: fu.FCircularProgress())),
          error: (err, _) => Padding(
            padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.large),
            child: Center(child: Text('Error: $err')),
          ),
          data: (stats) {
            final insights = ProductivityInsightsUtils.buildInsightsData(stats: stats, window: window, range: range);
            return InsightsContent(window: window, data: insights);
          },
        ),
      ],
    );
  }
}
