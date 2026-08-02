import '../entities/task.dart';
import '../entities/task_reminder_mode.dart';
import 'recurrence_expander.dart';

/// Pure reminder-time planner for one-shot and recurring tasks.
class TaskReminderPlanner {
  const TaskReminderPlanner._();

  /// How many upcoming occurrences to schedule reminders for.
  static const int rollingWindowSize = 5;

  /// Horizon used when expanding recurring occurrences for reminders.
  static const Duration rollingHorizon = Duration(days: 90);

  /// Single reminder for a non-recurring task (or the next one for recurring).
  static DateTime? computeReminderTime(Task task, {DateTime? now}) {
    final times = computeReminderTimes(task, now: now, windowSize: 1);
    return times.isEmpty ? null : times.first;
  }

  /// Rolling window of reminder times for [task].
  ///
  /// Non-recurring tasks yield 0–1 entries based on [Task.endDate].
  /// Recurring tasks expand the next [windowSize] occurrences and apply the
  /// same lead logic relative to each occurrence datetime.
  static List<DateTime> computeReminderTimes(
    Task task, {
    DateTime? now,
    int windowSize = rollingWindowSize,
  }) {
    if (task.id == null || task.reminderMode == TaskReminderMode.none) {
      return const [];
    }

    final effectiveNow = now ?? DateTime.now();

    if (task.isRecurring) {
      return _recurringReminders(task, effectiveNow, windowSize);
    }

    if (task.isCompleted) return const [];
    final deadline = task.endDate;
    if (deadline == null) return const [];

    final reminder = _reminderForDeadline(task, deadline, effectiveNow);
    return reminder == null ? const [] : [reminder];
  }

  static List<DateTime> _recurringReminders(Task task, DateTime now, int windowSize) {
    if (windowSize <= 0) return const [];

    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(rollingHorizon);
    final occurrences = RecurrenceExpander.expand(task, from, to)
        .where((o) => !o.isBefore(now))
        .take(windowSize)
        .toList();

    final reminders = <DateTime>[];
    for (final occurrence in occurrences) {
      final reminder = _reminderForDeadline(task, occurrence, now);
      if (reminder != null) reminders.add(reminder);
    }
    return reminders;
  }

  static DateTime? _reminderForDeadline(Task task, DateTime deadline, DateTime now) {
    final lead = _leadDuration(task, deadline: deadline, now: now);
    if (lead == null) return null;

    final reminderTime = deadline.subtract(lead);
    // If the planned reminder is already in the past, schedule immediately.
    return reminderTime.isAfter(now) ? reminderTime : now.add(const Duration(seconds: 2));
  }

  static Duration? _leadDuration(Task task, {required DateTime deadline, DateTime? now}) {
    switch (task.reminderMode) {
      case TaskReminderMode.weekBefore:
        return const Duration(days: 7);
      case TaskReminderMode.dayBefore:
        return const Duration(days: 1);
      case TaskReminderMode.custom:
        final minutes = task.customReminderMinutesBefore;
        if (minutes == null || minutes <= 0) return null;
        return Duration(minutes: minutes);
      case TaskReminderMode.none:
        return null;
      case TaskReminderMode.smart:
        return _smartLead(task, deadline: deadline, now: now);
    }
  }

  static Duration _smartLead(Task task, {required DateTime deadline, DateTime? now}) {
    final referenceStart = task.recurrenceAnchorDate ?? task.startDate ?? task.createdAt;
    final span = deadline.difference(referenceStart);

    if (span >= const Duration(days: 7)) {
      return const Duration(days: 7);
    }

    final effectiveNow = now ?? DateTime.now();
    final remaining = deadline.difference(effectiveNow);
    if (remaining >= const Duration(days: 7)) {
      return const Duration(days: 7);
    }

    return const Duration(days: 1);
  }
}
