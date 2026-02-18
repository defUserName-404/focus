import 'package:flutter/material.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/tasks/domain/entities/global_stats.dart';
import 'package:forui/forui.dart' as fu;

import 'mini_stat_card.dart';

class GlobalStatsRow extends StatelessWidget {
  final GlobalStats stats;

  const GlobalStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MiniStatCard(icon: fu.FIcons.timer, value: stats.formattedTotalTime, label: 'Total Focus'),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: MiniStatCard(icon: fu.FIcons.chartBar, value: '${stats.completedSessions}', label: 'Sessions'),
        ),
        SizedBox(width: AppConstants.spacing.regular),
        Expanded(
          child: MiniStatCard(
            icon: fu.FIcons.circleCheck,
            value: '${stats.completedTasks}/${stats.totalTasks}',
            label: 'Tasks Done',
          ),
        ),
      ],
    );
  }
}
