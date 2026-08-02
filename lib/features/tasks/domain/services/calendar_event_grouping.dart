import '../../../../core/utils/date_time_utils.dart';
import '../entities/daily_session_stats.dart';
import '../entities/task.dart';
import 'recurrence_expander.dart';

/// Groups tasks (including expanded recurrence) and session stats by local date.
abstract final class CalendarEventGrouping {
  /// Maps each local date in `[from, to]` to tasks due / occurring that day.
  ///
  /// Recurring tasks are expanded via [RecurrenceExpander]. Non-recurring tasks
  /// are keyed by [Task.endDate] when present.
  static Map<DateTime, List<Task>> groupTasksByDate({
    required List<Task> tasks,
    required DateTime from,
    required DateTime to,
  }) {
    final windowStart = DateTimeUtils.dateOnly(from);
    final windowEnd = DateTimeUtils.dateOnly(to);
    final map = <DateTime, List<Task>>{};

    for (final task in tasks) {
      if (task.recurrenceRule != null) {
        for (final occurrence in RecurrenceExpander.expand(task, windowStart, windowEnd)) {
          final key = DateTimeUtils.dateOnly(occurrence);
          map.putIfAbsent(key, () => []).add(task);
        }
        continue;
      }

      final end = task.endDate;
      if (end == null) continue;
      final key = DateTimeUtils.dateOnly(end);
      if (key.isBefore(windowStart) || key.isAfter(windowEnd)) continue;
      map.putIfAbsent(key, () => []).add(task);
    }

    for (final dateTasks in map.values) {
      dateTasks.sort((a, b) {
        final aEnd = a.endDate;
        final bEnd = b.endDate;
        if (aEnd == null && bEnd == null) return a.title.compareTo(b.title);
        if (aEnd == null) return -1;
        if (bEnd == null) return 1;
        final cmp = aEnd.compareTo(bEnd);
        if (cmp != 0) return cmp;
        return a.title.compareTo(b.title);
      });
    }

    return map;
  }

  /// Maps ISO date stats into local [DateTime] keys with completed session counts.
  static Map<DateTime, int> sessionCountsByDate(List<DailySessionStats> stats) {
    final map = <DateTime, int>{};
    for (final stat in stats) {
      if (stat.completedSessions <= 0 || stat.date.isEmpty) continue;
      final parsed = DateTime.tryParse(stat.date);
      if (parsed == null) continue;
      map[DateTimeUtils.dateOnly(parsed)] = stat.completedSessions;
    }
    return map;
  }
}
