import '../entities/task.dart';
import '../entities/task_reminder_mode.dart';

class TaskReminderPlanner {
  const TaskReminderPlanner._();

  static DateTime? computeReminderTime(Task task, {DateTime? now}) {
    final deadline = task.endDate;
    if (task.id == null || deadline == null || task.isCompleted || task.reminderMode == TaskReminderMode.none) {
      return null;
    }

    final lead = _leadDuration(task, now: now);
    if (lead == null) return null;

    final effectiveNow = now ?? DateTime.now();
    final reminderTime = deadline.subtract(lead);

    // If the planned reminder is already in the past, schedule immediately.
    return reminderTime.isAfter(effectiveNow) ? reminderTime : effectiveNow.add(const Duration(seconds: 2));
  }

  static Duration? _leadDuration(Task task, {DateTime? now}) {
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
        return _smartLead(task, now: now);
    }
  }

  static Duration _smartLead(Task task, {DateTime? now}) {
    final deadline = task.endDate!;
    final referenceStart = task.startDate ?? task.createdAt;
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
