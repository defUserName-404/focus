# Focus App — Architecture, Performance & Security Audit

> **Audit date**: 2026-02-15
> **Codebase version**: `feature` branch
> **Flutter SDK**: ≥ 3.10.0 · **Dart**: ≥ 3.10.0

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Clean Architecture Compliance](#2-clean-architecture-compliance)
3. [SOLID Principles Audit](#3-solid-principles-audit)
4. [Code Smells & Anti-Patterns](#4-code-smells--anti-patterns)
5. [Consistency Audit](#5-consistency-audit)
6. [Performance Audit](#6-performance-audit)
7. [Security Audit (Offline App)](#7-security-audit-offline-app)
8. [Actionable Recommendations](#8-actionable-recommendations)

---

## 1. Architecture Overview

### 1.1 High-Level Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI Framework** | ForUI (`forui` ^0.17.0) | Design system / widget library |
| **State Management** | Riverpod 3 (code-gen + legacy) | Reactive UI state |
| **Service Locator** | GetIt ^9.2.0 | Imperative DI for services/repos |
| **Database** | Drift ^2.31.0 (SQLite) | Local persistence |
| **Audio** | `audioplayers` + `audio_service` + `audio_session` | Ambience, alarms, media session |
| **Notifications** | `flutter_local_notifications` | Session alerts, alarm popups |
| **Routing** | Manual `onGenerateRoute` | Name-based, no code-gen router |

### 1.2 Feature Structure

```
lib/
├── core/              ← Shared services, DI, routing, theme, constants, widgets
├── features/
│   ├── focus/         ← Focus session timer, audio bridge, media controls
│   ├── tasks/         ← Task CRUD, stats, filtering
│   ├── projects/      ← Project CRUD, progress tracking
│   ├── settings/      ← Key-value preferences (audio, timer durations)
│   ├── home/          ← Dashboard, activity graph (presentation-only feature)
│   └── all_tasks/     ← Global task list with cross-project search/filter
```

Each feature follows a three-layer structure:

```
feature/
├── data/
│   ├── datasources/   ← Abstract + Impl (DB queries)
│   ├── models/        ← Drift table definitions
│   ├── mappers/       ← Extensions: Drift ↔ Domain conversion
│   └── repositories/  ← Interface implementations
├── domain/
│   ├── entities/      ← Plain Dart classes (no framework deps)
│   └── repositories/  ← Abstract interfaces
└── presentation/
    ├── providers/     ← Riverpod state management
    ├── commands/      ← Navigation + action orchestration
    ├── screens/       ← Full-page UI
    └── widgets/       ← Reusable components
```

### 1.3 Dual DI Strategy

The app uses **two** dependency injection systems:

| System | Scope | Registered Types |
|--------|-------|------------------|
| **GetIt** | Imperative singletons | `AppDatabase`, `AudioService`, `FocusAudioHandler`, `NotificationService`, `AudioSessionManager`, all `DataSource`s, all `Repository`s |
| **Riverpod** | Reactive state | `FocusTimer`, filter states, UI providers, computed values |

**Rationale**: GetIt handles "infrastructure" singletons that are initialized once and never change. Riverpod handles reactive data flows that the UI watches. This is a pragmatic split common in production Flutter apps, but it requires discipline — developers must know which container owns each dependency.

---

## 2. Clean Architecture Compliance

### 2.1 Layer Separation — ✅ Well Maintained

- **Data layer** never imports presentation layer.
- **Domain layer** has zero framework imports — entities are plain Dart.
- **Presentation layer** depends on domain interfaces (through DI), not concrete implementations.
- **Mappers** are isolated in `data/mappers/` as extension methods — clean boundary.

### 2.2 Dependency Rule — ✅ Mostly Respected

The dependency rule (outer layers depend inward, never the reverse) is followed with minor violations:

| Violation | Severity | Location |
|-----------|----------|----------|
| `FocusTimer` reaches into `ITaskRepository` via `getIt<ITaskRepository>()` to complete tasks | Low | `focus_session_provider.dart` |
| `task_local_datasource.dart` imports from `all_tasks/domain/entities/` | Low | Data layer cross-feature import |

### 2.3 Missing Use Case Layer — ⚠️ Intentional Omission

The domain layer has **no use case / interactor classes**. Business logic lives directly in:
- Riverpod `Notifier` classes (e.g., `FocusTimer`, `TaskNotifier`, `ProjectNotifier`)
- Static `Commands` classes (e.g., `FocusCommands`, `TaskCommands`)
- Repository implementations (for simple delegation)

**Verdict**: For an app of this complexity (single-developer, offline, ~40 screens/widgets), omitting use cases is a reasonable pragmatic choice. The providers effectively serve as use cases. If the app grew significantly, extracting use cases would become valuable for testability.

### 2.4 Domain Entity Purity — ✅ Good

Entities are framework-free plain Dart classes. The transient `breakStartElapsed` field on `FocusSession` is well-documented as non-persisted. `copyWith` extensions use a sentinel object pattern for nullable field discrimination, which is a clean solution.

---

## 3. SOLID Principles Audit

### 3.1 Single Responsibility Principle (SRP)

| Component | Responsibilities | Verdict |
|-----------|-----------------|---------|
| `FocusTimer` notifier | Session lifecycle, timer ticks, phase transitions, audio management, notification management, media session, audio session, task completion, label caching, mute state | ❌ **~11 responsibilities. Borderline god object.** |
| `AudioService` | Alarm playback + ambience playback (two distinct concerns) | ⚠️ Acceptable — both are audio |
| `NotificationService` | Local notifications + action stream management + launch navigation | ⚠️ Slightly overloaded |
| `FocusCommands` | Session creation + navigation + confirmation dialogs | ✅ Cohesive orchestration |
| `TaskNotifier` | CRUD operations + state refresh | ✅ Clean |
| `FocusAudioHandler` | Media session bridge only | ✅ Single responsibility |
| All repositories | Data mapping + delegation | ✅ Thin adapters |
| All datasources | DB queries only | ✅ Clean |

**Key SRP Violation — `FocusTimer`**: This notifier manages the entire focus session state machine including audio, notifications, media session, and cross-feature task completion. Suggested decomposition:

```
FocusTimer (state machine + tick logic)
├── FocusAudioCoordinator (ambience start/stop/resume, alarm playback)
├── FocusNotificationCoordinator (show/cancel notifications, action routing)
├── FocusMediaSessionCoordinator (updateMediaItem, updatePlaybackState, clearSession)
└── SessionLifecycleService (DB persistence, cleanup, task completion)
```

### 3.2 Open/Closed Principle (OCP)

- **`SortCriteria` / `SortOrder` interfaces** — Excellent. Each feature implements its own criteria without modifying core.
- **`FilterSelectable` interface** — Allows any feature to plug into `FilterSelect<T>` generics.
- **`AudioAssets` sound presets** — New sounds can be added to the list without changing consumer code.
- **`SessionState` enum** — Adding new states requires updating `switch` statements in `FocusTimer`, `_tick()`, `skipToNextPhase()`, etc. ⚠️ Consider making state transitions more declarative.

### 3.3 Liskov Substitution Principle (LSP)

- ✅ All repository interfaces (`IFocusSessionRepository`, `ITaskRepository`, etc.) can be freely substituted — implementations comply with interface contracts.
- ✅ `BaseFormScreen` / `BaseModalForm` are composable via constructor params, not inheritance.

### 3.4 Interface Segregation Principle (ISP)

- ✅ Repository interfaces are reasonably granular (separate `ITaskRepository` and `ITaskStatsRepository`).
- ⚠️ `ISettingsRepository` is broad — combines audio preferences, timer preferences, and raw key-value access. Could be split into `IAudioPreferencesRepository` and `ITimerPreferencesRepository` for clearer contracts.

### 3.5 Dependency Inversion Principle (DIP)

- ✅ Presentation depends on domain interfaces, not data implementations.
- ✅ DI registration maps interfaces to implementations (`IProjectRepository` → `ProjectRepositoryImpl`).
- ⚠️ `FocusTimer` accesses `getIt<ITaskRepository>()` inline — while this uses an interface, the access pattern mixes two DI systems in one class.

---

## 4. Code Smells & Anti-Patterns

### 4.1 Critical

| # | Issue | Location | Impact |
|---|-------|----------|--------|
| 1 | **God Object**: `FocusTimer` has ~11 responsibilities, ~490 lines of business logic | `focus_session_provider.dart` | Hard to test, hard to modify without side effects |
| 2 | **Dead Code**: `FocusControls` widget is fully superseded by `_FocusControlsWithCallback` | `focus_controls.dart` | Confusion, maintenance burden |

### 4.2 Major

| # | Issue | Location | Impact |
|---|-------|----------|--------|
| 3 | **Massive Form Duplication**: Every CRUD entity has near-identical screen + modal form variants (~90% identical code) | `create_task_screen.dart` ↔ `create_task_modal_content.dart`, `edit_task_screen.dart` ↔ `edit_task_modal_content.dart`, same for projects, `create_task_with_project_screen.dart` ↔ `create_task_with_project_modal.dart` | DRY violation — bugs must be fixed in 2 places |
| 4 | **Enum Index in Raw SQL**: `recalculateDailyStats` uses `${SessionState.completed.index}` in raw SQL string interpolation | `db_service.dart` | Reordering `SessionState` enum silently corrupts query logic |
| 5 | **`dynamic` type in router**: Route arguments cast with `as dynamic` | `app_router.dart` L67, L85 | Runtime crash if wrong argument type passed |
| 6 | **Missing null-out in Project `copyWith`**: Doesn't use sentinel pattern — `copyWith(deadline: null)` is a no-op | `project_extensions.dart` | Cannot clear project deadline via copyWith |
| 7 | **Provider style fragmentation**: Mix of `@Riverpod` code-gen and legacy `StreamProvider`/`Provider` patterns | Multiple files | Inconsistent lifecycle management, cognitive load |

### 4.3 Minor

| # | Issue | Location | Impact |
|---|-------|----------|--------|
| 8 | **Duplicated `getIntensity`** method | `activity_graph_constants.dart` + `activity_graph_utils.dart` | Confusing which to use |
| 9 | **Legacy `startNoise`/`stopNoise` API** alongside `startAmbience`/`stopAmbience` | `audio_service.dart` | Two ways to do the same thing |
| 10 | **`Future.delayed(500ms)` for deferred navigation** | `notification_service.dart` | Fragile timing hack |
| 11 | **Static stream controllers never closed** | `notification_service.dart` | Minor memory leak (acceptable for app-lifetime singleton) |
| 12 | **`BuildContext` as constructor param** to `_StatCard` | `task_stats_row.dart` | Unnecessary — `build()` method provides its own |
| 13 | **Hardcoded `Colors.orange`** instead of theme color | `task_date_row.dart` | Breaks if a light theme is ever added |
| 14 | **Unused constructor params** (`icon`, `iconSize`, `iconColor`, `position`) that `build()` never reads | `action_menu_button.dart` | Dead code, misleading API |
| 15 | **Hardcoded package name** `com.defusername.focus` | `focus_audio_handler.dart` | Breaks if package name changes |
| 16 | **No `dispose` calls** for registered singletons (`AudioService`, `AudioSessionManager`) | `injection.dart` | OS resources may not be released on app close |
| 17 | **Leading `/` in asset path** (`/assets/images/focus_app_icon.png`) | `filepath_constants.dart` | Flutter asset resolution expects no leading slash |

---

## 5. Consistency Audit

### 5.1 Interface Declaration Style

| Feature | Style | Standard? |
|---------|-------|-----------|
| Focus | `abstract class IFocusLocalDataSource` | ✅ |
| Tasks | `abstract class ITaskLocalDataSource` | ✅ |
| Projects | `abstract interface class IProjectLocalDataSource` | ❌ Different |
| Settings | `abstract class ISettingsLocalDataSource` | ✅ |

**Fix**: Standardize all to `abstract interface class` (Dart 3 best practice) or all to `abstract class`.

### 5.2 Entity `copyWith` Pattern

| Entity | Sentinel Pattern | Can null-out fields? |
|--------|-----------------|---------------------|
| `FocusSession` | ✅ `_FocusSessionCopyWithUnset` | ✅ Yes |
| `Task` | ✅ `_TaskCopyWithUnset` | ✅ Yes |
| `Project` | ❌ None | ❌ No — bug risk |
| `Setting` / `AudioPreferences` / `TimerPreferences` | N/A (no nullable fields) | N/A |

### 5.3 Provider Pattern

| Pattern | Count | Where |
|---------|-------|-------|
| `@Riverpod(keepAlive: true)` code-gen | ~18 | Feature notifiers, repository providers |
| `@riverpod` (autoDispose) code-gen | 2 | `focusProgressProvider`, `ambienceMarqueeProvider` |
| Legacy `StreamProvider` | ~12 | Stats, preferences, filtered lists |
| Legacy `Provider` | 1 | `taskStatsRepositoryProvider` |

**Recommendation**: Migrate legacy providers to code-gen `@riverpod` / `@Riverpod(keepAlive: true)` for consistent lifecycle management. Some of the `StreamProvider`s watch Drift streams — these map cleanly to `@riverpod Stream<T>` syntax.

### 5.4 Naming Conventions

Generally consistent. Notable exceptions:
- `extraLarge2` spacing sits between `large` and `extraLarge` conceptually but is named `extraLarge2` — should be `large2` or `largePlus`.
- `timerPreferencesProvider` (in `focus_session_provider.dart`) and `timerSettingsProvider` (in `settings_provider.dart`) appear to serve the same purpose — potential dead code or unnecessary duplication.

---

## 6. Performance Audit

### 6.1 Database Performance

| Aspect | Status | Notes |
|--------|--------|-------|
| **Pre-aggregated stats** | ✅ Excellent | `DailySessionStatsTable` avoids expensive on-the-fly aggregation for the activity graph. Recalculated on every session insert/update/delete. |
| **Indices** | ✅ Good | `FocusSessionTable` has indices on `taskId` + `startTime`. `TaskTable` has 6 indices. |
| **Raw SQL queries** | ⚠️ Risk | `recalculateDailyStats` and task stats queries use raw SQL with string interpolation — no compile-time validation. |
| **Cascade delete** | ⚠️ Suboptimal | Task cascade delete iterates children recursively in Dart (`for (final child in children) await deleteTask(child.id)`) rather than using SQL `ON DELETE CASCADE` or a recursive CTE. This is O(N) DB roundtrips for N descendants. |
| **Migration safety** | ⚠️ Early destructive | v2–v4 migrations use `deleteTable` + `createTable` (data loss). Only safe if no users had those versions. |
| **Session save frequency** | ✅ Good | Timer writes to DB every 10 ticks (10 seconds) during `_tick()` — balances crash-recovery with I/O. |

### 6.2 Widget Performance

| Aspect | Status | Notes |
|--------|--------|-------|
| **`IndexedStack` for tabs** | ✅ Standard | Keeps 4 tab screens in memory but avoids rebuild on tab switch. Acceptable for 4 tabs. |
| **`focusProgressProvider` is synchronous** | ✅ Excellent | Eliminates `AsyncValue.loading` flicker on every timer tick. Intentional optimization. |
| **Entities lack `==`/`hashCode`** | ⚠️ Over-rebuilds | Riverpod uses `==` to skip rebuilds. Without it, every state update triggers rebuilds even if the data hasn't changed. Impact is modest for this app's complexity but grows with list sizes. |
| **`YearGridPainter` repaints** | ⚠️ Minor | No `shouldRepaint` optimization beyond default reference check. Repaints on every heatmap data change, which is rare, so low impact. |
| **`AnimatedSwitcher` in timer** | ✅ Good | Phase label crossfade uses `ValueKey` to trigger animation only on actual phase changes. |
| **`CustomPaint` for timer ring** | ✅ Efficient | `CircularProgressPainter` is lightweight — single arc draw per frame. |
| **Activity graph tooltip** | ✅ Good | Uses `OverlayEntry` instead of `showDialog` — avoids modal barrier and route creation overhead. |
| **Marquee text animation** | ⚠️ Minor | `AnimationController` runs continuously when visible. `SingleTickerProviderStateMixin` ensures it pauses when off-screen. Acceptable. |

### 6.3 Memory & Lifecycle

| Aspect | Status | Notes |
|--------|--------|-------|
| **`keepAlive: true` providers** | ⚠️ Trade-off | ~18 keepAlive providers never get garbage collected. This is acceptable for the current app scale but means all watched DB streams stay open. |
| **Audio players** | ⚠️ Never disposed | `AudioService` has a `dispose()` method but it's never called. Two `AudioPlayer` instances live for the entire app lifetime. |
| **Notification streams** | ⚠️ Never closed | Static `StreamController`s in `NotificationService` are broadcast but never closed. Minor leak. |
| **Timer cleanup** | ✅ Good | `FocusTimer.build()` registers `ref.onDispose()` to cancel timer and subscriptions. |

### 6.4 Offline-Specific Performance

| Aspect | Status | Notes |
|--------|--------|-------|
| **No network calls** | ✅ Correct | Fully offline — no HTTP client, no REST/GraphQL, no cloud sync. |
| **SQLite as single data store** | ✅ Good | Single source of truth. Drift provides typed queries and migrations. |
| **Asset loading** | ✅ Standard | Audio files and Lottie animations are bundled as assets. |
| **Startup time** | ⚠️ Blocking async | `setupDependencyInjection()` is `await`ed in `main()`, which includes `FocusAudioHandler.init()` and `NotificationService.init()`. These are async platform channel calls that run sequentially. Consider parallelizing with `Future.wait()`. |

---

## 7. Security Audit (Offline App)

### 7.1 Threat Model

As a fully offline app with no network connectivity, the attack surface is minimal:

| Threat | Risk | Mitigation |
|--------|------|------------|
| **Local data theft** (rooted device) | Low | No sensitive data stored (focus sessions, tasks). No PII beyond what the user enters as task titles. |
| **SQL injection** | Very Low | Drift parameterizes queries automatically. Raw SQL queries use Dart string interpolation of known types (`int`, `String`), not user input. The enum index interpolation (`${SessionState.completed.index}`) is technically safe (it's an int literal) but fragile. |
| **Data tampering** | Very Low | SQLite DB is a local file. A rooted device could modify it, but there's no security-critical data. |
| **Notification content spoofing** | None | Notifications are generated locally by the app, not from external sources. |
| **Export data leakage** | None | No export/share feature exists. |

### 7.2 Data Storage

- **No encryption**: The SQLite database is unencrypted. For a focus timer app, this is acceptable — no sensitive data.
- **No authentication**: No user accounts, no biometric lock. Appropriate for the app's purpose.
- **Shared preferences**: Settings use a key-value Drift table, not `SharedPreferences`. Good — keeps everything in one place.

### 7.3 Platform Permissions

| Permission | Declared | Justified |
|------------|----------|-----------|
| `WAKE_LOCK` | ✅ | Yes — keeps timer running when screen off |
| `FOREGROUND_SERVICE` | ✅ | Yes — background task for audio_service |
| `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | ✅ | Yes — Android 14+ requires specific foreground service type |
| Network | ❌ Not requested | Correct — fully offline |
| Storage | ❌ Not requested | Correct — uses app-private directory |

### 7.4 Supply Chain

| Dependency | Risk Assessment |
|------------|----------------|
| `drift_flutter` / `drift` | ✅ Well-maintained, widely used |
| `audio_service` | ⚠️ Last major update was 2023 — monitor for Android compatibility |
| `audio_session` | ⚠️ Same maintainer as audio_service |
| `flutter_local_notifications` | ✅ Actively maintained |
| `forui` | ⚠️ Less established than Material/Cupertino — verify long-term maintenance |
| `audioplayers` | ✅ Widely used, actively maintained |
| `get_it` | ✅ Mature, stable |

### 7.5 Recommendations

1. **No immediate security concerns** for an offline focus timer app.
2. If user data ever becomes sensitive (journaling, personal notes), consider `sqflite_sqlcipher` or `drift`'s encryption support.
3. Keep `audio_service` and `audio_session` up to date — they interact with OS-level media APIs that change with each Android/iOS release.

---

## 8. Actionable Recommendations

### Priority 1 — High Impact, Low Effort

| # | Recommendation | Effort | Impact |
|---|---------------|--------|--------|
| 1 | **Delete `focus_controls.dart`** — dead code | 5 min | Reduces confusion |
| 2 | **Fix Project `copyWith`** — add sentinel pattern for nullable fields | 30 min | Prevents bugs |
| 3 | **Replace enum index in raw SQL** with a named constant or a `CASE WHEN` | 15 min | Prevents silent corruption |
| 4 | **Standardize interface declarations** to all use `abstract interface class` | 15 min | Consistency |
| 5 | **Remove duplicated `getIntensity`** from `activity_graph_utils.dart` | 5 min | DRY |
| 6 | **Remove legacy `startNoise`/`stopNoise`** from `AudioService` if unused | 10 min | Clean API |
| 7 | **Fix leading `/` in `appIconAsset`** path | 1 min | Correct asset resolution |

### Priority 2 — Medium Impact, Medium Effort

| # | Recommendation | Effort | Impact |
|---|---------------|--------|--------|
| 8 | **Extract form content into shared widgets** — a single `TaskFormContent` widget used by both screen and modal variants | 2-3 hours | Eliminates ~600 lines of duplication |
| 9 | **Migrate legacy providers** to Riverpod code-gen (`@riverpod`) | 2-3 hours | Consistent lifecycle, better tooling |
| 10 | **Add `Equatable` mixin** (or manual `==`/`hashCode`) to entities | 1 hour | Reduces unnecessary widget rebuilds |
| 11 | **Parallelize DI init** — use `Future.wait()` for independent async inits | 30 min | Faster startup |
| 12 | **Type-safe route arguments** — create argument record types per route instead of `dynamic` / `Map<String, dynamic>` | 1 hour | Compile-time safety |
| 13 | **Remove unused params** from `ActionMenuButton` | 10 min | Clean API |
| 14 | **Replace `Future.delayed(500ms)`** in notification tap handler with a `WidgetsBindingObserver` or a `Completer` pattern | 30 min | Reliable navigation |

### Priority 3 — High Impact, High Effort

| # | Recommendation | Effort | Impact |
|---|---------------|--------|--------|
| 15 | **Decompose `FocusTimer`** — extract audio coordination, notification management, and media session management into dedicated classes | 4-6 hours | Testable, maintainable, single responsibility |
| 16 | **Use SQL `ON DELETE CASCADE`** or recursive CTE for task deletion instead of Dart-side recursion | 2 hours | O(1) DB roundtrips instead of O(N) |
| 17 | **Add unit tests** for `FocusTimer` state machine transitions | 4-6 hours | Prevents regressions in complex state logic |
| 18 | **Convert to type-safe routing** (GoRouter or AutoRoute) | 4-6 hours | Eliminates entire class of runtime errors |

### Priority 4 — Nice to Have

| # | Recommendation | Effort | Impact |
|---|---------------|--------|--------|
| 19 | **Add `dispose` registration** in GetIt setup using `registerSingletonAsync` with `dispose:` parameter | 30 min | Clean OS resource release |
| 20 | **Close notification stream controllers** in a shutdown hook | 15 min | Clean lifecycle |
| 21 | **Add `shouldRepaint` optimization** to `YearGridPainter` | 30 min | Avoids unnecessary repaints |
| 22 | **Replace `_StatCard` context param** with normal `build` context | 10 min | Idiomatic Flutter |
| 23 | **Replace hardcoded `Colors.orange`** with a theme extension color | 10 min | Theme-safe |
| 24 | **Extract `timerPreferencesProvider` deduplication** — remove from one location | 10 min | Single source of truth |
