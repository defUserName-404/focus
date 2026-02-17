import 'package:focus/core/constants/date_time_constants.dart';

extension DateTimeFormattingExtensions on DateTime {
  String toDateString() {
    final m = DateTimeConstants.shortMonthNames[month - 1];
    return '$m $day, $year';
  }

  String toShortDateString() {
    final m = DateTimeConstants.shortMonthNames[month - 1];
    return '$m $day';
  }

  String toShortDateKey() {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  bool get isOverdue => isBefore(DateTime.now()) && !isToday;

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
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

extension MinutesFormatting on int {
  /// Formats minutes as 'Xm' or 'Yh Zm' if >= 60.
  String toHourMinuteString() {
    if (this < 60) return '${this}m';
    final hours = this ~/ 60;
    final mins = this % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

extension DoubleMinutesFormatting on double {
  /// Formats double minutes as rounded 'Xm'.
  String toMinuteString() => '${round()}m';
}

class DateTimeExtensions {
  static int weekIndex(DateTime date, DateTime jan1) {
    final firstMonday = jan1.subtract(Duration(days: (jan1.weekday - 1) % 7));
    return date.difference(firstMonday).inDays ~/ 7;
  }

  static DateTime getFirstMonday(int year) {
    final jan1 = DateTime(year, 1, 1);
    return jan1.subtract(Duration(days: (jan1.weekday - 1) % 7));
  }

  /// gets the short name for the month
  static String shortMonth(int month) {
    return DateTimeConstants.shortMonthNames[month - 1];
  }

  static String shortDateString(String dateKey) {
    final date = DateTime.parse(dateKey);
    final m = DateTimeConstants.shortMonthNames[date.month - 1];
    return '$m ${date.day}';
  }
}

extension DateMinutesFormatting on int {
  String get formatMinutesToMinuteAndSeconds => '${toString().padLeft(2, '0')}:${toString().padLeft(2, '0')}';
}
