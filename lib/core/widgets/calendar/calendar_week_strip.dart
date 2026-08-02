import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../utils/date_time_utils.dart';
import 'calendar_day_info.dart';
import 'calendar_week_day_cell.dart';

class CalendarWeekStrip<T extends Object> extends StatelessWidget {
  final DateTime weekStart;
  final Map<DateTime, CalendarDayInfo> dayInfo;
  final DateTime now;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDateTap;
  final void Function(DateTime date, T data)? onAcceptDrop;

  const CalendarWeekStrip({
    super.key,
    required this.weekStart,
    required this.dayInfo,
    required this.now,
    required this.selectedDay,
    required this.onDateTap,
    this.onAcceptDrop,
  });

  List<DateTime> get _days => List.generate(7, (index) => DateTimeUtils.addDays(weekStart, index));

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
            borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
            border: hovering ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5) : null,
          ),
          child: cell,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;

    return Row(
      children: [
        for (var index = 0; index < days.length; index++) ...[
          Expanded(
            child: Builder(
              builder: (context) {
                final date = DateTimeUtils.dateOnly(days[index]);
                final info = dayInfo[date] ?? const CalendarDayInfo();
                return _wrapCell(
                  date: date,
                  hasEvents: info.hasEvents,
                  child: CalendarWeekDayCell(
                    date: days[index],
                    taskCount: info.taskCount,
                    sessionCount: info.sessionCount,
                    isToday: DateUtils.isSameDay(days[index], now),
                    isSelected: DateUtils.isSameDay(days[index], selectedDay),
                  ),
                );
              },
            ),
          ),
          if (index < days.length - 1) SizedBox(width: AppConstants.spacing.extraSmall),
        ],
      ],
    );
  }
}
