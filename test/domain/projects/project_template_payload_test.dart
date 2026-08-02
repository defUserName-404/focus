import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/milestones/domain/entities/milestone.dart';
import 'package:focus/features/projects/domain/entities/built_in_templates.dart';
import 'package:focus/features/projects/domain/entities/project.dart';
import 'package:focus/features/projects/domain/entities/project_template_payload.dart';
import 'package:focus/features/tags/domain/entities/tag.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/domain/entities/task_priority.dart';
import 'package:focus/features/tasks/domain/entities/task_status.dart';

void main() {
  final now = DateTime.utc(2026, 8, 2, 12);

  group('ProjectTemplatePayload', () {
    test('round-trips through JSON', () {
      final original = BuiltInTemplates.all(now: now).first.payload;
      final restored = ProjectTemplatePayload.fromJsonString(original.toJsonString());
      expect(restored.version, original.version);
      expect(restored.defaultTitle, original.defaultTitle);
      expect(restored.milestones.length, original.milestones.length);
      expect(restored.tags.length, original.tags.length);
      expect(restored.tasks.length, original.tasks.length);
      expect(restored.tasks.map((t) => t.title), original.tasks.map((t) => t.title));
    });

    test('capture uses relative date offsets from project start', () {
      final project = Project(
        id: 1,
        uuid: 'p1',
        title: 'Launch',
        description: 'Ship it',
        createdAt: now,
        updatedAt: now,
        startDate: DateTime(2026, 8, 1),
      );
      final milestone = Milestone(
        id: 10,
        uuid: 'm1',
        projectId: 1,
        title: 'Beta',
        targetDate: DateTime(2026, 8, 15),
        createdAt: now,
        updatedAt: now,
      );
      final task = Task(
        id: 20,
        uuid: 't1',
        projectId: 1,
        title: 'Build',
        priority: TaskPriority.high,
        status: TaskStatus.todo,
        depth: 0,
        sortOrder: 1000,
        milestoneId: 10,
        startDate: DateTime(2026, 8, 3),
        endDate: DateTime(2026, 8, 10),
        recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 1, byWeekday: [1]),
        isHabit: true,
        createdAt: now,
        updatedAt: now,
      );
      final tag = Tag(id: 30, uuid: 'g1', name: 'launch', createdAt: now, updatedAt: now);
      final payload = ProjectTemplatePayload.capture(
        project: project,
        tasks: [task],
        milestones: [milestone],
        tagsByTaskId: {
          20: [tag],
        },
        fallbackNow: now,
      );
      expect(payload.defaultTitle, 'Launch');
      expect(payload.milestones.single.targetOffsetDays, 14);
      expect(payload.tasks.single.startOffsetDays, 2);
      expect(payload.tasks.single.endOffsetDays, 9);
      expect(payload.tasks.single.milestoneKey, isNotNull);
      expect(payload.tasks.single.tagKeys, isNotEmpty);
      expect(payload.tasks.single.isHabit, isTrue);
      expect(payload.tasks.single.recurrenceRuleJson?['frequency'], 'weekly');
      final roundTrip = ProjectTemplatePayload.fromJsonString(payload.toJsonString());
      expect(roundTrip.tasks.single.resolveStart(DateTime(2026, 9, 1)), DateTime(2026, 9, 3));
      expect(roundTrip.milestones.single.resolveDate(DateTime(2026, 9, 1)), DateTime(2026, 9, 15));
    });

    test('built-in templates include recurrence on at least one task', () {
      final withRecurrence = BuiltInTemplates.all(
        now: now,
      ).expand((t) => t.payload.tasks).where((t) => t.recurrenceRuleJson != null).toList();
      expect(withRecurrence, isNotEmpty);
    });
  });
}
