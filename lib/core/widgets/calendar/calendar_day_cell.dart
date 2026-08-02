import 'package:flutter/material.dart';

import '../../config/theme/app_theme.dart';
import '../../constants/app_constants.dart';

class CalendarDayCell extends StatelessWidget {
  final int day;
  final bool hasTasks;
  final bool hasSessions;
  final bool isToday;
  final bool isSelected;

  const CalendarDayCell({
    super.key,
    required this.day,
    required this.hasTasks,
    this.hasSessions = false,
    required this.isToday,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colors.primary
            : isToday
            ? context.colors.primary.withValues(alpha: 0.1)
            : null,
        borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: context.typography.xs.copyWith(
              fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected
                  ? context.colors.primaryForeground
                  : isToday
                  ? context.colors.primary
                  : context.colors.foreground,
            ),
          ),
          if ((hasTasks || hasSessions) && !isSelected)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTasks)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(color: context.colors.primary, shape: BoxShape.circle),
                  ),
                if (hasTasks && hasSessions) const SizedBox(width: 2),
                if (hasSessions)
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(color: context.colors.secondary, shape: BoxShape.circle),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
