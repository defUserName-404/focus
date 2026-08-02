# Focus Architecture

This document defines the canonical architecture used by coding agents in the Focus project.

## Project Purpose

Focus is an offline-first Flutter productivity app for deep work sessions, projects, and tasks.
All core data is stored on-device (SQLite via Drift). Network connectivity is not required for core flows.

## Tech Stack

- Flutter (Dart SDK >=3.10.0 <4.0.0)
- Riverpod with code generation (`riverpod_annotation`)
- GetIt for dependency injection
- Drift for local database and reactive queries
- go_router for navigation
- ForUI (`forui`) for UI components
- `flutter_local_notifications` for reminders

## Layered Architecture

Focus uses feature-first clean architecture.

```text
lib/
  core/
    config/
    constants/
    di/
    providers/
    routing/
    services/
    utils/
    widgets/
  features/
    <feature>/
      data/
      domain/
      presentation/
```

### Domain Layer

Location: `lib/features/<feature>/domain/`

- `entities/`: immutable business entities
- `repositories/`: abstract interfaces (`I<Feature>Repository`)
- `services/`: business logic, validation, orchestration

Rules:
- No imports from data or presentation layers.
- Services return `Result<T>` where failure is possible.

### Data Layer

Location: `lib/features/<feature>/data/`

- `models/`: Drift table definitions
- `datasources/`: direct DB interaction
- `mappers/`: row <-> domain mapping
- `repositories/`: implementations of domain interfaces

Rules:
- Data layer implements domain contracts.
- Keep query logic in datasources/repositories, not in UI.

### Presentation Layer

Location: `lib/features/<feature>/presentation/`

- `screens/`: route-level pages
- `widgets/`: reusable feature UI
- `providers/`: Riverpod providers/notifiers
- `commands/`: UI action handlers (navigation/dialog/provider mutations)
- `models/`: presentation-only state models (for example selection state)

Rules:
- UI state belongs in presentation, not in domain.
- Keep navigation and dialog orchestration out of domain services.

## Dependency Direction

Only these directions are allowed:

- presentation -> domain
- data -> domain
- core -> independent shared infrastructure

Domain must remain independent.

## Dependency Injection

Primary file: `lib/core/di/injection.dart`

Patterns:
- `registerSingleton` for eager infra (rare)
- `registerLazySingleton` for most services/repositories
- Group registration by feature (`_initProjectsDi`, `_initTasksDi`, etc.)

Access pattern:

```dart
import 'package:focus/core/di/injection.dart';

final service = getIt<ProjectService>();
```

## State Management

Riverpod is the source of truth for app and screen state.

Provider categories:
- Repository bridge providers (`getIt` -> Riverpod)
- Stream providers for reactive Drift data
- Notifier providers for mutations and command-style operations
- Persisted preference providers backed by settings service

Guidelines:
- Use provider-backed state for persistent view preferences.
- Avoid `setState` for state that should survive widget rebuilds or app restarts.

## Navigation Architecture

Primary files:
- `lib/core/routing/app_router.dart`
- `lib/core/routing/routes.dart`

Current pattern:
- `GoRouter` with shell-based app layout
- `AppRoutes` is the single source of truth for both route path and route name (`AppRoute` descriptors)
- `context.go`, `context.push`, and route helper paths
- Use root router helpers for context-free flows (for example notification taps)

Navigation UX split:
- Mobile shell: 4-item bottom navigation (`Home`, `Tasks`, `Projects`, `Inbox`)
- Desktop/tablet shell: side rail keeps separate `Reports` and `Notifications` entries
- Settings is a utility destination (header/rail action), not a primary tab
- Reports expands window-scoped insights (habit consistency, estimates, time breakdowns,
  throughput) via `ITaskStatsRepository` SQL aggregates; CSV export copies the active window

## Layout Architecture

Core layout widgets:
- `AdaptiveShell`
- `MasterDetailLayout`
- `ConstrainedContent`

Guidelines:
- Compact/mobile layouts should avoid double-applied page padding.
- Embedded list screens and standalone list screens may use different spacing strategies.

## Database Architecture

Primary file: `lib/core/services/db_service.dart`

Rules for schema changes:
1. Add/modify Drift table definitions.
2. Increment `schemaVersion`.
3. Implement migration logic in `onUpgrade`.
4. Regenerate code.
5. Verify migration behavior with existing user data.

Current sync-ready schema (v10) includes on `project_table`, `task_table`, and `focus_session_table`:
- `uuid` (TEXT, unique) — stable sync identity, generated on create and backfilled on migration
- `deleted_at` (nullable DateTime) — soft-delete tombstone; all reads filter `deletedAt IS NULL`

PM model (v7) adds:
- `task_table.status` (`TaskStatus` intEnum), `estimated_minutes`, `sort_order`, `milestone_id`
- `project_table.status` (`ProjectStatus` intEnum), `color` (nullable ARGB int)
- `tag_table` / `task_tag_table` (many-to-many) / `milestone_table`
- Domain `Task.isCompleted` is a computed getter (`status == done`); DB still keeps `is_completed`
  synced from status for one compatibility cycle

Recurrence / habits (v8) adds:
- `task_table.recurrence_rule` (nullable JSON text), `recurrence_anchor_date`, `is_habit`
- `task_completion_table` — occurrence log keyed by `(task_id, occurrence_date)` with soft-delete
  and a partial unique index among live rows
- Occurrences are expanded in pure domain code (`RecurrenceExpander`); habits are recurring tasks
  with `isHabit = true` and streaks via `HabitStreakCalculator`

Sync rewrite (v9) adds:
- `task_tag_table.uuid`, `created_at`, `updated_at`, `deleted_at` — junction tombstones for multi-device sync
- Cloud/local `SyncData` envelope is schema-versioned (`kSyncSchemaVersion = 2`); peers refuse newer payloads
- Entities in the envelope reference peers by UUID (`projectUuid`, `parentTaskUuid`, `milestoneUuid`, `taskUuid`, `tagUuid`)
- Coverage: projects, milestones, tags, tasks, task-tag links, completions, focus sessions, whitelisted settings
  (timer + audio). Excluded: `device_id`, desktop-local prefs, UI view-mode prefs
- Merge is pure (`SyncMergeEngine`): UUID-keyed union of local+remote, tombstone LWW, dependency-ordered apply
- Auto-sync via `SyncAutoSyncService` (foreground/background + debounced `DataChangeBus` mutations) gated by `sync_enabled`
- Local JSON backup/restore reuses `SyncData` serialization (`SyncBackupService`)

Project templates (v10) adds:
- `project_template_table` — `uuid`, `name`, `description`, `is_builtin`, `payload_json`, timestamps
- Payload JSON (`ProjectTemplatePayload`) captures tasks, milestones, tags, and recurrence with relative
  date offsets; apply remaps stable template keys to new entity IDs
- Three built-in templates seeded idempotently on `onCreate` / v10 upgrade (`BuiltInTemplates`)
- Save-as-template from project action menu; template picker on create-project flow
- Templates are local-only (not included in cloud sync envelope)

Deletes are soft deletes. `ON DELETE CASCADE` no longer fires for app-level deletes, so project/task
deletion must cascade soft-deletes to dependents inside a transaction (including milestones,
completions, and soft-deleted `task_tag` associations). `SyncPurgeService` hard-deletes tombstones older
than the retention window (default 30 days), including completion and task-tag rows before tasks. A stable
`device_id` setting UUID is generated once on first launch for sync provenance.

Current task schema also includes reminder configuration fields:
- `reminder_mode` (enum-backed)
- `custom_reminder_minutes_before` (nullable int)

## Tasks Board / Calendar Architecture

- Shared calendar primitives live in `lib/core/widgets/calendar/` (month grid, week strip, day cells,
  agenda). They take `CalendarDayInfo` markers and optional typed `DragTarget` handlers — no feature
  domain imports in core.
- Home and Tasks calendars both consume those widgets. Grouping (deadlines + recurrence expansion +
  session counts) is pure domain via `CalendarEventGrouping`.
- Tasks view mode (`list` / `board` / `calendar`) is a settings-backed Riverpod preference
  (`SettingsKeys.tasksViewMode`).
- Board columns map 1:1 to `TaskStatus`; ordering uses sparse `sortOrder` (`SparseSortOrder`).
- Project detail uses a local segmented tab: Overview / Tasks / Board / Milestones / Timeline.
- Desktop keyboard shortcuts: global (`AppKeyboardShortcuts` — ⌘/Ctrl+N/P, Space, Esc); board
  (←/→ columns, 1–4 status); calendar (←/→ period, T=today, 1–3 scope).
- Empty surfaces use shared `AppEmptyState` (board, agenda, timeline, milestones).

## Notifications Architecture

Primary file: `lib/core/services/notification_service.dart`

Android scheduling behavior should be resilient:
- Try exact scheduling when allowed.
- Fall back to inexact scheduling when exact alarms are not permitted.
- Use in-process fallback only as last resort.

Inbox behavior:
- Notification taps should deep-link to the exact destination payload when possible.
- Task reminder payloads include both task id and project id.
- In-app inbox reads a notification event stream plus upcoming task reminder projections.

## Required Code Generation

Run code generation after changing:
- Riverpod annotated providers
- Drift tables, queries, or DAOs
- Files with `part '*.g.dart'`

Command:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Mandatory Agent Documentation Updates

When making significant changes, update agent docs in this order:

1. `AGENTS.md` (top-level quick guidance and links)
2. `.agents/docs/architecture.md` for architecture changes
3. `.agents/docs/coding_style.md` for style or conventions
4. `.agents/docs/commands.md` for workflow/command changes
5. `.agents/docs/patterns.md` for new reusable implementation patterns
6. `.agents/docs/feature_plans.md` and `.agents/docs/audit_results.md` when roadmap or risk profile changes

Significant changes include:
- New architecture patterns or layers
- New core services/utilities
- DI strategy changes
- Database schema/migration changes
- Routing model changes
- Platform behavior changes (notifications/audio/lifecycle)
