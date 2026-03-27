# Architecture Documentation

This document describes the architectural design and patterns used in the Focus application.

---

## Table of Contents

1. [High-Level Architecture](#high-level-architecture)
2. [Clean Architecture Layers](#clean-architecture-layers)
3. [Dependency Injection](#dependency-injection)
4. [State Management](#state-management)
5. [Database Architecture](#database-architecture)
6. [Navigation Architecture](#navigation-architecture)
7. [Feature Modules](#feature-modules)
8. [Cross-Cutting Concerns](#cross-cutting-concerns)
9. [Platform Abstraction](#platform-abstraction)

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Screens   │  │   Widgets   │  │   Commands  │             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
│         │                │                │                     │
│         └────────────────┼────────────────┘                     │
│                          │                                       │
│                   ┌──────▼──────┐                                │
│                   │  Providers  │ (Riverpod)                     │
│                   └──────┬──────┘                                │
├──────────────────────────┼──────────────────────────────────────┤
│                     Domain                                       │
│                   ┌──────▼──────┐                                │
│                   │  Services   │ (Business Logic)               │
│                   └──────┬──────┘                                │
│                          │                                       │
│                   ┌──────▼──────┐                                │
│                   │ Repositories│ (Interfaces)                   │
│                   └──────┬──────┘                                │
│                          │                                       │
│                   ┌──────▼──────┐                                │
│                   │  Entities   │ (Immutable)                    │
│                   └─────────────┘                                │
├─────────────────────────────────────────────────────────────────┤
│                       Data                                       │
│                   ┌─────────────┐                                │
│                   │ Repository  │                                │
│                   │   Impls     │                                │
│                   └──────┬──────┘                                │
│                          │                                       │
│                   ┌──────▼──────┐                                │
│                   │ DataSources │                                │
│                   └──────┬──────┘                                │
│                          │                                       │
│                   ┌──────▼──────┐                                │
│                   │   Models    │ (Drift Tables)                 │
│                   └──────┬──────┘                                │
├──────────────────────────┼──────────────────────────────────────┤
│                     Core                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  │    DI    │  │ Services │  │  Utils   │  │  Theme   │        │
│  │ (GetIt)  │  │(DB,Audio)│  │ (Result) │  │ (ForUI)  │        │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Clean Architecture Layers

### Domain Layer (Innermost)

**Purpose**: Business logic and entities. Has ZERO dependencies on other layers.

**Contents**:
- **Entities**: Immutable data classes representing core business objects
- **Repository Interfaces**: Abstract contracts for data operations
- **Services**: Business logic orchestrating repository calls

**Key Rule**: Never import from `data/` or `presentation/` directories.

```
features/<feature>/domain/
├── entities/
│   ├── <entity>.dart           # Immutable class extending Equatable
│   └── <entity>_extensions.dart # copyWith and helper methods
├── repositories/
│   └── i_<name>_repository.dart # Abstract interface
└── services/
    └── <name>_service.dart      # Business logic, returns Result<T>
```

### Data Layer (Middle)

**Purpose**: Implementation of repository interfaces, database interaction.

**Contents**:
- **Models**: Drift table definitions
- **DataSources**: Direct database query classes
- **Repositories**: Implementations of domain interfaces
- **Mappers**: Bidirectional DB model <-> Domain entity converters

```
features/<feature>/data/
├── models/
│   └── <entity>_model.dart      # Drift table class
├── datasources/
│   └── <name>_local_datasource.dart  # Interface + Impl
├── repositories/
│   └── <name>_repository_impl.dart
└── mappers/
    └── <entity>_extensions.dart  # toDomain(), toCompanion()
```

### Presentation Layer (Outermost)

**Purpose**: UI components and state management.

**Contents**:
- **Screens**: Full-page widgets
- **Widgets**: Reusable UI components
- **Providers**: Riverpod state holders
- **Commands**: User action handlers (static methods)

```
features/<feature>/presentation/
├── screens/
│   ├── <name>_list_screen.dart
│   ├── <name>_detail_screen.dart
│   ├── create_<name>_screen.dart
│   └── edit_<name>_screen.dart
├── widgets/
│   ├── <name>_card.dart
│   └── <name>_form.dart
├── providers/
│   ├── <name>_provider.dart
│   └── <name>_provider.g.dart  # Generated
└── commands/
    └── <name>_commands.dart
```

---

## Dependency Injection

### GetIt Configuration

All dependencies are registered in `lib/core/di/injection.dart`:

```dart
final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // 1. Core Infrastructure (singletons, eager)
  getIt
    ..registerSingleton<AppDatabase>(AppDatabase())
    ..registerLazySingleton<AudioService>(() => AudioService())
    ..registerLazySingleton<NavigationService>(() => NavigationService());

  // 2. Platform-specific services (conditional)
  if (PlatformUtils.supportsMediaSession) {
    final audioHandler = await FocusAudioHandler.init();
    getIt.registerSingleton<FocusAudioHandler>(audioHandler);
  }

  // 3. Feature modules (lazy, grouped by feature)
  _initProjectsDi();
  _initTasksDi();
  _initSettingsDi();
  _initSessionDi();
}
```

### Registration Patterns

| Pattern | Use Case | Example |
|---------|----------|---------|
| `registerSingleton` | Eager, single instance | `AppDatabase` |
| `registerLazySingleton` | Lazy, single instance | Services, Repositories |
| `registerFactory` | New instance each time | Rarely used |

### Feature DI Initialization

```dart
void _initProjectsDi() {
  getIt
    ..registerLazySingleton<IProjectLocalDataSource>(
      () => ProjectLocalDataSourceImpl(getIt<AppDatabase>()),
    )
    ..registerLazySingleton<IProjectRepository>(
      () => ProjectRepositoryImpl(getIt<IProjectLocalDataSource>()),
    )
    ..registerLazySingleton<ProjectService>(
      () => ProjectService(getIt<IProjectRepository>()),
    );
}
```

### Accessing Dependencies

```dart
// In services, repositories, etc.
import 'package:focus/core/di/injection.dart';

final db = getIt<AppDatabase>();
final service = getIt<ProjectService>();

// In Riverpod providers
@Riverpod(keepAlive: true)
IProjectRepository projectRepository(Ref ref) {
  return getIt<IProjectRepository>();
}
```

---

## State Management

### Riverpod Architecture

Focus uses Riverpod with code generation for type-safe providers.

#### Provider Hierarchy

```
┌─────────────────────────────────────────────────┐
│            UI (ConsumerWidget)                   │
│                    │                             │
│              ref.watch()                         │
│                    ▼                             │
│  ┌─────────────────────────────────────────┐    │
│  │         Notifier Providers               │    │
│  │  (projectProvider, taskProvider, etc.)  │    │
│  │         Mutations + State               │    │
│  └──────────────────┬──────────────────────┘    │
│                     │                            │
│              uses services                       │
│                     ▼                            │
│  ┌─────────────────────────────────────────┐    │
│  │         Stream Providers                 │    │
│  │  (projectListProvider, etc.)            │    │
│  │         Reactive Data                   │    │
│  └──────────────────┬──────────────────────┘    │
│                     │                            │
│               watches                            │
│                     ▼                            │
│  ┌─────────────────────────────────────────┐    │
│  │         Repository Providers             │    │
│  │  (projectRepositoryProvider)            │    │
│  │         GetIt → Provider bridge         │    │
│  └─────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘
```

#### Provider Types Used

| Type | Purpose | Example |
|------|---------|---------|
| `@Riverpod(keepAlive: true)` | Singleton data | Repository providers |
| `StreamProvider` | Reactive DB streams | `projectListProvider` |
| `Notifier` | Mutable state + actions | `ProjectNotifier` |
| `@riverpod` (auto-dispose) | Screen-local state | Filter states |

---

## Database Architecture

### Drift Setup

Database is defined in `lib/core/services/db_service.dart`:

```dart
@DriftDatabase(tables: [
  ProjectTable,
  TaskTable,
  FocusSessionTable,
  DailySessionStatsTable,
  SettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'focus.sqlite'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async => await m.createAll(),
    onUpgrade: (m, from, to) async {
      // Migration logic here
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
```

### Table Relationships

```
┌──────────────┐       ┌──────────────┐
│   Project    │───┐   │   Settings   │
│              │   │   │   (Global)   │
└──────────────┘   │   └──────────────┘
                   │
              1:N  │
                   ▼
┌──────────────────────────────────┐
│              Task                │
│  project_id (FK) ─────────────► │
│  parent_task_id (FK, self) ◄──┐ │
│                               │ │
│  (Hierarchical tasks)         │ │
│  depth: 0=root, 1=subtask,... │ │
└──────────────────────────────────┘
                   │
              1:N  │
                   ▼
┌──────────────────────────────────┐
│          FocusSession            │
│  task_id (FK, nullable) ───────►│
│                                  │
│  state: running|paused|etc.     │
│  elapsed_seconds                │
└──────────────────────────────────┘
                   │
            Aggregates to
                   ▼
┌──────────────────────────────────┐
│       DailySessionStats          │
│  date (PK)                       │
│  completed_sessions              │
│  total_sessions                  │
│  focus_seconds                   │
└──────────────────────────────────┘
```

### Cascade Deletes

Foreign keys use `ON DELETE CASCADE`:
- Deleting a Project deletes all its Tasks
- Deleting a Task deletes all its FocusSessions and subtasks

---

## Navigation Architecture

### Navigator 1.0 Pattern

Focus uses traditional Navigator 1.0 with named routes:

```dart
// Routes defined in lib/core/constants/route_constants.dart
abstract final class RouteConstants {
  static const String homeRoute = '/';
  static const String projectDetailRoute = '/project_detail';
  static const String createProjectRoute = '/create_project';
  // ...
}
```

### NavigationService

Centralized navigation via `lib/core/routing/navigation_service.dart`:

```dart
class NavigationService {
  void goToProjectDetail(BuildContext context, int projectId) {
    Navigator.of(context).pushNamed(
      RouteConstants.projectDetailRoute,
      arguments: projectId,
    );
  }

  void goToCreateProject(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed(
      RouteConstants.createProjectRoute,
    );
  }
}
```

### Shell Architecture

The app uses `AdaptiveShell` for platform-responsive layouts:
- **Compact** (mobile): Bottom navigation + stacked screens
- **Expanded** (desktop/tablet): Side rail + master-detail

---

## Feature Modules

### Projects Feature

Manages user projects with CRUD operations.

```
features/projects/
├── data/
│   ├── datasources/project_local_datasource.dart
│   ├── mappers/project_extensions.dart
│   ├── models/project_model.dart
│   └── repositories/project_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── project.dart
│   │   ├── project_extensions.dart
│   │   ├── project_list_filter_state.dart
│   │   └── project_progress.dart
│   ├── repositories/i_project_repository.dart
│   └── services/project_service.dart
└── presentation/
    ├── commands/project_commands.dart
    ├── providers/project_provider.dart
    ├── screens/
    │   ├── create_project_screen.dart
    │   ├── edit_project_screen.dart
    │   ├── project_detail_screen.dart
    │   └── project_list_screen.dart
    └── widgets/
        ├── project_card.dart
        ├── project_detail_header.dart
        ├── project_meta_section.dart
        └── project_progress_bar.dart
```

### Tasks Feature

Manages hierarchical tasks (supports subtasks via `depth` and `parentTaskId`).

### Session Feature

Manages focus timer sessions with states:
- `running` → `paused` → `completed`
- `onBreak` for break intervals
- `cancelled` for user-cancelled
- `incomplete` for abandoned sessions

### Settings Feature

Global app settings including:
- Focus/break durations
- Audio preferences
- Notification settings

---

## Cross-Cutting Concerns

### Logging

Centralized via `LogService`:

```dart
final _log = LogService.instance;

_log.debug('Message', tag: 'ClassName');
_log.info('Message', tag: 'ClassName');
_log.warning('Message', tag: 'ClassName', error: e, stackTrace: st);
_log.error('Message', tag: 'ClassName', error: e, stackTrace: st);
```

### Error Handling

Result type pattern via `lib/core/utils/result.dart`:

```dart
sealed class Result<T> { ... }
final class Success<T> extends Result<T> { ... }
final class Failure<T> extends Result<T> { ... }

sealed class AppFailure { ... }
final class DatabaseFailure extends AppFailure { ... }
final class NotFoundFailure extends AppFailure { ... }
// etc.
```

### Constants

UI constants centralized in `lib/core/constants/app_constants.dart`:

```dart
AppConstants.spacing.small    // 4.0
AppConstants.spacing.regular  // 8.0
AppConstants.spacing.large    // 16.0
AppConstants.size.icon.small  // Icon sizes
```

---

## Platform Abstraction

### PlatformUtils

Located in `lib/core/utils/platform_utils.dart`:

```dart
abstract final class PlatformUtils {
  static bool get isDesktop { ... }
  static bool get isMobile { ... }
  static bool get isWeb { ... }
  static bool get supportsLocalNotifications { ... }
  static bool get supportsMediaSession { ... }
  static FormFactor formFactorOf(BuildContext context) { ... }
}
```

### Conditional Features

```dart
// In DI setup
if (PlatformUtils.supportsMediaSession) {
  final audioHandler = await FocusAudioHandler.init();
  getIt.registerSingleton<FocusAudioHandler>(audioHandler);
}

// In code
if (PlatformUtils.supportsLocalNotifications) {
  notificationService.showNotification(...);
}
```

---

## Data Flow Example

### Creating a Project

```
┌──────────────────────────────────────────────────────────────────┐
│ 1. UI: CreateProjectScreen                                        │
│    User fills form, taps "Create"                                 │
│    ↓                                                              │
│ 2. Provider: projectProvider.notifier.createProject(...)          │
│    ↓                                                              │
│ 3. Service: ProjectService.createProject(...)                     │
│    - Creates Project entity with timestamps                       │
│    - Calls repository                                             │
│    - Returns Result<Project>                                      │
│    ↓                                                              │
│ 4. Repository: ProjectRepositoryImpl.createProject(...)           │
│    - Maps entity to companion                                     │
│    - Calls datasource                                             │
│    ↓                                                              │
│ 5. DataSource: ProjectLocalDataSourceImpl.createProject(...)      │
│    - Inserts into Drift DB                                        │
│    - Returns generated ID                                         │
│    ↓                                                              │
│ 6. Back up the chain:                                             │
│    - Repository: Returns entity with ID                           │
│    - Service: Logs success, wraps in Success()                    │
│    - Provider: Updates state, refreshes list                      │
│    - UI: Navigates to project detail                              │
└──────────────────────────────────────────────────────────────────┘
```
