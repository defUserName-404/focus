# Coding Style Guide

This document defines the coding conventions and style guidelines for the Focus codebase. All code must follow these standards.

---

## Table of Contents

1. [Formatting](#formatting)
2. [Naming Conventions](#naming-conventions)
3. [Imports](#imports)
4. [File Organization](#file-organization)
5. [Types and Nullability](#types-and-nullability)
6. [Error Handling](#error-handling)
7. [Documentation](#documentation)
8. [Flutter/Dart Specifics](#flutterdart-specifics)
9. [Riverpod Guidelines](#riverpod-guidelines)
10. [Drift/Database Guidelines](#driftdatabase-guidelines)

---

## Formatting

### Line Width

- **Maximum line width: 120 characters**
- Configured in `analysis_options.yaml`

```bash
# Format command
dart format . --line-length=120
```

### Indentation

- Use 2 spaces for indentation (Dart default)
- No tabs

### Trailing Commas

Use trailing commas for better diffs and formatting:

```dart
// Good
const Project({
  required this.title,
  required this.createdAt,
  this.description,
});

// Avoid (harder to diff)
const Project({required this.title, required this.createdAt, this.description});
```

### Braces and Brackets

```dart
// Good - opening brace on same line
if (condition) {
  doSomething();
}

// Good - single-line bodies can omit braces
if (condition) return value;

// Good - arrow syntax for single expressions
int get count => items.length;
```

---

## Naming Conventions

### Files

| Type | Convention | Example |
|------|------------|---------|
| Classes | `snake_case.dart` | `project_service.dart` |
| Feature files | `<feature>_<type>.dart` | `project_provider.dart` |
| Extensions | `<subject>_extensions.dart` | `project_extensions.dart` |
| Mappers | `<entity>_mappers.dart` | `task_mappers.dart` |
| Generated | `<source>.g.dart` | `project_provider.g.dart` |

### Classes and Types

| Type | Convention | Example |
|------|------------|---------|
| Classes | `PascalCase` | `ProjectService` |
| Abstract interfaces | `I<Name>` prefix | `IProjectRepository` |
| Implementations | `<Name>Impl` suffix | `ProjectRepositoryImpl` |
| Providers (Riverpod) | `<name>Provider` | `projectListProvider` |
| Notifiers (Riverpod) | `<Name>Notifier` | `ProjectNotifier` |

### Variables and Functions

| Type | Convention | Example |
|------|------------|---------|
| Variables | `camelCase` | `projectCount` |
| Private | `_camelCase` | `_repository` |
| Constants | `camelCase` | `defaultPageSize` |
| Global finals | `_camelCase` | `final _log = LogService.instance;` |
| Functions | `camelCase` | `createProject()` |
| Boolean getters | `is`/`has`/`can` prefix | `isCompleted`, `hasDeadline` |

### Enums

```dart
// Enum values use camelCase
enum TaskPriority {
  critical,
  high,
  medium,
  low;
}

// Enums with methods
enum SessionState {
  running,
  paused,
  completed;

  String get label => switch (this) {
    running => 'Running',
    paused => 'Paused',
    completed => 'Completed',
  };
}
```

---

## Imports

### Order

Organize imports in this order (with blank lines between groups):

1. Dart SDK imports
2. Flutter imports
3. External packages
4. Internal packages (absolute paths from `package:focus/`)
5. Relative imports

```dart
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:equatable/equatable.dart';
import 'package:forui/forui.dart' as fu;

import 'package:focus/core/di/injection.dart';
import 'package:focus/core/services/log_service.dart';

import '../entities/project.dart';
import 'project_extensions.dart';
```

### Aliasing

Use aliases to avoid conflicts or clarify imports:

```dart
import 'package:forui/forui.dart' as fu;
import 'package:drift/drift.dart' show Value;
import 'dart:developer' as developer;
```

### Part Directives

For code generation, use `part` directives:

```dart
// In main file
part 'project_provider.g.dart';

// Never manually edit .g.dart files
```

---

## File Organization

### Class File Structure

Organize class members in this order:

```dart
class MyService {
  // 1. Static constants
  static const defaultTimeout = Duration(seconds: 30);
  
  // 2. Static methods
  static MyService get instance => _instance;
  
  // 3. Instance fields (final first, then mutable)
  final IRepository _repository;
  final LogService _log = LogService.instance;
  
  // 4. Constructors
  MyService(this._repository);
  
  // 5. Factory constructors
  factory MyService.create() => MyService(getIt<IRepository>());
  
  // 6. Getters/Setters
  bool get isActive => _active;
  
  // 7. Public methods
  Future<Result<Data>> fetchData() async { ... }
  
  // 8. Private methods
  void _processInternal() { ... }
  
  // 9. Overrides
  @override
  String toString() => 'MyService()';
}
```

### Widget File Structure

```dart
class MyWidget extends ConsumerStatefulWidget {
  // 1. Constructor parameters
  final String title;
  final VoidCallback? onTap;
  
  // 2. Constructor
  const MyWidget({super.key, required this.title, this.onTap});
  
  // 3. State creation
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  // 1. Controllers and state
  final _controller = TextEditingController();
  bool _isLoading = false;
  
  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
    // ...
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // 3. Build method
  @override
  Widget build(BuildContext context) { ... }
  
  // 4. Helper/builder methods
  Widget _buildContent() { ... }
  
  // 5. Event handlers
  Future<void> _handleSubmit() async { ... }
}
```

---

## Types and Nullability

### Null Safety

- Prefer non-nullable types when possible
- Use `?` only when null is a valid business value
- Use `late` sparingly, only when initialization is guaranteed

```dart
// Good - explicit nullability
final int? parentTaskId;  // Can legitimately be null (no parent)
final String title;       // Always required

// Avoid late unless necessary
late final ProjectService _service;  // OK if set in build()

// Prefer initializers
final _log = LogService.instance;  // Better than late
```

### Type Inference

- Use explicit types for public APIs
- Let Dart infer types for local variables when obvious

```dart
// Public API - explicit types
Future<Result<Project>> createProject(String title) async { ... }

// Local variables - inference OK when obvious
final projects = await repository.getAllProjects();
final count = projects.length;

// Explicit when clarity helps
final List<Project> filtered = projects.where((p) => p.isActive).toList();
```

---

## Error Handling

### Result Type Pattern

Services MUST return `Result<T>` for operations that can fail:

```dart
// In service layer
Future<Result<Project>> createProject({required String title}) async {
  try {
    final now = DateTime.now();
    final project = Project(
      title: title,
      createdAt: now,
      updatedAt: now,
    );
    final created = await _repository.createProject(project);
    _log.info('Project created: "$title"', tag: 'ProjectService');
    return Success(created);
  } catch (e, st) {
    _log.error('Failed to create project', tag: 'ProjectService', error: e, stackTrace: st);
    return Failure(DatabaseFailure('Failed to create project', error: e, stackTrace: st));
  }
}
```

### Using Results

```dart
// Pattern matching (preferred)
final result = await service.createProject(title: 'New Project');
switch (result) {
  case Success(:final value):
    // Use value
    break;
  case Failure(:final failure):
    // Handle failure
    state = AsyncValue.error(failure, StackTrace.current);
}

// Convenience methods
final project = result.getOrNull();
final projectOrDefault = result.getOrElse((_) => defaultProject);
```

### Failure Types

Use specific failure types from `lib/core/utils/result.dart`:

| Type | Usage |
|------|-------|
| `DatabaseFailure` | DB read/write/migration errors |
| `NotFoundFailure` | Entity not found |
| `SessionFailure` | Focus session state errors |
| `AudioFailure` | Audio playback errors |
| `NotificationFailure` | Notification scheduling errors |
| `UnexpectedFailure` | Catch-all for unexpected errors |

### Repository Layer

Repositories catch and rethrow - let services handle Result wrapping:

```dart
// Repository - catches, logs, rethrows
@override
Future<Project> createProject(Project project) async {
  try {
    final companion = project.toCompanion();
    final id = await _localDataSource.createProject(companion);
    _log.debug('Project row inserted (id=$id)', tag: 'ProjectRepository');
    return project.copyWith(id: id);
  } catch (e, st) {
    _log.error('Failed to insert project', tag: 'ProjectRepository', error: e, stackTrace: st);
    rethrow;
  }
}
```

---

## Documentation

### When to Document

- All public APIs (classes, methods, properties)
- Complex private logic
- Non-obvious behavior
- Extension methods

### Documentation Style

```dart
/// Brief one-line description.
///
/// More detailed description if needed. Can span
/// multiple paragraphs.
///
/// Example:
/// ```dart
/// final service = ProjectService(repository);
/// final result = await service.createProject(title: 'My Project');
/// ```
///
/// See also:
/// - [IProjectRepository] for the data layer contract
/// - [ProjectNotifier] for the UI layer
class ProjectService {
  /// Creates a new project with the given [title].
  ///
  /// Returns a [Success] with the created project including its
  /// generated ID, or a [Failure] if the database operation fails.
  Future<Result<Project>> createProject({required String title}) async { ... }
}
```

### Comments

```dart
// Single-line comments for implementation notes

// TODO: Implement pagination
// FIXME: Race condition when deleting

/*
 * Multi-line comments for complex explanations.
 * Prefer doc comments for public APIs.
 */
```

---

## Flutter/Dart Specifics

### Widget Construction

```dart
// Always use const where possible
const SizedBox(height: 8);
const EdgeInsets.all(16);
const Text('Hello');

// Use AppConstants for spacing
Padding(
  padding: EdgeInsets.all(AppConstants.spacing.regular),
  child: content,
);
```

### Build Method Best Practices

```dart
@override
Widget build(BuildContext context) {
  // 1. Watch providers at top
  final projectAsync = ref.watch(filteredProjectListProvider);
  final filter = ref.watch(projectListFilterProvider);
  
  // 2. Derive theme/context values
  final typography = context.typography;
  final colors = context.colors;
  
  // 3. Return widget tree
  return FScaffold(
    header: FHeader.nested(
      title: Text('Title', style: typography.xl2),
    ),
    child: projectAsync.when(
      loading: () => const Center(child: FCircularProgress()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (projects) => _buildList(projects),
    ),
  );
}
```

### ForUI Components

Use ForUI (`forui` package) components with the `fu` prefix:

```dart
import 'package:forui/forui.dart' as fu;

// Scaffolds and headers
fu.FScaffold(
  header: fu.FHeader.nested(...),
  child: content,
)

// Buttons
fu.FButton(
  prefix: Icon(fu.FIcons.plus),
  onPress: () => ...,
  child: Text('Create'),
)

// Icons use fu.FIcons
Icon(fu.FIcons.arrowRight, size: AppConstants.size.icon.regular)
```

---

## Riverpod Guidelines

### Provider Annotations

```dart
// Keep-alive providers (singletons, core data)
@Riverpod(keepAlive: true)
IProjectRepository projectRepository(Ref ref) {
  return getIt<IProjectRepository>();
}

// Auto-dispose providers (screen-specific data)
@riverpod
Stream<List<Task>> tasksByProject(Ref ref, String projectId) {
  final repository = ref.watch(taskRepositoryProvider);
  return repository.watchTasksByProject(int.parse(projectId));
}

// Notifier classes
@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier {
  @override
  AsyncValue<List<Project>> build() {
    // Initial state
    return const AsyncValue.loading();
  }
}
```

### Provider File Structure

```dart
// project_provider.dart

part 'project_provider.g.dart';

// 1. Repository providers
@Riverpod(keepAlive: true)
IProjectRepository projectRepository(Ref ref) => getIt<IProjectRepository>();

// 2. Stream providers for reactive data
@Riverpod(keepAlive: true)
Stream<List<Project>> projectList(Ref ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchAllProjects();
}

// 3. Parameterized providers
@Riverpod(keepAlive: true)
Stream<Project?> projectById(Ref ref, String id) { ... }

// 4. Filter/state notifiers
@Riverpod(keepAlive: true)
class ProjectListFilter extends _$ProjectListFilter { ... }

// 5. Computed/derived providers
final filteredProjectListProvider = StreamProvider<List<Project>>((ref) { ... });

// 6. Notifiers with mutations
@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier { ... }
```

---

## Drift/Database Guidelines

### Table Definitions

```dart
// In data/models/<name>_model.dart

@TableIndex(name: 'project_created_at_idx', columns: {#createdAt})
@TableIndex(name: 'project_updated_at_idx', columns: {#updatedAt})
class ProjectTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
```

### Mappers

Create bidirectional mappers as extensions:

```dart
// data/mappers/project_extensions.dart

extension DbProjectToDomain on ProjectTableData {
  Project toDomain() => Project(
    id: id,
    title: title,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

extension DomainProjectToCompanion on Project {
  ProjectTableCompanion toCompanion() {
    if (id != null) {
      return ProjectTableCompanion(
        id: Value(id!),
        title: Value(title),
        // ...
      );
    }
    return ProjectTableCompanion.insert(
      title: title,
      // ...
    );
  }
}
```

### Foreign Keys and Cascades

When defining FK relationships, specify cascade behavior:

```sql
FOREIGN KEY(project_id) REFERENCES project_table(id) ON DELETE CASCADE
```

---

## Logging

### LogService Usage

```dart
// At file top, after imports
final _log = LogService.instance;

class MyService {
  Future<void> doSomething() async {
    _log.debug('Starting operation', tag: 'MyService');
    
    try {
      // ...
      _log.info('Operation completed', tag: 'MyService');
    } catch (e, st) {
      _log.error('Operation failed', tag: 'MyService', error: e, stackTrace: st);
      rethrow;
    }
  }
}
```

### Log Levels

| Level | Usage |
|-------|-------|
| `debug` | Development-only details |
| `info` | Normal operations (CRUD success) |
| `warning` | Recoverable issues |
| `error` | Failures requiring attention |

---

## Anti-Patterns to Avoid

```dart
// DON'T use print() or debugPrint()
print('Debug');  // Bad
_log.debug('Debug', tag: 'ClassName');  // Good

// DON'T throw exceptions from services (use Result)
throw Exception('Failed');  // Bad in services
return Failure(DatabaseFailure('Failed'));  // Good

// DON'T use Navigator directly in widgets
Navigator.of(context).pushNamed('/route');  // Acceptable but avoid
getIt<NavigationService>().goToProjectDetail(context, id);  // Better

// DON'T ignore async errors
doSomething();  // Bad - unawaited future
await doSomething();  // Good

// DON'T create mutable domain entities
class Project {
  String title;  // Bad - mutable
}

@immutable
class Project extends Equatable {
  final String title;  // Good - immutable
}
```
