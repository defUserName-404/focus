import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'upcoming_calendar_view_provider.dart';

part 'upcoming_calendar_state_provider.g.dart';

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

@Riverpod(keepAlive: true)
class UpcomingCalendarUiStateNotifier extends _$UpcomingCalendarUiStateNotifier {
  @override
  UpcomingCalendarUiState build() {
    final today = _dateOnly(DateTime.now());
    return UpcomingCalendarUiState(
      displayMonth: DateTime(today.year, today.month),
      displayWeekStart: _startOfWeek(today),
      selectedDay: null,
    );
  }

  void switchView(CalendarViewMode mode, {DateTime? anchor}) {
    final base = _dateOnly(anchor ?? state.selectedDay ?? DateTime.now());

    state = switch (mode) {
      CalendarViewMode.week => state.copyWith(displayWeekStart: _startOfWeek(base), clearSelection: true),
      CalendarViewMode.month => state.copyWith(displayMonth: DateTime(base.year, base.month), clearSelection: true),
    };
  }

  void previousPeriod(CalendarViewMode mode) {
    state = switch (mode) {
      CalendarViewMode.month => state.copyWith(
        displayMonth: DateTime(state.displayMonth.year, state.displayMonth.month - 1),
        clearSelection: true,
      ),
      CalendarViewMode.week => state.copyWith(
        displayWeekStart: state.displayWeekStart.subtract(const Duration(days: 7)),
        clearSelection: true,
      ),
    };
  }

  void nextPeriod(CalendarViewMode mode) {
    state = switch (mode) {
      CalendarViewMode.month => state.copyWith(
        displayMonth: DateTime(state.displayMonth.year, state.displayMonth.month + 1),
        clearSelection: true,
      ),
      CalendarViewMode.week => state.copyWith(
        displayWeekStart: state.displayWeekStart.add(const Duration(days: 7)),
        clearSelection: true,
      ),
    };
  }

  void selectDay(DateTime? day) {
    if (day == null) {
      state = state.copyWith(clearSelection: true);
      return;
    }

    state = state.copyWith(selectedDay: _dateOnly(day));
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  DateTime _startOfWeek(DateTime date) {
    final normalized = _dateOnly(date);
    return normalized.subtract(Duration(days: normalized.weekday - DateTime.monday));
  }
}
