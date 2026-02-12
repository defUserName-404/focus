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
}
