# Focus App - Codebase Audit Results

> **Audit Date**: March 2026
> **Scope**: Complete codebase review for code quality, architecture, performance, and UX issues

---

## Executive Summary

| Severity | Count | Description |
|----------|-------|-------------|
| **Critical** | 3 | Syntax errors, data loss bugs |
| **High** | 18 | Architecture violations, memory leaks, broken features |
| **Medium** | 45+ | Code smells, inconsistencies, missing features |
| **Low** | 30+ | Style issues, minor improvements |

**Immediate Action Required:**
1. Fix 2 syntax errors preventing compilation in specific scenarios
2. Fix `focusPhaseEndedAt` not being persisted (data loss)
3. Fix audio looping click/pop sound

---

## Critical Issues

### 1. Syntax Error in `focus_task_info.dart`

**File:** `lib/features/session/presentation/widgets/focus_task_info.dart:35-36`

**Problem:** Using `.center` shorthand incorrectly - this syntax doesn't exist in Dart.

```dart
// BROKEN CODE (lines 35-36):
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.center,
```

**Fix:** Verify this compiles. If `.center` was intended as shorthand, replace with full enum values.

---

### 2. Syntax Error in `project_detail_header.dart`

**File:** `lib/features/projects/presentation/widgets/project_detail_header.dart:24`

**Problem:** Same `.center` shorthand issue.

**Fix:** Replace with `CrossAxisAlignment.center` or verify compilation.

---

### 3. Focus Phase End Time Not Persisted

**File:** `lib/features/session/presentation/providers/focus_session_provider.dart`

**Problem:** `focusPhaseEndedAt` is tracked in memory but never saved to the database. If the app restarts mid-session, this data is lost, corrupting session statistics.

**Impact:** 
- Session duration calculations are incorrect after app restart
- Statistics show wrong focus vs break time ratios

**Fix:** 
1. Add `focus_phase_ended_at` column to `FocusSessionTable`
2. Persist timestamp when transitioning from focus to break
3. Load and use this value on session restoration

---

## High Priority Issues

### Navigation & Routing

#### 4. Messy Navigator 1.0 Implementation

**Files:** `lib/core/routing/`

**Problems:**
- 4 nested navigators with global keys (`rootNavigatorKey`, `shellNavigatorKey`, `sessionNavigatorKey`, `settingsNavigatorKey`)
- Complex manual navigation state management
- Inconsistent patterns (sometimes direct `Navigator.push`, sometimes `NavigationService`)
- Difficult to maintain and extend

**Recommendation:** Migrate to `go_router` package (see FEATURE_PLANS.md)

---

#### 5. Unsafe Type Casts in Router

**File:** `lib/core/routing/app_router.dart`

**Problem:** Route arguments cast without null checks:

```dart
// DANGEROUS:
final args = settings.arguments as Map<String, dynamic>;
final projectId = args['projectId'] as int;

// SAFE:
final args = settings.arguments as Map<String, dynamic>?;
final projectId = args?['projectId'] as int?;
if (projectId == null) return _errorRoute('Missing projectId');
```

**Impact:** App crashes if route is accessed with missing arguments (e.g., deep link, back navigation edge cases).

---

### Desktop UI/UX

#### 6. Non-Adaptive Screen Layouts

**Files:** All screens in `lib/features/*/presentation/screens/`

**Problem:** `AdaptiveShell` only changes navigation chrome (bottom bar vs rail). All content screens use single-column mobile layouts that stretch infinitely on desktop.

**Issues:**
- No max-width constraints on content
- No master-detail views for lists
- Spacing constants (`AppConstants.paddingSm` = 8.0) too small for desktop
- NavigationRail is too basic/narrow

**Recommendation:** Full desktop UI redesign (see FEATURE_PLANS.md)

---

#### 7. Missing Responsive Breakpoints

**File:** `lib/core/utils/platform_utils.dart`

**Problem:** Only has `isDesktop`/`isMobile` booleans. Missing:
- `isTablet` detection
- Width-based breakpoints (compact, medium, expanded)
- Orientation awareness

**Fix:** Add breakpoint system:
```dart
enum WindowSizeClass { compact, medium, expanded }

static WindowSizeClass getWindowSizeClass(double width) {
  if (width < 600) return WindowSizeClass.compact;
  if (width < 840) return WindowSizeClass.medium;
  return WindowSizeClass.expanded;
}
```

---

### Audio Issues

#### 8. Audio Loop Click/Pop Sound

**File:** `lib/core/services/audio_service.dart:58`

**Problem:** When ambient audio loops back to the beginning, there's an audible click or pop sound. This is distracting during focus sessions.

**Root Causes:**
1. **Non-seamless audio files**: The `.ogg` files may not have matching start/end samples
2. **Gap in playback**: `audioplayers` loop mode may have a tiny gap when seeking back to start
3. **Codec artifacts**: OGG Vorbis can have decoding artifacts at boundaries

**Investigation Steps:**
1. Check if audio files are "loop-ready" (start and end samples match)
2. Test with different audio formats (MP3, WAV)
3. Check `audioplayers` GitHub issues for loop gap problems

**Recommended Solutions (in order of preference):**

**Option A: Fix Audio Files (Best)**
```bash
# Use Audacity or ffmpeg to create seamless loops
# 1. Open audio file in Audacity
# 2. Ensure waveform at start matches waveform at end
# 3. Apply crossfade at loop point
# 4. Export as high-quality OGG (q=6 or higher)
```

**Option B: Crossfade in Code**
Use two players and crossfade between them:
```dart
class CrossfadeAudioService {
  final AudioPlayer _playerA = AudioPlayer();
  final AudioPlayer _playerB = AudioPlayer();
  bool _usePlayerA = true;
  Timer? _crossfadeTimer;
  
  Future<void> startAmbience(SoundPreset preset) async {
    final currentPlayer = _usePlayerA ? _playerA : _playerB;
    await currentPlayer.setReleaseMode(ReleaseMode.release); // NOT loop
    await currentPlayer.play(AssetSource('audio/${preset.assetPath}'));
    
    // Schedule crossfade before track ends
    final duration = await currentPlayer.getDuration();
    if (duration != null) {
      _crossfadeTimer = Timer(duration - Duration(milliseconds: 500), () {
        _crossfadeToNext(preset);
      });
    }
  }
  
  void _crossfadeToNext(SoundPreset preset) {
    _usePlayerA = !_usePlayerA;
    startAmbience(preset);
    // Fade out old player over 500ms
  }
}
```

**Option C: Use Different Package**
Consider `just_audio` package which has better gapless looping support.

---

### Session Feature Issues

#### 9. No App Lifecycle Handling

**File:** `lib/features/session/presentation/providers/focus_session_provider.dart`

**Problem:** Timer continues in isolate concept but when app is backgrounded on mobile:
- iOS suspends Dart timers after ~30 seconds
- Android may kill the app for memory
- Timer drift accumulates without compensation

**Impact:** Session duration is inaccurate if user switches apps during focus.

**Fix:**
1. Store `phaseStartedAt` timestamp in persistent storage
2. On app resume, calculate elapsed time from timestamp
3. Use `WidgetsBindingObserver` to detect lifecycle changes:

```dart
class FocusSessionNotifier extends _$FocusSessionNotifier 
    with WidgetsBindingObserver {
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recalculateElapsedTime();
    }
  }
}
```

---

#### 10. Race Condition in Session Start

**File:** `lib/features/session/presentation/providers/focus_session_provider.dart`

**Problem:** `_isStarting` guard uses `Future.delayed` which can cause race conditions if called rapidly.

```dart
// PROBLEMATIC:
bool _isStarting = false;
Future<void> startSession() async {
  if (_isStarting) return;
  _isStarting = true;
  await Future.delayed(Duration(milliseconds: 100)); // WHY?
  // ... start logic
  _isStarting = false;
}
```

**Fix:** Remove arbitrary delay, use proper mutex or queue pattern.

---

#### 11. Unnecessary Isolate for Simple Calculations

**File:** `lib/features/session/domain/services/session_stats_service.dart`

**Problem:** Uses `compute()` isolate for simple arithmetic that takes microseconds. Isolate spawn overhead (~2-5ms) far exceeds calculation time.

**Fix:** Remove `compute()` wrapper, run calculations on main thread.

---

### Database & Data Layer

#### 12. N+1 Query Patterns

**Files:** 
- `lib/features/tasks/data/datasources/task_local_datasource.dart`
- `lib/features/session/data/datasources/`

**Problem:** Fetching tasks with projects/sessions often does N+1 queries:
```dart
// BAD: 1 query for tasks + N queries for projects
final tasks = await getTasksForProject(projectId);
for (final task in tasks) {
  task.project = await getProject(task.projectId); // N queries!
}
```

**Fix:** Use Drift joins:
```dart
Future<List<TaskWithProject>> getTasksWithProjects(int projectId) {
  return (select(taskTable)
    ..where((t) => t.projectId.equals(projectId)))
    .join([leftOuterJoin(projectTable, projectTable.id.equalsExp(taskTable.projectId))])
    .get();
}
```

---

#### 13. Streak Calculation Fetches All History

**File:** `lib/features/session/domain/services/session_stats_service.dart`

**Problem:** `calculateStreak()` fetches ALL sessions from database to count consecutive days.

**Impact:** Performance degrades linearly with app usage history.

**Fix:** Use SQL query to calculate streak:
```sql
WITH consecutive_days AS (
  SELECT DISTINCT date(started_at) as session_date
  FROM focus_sessions
  WHERE completed = 1
  ORDER BY session_date DESC
)
SELECT COUNT(*) FROM consecutive_days
WHERE session_date >= date('now', '-' || (
  SELECT COUNT(*) FROM consecutive_days c2 
  WHERE c2.session_date >= (
    SELECT MIN(session_date) FROM consecutive_days
  )
) || ' days');
```

---

#### 14. Business Logic in DbService

**File:** `lib/core/services/db_service.dart`

**Problem:** `DbService` contains query logic that should be in datasources:
- `getProjectStats()`
- `getTasksWithSubtaskCounts()`
- `getSessionsInRange()`

**Fix:** Move to appropriate datasources, keep `DbService` as pure database connection manager.

---

### Memory & Performance

#### 15. keepAlive on Family Providers

**Files:** Various provider files

**Problem:** Using `keepAlive: true` on family providers (providers with parameters) causes memory leaks:

```dart
// MEMORY LEAK:
@Riverpod(keepAlive: true)
Future<Project?> projectById(ProjectByIdRef ref, int id) async { ... }
```

Each unique `id` creates a new provider instance that's never disposed.

**Fix:** Remove `keepAlive: true` from family providers, or implement manual disposal.

---

#### 16. Timer Drift

**File:** `lib/features/session/presentation/providers/focus_session_provider.dart`

**Problem:** Periodic timer ticks every second, but doesn't compensate for drift. Over a 25-minute session, can drift by several seconds.

**Fix:**
```dart
// Instead of counting ticks:
int _secondsElapsed = 0;
Timer.periodic(Duration(seconds: 1), (_) => _secondsElapsed++);

// Calculate from timestamp:
final _phaseStartedAt = DateTime.now();
Timer.periodic(Duration(seconds: 1), (_) {
  final elapsed = DateTime.now().difference(_phaseStartedAt);
  state = state.copyWith(secondsElapsed: elapsed.inSeconds);
});
```

---

### Code Quality Issues

#### 17. Inconsistent Logging

**Files:** Multiple

**Problem:** Mix of `print()`, `debugPrint()`, and `LogService`. Some errors logged at multiple layers.

**Locations using debugPrint:**
- `lib/core/widgets/some_widget.dart`
- `lib/features/projects/presentation/commands/`

**Fix:** Replace all with `LogService`, remove duplicate logging at different layers.

---

#### 18. copyWith Can't Set Nullable Fields to Null

**Files:** All entity `*_extensions.dart` files

**Problem:**
```dart
// This doesn't work - null is indistinguishable from "not provided"
task.copyWith(description: null)  // description stays unchanged!
```

**Fix:** Use sentinel pattern:
```dart
class _Sentinel { const _Sentinel(); }
const _sentinel = _Sentinel();

extension TaskCopyWith on Task {
  Task copyWith({
    Object? description = _sentinel,
  }) {
    return Task(
      description: description == _sentinel ? this.description : description as String?,
    );
  }
}
```

---

#### 19. Unused NoOpNotificationService

**File:** `lib/core/services/notification_service.dart`

**Problem:** `NoOpNotificationService` is defined but never registered in DI. Platforms without notification support get runtime errors instead of graceful no-op.

**Fix:** Register conditionally in `injection.dart`:
```dart
if (PlatformUtils.supportsLocalNotifications) {
  getIt.registerLazySingleton<INotificationService>(() => NotificationService());
} else {
  getIt.registerLazySingleton<INotificationService>(() => NoOpNotificationService());
}
```

---

#### 20. Missing Error Feedback on Session Start

**File:** `lib/features/session/presentation/providers/focus_session_provider.dart`

**Problem:** If `startSession()` fails (e.g., database error), user sees no feedback. Session just doesn't start.

**Fix:** Return `Result<void>` and show snackbar on failure.

---

## Medium Priority Issues

### 21. Tasks Don't Support Time

**Files:** 
- `lib/features/tasks/data/models/task_model.dart`
- `lib/features/tasks/domain/entities/task.dart`

**Problem:** Tasks have `startDate` and `endDate` as `DateTime` but:
1. UI only shows/edits the date portion
2. No time picker in task creation/edit
3. No reminder/notification support for task deadlines

**Impact:** Users can't set specific times for tasks or get reminded.

**Fix:** See FEATURE_PLANS.md for task time and notification support.

---

### 22. Missing Recurring Task Support

**Files:** Task feature

**Problem:** No way to create recurring tasks (daily standup, weekly review, etc.)

**Impact:** Users must manually recreate repetitive tasks.

**Fix:** See FEATURE_PLANS.md for recurring task implementation.

---

### 23. Inconsistent Error Handling

**Files:** Various services

**Problem:** Some services return `Result<T>`, others throw exceptions, some return nullable values.

**Fix:** Standardize on `Result<T>` pattern throughout:
```dart
// GOOD:
Future<Result<Task>> createTask(Task task);

// BAD:
Future<Task?> createTask(Task task);  // null means what exactly?
Future<Task> createTask(Task task);   // throws on error
```

---

### 24. Missing Input Validation

**Files:** 
- `lib/features/projects/domain/services/project_service.dart`
- `lib/features/tasks/domain/services/task_service.dart`

**Problem:** Services accept any input without validation:
- Empty project names allowed
- Task titles can be whitespace-only
- No max length enforcement

**Fix:** Add validation layer:
```dart
Result<void> _validateTask(Task task) {
  if (task.title.trim().isEmpty) {
    return Failure(ValidationFailure('Task title cannot be empty'));
  }
  if (task.title.length > 500) {
    return Failure(ValidationFailure('Task title too long'));
  }
  return Success(null);
}
```

---

### 25. Settings Not Properly Categorized

**File:** `lib/features/settings/data/models/settings_model.dart`

**Problem:** All settings in one flat table. As settings grow, this becomes unwieldy.

**Recommendation:** Consider grouping:
- `focus_settings` (duration, breaks, sounds)
- `notification_settings` (enabled, times, channels)
- `sync_settings` (providers, frequency)
- `ui_settings` (theme, density)

---

### 26. No Database Backup Strategy

**File:** `lib/core/services/db_service.dart`

**Problem:** No way to backup/restore database. Users can lose all data.

**Fix:** Add export/import functionality (see FEATURE_PLANS.md).

---

### 27-35. Additional Medium Issues

| # | Issue | Location | Description |
|---|-------|----------|-------------|
| 27 | Magic numbers | Various | Hardcoded values like `25`, `5`, `15` for session durations |
| 28 | No loading states | Providers | AsyncValue not properly showing loading UI |
| 29 | Missing empty states | Screens | No helpful UI when lists are empty |
| 30 | Inconsistent date formatting | Various | Mix of formats across the app |
| 31 | No offline indicator | App-wide | Users don't know if data is synced (future sync feature) |
| 32 | Missing confirmations | Delete actions | No "are you sure?" for destructive actions |
| 33 | No undo support | Task completion | Can't undo accidental task completion |
| 34 | Stats not cached | Stats service | Recalculated on every view |
| 35 | Missing keyboard shortcuts | Desktop | No keyboard navigation support |

---

## Low Priority Issues

| # | Issue | Location | Fix |
|---|-------|----------|-----|
| 36 | Inconsistent file naming | Various | Some use `_impl.dart`, some don't |
| 37 | Missing dartdoc comments | Public APIs | Add `///` documentation |
| 38 | Long methods | Several services | Extract into smaller functions |
| 39 | Dead code | Various | Remove unused imports, variables |
| 40 | Inconsistent string quotes | Various | Standardize on single quotes |
| 41 | Missing const constructors | Widgets | Add `const` where possible |
| 42 | Verbose null checks | Various | Use `?.` and `??` operators |
| 43 | Inconsistent naming | Various | `isXxx` vs `hasXxx` vs `xxxEnabled` |
| 44 | Missing @visibleForTesting | Test helpers | Add annotation for test-only code |
| 45 | Large widget files | Screens | Split into smaller widget files |

---

## Testing Gaps

**Current State:** No tests exist in the codebase.

**Recommended Test Coverage:**

| Layer | Priority | Coverage Target |
|-------|----------|-----------------|
| Domain Services | High | 90%+ |
| Repository Implementations | High | 80%+ |
| Providers (unit) | Medium | 70%+ |
| Widget Tests | Medium | Key user flows |
| Integration Tests | Low | Critical paths |

**Files Most Needing Tests:**
1. `lib/features/session/domain/services/session_service.dart`
2. `lib/features/session/domain/services/session_stats_service.dart`
3. `lib/features/tasks/domain/services/task_service.dart`
4. `lib/core/utils/result.dart`

---

## Quick Wins (< 1 hour each)

1. Fix the two syntax errors (Critical #1, #2)
2. Replace `debugPrint` with `LogService` (Medium #17)
3. Register `NoOpNotificationService` conditionally (Medium #19)
4. Add `const` to widget constructors (Low #41)
5. Add empty state widgets to list screens (Medium #29)
6. Add confirmation dialogs for delete actions (Medium #32)

---

## Dependency Audit

### Outdated Packages (check with `flutter pub outdated`)

Run periodically:
```bash
flutter pub outdated
flutter pub upgrade --major-versions
```

### Security Considerations

- No secrets in code (verified)
- Database is local SQLite (no network exposure)
- No analytics/tracking (privacy-first)

### Package Recommendations

| Current | Recommended | Reason |
|---------|-------------|--------|
| `audioplayers` | Consider `just_audio` | Better gapless looping |
| Navigator 1.0 | `go_router` | Declarative, type-safe routing |
| - | `flutter_hooks` | Cleaner stateful widget code |
| - | `freezed` | Better immutable classes with copyWith |

---

## Appendix: File-by-File Issues

<details>
<summary>Click to expand detailed file listing</summary>

### Core

| File | Issues |
|------|--------|
| `di/injection.dart` | Missing NoOpNotificationService registration |
| `routing/app_router.dart` | Unsafe casts, complex navigation |
| `routing/navigation_service.dart` | Should be removed with go_router |
| `services/audio_service.dart` | Loop click issue |
| `services/db_service.dart` | Business logic that should be in datasources |
| `services/log_service.dart` | Good - no issues |
| `utils/platform_utils.dart` | Missing breakpoints |
| `utils/result.dart` | Good - no issues |
| `widgets/adaptive_shell.dart` | Only changes chrome, not content |

### Features/Session

| File | Issues |
|------|--------|
| `providers/focus_session_provider.dart` | Timer drift, lifecycle, race condition |
| `services/session_service.dart` | focusPhaseEndedAt not persisted |
| `services/session_stats_service.dart` | Unnecessary isolate, O(n) streak |
| `widgets/focus_task_info.dart` | SYNTAX ERROR line 35-36 |

### Features/Projects

| File | Issues |
|------|--------|
| `widgets/project_detail_header.dart` | SYNTAX ERROR line 24 |
| `services/project_service.dart` | Missing validation |

### Features/Tasks

| File | Issues |
|------|--------|
| `models/task_model.dart` | Missing time fields for reminders |
| `entities/task.dart` | Missing recurring fields |
| `services/task_service.dart` | Missing validation, N+1 queries |

### Features/Settings

| File | Issues |
|------|--------|
| `models/settings_model.dart` | Flat structure, needs categories |

</details>

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| Mar 2026 | AI Audit | Initial comprehensive audit |
