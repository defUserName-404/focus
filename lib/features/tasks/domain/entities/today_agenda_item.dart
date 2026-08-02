import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'task.dart';

/// Why a task appears on Today's Agenda.
enum TodayAgendaKind {
  /// Non-recurring task whose deadline is before today.
  overdue,

  /// Non-recurring task whose deadline is today.
  dueToday,

  /// Habit occurrence expanded for today via [RecurrenceExpander].
  habitOccurrence,
}

/// One actionable row in Today's Agenda.
@immutable
class TodayAgendaItem extends Equatable {
  final Task task;
  final TodayAgendaKind kind;

  /// Occurrence date for habit rows; deadline date for one-shot rows.
  final DateTime occurrenceDate;

  /// Whether the checkbox should appear checked (habit completion or task done).
  final bool isCompleted;

  const TodayAgendaItem({
    required this.task,
    required this.kind,
    required this.occurrenceDate,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [task, kind, occurrenceDate, isCompleted];
}
