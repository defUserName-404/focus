# Focus Code Patterns

This file contains reusable implementation patterns for Focus.

## Domain Entity Pattern

```dart
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Project extends Equatable {
  final int? id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, title, createdAt, updatedAt];
}
```

## Domain `copyWith` Pattern

```dart
extension ProjectCopyWith on Project {
  Project copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

## Repository Interface Pattern

```dart
abstract interface class IProjectRepository {
  Future<List<Project>> getAllProjects();
  Future<Project?> getProjectById(int id);
  Stream<List<Project>> watchAllProjects();
  Stream<Project?> watchProjectById(int id);
  Future<Project> createProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(int id);
}
```

## Service + `Result<T>` Pattern

```dart
import 'package:focus/core/utils/result.dart';

class ProjectService {
  ProjectService(this._repository);

  final IProjectRepository _repository;

  Future<Result<Project>> createProject({required String title}) async {
    try {
      final now = DateTime.now();
      final project = Project(title: title, createdAt: now, updatedAt: now);
      final created = await _repository.createProject(project);
      return Success(created);
    } catch (e, st) {
      return Failure(DatabaseFailure('Failed to create project', error: e, stackTrace: st));
    }
  }
}
```

## Drift Datasource Pattern

```dart
abstract interface class IProjectLocalDataSource {
  Future<List<ProjectTableData>> getAllProjects();
  Future<ProjectTableData?> getProjectById(int id);
  Future<int> createProject(ProjectTableCompanion companion);
  Future<void> updateProject(ProjectTableCompanion companion);
  Future<void> deleteProject(int id);
  Stream<List<ProjectTableData>> watchAllProjects();
}

class ProjectLocalDataSourceImpl implements IProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<ProjectTableData>> getAllProjects() {
    return _db.select(_db.projectTable).get();
  }

  @override
  Stream<List<ProjectTableData>> watchAllProjects() {
    return _db.select(_db.projectTable).watch();
  }

  // Additional methods omitted for brevity.
}
```

## Mapper Pattern

```dart
import 'package:drift/drift.dart' show Value;

extension DbProjectToDomain on ProjectTableData {
  Project toDomain() {
    return Project(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension DomainProjectToCompanion on Project {
  ProjectTableCompanion toCompanion() {
    if (id == null) {
      return ProjectTableCompanion.insert(
        title: title,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    return ProjectTableCompanion(
      id: Value(id!),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}
```

## Riverpod Provider Pattern

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'project_provider.g.dart';

@Riverpod(keepAlive: true)
IProjectRepository projectRepository(Ref ref) {
  return getIt<IProjectRepository>();
}

@Riverpod(keepAlive: true)
Stream<List<Project>> projectList(Ref ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchAllProjects();
}

@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> deleteProject(int id) async {
    final service = getIt<ProjectService>();
    final result = await service.deleteProject(id);
    switch (result) {
      case Success():
        return;
      case Failure(:final failure):
        state = AsyncError(failure, StackTrace.current);
    }
  }
}
```

## Presentation Command Pattern

```dart
class ProjectCommands {
  static void create(BuildContext context) {
    context.push(AppRoutes.createProject);
  }

  static Future<void> delete(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) async {
    if (project.id == null) return;

    await ConfirmationDialog.show(
      context,
      title: 'Delete Project',
      body: 'Are you sure?',
      onConfirm: () {
        ref.read(projectProvider.notifier).deleteProject(project.id!);
      },
    );
  }
}
```

## Persisted UI Preference Pattern

Use this pattern for view modes/filter tabs that must survive app restarts.

1. Add a typed setting key in settings domain.
2. Add get/watch/set methods in settings service if needed.
3. Create dedicated provider to read/write that key.
4. Bind UI switchers to the provider, not local `setState`.

## Screen Composition Pattern

For large route screens:
- Keep top-level screen lean.
- Extract filter bar, list body, and footer actions into small widgets.
- Keep business decisions in providers/commands/services, not in deeply nested build conditionals.

## Notification Scheduling Pattern

For Android reminder scheduling:
- Attempt exact mode when available.
- Retry with inexact mode on permission errors.
- Use in-process fallback only as last resort.

## Unified Route Descriptor Pattern

Use a single route descriptor for both path and name.

```dart
class AppRoute {
  final String path;
  final String name;

  const AppRoute({required this.path, required this.name});
}

abstract final class AppRoutes {
  static const home = AppRoute(path: '/', name: 'home');
  static const notifications = AppRoute(path: '/notifications', name: 'notifications');
}
```

Use `.path` for navigation calls and `.name` for route registration.

## Task Reminder Strategy Pattern

Per-task reminder behavior is configured on the task entity and resolved by a planner.

```dart
enum TaskReminderMode { smart, weekBefore, dayBefore, custom, none }

final reminderTime = TaskReminderPlanner.computeReminderTime(task);
if (reminderTime != null) {
  await notificationService.scheduleNotification(
    id: id,
    title: 'Task Reminder',
    body: task.title,
    scheduledTime: reminderTime,
    payload: NotificationConstants.taskPayload(taskId: task.id!, projectId: task.projectId),
  );
}
```

Guidelines:
- `smart` uses 1 week for long tasks and 1 day otherwise.
- `custom` stores minutes-before as an integer.
- Keep reminder computation in a pure planner utility so UI and services share logic.
- For recurring tasks, use `computeReminderTimes` (rolling window of upcoming occurrences)
  rather than a single `endDate`-based reminder.

## Soft Delete + UUID Sync Identity

Projects, tasks, and focus sessions carry a `uuid` and optional `deletedAt`.

```dart
// Soft delete in datasource (never hard DELETE for user-facing removes)
await (_db.update(_db.projectTable)..where((t) => t.id.equals(id))).write(
  ProjectTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
);

// Every read/watch filters tombstones
..where((t) => t.deletedAt.isNull())
```

Gotchas:
- Soft-deleting a project must transactionally soft-delete its tasks, milestones, completions, and their sessions.
- Soft-deleting a task must soft-delete descendants, their completions, and their sessions, and remove `task_tag` rows.
- Soft-deleting a tag removes its `task_tag` associations then tombstones the tag.
- Soft-deleting a milestone clears `task.milestoneId` then tombstones the milestone.
- Generate `uuid` on create via `generateUuid()`; migration backfills existing rows.
- `SyncPurgeService` permanently removes tombstones past the retention window (including tags/milestones/completions).
- Persist `SettingsKeys.deviceId` once via `SettingsService.ensureDeviceId()`.

## Task / Project Status + Tags / Milestones

`TaskStatus` and `ProjectStatus` are Drift `intEnum` values — declaration order is a schema contract.

```dart
enum TaskStatus { todo, inProgress, blocked, done; }

// Domain completion is derived — do not store a separate bool on the entity
bool get isCompleted => status == TaskStatus.done;

// Writes still sync legacy is_completed column during v7
isCompleted: Value(status == TaskStatus.done),
```

Tags and milestones follow the same feature-first stack (entity → repository → service → GetIt).
Optional `statusFilter` mirrors the existing nullable `priorityFilter` on list filter states.

Gotchas:
- Keep writing both `status` and `is_completed` until a later migration drops the bool column.
- Filter completion chips (`TaskCompletionFilter`) should query `status`, not the legacy bool.

## Recurrence Expansion + Habit Streaks

Recurring tasks stay a **single row**. Occurrences are computed, never materialised as task rows.

```dart
// Pure expansion — no I/O
final dates = RecurrenceExpander.expand(task, from, to);

// Occurrence completion log (soft-delete aware upsert)
await taskService.completeOccurrence(taskId, occurrenceDate);

// Streaks skip days the rule did not schedule
final streak = HabitStreakCalculator.calculate(
  rule: task.recurrenceRule!,
  anchor: task.recurrenceAnchorDate!,
  completionDates: completions.map((c) => c.occurrenceDate),
  from: windowStart,
  to: windowEnd,
);
```

Reminder scheduling uses a rolling window (`TaskReminderPlanner.computeReminderTimes`) so
`flutter_local_notifications` only holds the next few occurrence reminders.

Gotchas:
- Store `RecurrenceRule` as JSON text via `dart_mappable`; parse with `RecurrenceRule.tryParseJson`.
- Unique `(task_id, occurrence_date)` is a **partial** index (`WHERE deleted_at IS NULL`).
- Habits are recurring tasks with `isHabit = true` — no separate habit table.
- Reschedule reminders after `completeOccurrence` so the window advances.

## Mandatory Follow-Up

When a new pattern is introduced in production code, add it here with:
- Use case
- Minimal code template
- Gotchas
