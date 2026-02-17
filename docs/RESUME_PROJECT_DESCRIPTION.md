# Focus App — Resume & Portfolio Reference

> Use this document to describe your work on the Focus app in resumes, portfolios, LinkedIn, and interviews.

---

## 1. Resume Entry

```
Focus — Cross-Platform Offline Productivity App              Flutter · Dart · Riverpod · Drift · SQLite
```

Sole-developed a fully offline Pomodoro timer and task management app for Android, iOS, Linux, macOS, and Windows from a single Flutter codebase.

- Architected with Clean Architecture and dual DI (GetIt + Riverpod 3), enforcing strict layer separation with abstract repository interfaces and reactive state management
- Implemented OS-level background execution with lock-screen controls, notification actions, and headphone button routing via Android MediaSession and iOS Now Playing integration
- Designed a 5-state focus session state machine with auto-cycling, coordinated audio/notification side effects, and crash recovery through periodic DB persistence (≤10s data loss)
- Built a hierarchical project/task system with unlimited subtask depth, cross-project search, and a pre-aggregated stats table powering a 365-cell activity heatmap from a single query

---

## 2. Project Summary (for Portfolio / LinkedIn)

### Short (1–2 lines)

> Cross-platform offline productivity app (Flutter/Dart) with Pomodoro timer, project/task management, ambient sound playback, lock-screen controls, and activity heatmaps — built with Clean Architecture, Riverpod, Drift SQLite, and MediaSession integration.

### Medium (paragraph)

> **Focus** is a fully offline, cross-platform (Android, iOS, Linux, macOS, Windows) productivity application built with Flutter. It enables users to manage projects and tasks in a hierarchical structure, run Pomodoro-style focus sessions with configurable timers and ambient sounds, and track their productivity through daily/weekly/yearly activity heatmaps. The app features OS-level integration including lock-screen controls, notification shade actions, and headphone button support via Android MediaSession and iOS MPNowPlayingInfoCenter. Architecturally, it follows Clean Architecture with a dual DI strategy (GetIt + Riverpod 3), type-safe SQLite persistence via Drift with 10 schema migrations, pre-aggregated statistics for performance, and a robust crash-recovery mechanism.

---

## 3. Technical Skills Demonstrated

Use this to map your work to specific skills on your resume.

| Skill Area | What You Did |
|------------|-------------|
| **Flutter / Dart** | Built 6-platform app from single codebase; used CustomPaint for timer ring and 365-cell heatmap; managed complex widget trees with IndexedStack tab persistence |
| **State Management** | Riverpod 3 with code-gen notifiers (`@Riverpod`), keepAlive lifecycle, StreamProviders over Drift watch queries, synchronous computed providers for flicker-free 1Hz updates |
| **Architecture** | Clean Architecture (Data/Domain/Presentation layers), SOLID principles adherence, abstract repository pattern, mapper extensions for layer boundary crossing |
| **Dependency Injection** | Dual-container pattern: GetIt for infrastructure singletons, Riverpod for reactive state; interface-based registration for testability |
| **Local Database** | Drift (SQLite ORM) — type-safe table definitions, watchable queries, 10 sequential migrations, raw SQL for complex aggregations, index design for query performance |
| **Background Services** | Android foreground service via `audio_service`, iOS background audio mode, MediaSession/MPNowPlayingInfoCenter for lock-screen and notification controls |
| **Audio Engineering** | Multi-source audio (alarm + ambience), OS audio focus management, interruption handling (phone calls, headphone unplug), audio ducking |
| **Notifications** | Dual-channel system (ongoing session + one-shot alarms), notification action routing, cold-start deep linking from notification taps |
| **State Machines** | Focus session FSM with 5 states, phase transitions, auto-cycling, transient state fields for accurate phase tracking, crash recovery |
| **Performance** | Materialized view (pre-aggregated stats), batched DB writes (10s intervals), synchronous progress providers, CustomPaint over widget trees, OverlayEntry tooltips |
| **Data Modeling** | Self-referencing tree (tasks with unlimited subtask depth), enum-indexed columns, DateTime-as-milliseconds storage, sentinel-based `copyWith` for nullable fields |
| **Testing & Quality** | Wrote architecture audit identifying 17 code smells with severity classification, SOLID compliance analysis, and 24 prioritized action items |
| **Cross-Platform** | Single codebase targeting Android, iOS, Linux, macOS, Windows; platform-specific service configuration (foreground service types, permission manifests) |
| **UI/UX** | ForUI design system, dark theme, Lottie animations, custom painters, modal/screen form variants, marquee text animation, responsive layouts |

---

## 4. Key Technical Talking Points (Interview Prep)

### "Tell me about a complex technical problem you solved."

**The Lock-Screen Control Problem:**
> I needed focus session controls (play/pause/skip/stop) accessible from the lock screen, notification shade, and Bluetooth headsets. I implemented a relay architecture: `audio_service` creates a foreground service (Android) / background audio mode (iOS) that exposes a MediaSession. A `FocusAudioHandler` acts as a dumb relay — it translates OS media events into string action IDs. The `FocusTimer` Riverpod notifier processes these actions, updates state, and pushes the new state back to the handler, which syncs the notification. This unidirectional flow prevents synchronization bugs between the OS media layer and app state.

### "Tell me about an architecture decision you made."

**Dual DI Strategy (GetIt + Riverpod):**
> I used GetIt for imperative infrastructure singletons (database, audio players, notification service) and Riverpod for reactive UI state. GetIt services are initialized once at startup and never change — wrapping them in Riverpod would force the UI to handle pointless `AsyncValue.loading` states. Riverpod handles everything the UI watches: timer state, filter selections, computed providers. This separation gives each system its ideal use case and avoids forcing one tool to do both jobs.

### "Tell me about a performance optimization."

**Pre-Aggregated Activity Stats:**
> The home screen shows a 365-cell yearly activity heatmap. Computing `GROUP BY date, COUNT(*), SUM()` across thousands of sessions on every render would be slow. Instead, I maintain a `daily_session_stats` table that's incrementally recalculated per-date on every session insert, update, or delete. The heatmap reads from this table with a simple `WHERE date BETWEEN start AND end` — constant time regardless of session count. It's essentially a materialized view maintained at write time.

### "Tell me about a bug you fixed."

**The Double-Pop Bug:**
> When a focus session ended, the screen would pop twice — removing both the focus screen AND the underlying tab shell, leaving a black screen. Two code paths were triggering navigation: the "End Session" dialog called `Navigator.pop()` explicitly, AND the `build()` method auto-popped when session state became null. Both fired. I fixed it with a `_hasPopped` boolean gate and removed the explicit pop from the dialog, letting the reactive auto-pop handle all navigation when `cancelSession()` nulls the state.

### "What would you improve / refactor?"

> My top priority is decomposing the `FocusTimer` notifier. It currently has ~11 responsibilities: timer ticks, phase transitions, audio, notifications, media session, task completion, and more. I've designed a decomposition: extract `FocusAudioCoordinator`, `FocusNotificationCoordinator`, `FocusMediaSessionCoordinator`, and `SessionLifecycleService`. Each handles one concern while the timer orchestrates. I'd also extract shared form content widgets to eliminate ~600 lines of duplication between screen and modal form variants, and migrate 12 legacy `StreamProvider`s to Riverpod code-gen for consistent lifecycle management.

### "How do you handle crash recovery?"

> Three mechanisms: (1) The timer persists the session to SQLite every 10 seconds during ticks — max 10 seconds of data loss on crash. (2) On startup, a cleanup routine queries for sessions still marked running/paused/onBreak and marks them as incomplete. (3) Stats queries use `MIN(elapsed_seconds, focus_duration * 60)` to cap reported focus time, preventing corruption from edge cases.

---

## 5. Technologies & Packages (for Skills Section)

**Languages:** Dart  
**Framework:** Flutter (cross-platform: Android, iOS, Linux, macOS, Windows)  
**State Management:** Riverpod 3 (code-gen + legacy), GetIt (service locator)  
**Database:** SQLite via Drift ORM (type-safe queries, watch streams, migrations)  
**Audio:** audioplayers, audio_service (foreground service / MediaSession), audio_session (audio focus)  
**Notifications:** flutter_local_notifications (dual-channel, action handling)  
**UI:** ForUI design system, CustomPaint, Lottie animations  
**Architecture:** Clean Architecture, SOLID principles, Repository pattern, Dependency Injection  
**Tools:** build_runner (code generation), drift_dev (schema codegen), riverpod_generator

---

## 6. One-Liner for Resume Projects Section

```
Focus — Cross-Platform Productivity App                           Flutter, Dart, Riverpod, Drift, SQLite
• Built a fully offline Pomodoro timer + task manager for 5 platforms using Clean Architecture,
  featuring lock-screen controls (MediaSession), pre-aggregated analytics, crash recovery,
  ambient audio system, and hierarchical task management with 10 schema migrations
```

---

## 7. GitHub Repository Description (if open source)

> Fully offline, cross-platform (Android/iOS/Linux/macOS/Windows) Pomodoro & deep-work timer app built with Flutter. Features hierarchical project/task management, lock-screen & notification controls via MediaSession, ambient sound playback, yearly activity heatmaps, and crash-resilient session persistence. Architected with Clean Architecture, Riverpod 3, GetIt, and Drift SQLite ORM.
