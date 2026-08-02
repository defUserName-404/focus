import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/entities/task_reminder_mode.dart';
import 'package:focus/features/tasks/domain/services/task_reminder_planner.dart';

import '../../helpers/fixtures.dart';

void main() {
  group('TaskReminderPlanner.computeReminderTime', () {
    test('returns null when task has no id', () {
      final task = buildTask(id: null);
      expect(TaskReminderPlanner.computeReminderTime(task, now: testNow), isNull);
    });

    test('returns null when task has no deadline', () {
      final task = buildTask(endDate: null);
      expect(TaskReminderPlanner.computeReminderTime(task, now: testNow), isNull);
    });

    test('returns null when task is completed', () {
      final task = buildTask(isCompleted: true);
      expect(TaskReminderPlanner.computeReminderTime(task, now: testNow), isNull);
    });

    test('returns null when reminder mode is none', () {
      final task = buildTask(reminderMode: TaskReminderMode.none);
      expect(TaskReminderPlanner.computeReminderTime(task, now: testNow), isNull);
    });

    test('schedules one day before for dayBefore mode', () {
      final deadline = testNow.add(const Duration(days: 3));
      final task = buildTask(reminderMode: TaskReminderMode.dayBefore, endDate: deadline);
      final reminder = TaskReminderPlanner.computeReminderTime(task, now: testNow);
      expect(reminder, deadline.subtract(const Duration(days: 1)));
    });

    test('schedules one week before for weekBefore mode', () {
      final deadline = testNow.add(const Duration(days: 14));
      final task = buildTask(reminderMode: TaskReminderMode.weekBefore, endDate: deadline);
      final reminder = TaskReminderPlanner.computeReminderTime(task, now: testNow);
      expect(reminder, deadline.subtract(const Duration(days: 7)));
    });

    test('uses custom minutes when custom mode is set', () {
      final deadline = testNow.add(const Duration(hours: 5));
      final task = buildTask(reminderMode: TaskReminderMode.custom, customReminderMinutesBefore: 90, endDate: deadline);
      final reminder = TaskReminderPlanner.computeReminderTime(task, now: testNow);
      expect(reminder, deadline.subtract(const Duration(minutes: 90)));
    });

    test('returns null for invalid custom minutes', () {
      final task = buildTask(reminderMode: TaskReminderMode.custom, customReminderMinutesBefore: 0);
      expect(TaskReminderPlanner.computeReminderTime(task, now: testNow), isNull);
    });

    test('falls back to now+2s when planned reminder is already past', () {
      final deadline = testNow.add(const Duration(hours: 6));
      final task = buildTask(reminderMode: TaskReminderMode.dayBefore, endDate: deadline);
      final reminder = TaskReminderPlanner.computeReminderTime(task, now: testNow);
      expect(reminder, testNow.add(const Duration(seconds: 2)));
    });

    test('smart mode uses a week lead for long spans', () {
      final created = testNow.subtract(const Duration(days: 20));
      final deadline = testNow.add(const Duration(days: 10));
      final task = buildTask(
        reminderMode: TaskReminderMode.smart,
        createdAt: created,
        startDate: created,
        endDate: deadline,
      );
      final reminder = TaskReminderPlanner.computeReminderTime(task, now: testNow);
      expect(reminder, deadline.subtract(const Duration(days: 7)));
    });

    test('smart mode uses a day lead for short remaining windows', () {
      final created = testNow.subtract(const Duration(days: 1));
      final deadline = testNow.add(const Duration(days: 2));
      final task = buildTask(
        reminderMode: TaskReminderMode.smart,
        createdAt: created,
        startDate: created,
        endDate: deadline,
      );
      final reminder = TaskReminderPlanner.computeReminderTime(task, now: testNow);
      expect(reminder, deadline.subtract(const Duration(days: 1)));
    });
  });

  group('TaskReminderPlanner.computeReminderTimes (rolling window)', () {
    test('returns multiple reminders for recurring tasks', () {
      final task = buildTask(
        reminderMode: TaskReminderMode.dayBefore,
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
        recurrenceAnchorDate: DateTime(2026, 8, 1, 10),
        endDate: null,
      );
      final reminders = TaskReminderPlanner.computeReminderTimes(
        task,
        now: DateTime(2026, 8, 2, 8),
        windowSize: 3,
      );
      expect(reminders, hasLength(3));
      // Each reminder is 1 day before the occurrence (or now+2s if past).
      expect(reminders[0].isBefore(reminders[1]), isTrue);
    });

    test('returns empty for completed one-shot tasks', () {
      final task = buildTask(isCompleted: true);
      expect(TaskReminderPlanner.computeReminderTimes(task, now: testNow), isEmpty);
    });
  });
}
