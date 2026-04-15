abstract final class DateTimeUtils {
  static DateTime now() => DateTime.now();

  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
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