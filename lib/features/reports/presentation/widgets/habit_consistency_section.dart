import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../home/presentation/utils/activity_graph_constants.dart';
import '../../../home/presentation/utils/activity_graph_utils.dart';
import '../../../home/presentation/widgets/year_grid_painter.dart';
import '../../../tasks/domain/entities/habit_consistency_stat.dart';
import '../providers/report_insights_providers.dart';

class HabitConsistencySection extends ConsumerWidget {
  const HabitConsistencySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitConsistencyProvider);
    final heatmapAsync = ref.watch(habitHeatmapProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Habit Consistency', style: context.typography.md.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: AppConstants.spacing.regular),
        habitsAsync.when(
          loading: () => const SizedBox(height: 80, child: Center(child: fu.FCircularProgress())),
          error: (err, _) => Text('Error: $err', style: context.typography.sm),
          data: (habits) {
            if (habits.isEmpty) {
              return Text(
                'No habits in this window yet',
                style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
              );
            }
            return Column(
              children: [
                for (final habit in habits) ...[
                  _HabitConsistencyTile(habit: habit),
                  SizedBox(height: AppConstants.spacing.small),
                ],
              ],
            );
          },
        ),
        SizedBox(height: AppConstants.spacing.large),
        Text('Habit Heatmap', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: AppConstants.spacing.regular),
        heatmapAsync.when(
          loading: () => const SizedBox(height: 120, child: Center(child: fu.FCircularProgress())),
          error: (err, _) => Text('Error: $err', style: context.typography.sm),
          data: (lookup) => _HabitHeatmap(lookup: lookup),
        ),
      ],
    );
  }
}

class _HabitConsistencyTile extends StatelessWidget {
  final HabitConsistencyStat habit;

  const _HabitConsistencyTile({required this.habit});

  @override
  Widget build(BuildContext context) {
    final percent = (habit.completionRate * 100).round();
    return Container(
      padding: EdgeInsets.all(AppConstants.spacing.regular),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.border),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.title, style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
                SizedBox(height: AppConstants.spacing.extraSmall),
                Text(
                  '$percent% · ${habit.completedCount}/${habit.scheduledCount} scheduled',
                  style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${habit.currentStreak} day streak',
                style: context.typography.sm.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Best ${habit.longestStreak}',
                style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitHeatmap extends StatelessWidget {
  final Map<String, int> lookup;

  const _HabitHeatmap({required this.lookup});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final jan1 = DateTime(year, 1, 1);
    final dec31 = DateTime(year, 12, 31);
    final totalWeeks = DateTimeExtensions.weekIndex(dec31, jan1) + 1;
    final gridWidth = ActivityGraphConstants.dayLabelWidth + totalWeeks * ActivityGraphConstants.cellStep;
    final todayKey = ActivityGraphUtils.today().toShortDateKey();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: gridWidth,
        height: ActivityGraphConstants.monthLabelHeight + ActivityGraphConstants.graphHeight,
        child: CustomPaint(
          size: Size(gridWidth, ActivityGraphConstants.monthLabelHeight + ActivityGraphConstants.graphHeight),
          painter: YearGridPainter(
            year: year,
            lookup: lookup,
            cellColor: context.colors.primary,
            emptyColor: context.colors.mutedForeground.withValues(alpha: 0.12),
            textColor: context.colors.mutedForeground,
            textStyle: context.typography.xs,
            highlightDateKey: todayKey,
            highlightColor: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
