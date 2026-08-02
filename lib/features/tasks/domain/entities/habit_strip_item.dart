import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'task.dart';

/// Compact habit summary for the home habits strip.
@immutable
class HabitStripItem extends Equatable {
  final Task task;
  final bool completedToday;
  final int currentStreak;
  final bool dueToday;

  const HabitStripItem({
    required this.task,
    required this.completedToday,
    required this.currentStreak,
    required this.dueToday,
  });

  @override
  List<Object?> get props => [task, completedToday, currentStreak, dueToday];
}
