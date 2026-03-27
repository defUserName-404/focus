# Focus App - Feature Implementation Plans

> **Document Purpose**: Detailed implementation plans for new features
> **Target Audience**: AI coding agents and developers
> **Last Updated**: March 2026

---

## Table of Contents

1. [go_router Migration](#1-go_router-migration)
2. [Desktop UI Redesign](#2-desktop-ui-redesign)
3. [Task Time Support & Notifications](#3-task-time-support--notifications)
4. [Recurring Tasks](#4-recurring-tasks)
5. [Habit Tracking](#5-habit-tracking)
6. [Enhanced Statistics](#6-enhanced-statistics)
7. [Cloud Sync (Google Drive + Dropbox)](#7-cloud-sync-google-drive--dropbox)
8. [Import/Export](#8-importexport)
9. [User Onboarding](#9-user-onboarding)
10. [Audio Loop Fix](#10-audio-loop-fix)

---

## Implementation Order

Based on dependencies:

```
Phase 1 (Foundation):
├── 1. go_router Migration (unblocks desktop navigation)
├── 10. Audio Loop Fix (quick win, improves UX immediately)
└── 3. Task Time Support (extends existing system)

Phase 2 (Core Features):
├── 4. Recurring Tasks (builds on task time support)
├── 2. Desktop UI Redesign (benefits all features)
└── 5. Habit Tracking (standalone feature)

Phase 3 (Data & Insights):
├── 6. Enhanced Statistics (uses habits + sessions data)
└── 8. Import/Export (needed before sync)

Phase 4 (Advanced):
├── 7. Cloud Sync (complex, needs stable schema)
└── 9. User Onboarding (best after features stabilize)
```

---

## 1. go_router Migration

### Overview

Replace Navigator 1.0 with `go_router` for declarative, type-safe routing.

### Status (Implemented)

- `go_router` dependency added and active
- `AppRoutes` + `RouteNames` constants in place
- `app_router.dart` uses `GoRouter` + `ShellRoute`
- `AdaptiveShell` integrated with go_router state
- `NavigationService` removed and call sites migrated to `context.go`/`context.push`

### Current State

- 4 nested navigators with global keys
- `NavigationService` abstraction
- Manual route handling in `AppRouter`
- Complex shell navigation for adaptive UI

### Target State

- Single `GoRouter` configuration
- Type-safe route parameters
- `ShellRoute` for adaptive navigation
- Deep link support out of the box

### Dependencies

```yaml
# pubspec.yaml
dependencies:
  go_router: ^14.0.0
```

### New Files to Create

```
lib/core/routing/
├── app_router.dart          # REPLACE - GoRouter configuration
├── routes.dart              # NEW - Route path constants
├── route_names.dart         # NEW - Named route constants
└── navigation_service.dart  # REMOVE - no longer needed
```

### Implementation

#### Step 1: Define Routes

```dart
// lib/core/routing/routes.dart
abstract class AppRoutes {
  static const home = '/';
  static const projects = '/projects';
  static const projectDetail = '/projects/:projectId';
  static const projectEdit = '/projects/:projectId/edit';
  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:taskId';
  static const session = '/session';
  static const sessionActive = '/session/active';
  static const settings = '/settings';
  static const settingsSound = '/settings/sound';
  static const settingsNotifications = '/settings/notifications';
}
```

#### Step 2: Create Router Configuration

```dart
// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AdaptiveShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.projects,
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                path: ':projectId',
                name: 'projectDetail',
                builder: (context, state) {
                  final projectId = int.parse(state.pathParameters['projectId']!);
                  return ProjectDetailScreen(projectId: projectId);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'projectEdit',
                    builder: (context, state) {
                      final projectId = int.parse(state.pathParameters['projectId']!);
                      return ProjectEditScreen(projectId: projectId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.tasks,
            name: 'tasks',
            builder: (context, state) => const TasksScreen(),
          ),
          GoRoute(
            path: AppRoutes.session,
            name: 'session',
            builder: (context, state) => const SessionScreen(),
            routes: [
              GoRoute(
                path: 'active',
                name: 'sessionActive',
                pageBuilder: (context, state) => CustomTransitionPage(
                  child: const ActiveSessionScreen(),
                  transitionsBuilder: (context, animation, _, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'sound',
                name: 'settingsSound',
                builder: (context, state) => const SoundSettingsScreen(),
              ),
              GoRoute(
                path: 'notifications',
                name: 'settingsNotifications',
                builder: (context, state) => const NotificationSettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
}
```

#### Step 3: Update AdaptiveShell

```dart
// lib/core/widgets/adaptive_shell.dart
class AdaptiveShell extends ConsumerWidget {
  final Widget child;
  
  const AdaptiveShell({required this.child, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _getIndexFromLocation(location);
    
    if (PlatformUtils.isDesktop) {
      return _DesktopShell(
        currentIndex: currentIndex,
        onDestinationSelected: (index) => _navigate(context, index),
        child: child,
      );
    }
    
    return _MobileShell(
      currentIndex: currentIndex,
      onDestinationSelected: (index) => _navigate(context, index),
      child: child,
    );
  }
  
  void _navigate(BuildContext context, int index) {
    final routes = [
      AppRoutes.home,
      AppRoutes.projects,
      AppRoutes.tasks,
      AppRoutes.session,
      AppRoutes.settings,
    ];
    context.go(routes[index]);
  }
}
```

#### Step 4: Update App Entry Point

```dart
// lib/core/app.dart
class FocusApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}
```

#### Step 5: Migration Checklist

- [ ] Add go_router dependency
- [ ] Create `routes.dart` with all path constants
- [ ] Create new `app_router.dart` with GoRouter configuration
- [ ] Update `AdaptiveShell` to use GoRouterState
- [ ] Update all `Navigator.push` calls to `context.go` / `context.push`
- [ ] Update all `Navigator.pop` calls to `context.pop`
- [ ] Remove `NavigationService` class
- [ ] Remove global navigator keys
- [ ] Run code generation
- [ ] Test all navigation paths
- [ ] Test deep links
- [ ] Remove old routing files

### Testing

```bash
# Verify all routes work
flutter run

# Test deep links (Android)
adb shell am start -a android.intent.action.VIEW -d "focus://projects/1"

# Test deep links (iOS)
xcrun simctl openurl booted "focus://projects/1"
```

---

## 2. Desktop UI Redesign

### Overview

Transform mobile-first layouts into proper desktop experiences with master-detail views, appropriate spacing, and keyboard navigation.

### Current Problems

1. Content stretches infinitely on wide screens
2. No master-detail patterns for lists
3. Spacing too tight for desktop
4. NavigationRail too narrow/basic
5. No keyboard shortcuts

### Design Principles

- **Compact** (<600px): Mobile single-column layout
- **Medium** (600-840px): Tablet-optimized layout
- **Expanded** (>840px): Desktop master-detail layout

### New Files to Create

```
lib/core/
├── constants/
│   └── layout_breakpoints.dart      # NEW - responsive breakpoints
├── widgets/
│   ├── responsive_layout.dart       # NEW - layout wrapper
│   ├── master_detail_layout.dart    # NEW - two-pane layout
│   ├── constrained_content.dart     # NEW - max-width wrapper
│   └── keyboard_shortcuts.dart      # NEW - keyboard handling
```

### Status (Partially Implemented)

- Added `layout_breakpoints.dart` with compact/medium/expanded classes
- Added `master_detail_layout.dart`
- Added `constrained_content.dart`
- Added `responsive_layout.dart`
- Added `keyboard_shortcuts.dart` and wrapped desktop shell content
- Updated desktop `NavigationRail` to extended mode
- Added `ProjectsScreen` and `TasksScreen` master-detail containers
- Applied constrained layout wrapper to projects and tasks list screens

### Implementation

#### Step 1: Define Breakpoints

```dart
// lib/core/constants/layout_breakpoints.dart
enum WindowSizeClass { compact, medium, expanded }

class LayoutBreakpoints {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
  
  static WindowSizeClass getWindowSizeClass(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < compact) return WindowSizeClass.compact;
    if (width < medium) return WindowSizeClass.medium;
    return WindowSizeClass.expanded;
  }
}

// Spacing that scales with density
class ResponsiveSpacing {
  static double small(WindowSizeClass size) => switch (size) {
    WindowSizeClass.compact => 8.0,
    WindowSizeClass.medium => 12.0,
    WindowSizeClass.expanded => 16.0,
  };
  
  static double medium(WindowSizeClass size) => switch (size) {
    WindowSizeClass.compact => 16.0,
    WindowSizeClass.medium => 20.0,
    WindowSizeClass.expanded => 24.0,
  };
  
  static double large(WindowSizeClass size) => switch (size) {
    WindowSizeClass.compact => 24.0,
    WindowSizeClass.medium => 32.0,
    WindowSizeClass.expanded => 48.0,
  };
}
```

#### Step 2: Create Master-Detail Layout

```dart
// lib/core/widgets/master_detail_layout.dart
class MasterDetailLayout extends StatelessWidget {
  final Widget master;
  final Widget? detail;
  final Widget emptyDetail;
  final double masterWidth;
  
  const MasterDetailLayout({
    required this.master,
    this.detail,
    required this.emptyDetail,
    this.masterWidth = 360,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final sizeClass = LayoutBreakpoints.getWindowSizeClass(context);
    
    // Compact: Only show master or detail
    if (sizeClass == WindowSizeClass.compact) {
      return detail ?? master;
    }
    
    // Medium/Expanded: Side-by-side
    return Row(
      children: [
        SizedBox(
          width: masterWidth,
          child: master,
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: detail ?? emptyDetail,
        ),
      ],
    );
  }
}
```

#### Step 3: Create Constrained Content Wrapper

```dart
// lib/core/widgets/constrained_content.dart
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;
  
  const ConstrainedContent({
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
```

#### Step 4: Update Screens for Master-Detail

```dart
// lib/features/projects/presentation/screens/projects_screen.dart
class ProjectsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final sizeClass = LayoutBreakpoints.getWindowSizeClass(context);
    
    // Compact: Use navigation
    if (sizeClass == WindowSizeClass.compact) {
      return const ProjectListScreen();
    }
    
    // Medium/Expanded: Master-detail
    return MasterDetailLayout(
      master: ProjectListScreen(
        selectedId: selectedProjectId,
        onProjectSelected: (id) {
          ref.read(selectedProjectIdProvider.notifier).state = id;
        },
      ),
      detail: selectedProjectId != null 
        ? ProjectDetailScreen(projectId: selectedProjectId)
        : null,
      emptyDetail: const Center(
        child: Text('Select a project to view details'),
      ),
    );
  }
}
```

#### Step 5: Enhanced NavigationRail

```dart
// In AdaptiveShell for desktop
NavigationRail(
  extended: true,  // Show labels
  minExtendedWidth: 200,
  leading: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Focus', style: Theme.of(context).textTheme.headlineSmall),
  ),
  destinations: [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    // ... more destinations
  ],
  selectedIndex: currentIndex,
  onDestinationSelected: onDestinationSelected,
)
```

#### Step 6: Keyboard Shortcuts

```dart
// lib/core/widgets/keyboard_shortcuts.dart
class AppKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  
  const AppKeyboardShortcuts({required this.child, super.key});
  
  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          // New task
        },
        SingleActivator(LogicalKeyboardKey.keyP, control: true): () {
          // New project
        },
        SingleActivator(LogicalKeyboardKey.space): () {
          // Start/pause session
        },
        SingleActivator(LogicalKeyboardKey.escape): () {
          // Close detail panel
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
```

### Migration Checklist

- [ ] Add breakpoint constants
- [ ] Create MasterDetailLayout widget
- [ ] Create ConstrainedContent widget
- [ ] Create ResponsiveLayout builder widget
- [ ] Update AdaptiveShell with extended NavigationRail
- [ ] Convert ProjectsScreen to master-detail
- [ ] Convert TasksScreen to master-detail
- [ ] Add keyboard shortcuts wrapper
- [ ] Test at all breakpoints
- [ ] Update spacing throughout app

---

## 3. Task Time Support & Notifications

### Overview

Add time support to tasks so users can set specific times for deadlines and receive notifications.

### Status (Implemented)

- Task create/edit screens include time selection for start and end dates
- `TaskNotificationService` implemented and registered in DI
- Task notifications integrated in create/update/toggle/delete flows
- Reminder rescheduling runs on app launch in `main.dart`

### Current State

- `Task.startDate` and `Task.endDate` exist as `DateTime` but only date portion is used
- No UI for time selection
- No notification scheduling for task deadlines

### Database Changes

No schema change needed - `DateTime` already stores time. Just need to populate it.

### UI Changes

#### Task Creation/Edit Form

```dart
// Add time picker after date picker
Row(
  children: [
    Expanded(
      child: FDatePicker(
        label: 'Due Date',
        value: task.endDate,
        onChanged: (date) => ...,
      ),
    ),
    SizedBox(width: 16),
    Expanded(
      child: FTimePicker(
        label: 'Time',
        value: task.endDate != null 
          ? TimeOfDay.fromDateTime(task.endDate!)
          : null,
        onChanged: (time) {
          if (task.endDate != null && time != null) {
            final newDateTime = DateTime(
              task.endDate!.year,
              task.endDate!.month,
              task.endDate!.day,
              time.hour,
              time.minute,
            );
            // Update task.endDate with newDateTime
          }
        },
      ),
    ),
  ],
)
```

### Notification Scheduling

```dart
// lib/features/tasks/domain/services/task_notification_service.dart
class TaskNotificationService {
  final INotificationService _notificationService;
  final ITaskRepository _taskRepository;
  
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.endDate == null) return;
    
    // Schedule notification 15 minutes before deadline
    final reminderTime = task.endDate!.subtract(Duration(minutes: 15));
    
    if (reminderTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleNotification(
        id: task.id!,
        title: 'Task Reminder',
        body: task.title,
        scheduledTime: reminderTime,
        payload: 'task:${task.id}',
      );
    }
  }
  
  Future<void> cancelTaskReminder(int taskId) async {
    await _notificationService.cancelNotification(taskId);
  }
  
  Future<void> rescheduleAllReminders() async {
    // Called on app start to ensure notifications are scheduled
    final tasks = await _taskRepository.getTasksWithDeadlines();
    for (final task in tasks) {
      await scheduleTaskReminder(task);
    }
  }
}
```

### Integration Points

1. **On task create**: Schedule notification
2. **On task update**: Cancel old, schedule new
3. **On task complete**: Cancel notification
4. **On task delete**: Cancel notification
5. **On app launch**: Reschedule all (in case app was reinstalled)

### Implementation Checklist

- [ ] Add FTimePicker widget (or use forui's if available)
- [ ] Update task creation form to include time
- [ ] Update task edit form to include time
- [ ] Create TaskNotificationService
- [ ] Register in DI
- [ ] Integrate with TaskService
- [ ] Schedule notifications on task create/update
- [ ] Cancel notifications on complete/delete
- [ ] Reschedule on app launch
- [ ] Test notifications on Android/iOS

---

## 4. Recurring Tasks

### Overview

Add a "recurring" option to tasks that automatically creates new task instances based on a pattern.

### Design Decision

**Approach**: Recurring is a property of a task, not a separate system.

- Add `isRecurring` boolean and `recurrenceRule` to existing Task
- When a recurring task is completed, automatically create the next instance
- Keep history of completed instances linked to the recurring parent

### Database Schema Changes

```sql
-- Add to TaskTable
ALTER TABLE task_table ADD COLUMN is_recurring INTEGER NOT NULL DEFAULT 0;
ALTER TABLE task_table ADD COLUMN recurrence_rule TEXT;  -- JSON or iCal RRULE format
ALTER TABLE task_table ADD COLUMN recurring_parent_id INTEGER REFERENCES task_table(id);
ALTER TABLE task_table ADD COLUMN recurrence_end_date INTEGER;  -- Optional end date
```

```dart
// lib/features/tasks/data/models/task_model.dart
class TaskTable extends Table {
  // ... existing columns ...
  
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  
  /// JSON-encoded recurrence rule: 
  /// {"type": "daily"} 
  /// {"type": "weekly", "days": [1, 3, 5]} (Mon, Wed, Fri)
  /// {"type": "monthly", "dayOfMonth": 15}
  /// {"type": "custom", "intervalDays": 3}
  TextColumn get recurrenceRule => text().nullable()();
  
  /// For task instances generated from a recurring task
  IntColumn get recurringParentId => integer()
    .nullable()
    .references(TaskTable, #id, onDelete: KeyAction.cascade)();
  
  /// Optional end date for recurrence
  DateTimeColumn get recurrenceEndDate => dateTime().nullable()();
}
```

### Domain Entity Updates

```dart
// lib/features/tasks/domain/entities/task.dart
@immutable
class Task extends Equatable {
  // ... existing fields ...
  
  final bool isRecurring;
  final RecurrenceRule? recurrenceRule;
  final int? recurringParentId;
  final DateTime? recurrenceEndDate;
  
  bool get isRecurringInstance => recurringParentId != null;
  bool get isRecurringParent => isRecurring && recurringParentId == null;
}

// lib/features/tasks/domain/entities/recurrence_rule.dart
@immutable
class RecurrenceRule extends Equatable {
  final RecurrenceType type;
  final List<int>? daysOfWeek;  // 1=Mon, 7=Sun
  final int? dayOfMonth;
  final int? intervalDays;  // For custom
  
  const RecurrenceRule({
    required this.type,
    this.daysOfWeek,
    this.dayOfMonth,
    this.intervalDays,
  });
  
  /// Calculate next occurrence after given date
  DateTime? getNextOccurrence(DateTime after) {
    switch (type) {
      case RecurrenceType.daily:
        return after.add(Duration(days: 1));
      case RecurrenceType.weekly:
        // Find next day in daysOfWeek
        for (int i = 1; i <= 7; i++) {
          final candidate = after.add(Duration(days: i));
          if (daysOfWeek!.contains(candidate.weekday)) {
            return candidate;
          }
        }
        return null;
      case RecurrenceType.monthly:
        final nextMonth = DateTime(after.year, after.month + 1, dayOfMonth!);
        return nextMonth;
      case RecurrenceType.custom:
        return after.add(Duration(days: intervalDays!));
    }
  }
  
  String toJson() => jsonEncode({
    'type': type.name,
    'daysOfWeek': daysOfWeek,
    'dayOfMonth': dayOfMonth,
    'intervalDays': intervalDays,
  });
  
  factory RecurrenceRule.fromJson(String json) {
    final map = jsonDecode(json);
    return RecurrenceRule(
      type: RecurrenceType.values.byName(map['type']),
      daysOfWeek: (map['daysOfWeek'] as List?)?.cast<int>(),
      dayOfMonth: map['dayOfMonth'],
      intervalDays: map['intervalDays'],
    );
  }
  
  @override
  List<Object?> get props => [type, daysOfWeek, dayOfMonth, intervalDays];
}

enum RecurrenceType { daily, weekly, monthly, custom }
```

### Service Logic

```dart
// lib/features/tasks/domain/services/task_service.dart
class TaskService {
  Future<Result<void>> completeTask(int taskId) async {
    final taskResult = await _repository.getTaskById(taskId);
    if (taskResult case Failure(:final failure)) {
      return Failure(failure);
    }
    
    final task = (taskResult as Success).value;
    
    // Mark as complete
    final updateResult = await _repository.updateTask(
      task.copyWith(isCompleted: true, updatedAt: DateTime.now()),
    );
    
    // If this is a recurring task (parent or instance), create next instance
    if (task.isRecurring || task.isRecurringInstance) {
      await _createNextRecurringInstance(task);
    }
    
    return updateResult;
  }
  
  Future<void> _createNextRecurringInstance(Task completedTask) async {
    // Get the parent task (either this task or the recurring parent)
    final parentId = completedTask.recurringParentId ?? completedTask.id;
    final parentResult = await _repository.getTaskById(parentId!);
    if (parentResult case Failure()) return;
    
    final parent = (parentResult as Success).value;
    if (parent.recurrenceRule == null) return;
    
    // Check if recurrence has ended
    if (parent.recurrenceEndDate != null && 
        DateTime.now().isAfter(parent.recurrenceEndDate!)) {
      return;
    }
    
    // Calculate next occurrence
    final baseDate = completedTask.endDate ?? DateTime.now();
    final nextDate = parent.recurrenceRule!.getNextOccurrence(baseDate);
    if (nextDate == null) return;
    
    // Create new instance
    final newTask = Task(
      projectId: parent.projectId,
      title: parent.title,
      description: parent.description,
      priority: parent.priority,
      startDate: nextDate,
      endDate: nextDate,
      depth: parent.depth,
      isCompleted: false,
      isRecurring: false,  // Instance, not parent
      recurringParentId: parentId,
      recurrenceRule: null,  // Only parent has rule
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.createTask(newTask);
    
    // Schedule notification for new instance
    await _notificationService.scheduleTaskReminder(newTask);
  }
}
```

### UI Components

```dart
// Recurrence selector widget
class RecurrenceSelector extends StatelessWidget {
  final RecurrenceRule? value;
  final ValueChanged<RecurrenceRule?> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text('Recurring task'),
          value: value != null,
          onChanged: (enabled) {
            onChanged(enabled ? RecurrenceRule(type: RecurrenceType.daily) : null);
          },
        ),
        if (value != null) ...[
          DropdownButtonFormField<RecurrenceType>(
            value: value!.type,
            items: RecurrenceType.values.map((t) => DropdownMenuItem(
              value: t,
              child: Text(t.displayName),
            )).toList(),
            onChanged: (type) {
              if (type != null) {
                onChanged(RecurrenceRule(type: type));
              }
            },
          ),
          if (value!.type == RecurrenceType.weekly)
            DayOfWeekSelector(
              selectedDays: value!.daysOfWeek ?? [],
              onChanged: (days) {
                onChanged(value!.copyWith(daysOfWeek: days));
              },
            ),
          // ... more type-specific UI
        ],
      ],
    );
  }
}
```

### Implementation Checklist

- [ ] Add database columns (with migration)
- [ ] Update Task entity
- [ ] Create RecurrenceRule entity
- [ ] Update TaskMapper
- [ ] Update TaskService.completeTask to create next instance
- [ ] Create RecurrenceSelector widget
- [ ] Add to task creation form
- [ ] Add to task edit form
- [ ] Show recurring indicator in task list
- [ ] Allow viewing recurring task history
- [ ] Schedule notifications for generated instances
- [ ] Run code generation
- [ ] Test all recurrence patterns

---

## 5. Habit Tracking

### Overview

Standalone habit tracking feature that can optionally link to focus sessions.

### Design Principles

- Habits are independent of tasks and sessions
- Habits track daily completions (not time-based like sessions)
- Can optionally trigger/link to a focus session
- Statistics show streaks, completion rates, best days

### New Feature Structure

```
lib/features/habits/
├── data/
│   ├── datasources/
│   │   └── habit_local_datasource.dart
│   ├── mappers/
│   │   └── habit_mapper.dart
│   ├── models/
│   │   ├── habit_model.dart
│   │   └── habit_completion_model.dart
│   └── repositories/
│       └── habit_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── habit.dart
│   │   └── habit_completion.dart
│   ├── repositories/
│   │   └── i_habit_repository.dart
│   └── services/
│       └── habit_service.dart
└── presentation/
    ├── providers/
    │   ├── habits_provider.dart
    │   └── habit_stats_provider.dart
    ├── screens/
    │   ├── habits_screen.dart
    │   └── habit_detail_screen.dart
    └── widgets/
        ├── habit_card.dart
        ├── habit_calendar.dart
        ├── habit_streak_badge.dart
        └── habit_form.dart
```

### Database Schema

```dart
// lib/features/habits/data/models/habit_model.dart
@TableIndex(name: 'habit_archived_idx', columns: {#isArchived})
class HabitTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();  // Material icon name
  IntColumn get color => integer().nullable()();  // Color value
  
  /// Optional link to a project (for context)
  IntColumn get projectId => integer()
    .nullable()
    .references(ProjectTable, #id, onDelete: KeyAction.setNull)();
  
  /// If true, completing this habit starts a focus session
  BoolColumn get triggersFocusSession => boolean().withDefault(const Constant(false))();
  
  /// Target completions per day (usually 1)
  IntColumn get targetPerDay => integer().withDefault(const Constant(1))();
  
  /// Days of week this habit applies (null = every day)
  /// Stored as comma-separated: "1,2,3,4,5" for weekdays
  TextColumn get applicableDays => text().nullable()();
  
  /// Reminder time (null = no reminder)
  DateTimeColumn get reminderTime => dateTime().nullable()();
  
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

// lib/features/habits/data/models/habit_completion_model.dart
@TableIndex(name: 'habit_completion_date_idx', columns: {#completedAt})
class HabitCompletionTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer()
    .references(HabitTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedAt => dateTime()();
  
  /// Optional link to the focus session this completion triggered
  IntColumn get focusSessionId => integer()
    .nullable()
    .references(FocusSessionTable, #id, onDelete: KeyAction.setNull)();
  
  /// Optional note
  TextColumn get note => text().nullable()();
}
```

### Domain Entities

```dart
// lib/features/habits/domain/entities/habit.dart
@immutable
class Habit extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final String? icon;
  final int? color;
  final int? projectId;
  final bool triggersFocusSession;
  final int targetPerDay;
  final List<int>? applicableDays;
  final DateTime? reminderTime;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Computed
  bool appliesToDay(DateTime date) {
    if (applicableDays == null) return true;
    return applicableDays!.contains(date.weekday);
  }
  
  const Habit({...});
  
  @override
  List<Object?> get props => [...];
}

// lib/features/habits/domain/entities/habit_completion.dart
@immutable
class HabitCompletion extends Equatable {
  final int? id;
  final int habitId;
  final DateTime completedAt;
  final int? focusSessionId;
  final String? note;
  
  const HabitCompletion({...});
  
  @override
  List<Object?> get props => [...];
}
```

### Service Layer

```dart
// lib/features/habits/domain/services/habit_service.dart
class HabitService {
  final IHabitRepository _repository;
  final FocusSessionService? _sessionService;  // Optional for session linking
  
  Future<Result<void>> completeHabit(int habitId, {String? note}) async {
    final habitResult = await _repository.getHabitById(habitId);
    if (habitResult case Failure(:final failure)) return Failure(failure);
    
    final habit = (habitResult as Success).value;
    
    // Create completion record
    final completion = HabitCompletion(
      habitId: habitId,
      completedAt: DateTime.now(),
      note: note,
    );
    
    final createResult = await _repository.createCompletion(completion);
    if (createResult case Failure(:final failure)) return Failure(failure);
    
    // Optionally trigger focus session
    if (habit.triggersFocusSession && _sessionService != null) {
      // Start a session linked to this habit's project
      await _sessionService!.startSession(projectId: habit.projectId);
      
      // Update completion with session ID (would need to get it from session service)
    }
    
    return Success(null);
  }
  
  Future<HabitStats> getHabitStats(int habitId) async {
    final completions = await _repository.getCompletions(
      habitId,
      startDate: DateTime.now().subtract(Duration(days: 365)),
    );
    
    return HabitStats(
      totalCompletions: completions.length,
      currentStreak: _calculateStreak(completions),
      longestStreak: _calculateLongestStreak(completions),
      completionRateThisWeek: _calculateWeekRate(completions),
      completionRateThisMonth: _calculateMonthRate(completions),
      bestDay: _findBestDay(completions),
    );
  }
}
```

### UI Components

```dart
// lib/features/habits/presentation/widgets/habit_card.dart
class HabitCard extends StatelessWidget {
  final Habit habit;
  final int completionsToday;
  final int currentStreak;
  final VoidCallback onComplete;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final isComplete = completionsToday >= habit.targetPerDay;
    
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(habit.color ?? Colors.blue.value),
          child: Icon(
            isComplete ? Icons.check : _getIcon(habit.icon),
            color: Colors.white,
          ),
        ),
        title: Text(habit.name),
        subtitle: Text('$currentStreak day streak'),
        trailing: IconButton(
          icon: Icon(isComplete ? Icons.check_circle : Icons.circle_outlined),
          onPressed: isComplete ? null : onComplete,
        ),
        onTap: onTap,
      ),
    );
  }
}

// lib/features/habits/presentation/widgets/habit_calendar.dart
class HabitCalendar extends StatelessWidget {
  final List<HabitCompletion> completions;
  final DateTime month;
  
  @override
  Widget build(BuildContext context) {
    // GitHub-style contribution calendar
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: _daysInMonth(month),
      itemBuilder: (context, index) {
        final date = DateTime(month.year, month.month, index + 1);
        final completed = completions.any((c) => 
          c.completedAt.year == date.year &&
          c.completedAt.month == date.month &&
          c.completedAt.day == date.day
        );
        
        return Container(
          margin: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: completed ? Colors.green : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(child: Text('${index + 1}')),
        );
      },
    );
  }
}
```

### Implementation Checklist

- [ ] Create database tables (HabitTable, HabitCompletionTable)
- [ ] Add to DbService @DriftDatabase annotation
- [ ] Create domain entities
- [ ] Create repository interface and implementation
- [ ] Create HabitService
- [ ] Create HabitNotificationService (for reminders)
- [ ] Register all in DI
- [ ] Create Riverpod providers
- [ ] Create HabitsScreen with list view
- [ ] Create HabitDetailScreen with calendar and stats
- [ ] Create HabitForm for create/edit
- [ ] Add habit navigation to AdaptiveShell
- [ ] Add route to go_router
- [ ] Test habit completion flow
- [ ] Test session linking
- [ ] Test notifications

---

## 6. Enhanced Statistics

### Overview

Provide users with rich insights about their productivity patterns.

### New Statistics to Track

1. **Session Statistics**
   - Total focus time (daily, weekly, monthly, all-time)
   - Average session length
   - Sessions per day distribution
   - Most productive hours (heatmap)
   - Focus time by project
   - Session completion rate

2. **Task Statistics**
   - Tasks completed (daily, weekly, monthly)
   - Average task completion time
   - Tasks by priority distribution
   - Overdue task rate
   - Recurring task completion rate

3. **Habit Statistics**
   - Current streaks per habit
   - Longest streaks
   - Completion rate by day of week
   - Habit completion heatmap
   - Habits contributing to focus sessions

4. **Cross-Feature Insights**
   - Correlation: habits completed vs focus time
   - Best days of the week for productivity
   - Time of day patterns
   - Project productivity comparison

### New Files

```
lib/features/stats/
├── data/
│   └── repositories/
│       └── stats_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── productivity_stats.dart
│   │   ├── time_distribution.dart
│   │   └── streak_info.dart
│   ├── repositories/
│   │   └── i_stats_repository.dart
│   └── services/
│       └── stats_service.dart
└── presentation/
    ├── providers/
    │   └── stats_providers.dart
    ├── screens/
    │   └── stats_screen.dart
    └── widgets/
        ├── stats_card.dart
        ├── productivity_chart.dart
        ├── heatmap_calendar.dart
        └── streak_display.dart
```

### Key Queries

```dart
// Most productive hours (returns hour -> minutes focused)
Future<Map<int, int>> getFocusTimeByHour(DateTime startDate, DateTime endDate) async {
  final result = await database.customSelect('''
    SELECT 
      strftime('%H', started_at) as hour,
      SUM(
        CASE 
          WHEN ended_at IS NOT NULL 
          THEN (julianday(ended_at) - julianday(started_at)) * 24 * 60
          ELSE 0
        END
      ) as minutes
    FROM focus_sessions
    WHERE started_at >= ? AND started_at < ?
    GROUP BY hour
    ORDER BY hour
  ''', variables: [Variable(startDate), Variable(endDate)]).get();
  
  return Map.fromEntries(
    result.map((r) => MapEntry(int.parse(r.data['hour']), r.data['minutes'].toInt()))
  );
}
```

### UI: Heatmap Calendar

```dart
class HeatmapCalendar extends StatelessWidget {
  final Map<DateTime, double> data;  // Date -> intensity (0-1)
  final int weeksToShow;
  
  @override
  Widget build(BuildContext context) {
    // GitHub-style contribution heatmap
    return CustomPaint(
      painter: HeatmapPainter(
        data: data,
        weeks: weeksToShow,
        colorLow: Colors.green[100]!,
        colorHigh: Colors.green[800]!,
      ),
      size: Size(double.infinity, 7 * 12.0),  // 7 days * cell size
    );
  }
}
```

### Implementation Checklist

- [ ] Create stats domain entities
- [ ] Create StatsRepository with optimized SQL queries
- [ ] Create StatsService
- [ ] Register in DI
- [ ] Create Riverpod providers (with caching)
- [ ] Create StatsScreen
- [ ] Create reusable chart widgets
- [ ] Create HeatmapCalendar
- [ ] Create StreakDisplay
- [ ] Add stats to HomeScreen summary
- [ ] Add stats tab to ProjectDetailScreen
- [ ] Test with large datasets
- [ ] Ensure queries are performant

---

## 7. Cloud Sync (Google Drive + Dropbox)

### Overview

Synchronize data across devices using Google Drive AND Dropbox simultaneously. Support both as backup destinations.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      SyncManager                             │
│  - Orchestrates sync across all providers                   │
│  - Handles conflict resolution                               │
│  - Manages sync queue                                        │
└─────────────────────────────────────────────────────────────┘
                              │
           ┌──────────────────┼──────────────────┐
           ▼                  ▼                  ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ GoogleDriveSync │  │  DropboxSync    │  │   LocalSync     │
│   Provider      │  │   Provider      │  │   Provider      │
└─────────────────┘  └─────────────────┘  └─────────────────┘
           │                  │                  │
           ▼                  ▼                  ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│ Google Drive API│  │  Dropbox API    │  │ File System     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

### Dependencies

```yaml
dependencies:
  googleapis: ^13.0.0
  googleapis_auth: ^1.0.0
  dropbox_client: ^1.0.0  # or direct API integration
  connectivity_plus: ^6.0.0
  crypto: ^3.0.0  # For checksums
```

### Feature Structure

```
lib/features/sync/
├── data/
│   ├── models/
│   │   ├── sync_metadata_model.dart
│   │   └── sync_conflict_model.dart
│   ├── providers/
│   │   ├── google_drive_sync_provider.dart
│   │   └── dropbox_sync_provider.dart
│   └── repositories/
│       └── sync_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── sync_status.dart
│   │   ├── sync_conflict.dart
│   │   └── sync_provider_info.dart
│   ├── repositories/
│   │   └── i_sync_repository.dart
│   └── services/
│       ├── sync_manager.dart
│       └── conflict_resolver.dart
└── presentation/
    ├── providers/
    │   └── sync_providers.dart
    ├── screens/
    │   └── sync_settings_screen.dart
    └── widgets/
        ├── sync_status_indicator.dart
        └── conflict_resolution_dialog.dart
```

### Database Changes - Sync Metadata

```dart
// Track sync state for each entity
class SyncMetadataTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();  // 'project', 'task', 'habit', etc.
  IntColumn get entityId => integer()();
  TextColumn get checksum => text()();  // Content hash for change detection
  DateTimeColumn get localModifiedAt => dateTime()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  TextColumn get syncStatus => text()();  // 'pending', 'synced', 'conflict'
  TextColumn get remoteVersions => text()();  // JSON: {"gdrive": "123", "dropbox": "456"}
}
```

### Sync Data Format

```dart
/// Exported data format (JSON)
class SyncData {
  final String version;
  final DateTime exportedAt;
  final String deviceId;
  final List<ProjectSync> projects;
  final List<TaskSync> tasks;
  final List<HabitSync> habits;
  final List<HabitCompletionSync> habitCompletions;
  final List<FocusSessionSync> sessions;
  final SettingsSync settings;
}

/// Each entity includes sync metadata
class ProjectSync {
  final int localId;
  final String uuid;  // Stable ID across devices
  final String checksum;
  final DateTime modifiedAt;
  final Map<String, dynamic> data;
}
```

### Sync Provider Interface

```dart
abstract class ISyncProvider {
  String get providerName;
  
  Future<Result<bool>> authenticate();
  Future<Result<void>> signOut();
  Future<bool> isAuthenticated();
  
  Future<Result<SyncData?>> fetchRemoteData();
  Future<Result<void>> uploadData(SyncData data);
  
  Future<Result<DateTime?>> getLastModifiedTime();
}
```

### Sync Manager

```dart
class SyncManager {
  final List<ISyncProvider> _providers;
  final ISyncRepository _repository;
  final ConflictResolver _conflictResolver;
  
  /// Sync to all enabled providers
  Future<Result<SyncReport>> syncAll() async {
    final localData = await _repository.exportData();
    final results = <String, SyncResult>{};
    
    for (final provider in _providers) {
      if (!await provider.isAuthenticated()) continue;
      
      final result = await _syncWithProvider(provider, localData);
      results[provider.providerName] = result;
    }
    
    return Success(SyncReport(results: results));
  }
  
  Future<SyncResult> _syncWithProvider(
    ISyncProvider provider, 
    SyncData localData,
  ) async {
    // 1. Fetch remote data
    final remoteResult = await provider.fetchRemoteData();
    if (remoteResult case Failure(:final failure)) {
      return SyncResult.failed(failure.message);
    }
    
    final remoteData = (remoteResult as Success).value;
    
    // 2. If no remote data, just upload
    if (remoteData == null) {
      await provider.uploadData(localData);
      return SyncResult.uploaded();
    }
    
    // 3. Merge data (detect conflicts)
    final mergeResult = await _mergeData(localData, remoteData);
    
    // 4. Handle conflicts
    if (mergeResult.hasConflicts) {
      final resolved = await _conflictResolver.resolve(mergeResult.conflicts);
      mergeResult.applyResolutions(resolved);
    }
    
    // 5. Upload merged data
    await provider.uploadData(mergeResult.merged);
    
    // 6. Import any new remote data locally
    await _repository.importData(mergeResult.merged);
    
    return SyncResult.success(
      uploaded: mergeResult.uploadedCount,
      downloaded: mergeResult.downloadedCount,
      conflicts: mergeResult.conflicts.length,
    );
  }
}
```

### Task Notifications Across Devices

**Challenge**: If a task with a reminder is created on Device A, how does Device B get the notification?

**Solution**:

```dart
class TaskNotificationSyncService {
  /// Called after sync imports new/updated tasks
  Future<void> syncTaskNotifications(List<Task> importedTasks) async {
    for (final task in importedTasks) {
      if (task.endDate == null) continue;
      
      // Cancel any existing notification for this task
      await _notificationService.cancelNotification(task.id!);
      
      // Schedule new notification if deadline is in future
      if (task.endDate!.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: task.id!,
          title: 'Task Reminder',
          body: task.title,
          scheduledTime: task.endDate!.subtract(Duration(minutes: 15)),
        );
      }
    }
  }
}
```

**Flow**:
1. Device A creates task with reminder → notification scheduled on A
2. Sync runs → task uploaded to cloud
3. Device B syncs → task downloaded
4. `TaskNotificationSyncService.syncTaskNotifications()` called
5. Device B schedules its own local notification

**Important**: Notifications are LOCAL to each device. The sync only shares the task data (including the reminder time). Each device is responsible for scheduling its own notifications based on the synced data.

### Conflict Resolution

```dart
class ConflictResolver {
  Future<List<ConflictResolution>> resolve(List<SyncConflict> conflicts) async {
    final resolutions = <ConflictResolution>[];
    
    for (final conflict in conflicts) {
      // Auto-resolve if possible
      if (_canAutoResolve(conflict)) {
        resolutions.add(_autoResolve(conflict));
        continue;
      }
      
      // Show dialog to user
      final userChoice = await _showConflictDialog(conflict);
      resolutions.add(ConflictResolution(
        conflict: conflict,
        choice: userChoice,  // 'local', 'remote', 'merge'
      ));
    }
    
    return resolutions;
  }
  
  bool _canAutoResolve(SyncConflict conflict) {
    // Auto-resolve: take most recent if changes don't overlap
    return conflict.localChangedFields
        .toSet()
        .intersection(conflict.remoteChangedFields.toSet())
        .isEmpty;
  }
}
```

### Implementation Checklist

- [ ] Add sync dependencies to pubspec.yaml
- [ ] Create SyncMetadataTable
- [ ] Create sync domain entities
- [ ] Create ISyncProvider interface
- [ ] Implement GoogleDriveSyncProvider
- [ ] Implement DropboxSyncProvider
- [ ] Create SyncManager
- [ ] Create ConflictResolver
- [ ] Create TaskNotificationSyncService
- [ ] Register all in DI
- [ ] Create SyncSettingsScreen
- [ ] Create SyncStatusIndicator widget
- [ ] Add sync button to settings
- [ ] Implement background sync (when app resumes)
- [ ] Add connectivity check before sync
- [ ] Test sync between two devices
- [ ] Test conflict resolution
- [ ] Test notification sync across devices

---

## 8. Import/Export

### Overview

Allow users to export all their data and import from a file.

### Export Formats

1. **JSON** - Full fidelity, for backup/sync
2. **CSV** - For spreadsheet analysis
3. **PDF Report** - Human-readable summary

### New Files

```
lib/features/import_export/
├── domain/
│   └── services/
│       ├── export_service.dart
│       └── import_service.dart
└── presentation/
    ├── screens/
    │   └── import_export_screen.dart
    └── widgets/
        └── export_options.dart
```

### Export Service

```dart
class ExportService {
  final DbService _db;
  
  Future<Result<File>> exportToJson() async {
    final data = SyncData(
      version: '1.0',
      exportedAt: DateTime.now(),
      deviceId: await _getDeviceId(),
      projects: await _exportProjects(),
      tasks: await _exportTasks(),
      habits: await _exportHabits(),
      habitCompletions: await _exportHabitCompletions(),
      sessions: await _exportSessions(),
      settings: await _exportSettings(),
    );
    
    final json = jsonEncode(data.toJson());
    final file = await _getExportFile('focus_backup_${DateTime.now().toIso8601String()}.json');
    await file.writeAsString(json);
    
    return Success(file);
  }
  
  Future<Result<File>> exportToCsv() async {
    // Export each entity type to separate CSV sheets
    // Zip them together
  }
  
  Future<Result<File>> exportToPdfReport(DateTimeRange range) async {
    // Generate PDF with charts and statistics for the date range
  }
}
```

### Import Service

```dart
class ImportService {
  Future<Result<ImportReport>> importFromJson(File file) async {
    try {
      final json = await file.readAsString();
      final data = SyncData.fromJson(jsonDecode(json));
      
      // Validate version compatibility
      if (!_isVersionCompatible(data.version)) {
        return Failure(ImportFailure('Incompatible backup version'));
      }
      
      // Import with conflict detection
      var imported = 0;
      var skipped = 0;
      var conflicts = <ImportConflict>[];
      
      // Import projects first (tasks depend on them)
      for (final project in data.projects) {
        final result = await _importProject(project);
        // ... handle result
      }
      
      // Then tasks, habits, sessions...
      
      return Success(ImportReport(
        imported: imported,
        skipped: skipped,
        conflicts: conflicts,
      ));
    } catch (e, st) {
      return Failure(ImportFailure('Failed to parse backup file', error: e));
    }
  }
}
```

### Implementation Checklist

- [ ] Create ExportService
- [ ] Create ImportService
- [ ] Implement JSON export
- [ ] Implement JSON import with validation
- [ ] Create ImportExportScreen
- [ ] Add share/save file picker
- [ ] Add import file picker
- [ ] (Optional) CSV export
- [ ] (Optional) PDF report generation
- [ ] Test export/import roundtrip

---

## 9. User Onboarding

### Overview

Guide new users through app setup and feature discovery.

### Onboarding Flow

```
1. Welcome Screen
   - App introduction
   - Privacy notice (data stays local)

2. Quick Setup
   - Focus duration preference
   - Break duration preference
   - Sound preference (with preview)

3. First Project
   - Create first project (or skip)
   - Brief explanation of projects

4. First Task
   - Create first task (or skip)
   - Brief explanation of tasks

5. Focus Session Demo
   - Start a 1-minute demo session
   - Show timer controls

6. Ready!
   - Summary of setup
   - Link to settings for more customization
```

### Implementation

```dart
// lib/features/onboarding/presentation/screens/onboarding_screen.dart
class OnboardingScreen extends ConsumerStatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  // Collected preferences
  int _focusDuration = 25;
  int _breakDuration = 5;
  SoundPreset _selectedSound = AudioAssets.defaultAmbience;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
            ),
            
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  WelcomePage(),
                  QuickSetupPage(
                    focusDuration: _focusDuration,
                    breakDuration: _breakDuration,
                    onFocusDurationChanged: (v) => setState(() => _focusDuration = v),
                    onBreakDurationChanged: (v) => setState(() => _breakDuration = v),
                  ),
                  SoundSetupPage(
                    selectedSound: _selectedSound,
                    onSoundSelected: (s) => setState(() => _selectedSound = s),
                  ),
                  FirstProjectPage(),
                  FirstTaskPage(),
                  ReadyPage(),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text('Back'),
                    )
                  else
                    SizedBox.shrink(),
                  
                  ElevatedButton(
                    onPressed: _currentPage < 5 ? _nextPage : _completeOnboarding,
                    child: Text(_currentPage < 5 ? 'Next' : 'Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _completeOnboarding() async {
    // Save preferences
    await ref.read(settingsProvider.notifier).updateSettings(
      focusDuration: _focusDuration,
      breakDuration: _breakDuration,
      ambienceSound: _selectedSound,
    );
    
    // Mark onboarding complete
    await ref.read(settingsProvider.notifier).setOnboardingComplete(true);
    
    // Navigate to home
    context.go(AppRoutes.home);
  }
}
```

### Check Onboarding Status

```dart
// In app.dart
class FocusApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(appRouterProvider);
    
    return settings.when(
      data: (s) {
        if (!s.onboardingComplete) {
          return MaterialApp(
            home: OnboardingScreen(),
          );
        }
        return MaterialApp.router(routerConfig: router);
      },
      loading: () => SplashScreen(),
      error: (e, st) => ErrorScreen(error: e),
    );
  }
}
```

### Implementation Checklist

- [ ] Add `onboardingComplete` to settings
- [ ] Create OnboardingScreen with PageView
- [ ] Create WelcomePage
- [ ] Create QuickSetupPage
- [ ] Create SoundSetupPage
- [ ] Create FirstProjectPage
- [ ] Create FirstTaskPage
- [ ] Create ReadyPage
- [ ] Update app.dart to check onboarding status
- [ ] Save preferences on completion
- [ ] Add "Reset Onboarding" option in settings (for testing)

---

## 10. Audio Loop Fix

### Overview

Fix the clicking/popping sound when ambient audio loops back to the beginning.

### Root Cause Analysis

The `audioplayers` package's `ReleaseMode.loop` seeks back to the start of the audio file when it ends. This can cause audible artifacts if:

1. **Audio file not loop-ready**: Start and end samples don't match
2. **Decoder gap**: Small gap during seek operation
3. **Buffer underrun**: Audio buffer empties during loop transition

### Solution Options (Ranked by Preference)

#### Option A: Fix Audio Files (Recommended)

**Pros**: No code changes, best quality
**Cons**: Requires audio editing

**Steps**:
1. Open each `.ogg` file in Audacity (free) or similar
2. Ensure the waveform at the start matches the end
3. Apply crossfade at the loop point (50-100ms)
4. Export with high quality settings (OGG Vorbis, quality 6+)

**Audacity Process**:
```
1. Open audio file
2. Select last 100ms of audio
3. Copy
4. Select first 100ms
5. Effect > Crossfade Tracks
6. Export as OGG (quality 6)
```

**FFmpeg alternative** (batch processing):
```bash
# For each audio file, create a loop-ready version
# This example creates a 2-minute seamless loop with crossfade
ffmpeg -i input.ogg -filter_complex \
  "[0:a]aloop=loop=1:size=2646000[loop]; \
   [loop]acrossfade=d=0.1:c1=tri:c2=tri[out]" \
  -map "[out]" -c:a libvorbis -q:a 6 output_loop.ogg
```

#### Option B: Crossfade Player (Code Solution)

**Pros**: Works with existing audio files
**Cons**: More complex, uses more memory (two players)

```dart
// lib/core/services/crossfade_audio_service.dart
class CrossfadeAudioService {
  final AudioPlayer _playerA = AudioPlayer();
  final AudioPlayer _playerB = AudioPlayer();
  bool _usePlayerA = true;
  Timer? _crossfadeTimer;
  StreamSubscription? _positionSub;
  Duration? _trackDuration;
  SoundPreset? _currentPreset;
  double _volume = 1.0;
  
  static const _crossfadeDuration = Duration(milliseconds: 500);
  
  Future<void> startAmbience([SoundPreset? preset]) async {
    _currentPreset = preset ?? AudioAssets.defaultAmbience;
    
    // Configure both players (NOT looping - we manage the loop)
    await _playerA.setReleaseMode(ReleaseMode.release);
    await _playerB.setReleaseMode(ReleaseMode.release);
    await _playerA.setVolume(_volume);
    await _playerB.setVolume(0);
    
    // Start player A
    await _playerA.play(AssetSource('audio/${_currentPreset!.assetPath}'));
    
    // Get duration for scheduling
    _trackDuration = await _playerA.getDuration();
    
    if (_trackDuration != null) {
      _scheduleCrossfade();
    } else {
      // Fallback: listen to position
      _positionSub = _playerA.onPositionChanged.listen(_checkPosition);
    }
  }
  
  void _scheduleCrossfade() {
    _crossfadeTimer?.cancel();
    _crossfadeTimer = Timer(
      _trackDuration! - _crossfadeDuration,
      _performCrossfade,
    );
  }
  
  void _checkPosition(Duration position) {
    if (_trackDuration == null) return;
    if (position >= _trackDuration! - _crossfadeDuration) {
      _performCrossfade();
    }
  }
  
  Future<void> _performCrossfade() async {
    final outgoing = _usePlayerA ? _playerA : _playerB;
    final incoming = _usePlayerA ? _playerB : _playerA;
    _usePlayerA = !_usePlayerA;
    
    // Start incoming at volume 0
    await incoming.setVolume(0);
    await incoming.play(AssetSource('audio/${_currentPreset!.assetPath}'));
    
    // Crossfade over duration
    const steps = 10;
    final stepDuration = _crossfadeDuration ~/ steps;
    
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(stepDuration);
      final progress = i / steps;
      await outgoing.setVolume(_volume * (1 - progress));
      await incoming.setVolume(_volume * progress);
    }
    
    // Stop outgoing
    await outgoing.stop();
    
    // Schedule next crossfade
    if (_trackDuration != null) {
      _scheduleCrossfade();
    }
  }
  
  Future<void> setVolume(double volume) async {
    _volume = volume;
    final active = _usePlayerA ? _playerA : _playerB;
    await active.setVolume(volume);
  }
  
  Future<void> stopAmbience() async {
    _crossfadeTimer?.cancel();
    _positionSub?.cancel();
    await _playerA.stop();
    await _playerB.stop();
  }
  
  void dispose() {
    _crossfadeTimer?.cancel();
    _positionSub?.cancel();
    _playerA.dispose();
    _playerB.dispose();
  }
}
```

#### Option C: Use `just_audio` Package

**Pros**: Better loop support, gapless playback
**Cons**: Requires replacing `audioplayers` package

```yaml
dependencies:
  just_audio: ^0.9.0
```

```dart
import 'package:just_audio/just_audio.dart';

class JustAudioService {
  final AudioPlayer _bgPlayer = AudioPlayer();
  
  Future<void> startAmbience(SoundPreset preset) async {
    await _bgPlayer.setAsset('assets/audio/${preset.assetPath}');
    await _bgPlayer.setLoopMode(LoopMode.one);  // Native gapless loop
    await _bgPlayer.play();
  }
  
  // ... rest of implementation
}
```

### Recommended Approach

1. **First, try Option A** (fix audio files)
   - Lowest risk
   - Best quality result
   - Test with one file first

2. **If that doesn't work, try Option C** (just_audio)
   - Better loop implementation
   - More features for audio apps
   - May require some API migration

3. **Option B is a fallback** if you can't change audio files or packages
   - Works but uses more resources
   - More code to maintain

### Testing

```dart
// Create a test to verify loop is seamless
void main() {
  test('Audio loops without click', () async {
    final service = AudioService();
    await service.startAmbience(AudioAssets.brownNoise);
    
    // Let it loop at least once
    await Future.delayed(Duration(seconds: 65));  // Assuming ~60s tracks
    
    // Manual verification required - listen for clicks
    await service.stopAmbience();
  });
}
```

### Implementation Checklist

- [ ] Investigate current audio file loop points
- [ ] Try Option A: Edit audio files for seamless loops
- [ ] If A fails, evaluate Option C (just_audio migration)
- [ ] If neither works, implement Option B (crossfade)
- [ ] Test with headphones for subtle artifacts
- [ ] Test on multiple devices (Android, iOS, Desktop)

---

## Appendix: Database Migration Plan

When implementing these features, database migrations will be needed:

```dart
// lib/core/services/db_service.dart

@DriftDatabase(tables: [
  // Existing
  ProjectTable,
  TaskTable,
  FocusSessionTable,
  SettingsTable,
  // New
  HabitTable,
  HabitCompletionTable,
  SyncMetadataTable,
])
class DbService extends _$DbService {
  @override
  int get schemaVersion => 3;  // Increment for each migration
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Migration from v1 to v2: Add recurring task fields
      if (from < 2) {
        await m.addColumn(taskTable, taskTable.isRecurring);
        await m.addColumn(taskTable, taskTable.recurrenceRule);
        await m.addColumn(taskTable, taskTable.recurringParentId);
        await m.addColumn(taskTable, taskTable.recurrenceEndDate);
      }
      
      // Migration from v2 to v3: Add habits and sync
      if (from < 3) {
        await m.createTable(habitTable);
        await m.createTable(habitCompletionTable);
        await m.createTable(syncMetadataTable);
        await m.addColumn(settingsTable, settingsTable.onboardingComplete);
      }
    },
  );
}
```

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| Mar 2026 | AI Agent | Initial feature plans document |
