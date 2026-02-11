import 'package:intl/intl.dart';

class DateTimeFormatter {
  const DateTimeFormatter._();

  static String formatDate(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);
}
