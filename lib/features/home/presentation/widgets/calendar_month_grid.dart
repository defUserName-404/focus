import 'package:flutter/material.dart';

import '../../../tasks/domain/entities/task.dart';
import '../utils/upcoming_calendar_utils.dart';
import 'calendar_day_cell.dart';

class CalendarMonthGrid extends StatelessWidget {
  final DateTime displayMonth;
  final int daysInMonth;
  final int firstWeekday;
  final Map<DateTime, List<Task>> tasksByDate;
  final DateTime now;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDateTap;

  const CalendarMonthGrid({
    super.key,
    required this.displayMonth,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.tasksByDate,
    required this.now,
    required this.selectedDay,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = <Widget>[];
    var dayCounter = 1;
    final leadingEmpty = firstWeekday - 1;

    var cellIndex = 0;
    var currentWeekCells = <Widget>[];

    for (var i = 0; i < leadingEmpty; i++) {
      currentWeekCells.add(const Expanded(child: SizedBox.shrink()));
      cellIndex++;
    }

    while (dayCounter <= daysInMonth) {
      final day = dayCounter;
      final date = UpcomingCalendarUtils.monthDate(displayMonth, day);
      final hasTasks = tasksByDate.containsKey(date);
      final isToday = DateUtils.isSameDay(now, date);
      final isSelected = DateUtils.isSameDay(selectedDay, date);

      currentWeekCells.add(
        Expanded(
          child: GestureDetector(
            onTap: hasTasks ? () => onDateTap(date) : null,
            child: CalendarDayCell(day: day, hasTasks: hasTasks, isToday: isToday, isSelected: isSelected),
          ),
        ),
      );

      cellIndex++;
      dayCounter++;

      if (cellIndex % 7 == 0) {
        weeks.add(Row(children: currentWeekCells));
        currentWeekCells = [];
      }
    }

    if (currentWeekCells.isNotEmpty) {
      while (currentWeekCells.length < 7) {
        currentWeekCells.add(const Expanded(child: SizedBox.shrink()));
      }
      weeks.add(Row(children: currentWeekCells));
    }

    return Column(children: weeks);
  }
}
