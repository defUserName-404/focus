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

Use this pattern for view modes/filter tabs **and resizable pane widths** that must survive app restarts.

1. Add a typed setting key in settings domain (UI prefs stay out of `syncableKeys`).
2. Add get/watch/set methods in settings service if needed.
3. Create dedicated provider to read/write that key.
4. Bind UI switchers / `FResizableControl.onResizeEnd` to the provider, not local `setState`.

Examples: `tasksViewModeProvider`, `tasksMasterPaneWidthProvider`, `projectsMasterPaneWidthProvider`.

## Desktop Detail Pane Form Pattern

On expanded Tasks/Projects, create/edit should not push a centered full-window form:

1. KeepAlive pane-form provider (`empty` vs create vs edit).
2. Commands branch on `context.isCompact` — desktop sets pane mode; compact `context.push`es.
3. `BaseFormScreen(isEmbedded: true)` renders in the detail pane with dismiss/clear callbacks.
4. On success, clear the form mode and select the created/updated entity in the detail pane.

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

// Home dashboard agenda + habits strip (pure)
final agenda = TodayAgendaBuilder.buildAgenda(
  tasks: deadlineTasks,
  completionsByTaskId: completionsByTaskId,
  today: DateTimeUtils.now(),
);
```

Reminder scheduling uses a rolling window (`TaskReminderPlanner.computeReminderTimes`) so
`flutter_local_notifications` only holds the next few occurrence reminders.

Home `todayAgendaProvider` / `habitsStripProvider` combine `watchTasksWithDeadlines()` with
`watchAllCompletions()` via `asyncExpand` so habit checkboxes refresh without touching the task row.

Gotchas:
- Store `RecurrenceRule` as JSON text via `dart_mappable`; parse with `RecurrenceRule.tryParseJson`.
- Unique `(task_id, occurrence_date)` is a **partial** index (`WHERE deleted_at IS NULL`).
- Habits are recurring tasks with `isHabit = true` — no separate habit table.
- Reschedule reminders after `completeOccurrence` so the window advances.
- Home shows week strip only; month grid lives on Tasks / Calendar.

## Tasks View Modes + Sparse Board Ordering

Persist Tasks tab chrome with `SettingsKeys.tasksViewMode` (`list` | `board` | `calendar`) via
`tasksViewModeProvider`, mirroring `upcomingCalendarViewModeProvider`. Slot the segmented
control into `ListToolbar.viewModeControl` — do not add another stacked filter row.

Shared calendar widgets live in `lib/core/widgets/calendar/` (domain-agnostic day markers +
optional `DragTarget<T>`). Feature screens map tasks/sessions into `CalendarDayInfo` and use
`CalendarEventGrouping` for recurrence expansion.

Board columns are `TaskStatus` values. Card order uses sparse `sortOrder` gaps:

```dart
// Prefer a single-row rewrite between neighbours
final order = SparseSortOrder.forInsert(
  neighborOrders: neighbors,
  insertIndex: index,
);
// null => gap collapsed; rewrite the column with SparseSortOrder.rebalance(n)
```

Gotchas:
- Cross-column drops update both `status` and `sortOrder` through `TaskService.updateTask`.
- Compact boards page one column at a time; expanded boards show all four columns.
- Calendar day-cell drops reschedule `endDate` (skip recurring tasks — occurrences are expanded).

## Reports Insights Aggregates

Phase 6 report sections read window-scoped SQL aggregates from `ITaskStatsLocalDataSource`,
mapped through `ITaskStatsRepository`, then bound to `reportsInsightsWindowProvider`.

```dart
// Window key stays ISO `start|end` (same as dailyStatsForRangeProvider)
final range = ProductivityInsightsUtils.dateRangeForWindow(window);

// SQL aggregates (watch + readsFrom) — prefer DB-side SUM/COUNT/GROUP BY
watchEstimateAccuracy(start, end);
watchTimeByProject(start, end);
watchTimeByTag(start, end);
watchTaskCompletionsByDate(start, end);
watchAverageCycleTime(start, end);
watchHabitCompletionHeatmap(start, end);

// Habit rate/streak still uses pure HabitStreakCalculator after SQL loads sources
ReportInsightsCalculator.buildHabitConsistency(sources: ..., from: ..., to: ...);

// CSV is a pure string builder — UI copies to clipboard
ReportInsightsCalculator.buildCsvExport(...);
```

Gotchas:
- Keep custom-painted charts (no chart package). Habit heatmap reuses `YearGridPainter`.
- Cycle time approximates in-progress start as first focus session (else `startDate` / `createdAt`)
  because there is no status-history table yet.
- Tag time double-counts sessions on multi-tagged tasks (intentional for tag breakdowns).
- Export respects the selected insights window; heatmap uses the current calendar year.

## Sync Merge + Auto Sync

Phase 7 rewrote cloud sync around UUID identity and a pure merge engine:

```dart
// Pure — unit-tested in test/domain/sync/sync_merge_engine_test.dart
final result = const SyncMergeEngine().merge(local, remote, lastSyncedAt);
// result.merged is SyncData keyed by uuid; conflicts use String entityId

// I/O orchestration
await syncEngine.performSync(force: true); // manual Sync Now ignores sync_enabled
await syncEngine.performSync();            // auto path respects sync_enabled

// Local gather/apply is bulk (no per-project N+1)
final bundle = await syncLocalDataSource.gatherLocalData();
await syncLocalDataSource.applyMergedData(merged);
```

Dependency apply order: projects → milestones → tags → tasks (by depth) → task-tags →
completions → sessions → settings.

Auto-sync triggers:
- App foreground / background (`SyncAutoSyncService` + `WidgetsBindingObserver`)
- Debounced after mutation batches (`DataChangeBus` from repository writes)
- Manual "Sync Now" always available

Backup/restore:
- Export/import SyncData JSON via `SyncBackupService` + `file_picker`
- Restore requires explicit confirmation and replaces sync-covered local data

Gotchas:
- Refuse remote/backup `schemaVersion` newer than `kSyncSchemaVersion`.
- Do not sync `device_id`, desktop prefs, or UI view-mode keys.
- Focus sessions derive merge clocks from `deletedAt ?? endTime ?? startTime` (no DB `updatedAt`).
- Task↔tag links soft-delete (do not hard-delete) so tombstones can propagate.

## Project Templates

Templates live under `lib/features/projects/` (not a separate feature root).

```dart
final payload = ProjectTemplatePayload.capture(
  project: project,
  tasks: tasks,
  milestones: milestones,
  tagsByTaskId: tagsByTaskId,
);

final result = await templateService.applyTemplate(
  template: template,
  title: title,
  startDate: startDate,
);
```

Payload rules:
- Stable string keys (`m0`, `t0`, `g0`) link milestones/tasks/tags inside the JSON.
- Dates are relative offsets from project start (or earliest dated item / today).
- Apply creates project → milestones → tags (reuse by name) → tasks (depth/parent order) → task tags.
- Built-ins use fixed UUIDs (`BuiltInTemplateIds`) and are seeded idempotently in migration v10 / `onCreate`.
- Templates are local-only; do not add them to the sync envelope without an explicit schema bump.

UI hooks:
- `ActionMenuButton.onSaveAsTemplate` on project detail.
- `ProjectTemplatePicker` on `CreateProjectScreen`.

## Desktop Keyboard Shortcuts + Empty States

```dart
// Global (desktop shell): ⌘/Ctrl+N task, ⌘/Ctrl+P project, Space session, Esc pop
// Board: ←/→ column, 1–4 status; Calendar: ←/→ period, T today, 1–3 scope
```

Use `AppEmptyState` for board/calendar agenda/timeline/milestones empty surfaces.
Home may keep `EmptySection` or migrate to `AppEmptyState` — prefer the core widget for new views.

## ListToolbar Overflow Pattern

`ListToolbar` keeps search + optional view switcher + filter (+ create) on one row.

```dart
ListToolbar(
  searchHint: 'Search tasks...',
  onSearchChanged: (q) => notifier.updateFilter(searchQuery: q),
  filterPanel: const AllTasksFilterPanel(),
  activeFilterCount: count,
  activeFilters: chips,
  onReset: () => notifier.reset(), // sheet Reset button
  viewModeControl: TasksViewModeToggle(...), // optional
);
```

Overflow rules:
- Pane width `< 360`: icon-only create/filter (with `FTooltip`) via `ListToolbarLayout.iconOnly`.
- Window width `< 400`: filters open in a bottom `FSheet` (drag handle + Reset/Done).
- Wider panes: filters open in an `FPopover` anchored to the filter button.
- Active-filter chips always render under the toolbar row when non-empty.

## Adaptive Drag Pattern

Board (and similar) cards use immediate drag on desktop and long-press drag on touch:

```dart
Widget _buildDraggable({required Widget child, required Widget feedback}) {
  if (PlatformUtils.isDesktop) {
    return Draggable<Task>(
      data: task,
      feedback: feedback,
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      child: child,
    );
  }
  return LongPressDraggable<Task>(
    data: task,
    feedback: feedback,
    childWhenDragging: Opacity(opacity: 0.35, child: child),
    child: child,
  );
}
```

Gotchas:
- Desktop: `SystemMouseCursors.grab` / `grabbing` on board cards.
- Touch: long-press avoids fighting vertical scroll / page swipe.
- Pair with edge auto-scroll while dragging in compact PageView boards.

## Mandatory Follow-Up

When a new pattern is introduced in production code, add it here with:
- Use case
- Minimal code template
- Gotchas
