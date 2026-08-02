import '../../../../core/utils/date_time_utils.dart';
import '../entities/habit_strip_item.dart';
import '../entities/task.dart';
import '../entities/task_completion.dart';
import '../entities/today_agenda_item.dart';
import 'habit_streak_calculator.dart';
import 'recurrence_expander.dart';

/// Pure builder for Today's Agenda and the habits strip.
///
/// Combines deadline tasks with [RecurrenceExpander] habit occurrences and
/// completion logs — no I/O.
abstract final class TodayAgendaBuilder {
  /// Builds a merged, ordered agenda for [today].
  ///
  /// Order: overdue → due today → incomplete habit occurrences → completed habits.
  static List<TodayAgendaItem> buildAgenda({
    required List<Task> tasks,
    required Map<int, List<TaskCompletion>> completionsByTaskId,
    required DateTime today,
  }) {
    final day = DateTimeUtils.dateOnly(today);
    final items = <TodayAgendaItem>[];

    for (final task in tasks) {
      if (task.isHabit && task.recurrenceRule != null) {
        final occurrences = RecurrenceExpander.expand(task, day, day);
        if (occurrences.isEmpty) continue;

        final occurrenceDate = DateTimeUtils.dateOnly(occurrences.first);
        final completed = _isCompletedOn(completionsByTaskId[task.id] ?? const [], occurrenceDate);
        items.add(
          TodayAgendaItem(
            task: task,
            kind: TodayAgendaKind.habitOccurrence,
            occurrenceDate: occurrenceDate,
            isCompleted: completed,
          ),
        );
        continue;
      }

      if (task.isRecurring) continue;

      final end = task.endDate;
      if (end == null) continue;
      final endDay = DateTimeUtils.dateOnly(end);

      if (endDay.isBefore(day)) {
        items.add(
          TodayAgendaItem(
            task: task,
            kind: TodayAgendaKind.overdue,
            occurrenceDate: endDay,
            isCompleted: task.isCompleted,
          ),
        );
      } else if (endDay == day) {
        items.add(
          TodayAgendaItem(
            task: task,
            kind: TodayAgendaKind.dueToday,
            occurrenceDate: endDay,
            isCompleted: task.isCompleted,
          ),
        );
      }
    }

    items.sort(_compareAgendaItems);
    return items;
  }

  /// Builds strip items for every habit task (whether or not due today).
  static List<HabitStripItem> buildHabitStrip({
    required List<Task> tasks,
    required Map<int, List<TaskCompletion>> completionsByTaskId,
    required DateTime today,
    int streakLookbackDays = 365,
  }) {
    final day = DateTimeUtils.dateOnly(today);
    final windowFrom = day.subtract(Duration(days: streakLookbackDays));
    final items = <HabitStripItem>[];

    for (final task in tasks) {
      if (!task.isHabit || task.recurrenceRule == null || task.id == null) continue;

      final rule = task.recurrenceRule!;
      final anchor = DateTimeUtils.dateOnly(task.recurrenceAnchorDate ?? task.startDate ?? task.createdAt);
      final completions = completionsByTaskId[task.id!] ?? const <TaskCompletion>[];
      final completionDates = completions.map((c) => c.occurrenceDate);

      final streak = HabitStreakCalculator.calculate(
        rule: rule,
        anchor: anchor,
        completionDates: completionDates,
        from: windowFrom,
        to: day,
        now: day,
      );

      final dueToday = RecurrenceExpander.expand(task, day, day).isNotEmpty;
      final completedToday = _isCompletedOn(completions, day);

      items.add(
        HabitStripItem(
          task: task,
          completedToday: completedToday,
          currentStreak: streak.currentStreak,
          dueToday: dueToday,
        ),
      );
    }

    items.sort((a, b) {
      if (a.dueToday != b.dueToday) return a.dueToday ? -1 : 1;
      if (a.completedToday != b.completedToday) return a.completedToday ? 1 : -1;
      return a.task.title.compareTo(b.task.title);
    });

    return items;
  }

  static bool _isCompletedOn(List<TaskCompletion> completions, DateTime day) {
    final key = DateTimeUtils.dateOnly(day);
    for (final c in completions) {
      if (DateTimeUtils.dateOnly(c.occurrenceDate) == key) return true;
    }
    return false;
  }

  static int _compareAgendaItems(TodayAgendaItem a, TodayAgendaItem b) {
    final kindOrder = _kindRank(a.kind).compareTo(_kindRank(b.kind));
    if (kindOrder != 0) return kindOrder;

    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;

    final aTime = a.task.endDate ?? a.occurrenceDate;
    final bTime = b.task.endDate ?? b.occurrenceDate;
    final timeCmp = aTime.compareTo(bTime);
    if (timeCmp != 0) return timeCmp;
    return a.task.title.compareTo(b.task.title);
  }

  static int _kindRank(TodayAgendaKind kind) => switch (kind) {
    TodayAgendaKind.overdue => 0,
    TodayAgendaKind.dueToday => 1,
    TodayAgendaKind.habitOccurrence => 2,
  };
}
