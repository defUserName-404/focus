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

Current task schema includes reminder configuration fields:
- `reminder_mode` (enum-backed)
- `custom_reminder_minutes_before` (nullable int)

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
