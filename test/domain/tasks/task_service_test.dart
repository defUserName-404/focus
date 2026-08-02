import 'package:flutter_test/flutter_test.dart';
import 'package:focus/core/utils/result.dart';
import 'package:focus/features/tasks/domain/entities/recurrence_rule.dart';
import 'package:focus/features/tasks/domain/entities/task.dart';
import 'package:focus/features/tasks/domain/entities/task_completion.dart';
import 'package:focus/features/tasks/domain/entities/task_completion_extensions.dart';
import 'package:focus/features/tasks/domain/entities/task_extensions.dart';
import 'package:focus/features/tasks/domain/entities/task_status.dart';
import 'package:focus/features/tasks/domain/repositories/i_task_repository.dart';
import 'package:focus/features/tasks/domain/services/task_notification_service.dart';
import 'package:focus/features/tasks/domain/services/task_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class _MockTaskRepository extends Mock implements ITaskRepository {}

class _MockTaskNotificationService extends Mock implements TaskNotificationService {}

void main() {
  late _MockTaskRepository repository;
  late _MockTaskNotificationService notifications;
  late TaskService service;

  setUpAll(() {
    registerFallbackValue(buildTask());
    registerFallbackValue(buildCompletion());
  });

  setUp(() {
    repository = _MockTaskRepository();
    notifications = _MockTaskNotificationService();
    service = TaskService(repository, notifications);
    when(() => notifications.scheduleTaskReminder(any())).thenAnswer((_) async => const Success(null));
    when(() => notifications.cancelTaskReminder(any())).thenAnswer((_) async => const Success(null));
  });

  test('createTask persists and schedules a reminder', () async {
    when(() => repository.createTask(any())).thenAnswer((invocation) async {
      final task = invocation.positionalArguments.first as Task;
      return task.copyWith(id: 11);
    });

    final result = await service.createTask(projectId: 1, title: 'Write Phase 0', depth: 0);
    expect(result, isA<Success<Task>>());
    final created = (result as Success<Task>).value;
    expect(created.id, 11);
    verify(() => repository.createTask(any())).called(1);
    verify(() => notifications.scheduleTaskReminder(created)).called(1);
  });

  test('updateTask cancels then reschedules reminders', () async {
    when(() => repository.updateTask(any())).thenAnswer((_) async {});
    final task = buildTask(id: 5, title: 'Updated');
    final result = await service.updateTask(task);
    expect(result, isA<Success<void>>());
    verifyInOrder([
      () => notifications.cancelTaskReminder(5),
      () => repository.updateTask(any()),
      () => notifications.scheduleTaskReminder(any()),
    ]);
  });

  test('deleteTask cancels reminder then deletes', () async {
    when(() => repository.deleteTask(3)).thenAnswer((_) async {});
    final result = await service.deleteTask(3);
    expect(result, isA<Success<void>>());
    verifyInOrder([() => notifications.cancelTaskReminder(3), () => repository.deleteTask(3)]);
  });

  test('toggleTaskCompletion cancels reminder when completing', () async {
    when(() => repository.updateTask(any())).thenAnswer((_) async {});
    final task = buildTask(id: 8, isCompleted: false);
    final result = await service.toggleTaskCompletion(task);
    expect(result, isA<Success<void>>());
    final captured = verify(() => repository.updateTask(captureAny())).captured.single as Task;
    expect(captured.isCompleted, isTrue);
    expect(captured.status, TaskStatus.done);
    verify(() => notifications.cancelTaskReminder(8)).called(1);
    verifyNever(() => notifications.scheduleTaskReminder(any()));
  });

  test('toggleTaskCompletion reschedules when reopening', () async {
    when(() => repository.updateTask(any())).thenAnswer((_) async {});
    final task = buildTask(id: 8, isCompleted: true);
    final result = await service.toggleTaskCompletion(task);
    expect(result, isA<Success<void>>());
    verify(() => notifications.scheduleTaskReminder(any())).called(1);
  });

  test('completeOccurrence marks non-recurring task done', () async {
    when(() => repository.getTaskById(4)).thenAnswer((_) async => buildTask(id: 4, isCompleted: false));
    when(() => repository.updateTask(any())).thenAnswer((_) async {});

    final result = await service.completeOccurrence(4, DateTime(2026, 8, 2));
    expect(result, isA<Success<TaskCompletion?>>());
    expect((result as Success<TaskCompletion?>).value, isNull);
    final captured = verify(() => repository.updateTask(captureAny())).captured.single as Task;
    expect(captured.status, TaskStatus.done);
    verify(() => notifications.cancelTaskReminder(4)).called(1);
    verifyNever(() => repository.upsertCompletion(any()));
  });

  test('completeOccurrence upserts completion for recurring tasks', () async {
    final task = buildTask(
      id: 9,
      recurrenceRule: const RecurrenceRule(frequency: RecurrenceFrequency.daily),
      recurrenceAnchorDate: DateTime(2026, 8, 1),
      isHabit: true,
      endDate: null,
    );
    when(() => repository.getTaskById(9)).thenAnswer((_) async => task);
    when(() => repository.upsertCompletion(any())).thenAnswer((invocation) async {
      final c = invocation.positionalArguments.first as TaskCompletion;
      return c.copyWith(id: 42);
    });

    final result = await service.completeOccurrence(9, DateTime(2026, 8, 2, 15));
    expect(result, isA<Success<TaskCompletion?>>());
    final saved = (result as Success<TaskCompletion?>).value!;
    expect(saved.id, 42);
    expect(saved.occurrenceDate, DateTime(2026, 8, 2));
    verify(() => notifications.scheduleTaskReminder(task)).called(1);
    verifyNever(() => repository.updateTask(any()));
  });

  test('completeOccurrence returns NotFound when task missing', () async {
    when(() => repository.getTaskById(99)).thenAnswer((_) async => null);
    final result = await service.completeOccurrence(99, DateTime(2026, 8, 2));
    expect(result, isA<Failure<TaskCompletion?>>());
  });

  test('createTask returns Failure when repository throws', () async {
    when(() => repository.createTask(any())).thenThrow(Exception('disk full'));
    final result = await service.createTask(projectId: 1, title: 'Fail', depth: 0);
    expect(result, isA<Failure<Task>>());
  });
}
