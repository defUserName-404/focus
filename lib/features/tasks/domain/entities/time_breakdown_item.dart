import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Named focus-time bucket used for project or tag breakdowns.
@immutable
class TimeBreakdownItem extends Equatable {
  final int id;
  final String name;
  final int focusSeconds;
  final int? color;

  const TimeBreakdownItem({required this.id, required this.name, required this.focusSeconds, this.color});

  int get focusMinutes => focusSeconds ~/ 60;

  double get focusHours => focusSeconds / 3600;

  @override
  List<Object?> get props => [id, name, focusSeconds, color];
}
