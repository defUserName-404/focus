import 'package:flutter/material.dart';

import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
import 'package:focus/features/home/presentation/utils/activity_graph_constants.dart';

class ActivityGraphLegend extends StatelessWidget {
  const ActivityGraphLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final emptyColor = context.colors.mutedForeground.withValues(alpha: 0.12);
    final cellColor = context.colors.primary;
    final levels = [
      emptyColor,
      cellColor.withValues(alpha: 0.25),
      cellColor.withValues(alpha: 0.50),
      cellColor.withValues(alpha: 0.75),
      cellColor,
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Less', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
        SizedBox(width: AppConstants.spacing.small),
        ...levels.map(
          (color) => Container(
            width: ActivityGraphConstants.legendCellSize,
            height: ActivityGraphConstants.legendCellSize,
            margin: const EdgeInsets.only(right: ActivityGraphConstants.legendCellMargin),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(ActivityGraphConstants.legendCellRadius),
            ),
          ),
        ),
        SizedBox(width: AppConstants.spacing.small),
        Text('More', style: context.typography.xs.copyWith(color: context.colors.mutedForeground)),
      ],
    );
  }
}
