# Focus App — System Design & Interview Prep Guide

> A deep reference for understanding how every component interacts, the reasoning behind each architectural choice, and how to articulate them in technical interviews.

---

## Table of Contents

1. [System Overview & Component Map](#1-system-overview--component-map)
2. [Data Flow Architecture](#2-data-flow-architecture)
3. [Focus Session State Machine](#3-focus-session-state-machine)
4. [Audio & Media Notification System](#4-audio--media-notification-system)
5. [Notification System Deep Dive](#5-notification-system-deep-dive)
6. [Database & Persistence Strategy](#6-database--persistence-strategy)
7. [State Management Architecture](#7-state-management-architecture)
8. [Navigation Architecture](#8-navigation-architecture)
9. [Key Design Decisions & Trade-offs](#9-key-design-decisions--trade-offs)
10. [Interview Q&A](#10-interview-qa)

---

## 1. System Overview & Component Map

### 1.1 What the App Does

**Focus** is a full-offline Pomodoro/deep-work timer app for Android, iOS, Linux, macOS, and Windows. Users can:

- Create **projects** containing **tasks** (with subtasks, up to depth N)
- Start **focus sessions** tied to a task, or **quick sessions** with no task
- Each session follows a **focus → break → auto-cycle** pattern
- Control sessions from the app, **lock-screen**, **notification shade**, or **headphone buttons**
- Track statistics: completion streaks, daily/weekly/yearly activity heatmaps
- Configure ambience sounds, alarm sounds, and timer durations

### 1.2 Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Flutter App                                │
│                                                                     │
│  ┌──────────────┐   ┌──────────────────┐   ┌──────────────────┐   │
│  │  UI Screens  │──▶│ Riverpod Providers│──▶│     Commands     │   │
│  │  & Widgets   │◀──│  (Reactive State) │   │  (Orchestration) │   │
│  └──────────────┘   └────────┬─────────┘   └──────────────────┘   │
│                              │                                      │
│                    ┌─────────▼──────────┐                          │
│                    │   Domain Entities   │                          │
│                    │   & Interfaces      │                          │
│                    └─────────┬──────────┘                          │
│                              │                                      │
│  ┌──────────┐    ┌──────────▼──────────┐    ┌──────────────────┐  │
│  │  GetIt   │───▶│    Repositories     │───▶│   Data Sources   │  │
│  │  (DI)    │    │  (Interface Impls)  │    │  (Drift Queries) │  │
│  └──────────┘    └─────────────────────┘    └───────┬──────────┘  │
│                                                      │             │
│                                              ┌───────▼──────────┐ │
│                                              │  SQLite (Drift)  │ │
│                                              │  Local Database   │ │
│                                              └──────────────────┘ │
│                                                                     │
│  ┌────────────────┐  ┌───────────────┐  ┌───────────────────────┐ │
│  │  AudioService  │  │ AudioSession  │  │ NotificationService   │ │
│  │  (audioplayers)│  │   Manager     │  │ (flutter_local_notif) │ │
│  └───────┬────────┘  └──────┬────────┘  └──────────┬────────────┘ │
│          │                  │                       │              │
│  ┌───────▼──────────────────▼───────────────────────▼────────────┐ │
│  │                  FocusAudioHandler                             │ │
│  │               (audio_service bridge)                           │ │
│  └───────────────────────────┬───────────────────────────────────┘ │
└──────────────────────────────┼─────────────────────────────────────┘
                               │
               ┌───────────────▼───────────────┐
               │        Operating System        │
               │                                │
               │  ┌─────────────────────────┐  │
               │  │ MediaSession / Now Playing│  │
               │  │ (Android / iOS)          │  │
               │  └────────────┬────────────┘  │
               │               │                │
               │  ┌────────────▼────────────┐  │
               │  │ Lock Screen Controls    │  │
               │  │ Notification Shade      │  │
               │  │ Bluetooth/Headset Btns  │  │
               │  └─────────────────────────┘  │
               └────────────────────────────────┘
```

### 1.3 Feature Dependency Graph

```
                     ┌─────────────┐
                     │    core      │
                     │ (services,   │
                     │  DI, theme,  │
                     │  routing)    │
                     └──────┬──────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐       ┌─────▼─────┐      ┌─────▼─────┐
   │settings │       │ projects  │      │   tasks   │
   └────┬────┘       └─────┬─────┘      └──┬──┬────┘
        │                   │               │  │
        │            ┌──────┘               │  │
        │            │    ┌─────────────────┘  │
   ┌────▼────────────▼────▼──┐           ┌─────▼─────┐
   │        focus            │           │ all_tasks  │
   │  (reads settings,       │           │ (view over │
   │   completes tasks)      │           │  tasks +   │
   └─────────┬───────────────┘           │  projects) │
             │                           └────────────┘
        ┌────▼────┐
        │  home   │  (dashboard — reads from tasks, projects, focus)
        └─────────┘
```

---

## 2. Data Flow Architecture

### 2.1 The Three Data Paths

The app has three distinct data flow patterns:

#### Path A: UI → Provider → Repository → DB (Write)

```
User taps "Create Task"
  → TaskCommands.createTask()          // Orchestration
    → Navigator.push(CreateTaskScreen) // Navigation
      → User fills form, taps Save
        → TaskNotifier.createTask()    // Riverpod notifier
          → ITaskRepository.createTask()  // Domain interface
            → TaskLocalDataSource.insertTask()  // DB write
              → Drift INSERT + recalculateDailyStats()
```

#### Path B: DB → Stream → Provider → UI (Read / Watch)

```
SQLite row changes
  → Drift watchable query emits new data
    → Repository maps Drift model → Domain entity
      → StreamProvider/Notifier receives update
        → Riverpod notifies watching widgets
          → Widget rebuilds with new data
```

#### Path C: Timer Tick → In-Memory State → Periodic DB Sync

```
Timer.periodic(1 second, _tick)
  → Update FocusSession in-memory (elapsedSeconds++)
    → Riverpod state update → UI rebuilds (every tick)
    → Every 10 ticks: persist to DB (crash recovery)
    → Phase transition? → DB write + notification + audio + media session
```

### 2.2 Stats Aggregation Pipeline

```
Session INSERT/UPDATE/DELETE
  → DataSource calls _recalcForCompanion(dateKey)
    → AppDatabase.recalculateDailyStatsForDate(dateKey)
      → Raw SQL: INSERT OR REPLACE INTO daily_session_stats_table
         SELECT date, COUNT(*), SUM(MIN(elapsed, max))
         FROM focus_session_table
         WHERE date = :dateKey AND state = completed
    → Materialized in DailySessionStatsTable

Activity graph reads from pre-aggregated table:
  → dailyStatsForRangeProvider(rangeKey)
    → ITaskStatsRepository.watchDailyStatsForRange()
      → TaskStatsLocalDataSource.watchDailyStatsForRange()
        → SELECT * FROM daily_session_stats_table
           WHERE date BETWEEN :start AND :end
```

**Why pre-aggregate?** The activity graph shows an entire year (365 cells). Computing `COUNT(*)` and `SUM()` for each day on every render would be expensive. Instead, a denormalized table is maintained incrementally — each session CRUD triggers a recalculation for just that one day.

---

## 3. Focus Session State Machine

### 3.1 States

```
                    ┌─────────┐
     createSession()│  idle   │  (in-memory only, not in DB)
                    └────┬────┘
                         │ startTimer()
                    ┌────▼────┐
              ┌─────│ running │◄────────────┐
              │     └────┬────┘             │
              │          │                  │
   pauseSession()       │ timer reaches    │ resumeSession()
              │          │ focusDuration    │ (from paused, was in focus)
              │     ┌────▼────┐             │
              │     │ onBreak │─────────────┤
              │     └────┬────┘             │
              │          │                  │
              │   pauseSession()            │
              │          │                  │
              ▼     ┌────▼────┐             │
         ┌────────┐ │ paused  │─────────────┘
         │ paused │ └────┬────┘  resumeSession()
         └───┬────┘      │      (from paused, was on break → onBreak)
             │           │
             │    ┌──────▼──────────────┐
             │    │ Timer reaches       │
             │    │ breakDuration       │
             │    └──────┬──────────────┘
             │           │
             │    ┌──────▼──────┐    _startNextCycle()    ┌─────────┐
             │    │ completed   │─────────────────────────▶│ running │
             │    └─────────────┘  (auto-creates new       └─────────┘
             │                      session in DB)
             │
      cancelSession()  completeSessionEarly()  completeTaskAndSession()
             │                    │                         │
        ┌────▼────┐       ┌──────▼──────┐           ┌──────▼──────┐
        │cancelled│       │ completed   │           │ completed   │
        └─────────┘       └─────────────┘           │ + task done │
                                                    └─────────────┘
```

### 3.2 The `breakStartElapsed` Field

**Problem solved**: When a user skips from focus → break, `elapsedSeconds` hasn't reached `focusDurationMinutes * 60`. If we inflate it to the full duration for break calculation, stats are corrupted. If we don't, break progress calculation breaks.

**Solution**: A transient (non-persisted) field `breakStartElapsed` records the *actual* elapsed seconds when the focus phase ended. Break progress is calculated as `elapsedSeconds - breakStartElapsed`.

```
Focus starts:    elapsedSeconds = 0,    breakStartElapsed = null
User skips at:   elapsedSeconds = 180,  breakStartElapsed = 180  (3 min actual)
Break ticks:     elapsedSeconds = 181,  break elapsed = 181 - 180 = 1 sec
Break completes: elapsedSeconds = 480,  break elapsed = 480 - 180 = 300 (5 min break)
```

Stats record: `MIN(elapsed_seconds, focus_duration * 60)` = `MIN(480, 1500)` = 480 seconds. But the actual focus time was 180 seconds, which is captured in `breakStartElapsed`. The DB query uses `MIN()` as a cap, not as the actual focus time.

**Why transient?** The `keepAlive: true` Riverpod provider survives navigation. On app restart, abandoned sessions are marked incomplete and stats use the DB `elapsedSeconds` value with `MIN()` capping. No need to persist the field.

### 3.3 Auto-Cycle Mechanism

When break completes:
1. `_handleSessionCompleted()` marks the current session as `completed` in DB
2. Keeps the completed session in state (not `null`) — **critical**: setting `null` would trigger auto-pop
3. Calls `_startNextCycle()` which creates a **new** session in DB with `state: running`
4. Sets the new session as state — UI seamlessly transitions from break→focus

The old completed session and new running session are two distinct DB rows.

---

## 4. Audio & Media Notification System

### 4.1 Three Audio Systems Working Together

The app uses three complementary audio packages, each with a distinct role:

```
┌────────────────────────────────────────────────────────────────┐
│                        Focus App                                │
│                                                                  │
│  ┌──────────────────────┐                                       │
│  │    AudioService       │  App-level audio player               │
│  │    (audioplayers)     │                                       │
│  │                       │  _alarmPlayer → one-shot alarm sounds │
│  │                       │  _bgPlayer → looping ambience sounds  │
│  └──────────────────────┘                                       │
│                                                                  │
│  ┌──────────────────────┐                                       │
│  │  AudioSessionManager  │  OS audio focus negotiation           │
│  │  (audio_session)      │                                       │
│  │                       │  Handles:                             │
│  │                       │  • Audio focus (duck/pause others)    │
│  │                       │  • Headphone unplug → auto-pause      │
│  │                       │  • Phone call interruption → pause    │
│  └──────────────────────┘                                       │
│                                                                  │
│  ┌──────────────────────┐                                       │
│  │  FocusAudioHandler    │  OS media session bridge              │
│  │  (audio_service)      │                                       │
│  │                       │  Provides:                            │
│  │                       │  • MediaStyle notification            │
│  │                       │  • Lock screen controls               │
│  │                       │  • Bluetooth/headset button events    │
│  │                       │  • Background execution keepalive     │
│  └──────────────────────┘                                       │
└──────────────────────────────────────────────────────────────────┘
```

### 4.2 How `audio_service` Works Under the Hood

#### Android

1. **`AudioService.init()`** is called at app startup.
2. This starts a **foreground service** (`com.ryanheise.audioservice.AudioService`) with `foregroundServiceType="mediaPlayback"`.
3. The foreground service creates a **MediaSession** — Android's standard mechanism for media apps.
4. A **MediaStyle notification** is created and bound to the MediaSession.
5. The notification shows:
   - **Small icon** (configured via `androidNotificationIcon: 'mipmap/launcher_icon'`)
   - **Large image** (from `MediaItem.artUri` — set to the app icon via `android.resource://` URI)
   - **Title/subtitle** (from `MediaItem.title` and `MediaItem.artist`)
   - **Action buttons** (from `PlaybackState.controls` — play/pause, skip, stop)
   - **Progress bar** (from `PlaybackState.updatePosition` and `duration`)
6. When the user taps a button on the notification or lock screen:
   - Android sends the action to the `AudioService` foreground service
   - The service calls the corresponding method on `FocusAudioHandler` (`play()`, `pause()`, `stop()`, `skipToNext()`)
   - The handler delegates to `FocusTimer` via the `onAction` callback
   - `FocusTimer` updates state → Riverpod notifies UI → `_updateMediaSession()` syncs back to the notification

#### iOS

1. **`AudioService.init()`** configures the **Now Playing** info center.
2. iOS doesn't use a foreground service — instead, the `audio_service` plugin uses a background audio mode.
3. Lock screen controls appear automatically via `MPNowPlayingInfoCenter` and `MPRemoteCommandCenter`.
4. The control flow is the same as Android: button tap → handler method → `onAction` callback → `FocusTimer`.

#### The Relay Pattern

```
OS Button Tap (notification/lock-screen/headset)
  → audio_service foreground service (Android) / MPRemoteCommandCenter (iOS)
    → FocusAudioHandler.play() / .pause() / .stop() / .skipToNext()
      → onAction?.call('resume') / 'pause' / 'stop' / 'skip'
        → FocusTimer._handleNotificationAction(actionId)
          → pauseSession() / resumeSession() / stopCycle() / skipToNextPhase()
            → state update → Riverpod rebuilds
            → _updateMediaSession() → FocusAudioHandler.updatePlaybackState()
              → audio_service updates OS notification/lock-screen
```

The handler is a **dumb relay** — it owns no state, no timer, no audio. It only translates OS-level media actions into app-level string action IDs, and accepts state updates to push back to the OS.

### 4.3 Headphone Unplug & Interruption Handling

```
Headphone unplugged
  → audio_session package fires "becoming noisy" event
    → AudioSessionManager.onBecomingNoisy callback
      → FocusTimer.pauseSession()

Phone call arrives
  → audio_session fires interruption begin event
    → AudioSessionManager.onInterruption(shouldPause: true)
      → FocusTimer.pauseSession()

Phone call ends
  → audio_session fires interruption end event
    → AudioSessionManager.onInterruption(shouldPause: false)
      → FocusTimer.resumeSession()
```

### 4.4 Audio Focus

```
User taps Play
  → FocusTimer.startTimer()
    → AudioSessionManager.activate()  // Request OS audio focus
      → audio_session plugin requests focus with:
         - type: AudioSessionType.speech (duck other audio)
         - configuration: AndroidAudioAttributes(usage: usage.media)
    → Start ambience playback
    → Update media session (notification appears)

Session ends / cancelled
  → FocusTimer._clearMediaSession()
    → FocusAudioHandler.clearSession()  // Clear notification
    → AudioSessionManager.deactivate()  // Release audio focus
```

---

## 5. Notification System Deep Dive

### 5.1 Two Notification Channels

| Channel | Purpose | Priority | Behaviour |
|---------|---------|----------|-----------|
| **Focus Session** (`focus_session_channel`) | Ongoing timer notification | Low | Ongoing (can't swipe away), reused by `audio_service` for MediaStyle |
| **Alarm** (`focus_alarm_channel`) | Phase-complete alerts | High | One-shot, auto-dismisses, sound/vibration |

### 5.2 Notification Lifecycle

```
Session starts (Play tapped)
  → audio_service creates MediaStyle notification (Focus Session channel)
  → Notification shows: app icon, "Focus", task name, play/pause/skip/stop buttons

Focus phase completes
  → FocusTimer._handleFocusCompleted()
    → NotificationService.showAlarmNotification("Break Time!", "Take a 5min break")
    → Updates MediaStyle notification: "Break", task name
    → Plays alarm sound

Break phase completes
  → FocusTimer._handleSessionCompleted()
    → NotificationService.showAlarmNotification("Break Over!", "Starting next focus...")
    → _startNextCycle() → Updates MediaStyle: "Focus", task name

Session ends (cancel/complete/stop)
  → NotificationService.cancelFocusNotification()
  → FocusAudioHandler.clearSession() → MediaStyle notification disappears
  → NotificationService.showAlarmNotification("Session Complete!", "...")
```

### 5.3 Notification Action Handling

When the user taps a notification action button on `flutter_local_notifications` channel:

```
Tap action button
  → @pragma('vm:entry-point') onNotificationResponse (background)
  → OR: NotificationService._onNotificationAction (foreground)
    → _actionController.add(actionId)
      → FocusTimer._notificationActionSub listens
        → _handleNotificationAction(actionId)
```

When the user taps the notification body:

```
Tap notification body
  → NotificationService._onNotificationTap
    → _tapController.add(payload)
      → If payload == 'focus_session' → navigateToFocusSession()
```

When the app launches from a notification tap:

```
App cold start from notification
  → NotificationService.init()
    → getNotificationAppLaunchDetails()
      → If notification was tapped and payload is present
        → Future.delayed(500ms) → navigateToFocusSession()
```

The 500ms delay is a pragmatic workaround — the widget tree needs time to mount before navigation can happen. A more robust solution would use `WidgetsBindingObserver`.

---

## 6. Database & Persistence Strategy

### 6.1 Schema

```sql
-- Projects
CREATE TABLE project_table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  start_date INTEGER,     -- DateTime as milliseconds
  deadline INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Tasks (self-referencing tree)
CREATE TABLE task_table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  project_id INTEGER NOT NULL REFERENCES project_table(id) ON DELETE CASCADE,
  parent_task_id INTEGER REFERENCES task_table(id),  -- NULL = root task
  title TEXT NOT NULL,
  description TEXT,
  priority INTEGER NOT NULL,  -- intEnum: 0=critical, 1=high, 2=medium, 3=low
  start_date INTEGER,
  end_date INTEGER,
  depth INTEGER NOT NULL DEFAULT 0,
  is_completed INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Focus Sessions
CREATE TABLE focus_session_table (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id INTEGER REFERENCES task_table(id) ON DELETE CASCADE,  -- NULL = quick session
  focus_duration_minutes INTEGER NOT NULL,
  break_duration_minutes INTEGER NOT NULL,
  start_time INTEGER NOT NULL,
  end_time INTEGER,
  state INTEGER NOT NULL,  -- intEnum: SessionState
  elapsed_seconds INTEGER NOT NULL DEFAULT 0
);

-- Pre-aggregated daily stats (materialized view)
CREATE TABLE daily_session_stats_table (
  date TEXT PRIMARY KEY,           -- ISO 'YYYY-MM-DD'
  completed_sessions INTEGER NOT NULL,
  total_sessions INTEGER NOT NULL,
  focus_seconds INTEGER NOT NULL
);

-- Key-value settings
CREATE TABLE settings_table (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

### 6.2 Indices

```sql
CREATE INDEX idx_focus_session_task_id ON focus_session_table(task_id);
CREATE INDEX idx_focus_session_start_time ON focus_session_table(start_time);
CREATE INDEX idx_task_project_id ON task_table(project_id);
CREATE INDEX idx_task_parent_task_id ON task_table(parent_task_id);
CREATE INDEX idx_task_priority ON task_table(priority);
CREATE INDEX idx_task_end_date ON task_table(end_date);
CREATE INDEX idx_task_is_completed ON task_table(is_completed);
CREATE INDEX idx_task_created_at ON task_table(created_at);
```

### 6.3 Migration Strategy

The database is at schema version 10. Migrations are applied sequentially:

- **v1**: Initial schema
- **v2–v4**: Destructive recreations (early development, acceptable data loss)
- **v5**: Added settings table
- **v6**: Added daily_session_stats materialized view
- **v7**: Backfilled daily stats from existing sessions
- **v8–v9**: Schema refinements (task_id nullable, index recreation)
- **v10**: Added depth column to task_table

**Lesson**: Early destructive migrations are fine during development. Once users have real data, all migrations must be non-destructive with careful ALTER TABLE / data migration.

### 6.4 Crash Recovery Strategy

During a focus session:
- The `FocusSession` exists in-memory as the Riverpod `FocusTimer` state (keepAlive).
- Every 10 seconds, the in-memory state is persisted to SQLite via `_repository.updateSession()`.
- On app restart:
  - `_cleanupAbandonedSessions()` queries for sessions with state `running`, `paused`, or `onBreak`.
  - If any are found (and they don't match the current in-memory session), they're marked as `incomplete`.
  - This means the user loses at most ~10 seconds of elapsed time on a crash.

---

## 7. State Management Architecture

### 7.1 The Dual-Container Pattern

```
┌─────────────────────────────────────────────┐
│                  GetIt                       │
│  (Imperative, one-time setup, singletons)   │
│                                              │
│  AppDatabase ─▶ DataSources ─▶ Repositories │
│  AudioService                                │
│  FocusAudioHandler                           │
│  NotificationService                         │
│  AudioSessionManager                         │
└─────────────────────────────────────────────┘
                     │
                     ▼ (injected into providers via getIt<T>() or ref.watch)
┌─────────────────────────────────────────────┐
│                Riverpod                      │
│  (Reactive, lifecycle-managed, watchable)    │
│                                              │
│  FocusTimer (keepAlive)                      │
│  TaskNotifier (keepAlive)                    │
│  ProjectNotifier (keepAlive)                 │
│  SettingsNotifier (keepAlive)                │
│  focusProgressProvider (autoDispose)         │
│  Various StreamProviders (stats, lists)      │
│  Filter states (keepAlive)                   │
└─────────────────────────────────────────────┘
```

**Why two systems?**

- GetIt excels at imperative, one-time initialization of platform services (audio, notifications, DB) that don't change.
- Riverpod excels at reactive, watchable state that the UI rebuilds on.
- Mixing them in one system is possible but awkward — GetIt singletons don't trigger Riverpod rebuilds, and Riverpod providers aren't easily accessed from non-widget code (e.g., notification handlers).

### 7.2 Provider Types Used

| Type | Lifecycle | Use Case | Example |
|------|-----------|----------|---------|
| `@Riverpod(keepAlive: true)` Notifier | Lives forever | Mutable state that survives navigation | `FocusTimer`, `TaskNotifier` |
| `@riverpod` (autoDispose) | Dies when unwatched | Computed/derived values | `focusProgressProvider` |
| Legacy `StreamProvider` | Auto-dispose by default | Watching Drift DB streams | `taskStatsProvider`, `globalStatsProvider` |
| Legacy `Provider` | Auto-dispose | Simple synchronous derivation | `taskStatsRepositoryProvider` |

### 7.3 How `FocusTimer` Coordinates Everything

The `FocusTimer` is the central orchestrator. On each state change:

```
State change (e.g., pauseSession())
  ├── Update in-memory state (Riverpod)
  ├── Persist to DB (via repository)
  ├── Update ambience audio (AudioService.pauseAmbience())
  ├── Update media session (FocusAudioHandler.updateSessionPlaybackState())
  └── (On phase transitions) Show notification + play alarm
```

This is a "transaction script" pattern — one method coordinates multiple side effects. The alternative would be event-driven (emit events, let listeners react), but that adds complexity for a single-developer app.

---

## 8. Navigation Architecture

### 8.1 Navigator Structure

```
MaterialApp (root navigator — rootNavigatorKey)
  │
  ├── MainShell (contains bottom nav + mini-player)
  │   │
  │   ├── Tab 0: Home Navigator
  │   │     └── HomeScreen (dashboard)
  │   │
  │   ├── Tab 1: Tasks Navigator
  │   │     ├── AllTasksScreen (root)
  │   │     └── TaskDetailScreen (pushed)
  │   │
  │   ├── Tab 2: Projects Navigator
  │   │     ├── ProjectListScreen (root)
  │   │     ├── ProjectDetailScreen (pushed)
  │   │     └── TaskDetailScreen (pushed from project)
  │   │
  │   └── Tab 3: Settings Navigator
  │         └── SettingsScreen (root)
  │
  ├── FocusSessionScreen (full-screen, above shell)
  ├── CreateProjectScreen (full-screen)
  ├── EditProjectScreen (full-screen)
  ├── CreateTaskScreen (full-screen)
  ├── EditTaskScreen (full-screen)
  └── CreateTaskWithProjectScreen (full-screen)
```

### 8.2 Two Route Resolution Tiers

1. **Full-screen routes** (`generateFullScreenRoute`): Render above the bottom nav shell. Used for focus session, create/edit forms.
2. **Tab routes** (`generateTabRoute`): Render inside the tab's nested navigator. Bottom nav stays visible.

### 8.3 Focus Session Navigation Flow

```
User taps "Start Focus"
  → FocusCommands.start(context, ref, taskId: ...)
    → Check for existing active session
      → Same task? navigateToFocusSession() (no-op if already there)
      → Different task? _confirmReplace() dialog → cancelSession() + create new
      → No session? _createAndNavigate()
        → FocusTimer.createSession() (in-memory, idle state)
        → navigateToFocusSession()
          → rootNavigatorKey.pushNamed('/focus-session')
            → FocusSessionScreen mounts, watches focusTimerProvider
```

The `navigateToFocusSession` helper prevents duplicate pushes by inspecting the route stack.

---

## 9. Key Design Decisions & Trade-offs

### 9.1 ForUI Instead of Material Design

**Decision**: Use `forui` (a custom design system) instead of stock Material or Cupertino widgets.

**Reasoning**: ForUI provides a more opinionated, consistent design language with built-in dark theme support, less boilerplate than raw Material, and composable primitives (FCard, FBadge, FSelect, FButton, etc.).

**Trade-off**: Smaller community, less documentation, dependency on a single maintainer. Material compatibility requires `toApproximateMaterialTheme()` bridge.

### 9.2 Pre-Aggregated Stats Table

**Decision**: Maintain a `daily_session_stats_table` that is recalculated on every session CRUD operation.

**Reasoning**: The activity graph renders 365 cells. Aggregating from raw sessions on every render would require a GROUP BY across the full year. The pre-aggregated table turns this into a simple SELECT.

**Trade-off**: Extra write cost on every session update. Acceptable because session writes are infrequent (every 10 seconds during a session, once on start/end).

### 9.3 `keepAlive: true` for Most Providers

**Decision**: Almost all providers (18+) are keepAlive, meaning they never get garbage collected.

**Reasoning**: The app has 4 tabs with persistent state. Users switch between tabs frequently. Without keepAlive, navigating away from a tab would dispose providers and lose filter/scroll/expansion state.

**Trade-off**: Memory pressure from always-open Drift watch streams. Acceptable for this app's scale.

### 9.4 In-Memory Idle Sessions

**Decision**: `createSession()` only holds the session in Riverpod state. DB write happens on `startTimer()`.

**Reasoning**: Users might navigate to the focus session screen and then leave without pressing play. No point polluting the DB with never-started sessions.

**Trade-off**: If the app is killed between navigation and play, the session is lost. Since no timer was running, no user effort is lost.

### 9.5 Manual Routing Instead of GoRouter/AutoRoute

**Decision**: Use `onGenerateRoute` with string-based route names.

**Reasoning**: Simpler setup, no code generation dependency, sufficient for ~10 routes.

**Trade-off**: No compile-time safety for route arguments. Arguments are cast with `as dynamic`, risking runtime errors. Type-safe alternatives (GoRouter, AutoRoute) would prevent this class of bugs.

### 9.6 Transient `breakStartElapsed` Field

**Decision**: Track the focus phase's actual elapsed seconds in a field that is NOT persisted to the database.

**Reasoning**: This field is only needed while the session is active (in the keepAlive provider). On app restart, abandoned sessions are marked incomplete. The DB `elapsed_seconds` + `MIN()` capping in SQL handles stats correctly without this field.

**Trade-off**: If Riverpod somehow loses the keepAlive state without the app restarting (e.g., a hot reload during development), the break progress calculation falls back to `focusDurationMinutes * 60` as the break start. Minor development inconvenience.

### 9.7 `FocusAudioHandler` as a Dumb Relay

**Decision**: The audio handler does NOT own timer state, audio players, or business logic. It only relays between the OS MediaSession and the app's `FocusTimer`.

**Reasoning**: Centralizing state in one place (`FocusTimer`) avoids synchronization bugs between the handler and the timer. The handler is trivially testable — mock the callback and verify calls.

**Trade-off**: Every state change requires the `FocusTimer` to explicitly push updates to the handler. An event-driven architecture could make this more automatic, but adds complexity.

---

## 10. Interview Q&A

### Architecture & Design

**Q: Why did you choose Clean Architecture for a mobile app?**

A: Clean Architecture provides clear boundaries between data access, business logic, and UI. Even for a single-developer project, it pays off in:
- **Testability**: I can unit test domain logic without mocking Flutter or SQLite.
- **Replaceability**: I swapped my audio notification approach twice without touching the domain layer.
- **Navigability**: Any developer can find where a piece of logic lives based on the layer structure.

I intentionally omitted the use-case layer since the app's business rules are simple enough to live in Riverpod providers. If complexity grew, I'd extract use cases.

---

**Q: Why two DI systems (GetIt + Riverpod)?**

A: They serve complementary roles:
- **GetIt** handles imperative singletons — the database, audio players, notification service. These are initialized once at startup and never change.
- **Riverpod** handles reactive state — timer state, filter selections, computed UI values. The UI watches these and rebuilds automatically.

Using Riverpod for everything would require wrapping platform services in providers, which either forces the UI to handle `AsyncValue.loading` states for services, or requires keepAlive overrides everywhere. GetIt is simpler for "set it and forget it" dependencies.

---

**Q: How do you handle the focus timer running in the background?**

A: Three packages work together:
1. **`audio_service`** creates a foreground service (Android) or activates background audio mode (iOS), keeping the timer alive.
2. **`audio_session`** manages audio focus — it tells other apps to duck/pause and handles interruptions (phone calls, headphone unplug).
3. **`audioplayers`** handles the actual sound playback (ambient sounds, alarms).

The `FocusAudioHandler` bridges between the OS media controls and my app's `FocusTimer` Riverpod notifier. It's a dumb relay — it translates OS events into app-level actions and accepts state pushes to update the notification.

---

**Q: Why a pre-aggregated stats table instead of computing on the fly?**

A: The activity graph shows 365 cells, one per day. Computing `GROUP BY date, COUNT(*), SUM()` across the `focus_session_table` for an entire year would be fine for small datasets, but:
- It adds latency proportional to session count (potentially thousands over a year).
- The graph is visible on the home screen, so it must be fast.
- Sessions change infrequently (at most once per second during a session, once per start/end otherwise).

So I maintain a `daily_session_stats_table` that's recalculated incrementally per-date on every session insert/update/delete. The graph reads from this pre-aggregated table with a simple range SELECT. It's essentially a materialized view.

---

### State Management

**Q: Walk me through what happens when a user taps "Pause" on the lock screen.**

A:
1. The OS sends a "pause" media button event to the `audio_service` foreground service.
2. The service calls `FocusAudioHandler.pause()`.
3. The handler calls `onAction?.call('pause')`, which routes to `FocusTimer._handleNotificationAction('pause')`.
4. That calls `FocusTimer.pauseSession()`, which:
   - Cancels the `Timer.periodic`
   - Pauses the ambience audio player
   - Updates the in-memory state to `SessionState.paused`
   - Persists to the DB
   - Calls `_updateMediaSession()` to push the paused state back to the notification
5. The notification updates to show a "Play" button instead of "Pause", and the subtitle changes to "Task Name — Paused".
6. Any UI widgets watching `focusTimerProvider` or `focusProgressProvider` rebuild to show the paused state.

---

**Q: How do you prevent the timer screen from popping twice when a session ends?**

A: This was a real bug I encountered. Two paths could trigger a pop:
1. The "End Session" dialog explicitly called `Navigator.pop()`.
2. The `build()` method auto-pops when `session == null` (set by `cancelSession()`).

Both fired, causing a double-pop that removed the focus screen AND the underlying tab shell, leaving a black screen.

The fix was twofold:
1. Added a `_hasPopped` boolean flag that gates all pop calls — once one pop fires, no others can.
2. Removed explicit `Navigator.pop()` from the end-session dialog — the auto-pop in `build()` handles navigation when `cancelSession()` sets state to null.

---

**Q: Why is `focusProgressProvider` synchronous instead of async?**

A: The progress provider recomputes on every timer tick (once per second). If it were an `AsyncValue`, every tick would briefly emit `AsyncValue.loading`, causing the UI to flash a loading state. The calculation is trivially cheap — a handful of integer operations — so there's no benefit to making it async. The synchronous provider returns `FocusProgress?` directly, and the UI simply checks for null.

---

### Data & Persistence

**Q: How do you handle crash recovery for in-progress sessions?**

A: Three mechanisms:
1. **Periodic persistence**: The timer writes the session to SQLite every 10 seconds during `_tick()`. So the most data loss after a crash is ~10 seconds.
2. **Startup cleanup**: On app launch, `_cleanupAbandonedSessions()` queries for sessions still marked as `running`, `paused`, or `onBreak`. If any exist (and aren't the current in-memory session), they're marked as `incomplete`.
3. **Capped stats**: The SQL query for stats uses `MIN(elapsed_seconds, focus_duration_minutes * 60)` to ensure a session can never report more focus time than its configured duration, even if corruption occurs.

---

**Q: Why did you use Drift instead of sqflite?**

A: Drift provides:
- **Type-safe queries**: Table definitions in Dart, compiler catches schema mismatches.
- **Watch queries**: `watchable()` queries emit a stream that updates whenever the underlying table changes — perfect for Riverpod `StreamProvider` integration.
- **Automatic serialization**: Drift handles DateTime↔int, enum↔int conversions via column types.
- **Migration framework**: Structured `onUpgrade` with version-based if/else blocks.

The main drawback is that complex queries sometimes still need raw SQL (e.g., the stats aggregation), which loses Drift's type safety. But for CRUD operations — which are 90% of database access — Drift is excellent.

---

### Performance

**Q: What performance optimizations did you make?**

A: Several key ones:
1. **Pre-aggregated stats**: Activity graph reads from a materialized view instead of computing GROUP BYs on the fly.
2. **Synchronous progress provider**: Eliminates async loading flicker on the timer screen's per-second updates.
3. **Batched DB writes**: Timer persists every 10 seconds, not every tick. This reduces SQLite write amplification by 10x.
4. **keepAlive providers**: Tab state survives navigation, avoiding re-fetches when switching tabs.
5. **IndexedStack**: All 4 tabs are kept mounted in memory, so switching tabs is instant (no rebuild/re-fetch).
6. **OverlayEntry for tooltips**: Activity graph tooltips use `OverlayEntry` instead of `showDialog`, avoiding route creation overhead and modal barriers.
7. **Custom painter**: The 365-cell activity heatmap and timer ring use `CustomPaint` instead of building 365+ widget trees.

---

### Security

**Q: What security considerations apply to an offline app?**

A: The attack surface is small but not zero:
- **Local data**: Stored in unencrypted SQLite. Acceptable for non-sensitive data (focus sessions, tasks). If I added journaling or personal notes, I'd use SQLCipher encryption.
- **SQL injection**: Drift parameterizes queries automatically. My few raw SQL queries interpolate Dart variables of known types (integers, strings from enums), not user input.
- **Permissions**: Only `WAKE_LOCK` and `FOREGROUND_SERVICE_MEDIA_PLAYBACK` — minimal permission footprint. No network, storage, or camera permissions.
- **Supply chain**: I audit dependencies for maintenance status. `audio_service` and `audio_session` are from the same maintainer and interact with OS-level APIs that change yearly — these need monitoring.

---

### Code Quality

**Q: What would you refactor if you had more time?**

A: In priority order:
1. **Decompose `FocusTimer`**: It has ~11 responsibilities. I'd extract audio coordination, notification management, and media session handling into dedicated services that the timer calls into.
2. **Eliminate form duplication**: Every CRUD entity has near-identical screen and modal form variants. I'd extract shared `TaskFormContent` / `ProjectFormContent` widgets used by both.
3. **Migrate legacy providers**: About 12 `StreamProvider` instances use the legacy API. I'd convert to `@riverpod` code-gen for consistent lifecycle management.
4. **Type-safe routing**: Replace `onGenerateRoute` with GoRouter or AutoRoute to eliminate runtime argument casting errors.
5. **Add `Equatable` to entities**: Proper `==`/`hashCode` would let Riverpod skip unnecessary rebuilds when entity data hasn't actually changed.
