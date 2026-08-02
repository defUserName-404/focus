import 'package:meta/meta.dart';

/// Lightweight day markers for shared calendar cells.
@immutable
class CalendarDayInfo {
  final int taskCount;
  final int sessionCount;

  const CalendarDayInfo({this.taskCount = 0, this.sessionCount = 0});

  bool get hasTasks => taskCount > 0;
  bool get hasSessions => sessionCount > 0;
  bool get hasEvents => hasTasks || hasSessions;

  CalendarDayInfo copyWith({int? taskCount, int? sessionCount}) {
    return CalendarDayInfo(taskCount: taskCount ?? this.taskCount, sessionCount: sessionCount ?? this.sessionCount);
  }
}
