abstract final class DateTimeUtils {
  static DateTime now() => DateTime.now();

  /// Local calendar date at midnight (never UTC).
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Rebuilds [dateTime] as a non-UTC local wall-clock value.
  ///
  /// ForUI date pickers may return UTC midnight; Drift stores absolute ms, so
  /// UTC values shift by the device offset when displayed locally.
  static DateTime toLocalWallClock(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
      dateTime.millisecond,
      dateTime.microsecond,
    );
  }

  /// Combines a calendar [date] with hours/minutes into a local DateTime.
  static DateTime combineLocalDateAndTime(DateTime date, {int hour = 0, int minute = 0}) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static DateTime? normalizeLocal(DateTime? dateTime) {
    if (dateTime == null) return null;
    return toLocalWallClock(dateTime);
  }

  static DateTime addDays(DateTime dateTime, int days) {
    return dateTime.add(Duration(days: days));
  }

  static bool isBeforeNow(DateTime dateTime) {
    return dateTime.isBefore(now());
  }

  static bool isApproaching(DateTime dateTime, {int withinDays = 3}) {
    return dateTime.difference(now()).inDays <= withinDays;
  }
}
