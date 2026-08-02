import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../tasks/domain/entities/task_throughput_stats.dart';
import '../providers/report_insights_providers.dart';
import '../providers/reports_insights_window_provider.dart';

class TaskThroughputSection extends ConsumerWidget {
  const TaskThroughputSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final window = ref.watch(reportsInsightsWindowProvider).value ?? InsightsWindowMode.weekly;
    final async = ref.watch(taskThroughputProvider);
    final title = window == InsightsWindowMode.weekly ? 'Completed per Day' : 'Completed per Week';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Task Throughput', style: context.typography.md.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: AppConstants.spacing.regular),
        async.when(
          loading: () => const SizedBox(height: 120, child: Center(child: fu.FCircularProgress())),
          error: (err, _) => Text('Error: $err', style: context.typography.sm),
          data: (stats) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: AppConstants.spacing.regular),
                _ThroughputBars(stats: stats),
                SizedBox(height: AppConstants.spacing.regular),
                _CycleTimeInsight(stats: stats),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ThroughputBars extends StatelessWidget {
  final TaskThroughputStats stats;

  const _ThroughputBars({required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.buckets.isEmpty) {
      return Text(
        'No completions in this window',
        style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
      );
    }
    final maxCount = stats.buckets.fold<int>(0, (maxValue, b) => math.max(maxValue, b.completedCount));
    const barHeight = 72.0;
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final bucket in stats.buckets)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.extraSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${bucket.completedCount}',
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                    SizedBox(height: AppConstants.spacing.extraSmall),
                    Container(
                      height: maxCount <= 0 ? 2 : (bucket.completedCount / maxCount * barHeight).clamp(2.0, barHeight),
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(AppConstants.border.radius.small),
                      ),
                    ),
                    SizedBox(height: AppConstants.spacing.small),
                    Text(bucket.label, style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CycleTimeInsight extends StatelessWidget {
  final TaskThroughputStats stats;

  const _CycleTimeInsight({required this.stats});

  @override
  Widget build(BuildContext context) {
    final hours = stats.averageCycleHours;
    if (hours == null || stats.cycleSampleCount == 0) {
      return Text(
        'Complete tasks to measure average cycle time',
        style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
      );
    }
    final label = hours < 1 ? '${(hours * 60).round()}m' : '${hours.toStringAsFixed(1)}h';
    return Text(
      'Average cycle time $label (in progress → done, ${stats.cycleSampleCount} tasks)',
      style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
    );
  }
}
