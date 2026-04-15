import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../tasks/domain/entities/task.dart';
import '../utils/upcoming_calendar_utils.dart';
import 'calendar_week_day_cell.dart';

class CalendarWeekStrip extends StatelessWidget {
  final DateTime weekStart;
  final Map<DateTime, List<Task>> tasksByDate;
  final DateTime now;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDateTap;

  const CalendarWeekStrip({
    super.key,
    required this.weekStart,
    required this.tasksByDate,
    required this.now,
    required this.selectedDay,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final days = UpcomingCalendarUtils.weekDays(weekStart);

    return Row(
      children: [
        for (var index = 0; index < days.length; index++) ...[
          Expanded(
            child: GestureDetector(
              onTap: tasksByDate.containsKey(days[index]) ? () => onDateTap(days[index]) : null,
              child: CalendarWeekDayCell(
                date: days[index],
                taskCount: tasksByDate[days[index]]?.length ?? 0,
                isToday: DateUtils.isSameDay(days[index], now),
                isSelected: DateUtils.isSameDay(days[index], selectedDay),
              ),
            ),
          ),
          if (index < days.length - 1) SizedBox(width: AppConstants.spacing.extraSmall),
        ],
      ],
    );
  }
}
