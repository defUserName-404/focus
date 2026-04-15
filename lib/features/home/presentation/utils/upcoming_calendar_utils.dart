import '../../../../core/constants/date_time_constants.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../tasks/domain/entities/task.dart';
import '../models/upcoming_calendar_ui_state.dart';
import '../providers/upcoming_calendar_view_provider.dart';

abstract final class UpcomingCalendarUtils {
  static DateTime normalizeDate(DateTime date) {
    return DateTimeUtils.dateOnly(date);
  }

  static DateTime today() {
    return DateTimeUtils.dateOnly(DateTimeUtils.now());
  }

  static bool isDateVisibleInCurrentView({
    required CalendarViewMode viewMode,
    required UpcomingCalendarUiState uiState,
    required DateTime date,
  }) {
    if (viewMode == CalendarViewMode.month) {
      return date.year == uiState.displayMonth.year && date.month == uiState.displayMonth.month;
    }

    final weekEnd = DateTimeUtils.addDays(uiState.displayWeekStart, 6);
    return !date.isBefore(uiState.displayWeekStart) && !date.isAfter(weekEnd);
  }

  static DateTime? effectiveSelectedDay({
    required CalendarViewMode viewMode,
    required UpcomingCalendarUiState uiState,
    required Map<DateTime, List<Task>> tasksByDate,
    required DateTime today,
  }) {
    final selected = uiState.selectedDay;

    if (selected != null &&
        tasksByDate.containsKey(selected) &&
        isDateVisibleInCurrentView(viewMode: viewMode, uiState: uiState, date: selected)) {
      return selected;
    }

    if (selected == null &&
        tasksByDate.containsKey(today) &&
        isDateVisibleInCurrentView(viewMode: viewMode, uiState: uiState, date: today)) {
      return today;
    }

    return null;
  }

  static Map<DateTime, List<Task>> groupTasksByDate(List<Task> tasks) {
    final map = <DateTime, List<Task>>{};
    for (final task in tasks) {
      final end = task.endDate;
      if (end != null) {
        final key = normalizeDate(end);
        map.putIfAbsent(key, () => []).add(task);
      }
    }

    for (final dateTasks in map.values) {
      dateTasks.sort((a, b) {
        final aEnd = a.endDate;
        final bEnd = b.endDate;
        if (aEnd == null && bEnd == null) return 0;
        if (aEnd == null) return -1;
        if (bEnd == null) return 1;
        return aEnd.compareTo(bEnd);
      });
    }

    return map;
  }

  static DateTime resolveViewAnchor({DateTime? selectedDay, DateTime? uiSelectedDay}) {
    return selectedDay ?? uiSelectedDay ?? DateTimeUtils.now();
  }

  static String periodLabel({
    required CalendarViewMode viewMode,
    required DateTime displayMonth,
    required DateTime displayWeekStart,
  }) {
    if (viewMode == CalendarViewMode.month) {
      final monthName = DateTimeConstants.shortMonthNames[displayMonth.month - 1];
      return '$monthName ${displayMonth.year}';
    }

    final weekEnd = DateTimeUtils.addDays(displayWeekStart, 6);
    return '${displayWeekStart.toShortDateString()} - ${weekEnd.toShortDateString()}';
  }

  static int daysInMonth(DateTime displayMonth) {
    return DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
  }

  static int firstWeekday(DateTime displayMonth) {
    return DateTime(displayMonth.year, displayMonth.month, 1).weekday;
  }

  static DateTime monthDate(DateTime displayMonth, int day) {
    return DateTime(displayMonth.year, displayMonth.month, day);
  }

  static List<DateTime> weekDays(DateTime weekStart) {
    return List.generate(7, (index) => DateTimeUtils.addDays(weekStart, index));
  }

  static bool isTaskOverdue(Task task) {
    return task.endDate != null && DateTimeUtils.isBeforeNow(task.endDate!);
  }
}
