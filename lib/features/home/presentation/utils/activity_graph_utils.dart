import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/datetime_formatter.dart';

class ActivityGraphUtils {
  static String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static double getIntensity(int sessions) {
    if (sessions <= 0) return 0;
    if (sessions == 1) return 0.25;
    if (sessions == 2) return 0.50;
    if (sessions <= 4) return 0.75;
    return 1.0;
  }

  static DateTime today() {
    return DateTimeUtils.dateOnly(DateTimeUtils.now());
  }

  static List<int> selectableYears({required int startYear}) {
    final currentYear = DateTimeUtils.now().year;
    return List.generate(currentYear - (startYear - 1), (i) => currentYear - i);
  }

  static int weekIndexForToday(int year) {
    final todayDate = today();
    if (todayDate.year != year) return 0;
    final jan1 = DateTime(year, 1, 1);
    final dayOfYear = todayDate.difference(jan1).inDays;
    return (dayOfYear + (jan1.weekday - 1)) ~/ 7;
  }

  static DateTime dateFromGridCell({required int year, required int weekCol, required int dayRow}) {
    final firstMonday = DateTimeExtensions.getFirstMonday(year);
    return DateTimeUtils.addDays(firstMonday, weekCol * 7 + dayRow);
  }

  static bool isFutureDate(DateTime date) {
    return date.isAfter(today());
  }
}
