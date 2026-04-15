import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../home/presentation/utils/stats_formatting.dart';
import '../../domain/entities/task_stats.dart';
import 'task_stat_card.dart';

/// Row of three stat cards: Total time, Sessions, Average.
class TaskStatsRow extends StatelessWidget {
  final TaskStats stats;

  const TaskStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TaskStatCard(
            icon: Icons.timer_outlined,
            value: stats.formattedTotalTime,
            label: 'Total',
          ),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: TaskStatCard(
            icon: Icons.bar_chart_rounded,
            value: stats.totalSessions.toString(),
            label: 'Sessions',
          ),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: TaskStatCard(
            icon: Icons.av_timer_outlined,
            value: stats.formattedAvgTime,
            label: 'Average',
          ),
        ),
      ],
    );
  }
}
