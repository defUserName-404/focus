import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/services/habit_streak_calculator.dart';

void main() {
  group('HabitStreakCalculator', () {
    const daily = RecurrenceRule(frequency: RecurrenceFrequency.daily);
    final anchor = DateTime(2026, 8, 1);

    test('returns zeros when nothing is scheduled in the window', () {
      final result = HabitStreakCalculator.calculate(
        rule: daily,
        anchor: DateTime(2027, 1, 1),
        completionDates: const [],
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 7),
        now: DateTime(2026, 8, 7),
      );
      expect(result.scheduledCount, 0);
      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.completionRate, 0);
    });

    test('computes completion rate from scheduled days only', () {
      final result = HabitStreakCalculator.calculate(
        rule: daily,
        anchor: anchor,
        completionDates: [DateTime(2026, 8, 1), DateTime(2026, 8, 2), DateTime(2026, 8, 4)],
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 4),
        now: DateTime(2026, 8, 4),
      );
      expect(result.scheduledCount, 4);
      expect(result.completedCount, 3);
      expect(result.completionRate, 0.75);
    });

    test('longest streak counts consecutive scheduled completions', () {
      final result = HabitStreakCalculator.calculate(
        rule: daily,
        anchor: anchor,
        completionDates: [
          DateTime(2026, 8, 1),
          DateTime(2026, 8, 2),
          DateTime(2026, 8, 3),
          // miss 4
          DateTime(2026, 8, 5),
          DateTime(2026, 8, 6),
        ],
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 6),
        now: DateTime(2026, 8, 6),
      );
      expect(result.longestStreak, 3);
      expect(result.currentStreak, 2);
    });

    test('current streak ignores incomplete today', () {
      final result = HabitStreakCalculator.calculate(
        rule: daily,
        anchor: anchor,
        completionDates: [DateTime(2026, 8, 1), DateTime(2026, 8, 2), DateTime(2026, 8, 3)],
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 4),
        now: DateTime(2026, 8, 4),
      );
      expect(result.currentStreak, 3);
    });

    test('weekly habit skips non-scheduled days without breaking streak', () {
      const weekly = RecurrenceRule(
        frequency: RecurrenceFrequency.weekly,
        byWeekday: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      );
      // Aug 2026: Mon3, Wed5, Fri7, Mon10, Wed12, Fri14
      final result = HabitStreakCalculator.calculate(
        rule: weekly,
        anchor: DateTime(2026, 8, 3),
        completionDates: [DateTime(2026, 8, 3), DateTime(2026, 8, 5), DateTime(2026, 8, 7), DateTime(2026, 8, 10)],
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 14),
        now: DateTime(2026, 8, 11),
      );
      expect(result.currentStreak, 4);
      expect(result.longestStreak, 4);
      // Tue/Thu gaps do not appear in scheduled set.
      expect(result.scheduledCount, 6);
    });

    test('broken streak resets current but keeps longest', () {
      final result = HabitStreakCalculator.calculate(
        rule: daily,
        anchor: anchor,
        completionDates: [DateTime(2026, 8, 1), DateTime(2026, 8, 2), DateTime(2026, 8, 3), DateTime(2026, 8, 5)],
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 5),
        now: DateTime(2026, 8, 5),
      );
      expect(result.longestStreak, 3);
      expect(result.currentStreak, 1);
    });
  });
}
