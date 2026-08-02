import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/services/recurrence_expander.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('RecurrenceExpander.expand', () {
    test('returns empty list when task has no recurrence rule', () {
      final task = buildTask(recurrenceRule: null);
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 1), DateTime(2026, 8, 31));
      expect(result, isEmpty);
    });

    test('expands daily occurrences within the window', () {
      final task = buildTask(
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceAnchorDate: DateTime(2026, 8, 1, 9),
        startDate: DateTime(2026, 8, 1, 9),
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 2), DateTime(2026, 8, 4));
      expect(result, [DateTime(2026, 8, 2, 9), DateTime(2026, 8, 3, 9), DateTime(2026, 8, 4, 9)]);
    });

    test('respects daily interval', () {
      final task = buildTask(
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily, interval: 2),
        recurrenceAnchorDate: DateTime(2026, 8, 1),
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 1), DateTime(2026, 8, 7));
      expect(result.map((d) => d.day).toList(), [1, 3, 5, 7]);
    });

    test('respects count limit', () {
      final task = buildTask(
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 3),
        recurrenceAnchorDate: DateTime(2026, 8, 1),
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 1), DateTime(2026, 8, 31));
      expect(result, hasLength(3));
      expect(result.last.day, 3);
    });

    test('respects until date', () {
      final task = buildTask(
        recurrenceRule: RecurrenceRule(frequency: RecurrenceFrequency.daily, until: DateTime(2026, 8, 3)),
        recurrenceAnchorDate: DateTime(2026, 8, 1),
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 1), DateTime(2026, 8, 31));
      expect(result.map((d) => d.day).toList(), [1, 2, 3]);
    });

    test('expands weekly on selected weekdays', () {
      final task = buildTask(
        recurrenceRule: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          byWeekday: [DateTime.monday, DateTime.wednesday, DateTime.friday],
        ),
        // Saturday Aug 1 2026
        recurrenceAnchorDate: DateTime(2026, 8, 1),
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 1), DateTime(2026, 8, 14));
      expect(result.map((d) => d.weekday).toSet(), {DateTime.monday, DateTime.wednesday, DateTime.friday});
      expect(result.first, DateTime(2026, 8, 3)); // first Mon after anchor
    });

    test('expands weekly with interval of 2 weeks', () {
      final task = buildTask(
        recurrenceRule: const RecurrenceRule(
          frequency: RecurrenceFrequency.weekly,
          interval: 2,
          byWeekday: [DateTime.monday],
        ),
        recurrenceAnchorDate: DateTime(2026, 8, 3), // Mon
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 3), DateTime(2026, 8, 31));
      expect(result.map((d) => d.day).toList(), [3, 17, 31]);
    });

    test('expands monthly clamping to last day of short months', () {
      final task = buildTask(
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.monthly, byMonthDay: 31),
        recurrenceAnchorDate: DateTime(2026, 1, 31),
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 1, 1), DateTime(2026, 4, 30));
      expect(result, [DateTime(2026, 1, 31), DateTime(2026, 2, 28), DateTime(2026, 3, 31), DateTime(2026, 4, 30)]);
    });

    test('excludes occurrences before the window', () {
      final task = buildTask(
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceAnchorDate: DateTime(2026, 7, 1),
        endDate: null,
      );
      final result = RecurrenceExpander.expand(task, DateTime(2026, 8, 1), DateTime(2026, 8, 2));
      expect(result, [DateTime(2026, 8, 1), DateTime(2026, 8, 2)]);
    });
  });
}
