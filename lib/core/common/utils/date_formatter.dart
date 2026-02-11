import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toDateString() => DateFormat('MMM d, yyyy').format(this);

  String toShortDateString() => DateFormat('MMM d').format(this);

  bool get isOverdue => isBefore(DateTime.now()) && !isToday;

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  String toRelativeDueString() {
    final now = DateTime.now();
    final difference = this.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue ${difference.abs()}d';
    } else if (isToday) {
      return 'Due today';
    } else if (isTomorrow) {
      return 'Due tomorrow';
    } else {
      return 'Due in ${difference + 1}d';
    }
  }

  String toRelativeStartString() {
    return 'Start: ${toShortDateString()}';
  }
}
