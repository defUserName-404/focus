import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task_stats.dart';

/// Row of three stat cards: Total time, Sessions, Average.
class TaskStatsRow extends StatelessWidget {
  final TaskStats stats;

  const TaskStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            value: stats.formattedTotalTime,
            label: 'Total',
            context: context,
          ),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: _StatCard(
            icon: Icons.bar_chart_rounded,
            value: stats.totalSessions.toString(),
            label: 'Sessions',
            context: context,
          ),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: _StatCard(
            icon: Icons.av_timer_outlined,
            value: stats.formattedAvgTime,
            label: 'Average',
            context: context,
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
  final BuildContext context;

  const _StatCard({required this.icon, required this.value, required this.label, required this.context});

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
          Text(label, style: outerContext.typography.xs.copyWith(color: outerContext.colors.mutedForeground)),
        ],
      ),
    );
  }
}
