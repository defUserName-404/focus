import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/entities/today_agenda_item.dart';
import 'package:focus/features/tasks/domain/services/today_agenda_builder.dart';

import '../../helpers/fixtures.dart';

void main() {
  final today = DateTime(2026, 8, 2);

  group('TodayAgendaBuilder.buildAgenda', () {
    test('includes overdue and due-today one-shot tasks', () {
      final overdue = buildTask(id: 1, title: 'Late', endDate: DateTime(2026, 7, 30));
      final dueToday = buildTask(id: 2, title: 'Today', endDate: DateTime(2026, 8, 2, 18));
      final future = buildTask(id: 3, title: 'Later', endDate: DateTime(2026, 8, 5));

      final items = TodayAgendaBuilder.buildAgenda(
        tasks: [overdue, dueToday, future],
        completionsByTaskId: const {},
        today: today,
      );

      expect(items.map((i) => i.task.id), [1, 2]);
      expect(items[0].kind, TodayAgendaKind.overdue);
      expect(items[1].kind, TodayAgendaKind.dueToday);
    });

    test('includes habit occurrences expanded for today', () {
      final habit = buildTask(
        id: 10,
        title: 'Meditate',
        endDate: null,
        isHabit: true,
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceAnchorDate: DateTime(2026, 8, 1),
        startDate: DateTime(2026, 8, 1),
      );

      final items = TodayAgendaBuilder.buildAgenda(tasks: [habit], completionsByTaskId: const {}, today: today);

      expect(items, hasLength(1));
      expect(items.single.kind, TodayAgendaKind.habitOccurrence);
      expect(items.single.isCompleted, isFalse);
    });

    test('marks habit complete when completion exists for today', () {
      final habit = buildTask(
        id: 10,
        title: 'Meditate',
        endDate: null,
        isHabit: true,
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceAnchorDate: DateTime(2026, 8, 1),
      );

      final items = TodayAgendaBuilder.buildAgenda(
        tasks: [habit],
        completionsByTaskId: {
          10: [buildCompletion(taskId: 10, occurrenceDate: today)],
        },
        today: today,
      );

      expect(items.single.isCompleted, isTrue);
    });

    test('skips non-habit recurring tasks without deadline kind', () {
      final recurring = buildTask(
        id: 5,
        title: 'Standup',
        endDate: null,
        isHabit: false,
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, byWeekday: [DateTime.sunday]),
        recurrenceAnchorDate: DateTime(2026, 8, 2),
      );

      final items = TodayAgendaBuilder.buildAgenda(tasks: [recurring], completionsByTaskId: const {}, today: today);

      expect(items, isEmpty);
    });
  });

  group('TodayAgendaBuilder.buildHabitStrip', () {
    test('computes streak and dueToday for habits', () {
      final habit = buildTask(
        id: 10,
        title: 'Walk',
        endDate: null,
        isHabit: true,
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceAnchorDate: DateTime(2026, 7, 30),
      );

      final items = TodayAgendaBuilder.buildHabitStrip(
        tasks: [habit],
        completionsByTaskId: {
          10: [
            buildCompletion(id: 1, taskId: 10, occurrenceDate: DateTime(2026, 7, 31)),
            buildCompletion(id: 2, taskId: 10, occurrenceDate: DateTime(2026, 8, 1)),
          ],
        },
        today: today,
      );

      expect(items, hasLength(1));
      expect(items.single.dueToday, isTrue);
      expect(items.single.completedToday, isFalse);
      expect(items.single.currentStreak, 2);
    });
  });
}
