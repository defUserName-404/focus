import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  /// Strips time components, returning midnight of the same date.
  DateTime toDateOnly() => DateTime(year, month, day);

  /// Converts epoch seconds (as stored by Drift) to a date-only DateTime.
  ///
  /// Returns a UTC midnight [DateTime] using the local-timezone calendar date.
  /// UTC normalisation guarantees consistent [==] / [hashCode] when used as
  /// [Map] keys, avoiding subtle DST-related mismatches.
  static DateTime fromEpochSecondsToDateOnly(int epochSeconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

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
