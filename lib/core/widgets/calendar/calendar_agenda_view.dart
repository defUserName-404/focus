import 'package:flutter/material.dart';

import '../../config/theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../constants/date_time_constants.dart';
import '../../utils/date_time_utils.dart';
import 'calendar_day_info.dart';

/// Day/agenda list for a selected calendar day.
class CalendarAgendaView<T extends Object> extends StatelessWidget {
  final DateTime selectedDay;
  final CalendarDayInfo dayInfo;
  final List<Widget> taskTiles;
  final Widget? emptyTasks;
  final void Function(T data)? onAcceptDrop;

  const CalendarAgendaView({
    super.key,
    required this.selectedDay,
    required this.dayInfo,
    required this.taskTiles,
    this.emptyTasks,
    this.onAcceptDrop,
  });

  @override
  Widget build(BuildContext context) {
    final weekday = DateTimeConstants.shortWeekdayNames[selectedDay.weekday - 1];
    final month = DateTimeConstants.shortMonthNames[selectedDay.month - 1];
    final isToday = DateUtils.isSameDay(selectedDay, DateTimeUtils.now());

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '$weekday, $month ${selectedDay.day}',
              style: context.typography.sm.copyWith(fontWeight: FontWeight.w700),
            ),
            if (isToday) ...[
              SizedBox(width: AppConstants.spacing.small),
              Text('Today', style: context.typography.xs.copyWith(color: context.colors.primary)),
            ],
            const Spacer(),
            if (dayInfo.sessionCount > 0)
              Text(
                '${dayInfo.sessionCount} focus session${dayInfo.sessionCount == 1 ? '' : 's'}',
                style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
              ),
          ],
        ),
        SizedBox(height: AppConstants.spacing.small),
        if (taskTiles.isEmpty)
          emptyTasks ??
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.large),
                child: Text(
                  'No tasks for this day',
                  style: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                  textAlign: TextAlign.center,
                ),
              )
        else
          ...taskTiles,
      ],
    );

    final accept = onAcceptDrop;
    if (accept == null) return body;

    return DragTarget<T>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => accept(details.data),
      builder: (context, candidateData, _) {
        final hovering = candidateData.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
            border: hovering ? Border.all(color: context.colors.primary, width: 1.5) : null,
          ),
          child: Padding(padding: EdgeInsets.all(AppConstants.spacing.small), child: body),
        );
      },
    );
  }
}
