import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/tasks/domain/entities/daily_session_stats.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/services/calendar_event_grouping.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('CalendarEventGrouping.groupTasksByDate', () {
    test('keys non-recurring tasks by endDate within window', () {
      final tasks = [
        buildTask(id: 1, title: 'A', endDate: DateTime(2026, 8, 2, 10)),
        buildTask(id: 2, title: 'B', endDate: DateTime(2026, 8, 5, 10)),
        buildTask(id: 3, title: 'Out', endDate: DateTime(2026, 9, 1)),
      ];

      final map = CalendarEventGrouping.groupTasksByDate(
        tasks: tasks,
        from: DateTime(2026, 8, 1),
        to: DateTime(2026, 8, 7),
      );

      expect(map.keys, containsAll([DateTime(2026, 8, 2), DateTime(2026, 8, 5)]));
      expect(map.containsKey(DateTime(2026, 9, 1)), isFalse);
      expect(map[DateTime(2026, 8, 2)]!.single.title, 'A');
    });

    test('expands recurring tasks into the window', () {
      final task = buildTask(
        id: 10,
        title: 'Habit',
        endDate: null,
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceAnchorDate: DateTime(2026, 8, 1, 8),
        startDate: DateTime(2026, 8, 1, 8),
      );

      final map = CalendarEventGrouping.groupTasksByDate(
        tasks: [task],
        from: DateTime(2026, 8, 2),
        to: DateTime(2026, 8, 4),
      );

      expect(map.keys.toSet(), {DateTime(2026, 8, 2), DateTime(2026, 8, 3), DateTime(2026, 8, 4)});
      expect(map[DateTime(2026, 8, 3)]!.single.id, 10);
    });
  });

  group('CalendarEventGrouping.sessionCountsByDate', () {
    test('maps completed session counts by ISO date', () {
      final counts = CalendarEventGrouping.sessionCountsByDate(const [
        DailySessionStats(date: '2026-08-02', completedSessions: 2, totalSessions: 2, focusSeconds: 1200),
        DailySessionStats(date: '2026-08-03', completedSessions: 0, totalSessions: 1, focusSeconds: 0),
      ]);

      expect(counts[DateTime(2026, 8, 2)], 2);
      expect(counts.containsKey(DateTime(2026, 8, 3)), isFalse);
    });
  });
}
