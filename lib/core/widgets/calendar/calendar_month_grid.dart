import 'package:flutter/material.dart';

import '../../utils/date_time_utils.dart';
import 'calendar_day_cell.dart';
import 'calendar_day_info.dart';

class CalendarMonthGrid<T extends Object> extends StatelessWidget {
  final DateTime displayMonth;
  final int daysInMonth;
  final int firstWeekday;
  final Map<DateTime, CalendarDayInfo> dayInfo;
  final DateTime now;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDateTap;
  final void Function(DateTime date, T data)? onAcceptDrop;

  const CalendarMonthGrid({
    super.key,
    required this.displayMonth,
    required this.daysInMonth,
    required this.firstWeekday,
    required this.dayInfo,
    required this.now,
    required this.selectedDay,
    required this.onDateTap,
    this.onAcceptDrop,
  });

  DateTime _monthDate(int day) => DateTime(displayMonth.year, displayMonth.month, day);

  Widget _wrapCell({required DateTime date, required Widget child, required bool hasEvents}) {
    final cell = GestureDetector(onTap: hasEvents || onAcceptDrop != null ? () => onDateTap(date) : null, child: child);

    final accept = onAcceptDrop;
    if (accept == null) return cell;

    return DragTarget<T>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => accept(date, details.data),
      builder: (context, candidateData, _) {
        final hovering = candidateData.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: hovering ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5) : null,
          ),
          child: cell,
        );
      },
    );
  }

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
      final date = _monthDate(day);
      final key = DateTimeUtils.dateOnly(date);
      final info = dayInfo[key] ?? const CalendarDayInfo();
      final isToday = DateUtils.isSameDay(now, date);
      final isSelected = DateUtils.isSameDay(selectedDay, date);

      currentWeekCells.add(
        Expanded(
          child: _wrapCell(
            date: key,
            hasEvents: info.hasEvents,
            child: CalendarDayCell(
              day: day,
              hasTasks: info.hasTasks,
              hasSessions: info.hasSessions,
              isToday: isToday,
              isSelected: isSelected,
            ),
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
