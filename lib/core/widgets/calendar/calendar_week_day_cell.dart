import 'package:flutter/material.dart';

import '../../config/theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../constants/date_time_constants.dart';

class CalendarWeekDayCell extends StatelessWidget {
  final DateTime date;
  final int taskCount;
  final int sessionCount;
  final bool isToday;
  final bool isSelected;

  const CalendarWeekDayCell({
    super.key,
    required this.date,
    required this.taskCount,
    this.sessionCount = 0,
    required this.isToday,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateTimeConstants.shortWeekdayNames[date.weekday - 1];
    final indicatorCount = (taskCount + (sessionCount > 0 ? 1 : 0)).clamp(0, 3);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep a 44dp touch target; grow a bit when the strip cell is wider.
        final minSide = (constraints.maxWidth.isFinite && constraints.maxWidth > 44)
            ? (44.0 + ((constraints.maxWidth - 44) * 0.25).clamp(0.0, 12.0))
            : 44.0;
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: minSide, minWidth: 44),
          child: Container(
            width: double.infinity,
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
              mainAxisSize: MainAxisSize.min,
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
                                : (i == 0 && sessionCount > 0 && taskCount == 0)
                                ? context.colors.secondary
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
          ),
        );
      },
    );
  }
}
