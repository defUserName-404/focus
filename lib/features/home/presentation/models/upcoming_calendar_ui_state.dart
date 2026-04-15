import 'package:flutter/foundation.dart';

@immutable
class UpcomingCalendarUiState {
  final DateTime displayMonth;
  final DateTime displayWeekStart;
  final DateTime? selectedDay;

  const UpcomingCalendarUiState({
    required this.displayMonth,
    required this.displayWeekStart,
    required this.selectedDay,
  });

  UpcomingCalendarUiState copyWith({
    DateTime? displayMonth,
    DateTime? displayWeekStart,
    DateTime? selectedDay,
    bool clearSelection = false,
  }) {
    return UpcomingCalendarUiState(
      displayMonth: displayMonth ?? this.displayMonth,
      displayWeekStart: displayWeekStart ?? this.displayWeekStart,
      selectedDay: clearSelection ? null : (selectedDay ?? this.selectedDay),
    );
  }
}
