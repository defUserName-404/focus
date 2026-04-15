import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/date_time_constants.dart';

class CalendarWeekDayCell extends StatelessWidget {
  final DateTime date;
  final int taskCount;
  final bool isToday;
  final bool isSelected;

  const CalendarWeekDayCell({
    super.key,
    required this.date,
    required this.taskCount,
    required this.isToday,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateTimeConstants.shortWeekdayNames[date.weekday - 1];
    final indicatorCount = taskCount.clamp(0, 3);

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.small, vertical: AppConstants.spacing.small),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.primary
            : isToday
            ? context.colors.primary.withValues(alpha: 0.1)
            : context.colors.muted.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayLabel,
            style: context.typography.xs.copyWith(
              color: isSelected ? context.colors.primaryForeground : context.colors.mutedForeground,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppConstants.spacing.extraSmall),
          Text(
            '${date.day}',
            style: context.typography.sm.copyWith(
              color: isSelected ? context.colors.primaryForeground : context.colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppConstants.spacing.extraSmall),
          if (indicatorCount > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < indicatorCount; i++) ...[
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primaryForeground.withValues(alpha: 0.85)
                          : context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (i < indicatorCount - 1) SizedBox(width: AppConstants.spacing.extraSmall),
                ],
              ],
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}
