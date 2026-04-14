enum TaskReminderMode {
  smart,
  weekBefore,
  dayBefore,
  custom,
  none;

  String get label {
    switch (this) {
      case TaskReminderMode.smart:
        return 'Smart';
      case TaskReminderMode.weekBefore:
        return '1 week before';
      case TaskReminderMode.dayBefore:
        return '1 day before';
      case TaskReminderMode.custom:
        return 'Custom';
      case TaskReminderMode.none:
        return 'None';
    }
  }
}
