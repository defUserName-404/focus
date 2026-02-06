5-6 Hour Flutter Project Implementation Plan
Architecture Overview
lib/
├── core/
│   ├── di/
│   │   └── injection.dart
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── audio_assets.dart
│   └── services/
│       ├── notification_service.dart
│       └── audio_service.dart
├── domain/
│   ├── entities/
│   │   ├── project.dart
│   │   ├── task.dart
│   │   ├── focus_session.dart
│   │   └── app_settings.dart
│   ├── repositories/
│   │   ├── i_project_repository.dart
│   │   ├── i_task_repository.dart
│   │   ├── i_focus_session_repository.dart
│   │   └── i_settings_repository.dart
│   └── enums/
│       ├── task_priority.dart
│       └── session_state.dart
├── data/
│   ├── models/
│   │   ├── project_model.dart
│   │   ├── task_model.dart
│   │   ├── focus_session_model.dart
│   │   └── settings_model.dart
│   ├── datasources/
│   │   └── local/
│   │       └── isar_database.dart
│   └── repositories/
│       ├── project_repository_impl.dart
│       ├── task_repository_impl.dart
│       ├── focus_session_repository_impl.dart
│       └── settings_repository_impl.dart
├── presentation/
│   ├── providers/
│   │   ├── project_provider.dart
│   │   ├── task_provider.dart
│   │   ├── focus_session_provider.dart
│   │   └── settings_provider.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── project_summary_card.dart
│   │   │       └── active_tasks_list.dart
│   │   ├── projects/
│   │   │   ├── project_list_screen.dart
│   │   │   ├── project_detail_screen.dart
│   │   │   ├── create_project_screen.dart
│   │   │   └── widgets/
│   │   │       └── project_card.dart
│   │   ├── tasks/
│   │   │   ├── task_detail_screen.dart
│   │   │   ├── create_task_screen.dart
│   │   │   └── widgets/
│   │   │       ├── task_item.dart
│   │   │       └── task_tree_view.dart
│   │   ├── focus/
│   │   │   ├── focus_session_screen.dart
│   │   │   └── widgets/
│   │   │       ├── focus_timer_widget.dart
│   │   │       └── session_controls.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   │           └── settings_item.dart
│   └── theme/
│       └── app_theme.dart
└── main.dart
Hour-by-Hour Implementation Plan
Hour 1: Setup & Core Infrastructure (60 min)
Tasks:

Create Flutter project with required dependencies (10 min)
Setup Isar database schema and collections (20 min)
Setup GetIt dependency injection (15 min)
Create domain entities (15 min)

Dependencies to add:
yamldependencies:
  flutter:
    sdk: flutter
  forui: ^latest
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  get_it: ^7.6.0
  audioplayers: ^5.2.1
  flutter_local_notifications: ^16.3.0
  intl: ^0.18.1

dev_dependencies:
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.7
Deliverables:

Project structure created
Isar collections defined (Project, Task, Settings)
DI container configured
Domain entities ready


Hour 2: Data Layer & Repositories (60 min)
Tasks:

Implement Isar models with converters (20 min)
Create repository interfaces in domain layer (10 min)
Implement concrete repositories (25 min)
Test database CRUD operations (5 min)

Key Classes:

ProjectRepositoryImpl with Isar
TaskRepositoryImpl with hierarchical task support
SettingsRepositoryImpl for app preferences

Deliverables:

All repositories functional
CRUD operations working offline
Data persists across app restarts


Hour 3: State Management & Business Logic (60 min)
Tasks:

Create Riverpod providers for all features (20 min)
Implement focus session logic with timer (20 min)
Setup notification service (15 min)
Create settings provider with sound preferences (5 min)

Key Providers:

projectProvider - AsyncNotifierProvider for projects
taskProvider - AsyncNotifierProvider for tasks
focusSessionProvider - StateNotifierProvider for active session
settingsProvider - StateNotifierProvider for app settings

Deliverables:

State management fully configured
Focus timer with background capability
Notification system ready


Hour 4: UI - Core Screens (60 min)
Tasks:

Create home screen with project overview (15 min)
Build project list and detail screens (20 min)
Implement task creation/editing with hierarchy (20 min)
Setup Forui theme and styling (5 min)

Screens:

Home: Dashboard with active projects & tasks
Projects: List view with create/edit
Project Detail: Tasks grouped by hierarchy
Task Detail: Full CRUD with priority, dates

Deliverables:

Navigation working
Basic CRUD UI functional
Forui components integrated


Hour 5: Focus Session & Audio (60 min)
Tasks:

Build focus session screen with timer UI (20 min)
Integrate audio player with customizable sounds (15 min)
Implement background notification with controls (15 min)
Add session completion alarm (10 min)

Features:

Customizable focus/break durations
Sound selection (white noise, rain, silence, etc.)
Persistent notification during session
Alarm on completion

Deliverables:

Focus sessions fully working
Background playback functional
Notification controls active


Hour 6: Settings, Polish & Testing (60 min)
Tasks:

Build settings screen (15 min)
Add task priority filtering/sorting (10 min)
Polish UI with Forui components (15 min)
End-to-end testing on mobile & desktop (20 min)

Settings:

Focus duration (default: 25 min)
Break duration (default: 5 min)
Sound selection
Notification preferences

Final Testing:

Create project → Add tasks → Start focus session
Test offline persistence
Verify notifications
Check cross-platform compatibility

Deliverables:

Fully functional MVP
Settings configured
App tested on target platforms


Future-Proof Architecture Guidelines
Sync Capability (Future Enhancement)
Current Architecture:
dartabstract class ProjectRepository {
  Future<List<Project>> getAll();
  Future<void> create(Project project);
  // ... CRUD methods
}
Future Sync Layer:
dartabstract class SyncService {
  Future<void> syncProjects();
  Future<void> syncTasks();
}

class ProjectRepositoryImpl implements ProjectRepository {
  final IsarDatabase _local;
  final SyncService? _sync; // Optional sync

  @override
  Future<void> create(Project project) async {
    await _local.saveProject(project);
    await _sync?.syncProjects(); // Auto-sync if enabled
  }
}
Migration Strategy

Add sync flag to models:

dartclass ProjectModel {
  String? remoteId;
  DateTime? lastSyncedAt;
  bool needsSync;
}

Create sync abstraction:

dartabstract class RemoteDataSource {
  Future<List<Project>> fetchProjects();
  Future<void> pushProjects(List<Project> projects);
}

// Implementations: Firebase, Supabase, Custom API
class FirebaseDataSource implements RemoteDataSource { }

No changes needed in:


Domain layer (entities, use cases)
Presentation layer (providers, UI)
Just swap repository implementation in DI


Critical Implementation Details
1. Hierarchical Tasks (Isar)
dart@collection
class TaskModel {
  Id id = Isar.autoIncrement;
  String? parentId; // Reference to parent task
  int depth; // 0 = root, 1 = subtask, 2 = sub-subtask

  // Query children
  @Backlink(to: 'parentId')
  final children = IsarLinks<TaskModel>();
}
2. Focus Session Background Service
dartclass FocusSessionProvider extends StateNotifier<FocusSessionState> {
  Timer? _timer;

  void startSession(int durationMinutes) {
    _showNotification();
    _playAudio();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      // Update notification with remaining time
      // On completion: play alarm, show completion notification
    });
  }
}
3. Cross-Platform Notifications
dartclass NotificationHelper {
  static Future<void> init() async {
    // Android: Configure channel
    // iOS: Request permissions
    // Desktop: Use flutter_local_notifications
  }

  static Future<void> showOngoingSession(Duration remaining) async {
    // Show persistent notification with play/pause/stop
  }
}
4. Forui Theme Setup
dartvoid main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData(
          extensions: [
            FThemeData(
              colorScheme: FColorScheme.zinc(),
              // Customize to match Shadcn aesthetics
            ),
          ],
        ),
        home: HomeScreen(),
      ),
    ),
  );
}

Risk Mitigation
Potential Blockers:

Desktop notifications - May need platform-specific implementations

Solution: Use flutter_local_notifications v16+ with desktop support


Background audio on mobile - iOS restrictions

Solution: Use audioplayers with proper audio session configuration


Isar web support - Limited

Solution: Abstract storage layer, use Hive/SharedPreferences for web



Time Buffers:

Each hour has 5-10 min buffer for debugging
Hour 6 has 20 min testing buffer
If ahead of schedule, add polish (animations, error handling)


Success Criteria
✅ Must Have (MVP):

Create projects with tasks (unlimited nesting)
Focus sessions with timer
Offline persistence
Basic notifications
Settings for session duration
Works on Android/iOS/Desktop

✅ Should Have (If time permits):

Task priority sorting
Multiple sound options
Session history
Better UI polish

✅ Future Enhancements:

Cloud sync
Analytics/reports
Collaboration
Recurring tasks


Getting Started Commands
bash# Create project
flutter create focus_task_manager
cd focus_task_manager

# Add dependencies
flutter pub add isar isar_flutter_libs riverpod flutter_riverpod get_it audioplayers flutter_local_notifications forui intl

flutter pub add --dev isar_generator build_runner

# Generate Isar files
flutter pub run build_runner build

# Run
flutter run
This plan delivers a production-ready MVP in 5-6 hours while maintaining clean architecture that scales to sync, web, and team features. The contract-based approach with interfaces ensures you can swap implementations without touching business logic or UI.