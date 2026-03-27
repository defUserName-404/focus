# Code Patterns Reference

This document provides comprehensive code patterns and templates used throughout the Focus codebase. Use these as references when implementing new features.

---

## Table of Contents

1. [Domain Layer Patterns](#domain-layer-patterns)
2. [Data Layer Patterns](#data-layer-patterns)
3. [Presentation Layer Patterns](#presentation-layer-patterns)
4. [Riverpod Patterns](#riverpod-patterns)
5. [Widget Patterns](#widget-patterns)
6. [Utility Patterns](#utility-patterns)
7. [Common Tasks](#common-tasks)

---

## Domain Layer Patterns

### Entity Definition

```dart
// lib/features/<feature>/domain/entities/<entity>.dart

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Brief description of what this entity represents.
///
/// Entities are immutable domain objects that represent core
/// business concepts. They should contain no business logic.
@immutable
class Project extends Equatable {
  final int? id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    this.id,
    required this.title,
    this.description,
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, title, description, startDate, deadline, createdAt, updatedAt,
  ];
}
```

### Entity Extensions (copyWith)

```dart
// lib/features/<feature>/domain/entities/<entity>_extensions.dart

import '<entity>.dart';

extension ProjectCopyWith on Project {
  Project copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### Repository Interface

```dart
// lib/features/<feature>/domain/repositories/i_<name>_repository.dart

import '../entities/<entity>.dart';

/// Contract for <entity> data operations.
///
/// Implementations handle persistence; the domain layer only
/// knows about this interface.
abstract interface class IProjectRepository {
  // Read operations
  Future<List<Project>> getAllProjects();
  Future<Project?> getProjectById(int id);
  
  // Reactive streams
  Stream<List<Project>> watchAllProjects();
  Stream<Project?> watchProjectById(int id);
  
  // Write operations
  Future<Project> createProject(Project project);
  Future<void> updateProject(Project project);
  Future<void> deleteProject(int id);
  
  // Filtered queries
  Stream<List<Project>> watchFilteredProjects({
    String searchQuery,
    SortCriteria sortCriteria,
    SortOrder sortOrder,
  });
}
```

### Domain Service

```dart
// lib/features/<feature>/domain/services/<name>_service.dart

import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../entities/<entity>.dart';
import '../entities/<entity>_extensions.dart';
import '../repositories/i_<name>_repository.dart';

final _log = LogService.instance;

/// Domain service for <entity> operations.
///
/// Sits between the presentation layer (providers/commands) and the
/// repository. Encapsulates business logic beyond simple CRUD.
class ProjectService {
  final IProjectRepository _repository;

  ProjectService(this._repository);

  // ─────────────────────────────────────────────────────────────
  // Read Operations (passthrough to repository)
  // ─────────────────────────────────────────────────────────────

  Future<List<Project>> getAllProjects() => _repository.getAllProjects();

  Stream<List<Project>> watchAllProjects() => _repository.watchAllProjects();

  Stream<Project?> watchProjectById(int id) => _repository.watchProjectById(id);

  // ─────────────────────────────────────────────────────────────
  // Write Operations (with business logic)
  // ─────────────────────────────────────────────────────────────

  Future<Result<Project>> createProject({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    try {
      final now = DateTime.now();
      final project = Project(
        title: title,
        description: description,
        startDate: startDate,
        deadline: deadline,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _repository.createProject(project);
      _log.info('Project created: "$title" (id=${created.id})', tag: 'ProjectService');
      return Success(created);
    } catch (e, st) {
      _log.error('Failed to create project "$title"', tag: 'ProjectService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to create project', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> updateProject(Project project) async {
    try {
      final updated = project.copyWith(updatedAt: DateTime.now());
      await _repository.updateProject(updated);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to update project ${project.id}', tag: 'ProjectService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to update project', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> deleteProject(int id) async {
    try {
      await _repository.deleteProject(id);
      _log.info('Project $id deleted', tag: 'ProjectService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to delete project $id', tag: 'ProjectService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to delete project', error: e, stackTrace: st));
    }
  }
}
```

---

## Data Layer Patterns

### Drift Table Model

```dart
// lib/features/<feature>/data/models/<entity>_model.dart

import 'package:drift/drift.dart';

@TableIndex(name: 'project_created_at_idx', columns: {#createdAt})
@TableIndex(name: 'project_updated_at_idx', columns: {#updatedAt})
class ProjectTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  
  // Foreign key example (from TaskTable)
  // IntColumn get projectId => integer().references(ProjectTable, #id)();
}
```

### DataSource Interface and Implementation

```dart
// lib/features/<feature>/data/datasources/<name>_local_datasource.dart

import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';

/// Interface for local data operations.
abstract interface class IProjectLocalDataSource {
  Future<List<ProjectTableData>> getAllProjects();
  Future<ProjectTableData?> getProjectById(int id);
  Future<int> createProject(ProjectTableCompanion companion);
  Future<void> updateProject(ProjectTableCompanion companion);
  Future<void> deleteProject(int id);
  Stream<ProjectTableData?> watchProjectById(int id);
  Stream<List<ProjectTableData>> watchAllProjects();
}

class ProjectLocalDataSourceImpl implements IProjectLocalDataSource {
  ProjectLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<List<ProjectTableData>> getAllProjects() async {
    return await _db.select(_db.projectTable).get();
  }

  @override
  Future<ProjectTableData?> getProjectById(int id) async {
    final query = _db.select(_db.projectTable)..where((t) => t.id.equals(id));
    return await query.getSingleOrNull();
  }

  @override
  Future<int> createProject(ProjectTableCompanion companion) async {
    try {
      return await _db.into(_db.projectTable).insert(companion);
    } catch (e, st) {
      _log.error('createProject failed', tag: 'ProjectLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateProject(ProjectTableCompanion companion) async {
    try {
      await (_db.update(_db.projectTable)
        ..where((t) => t.id.equals(companion.id.value)))
        .write(companion);
    } catch (e, st) {
      _log.error('updateProject failed', tag: 'ProjectLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      await (_db.delete(_db.projectTable)..where((t) => t.id.equals(id))).go();
    } catch (e, st) {
      _log.error('deleteProject failed', tag: 'ProjectLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<ProjectTableData?> watchProjectById(int id) {
    return (_db.select(_db.projectTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  @override
  Stream<List<ProjectTableData>> watchAllProjects() {
    return _db.select(_db.projectTable).watch();
  }
}
```

### Mapper Extensions

```dart
// lib/features/<feature>/data/mappers/<entity>_extensions.dart

import 'package:drift/drift.dart' show Value;

import '../../../../core/services/db_service.dart';
import '../../domain/entities/<entity>.dart';

/// Maps database rows to domain entities.
extension DbProjectToDomain on ProjectTableData {
  Project toDomain() => Project(
    id: id,
    title: title,
    description: description,
    startDate: startDate,
    deadline: deadline,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

/// Maps domain entities to database companions for insert/update.
extension DomainProjectToCompanion on Project {
  ProjectTableCompanion toCompanion() {
    if (id != null) {
      // Update: include ID
      return ProjectTableCompanion(
        id: Value(id!),
        title: Value(title),
        description: Value(description),
        startDate: Value(startDate),
        deadline: Value(deadline),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
      );
    }
    // Insert: use .insert() constructor (omits auto-increment ID)
    return ProjectTableCompanion.insert(
      title: title,
      description: Value<String?>(description),
      startDate: Value<DateTime?>(startDate),
      deadline: Value<DateTime?>(deadline),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

### Repository Implementation

```dart
// lib/features/<feature>/data/repositories/<name>_repository_impl.dart

import '../../../../core/services/log_service.dart';
import '../../domain/entities/<entity>.dart';
import '../../domain/entities/<entity>_extensions.dart';
import '../../domain/repositories/i_<name>_repository.dart';
import '../datasources/<name>_local_datasource.dart';
import '../mappers/<entity>_extensions.dart';

final _log = LogService.instance;

class ProjectRepositoryImpl implements IProjectRepository {
  final IProjectLocalDataSource _localDataSource;

  ProjectRepositoryImpl(this._localDataSource);

  @override
  Future<List<Project>> getAllProjects() async {
    final rows = await _localDataSource.getAllProjects();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Project?> getProjectById(int id) async {
    final row = await _localDataSource.getProjectById(id);
    return row?.toDomain();
  }

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

  @override
  Future<void> updateProject(Project project) async {
    try {
      final companion = project.toCompanion();
      await _localDataSource.updateProject(companion);
    } catch (e, st) {
      _log.error('Failed to update project', tag: 'ProjectRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      await _localDataSource.deleteProject(id);
    } catch (e, st) {
      _log.error('Failed to delete project', tag: 'ProjectRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<Project?> watchProjectById(int id) {
    return _localDataSource.watchProjectById(id).map((row) => row?.toDomain());
  }

  @override
  Stream<List<Project>> watchAllProjects() {
    return _localDataSource.watchAllProjects()
        .map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
```

---

## Presentation Layer Patterns

### Riverpod Provider File

```dart
// lib/features/<feature>/presentation/providers/<name>_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/<entity>.dart';
import '../../domain/repositories/i_<name>_repository.dart';
import '../../domain/services/<name>_service.dart';

part '<name>_provider.g.dart';

// ─────────────────────────────────────────────────────────────
// 1. Repository Provider (bridge from GetIt)
// ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
IProjectRepository projectRepository(Ref ref) {
  return getIt<IProjectRepository>();
}

// ─────────────────────────────────────────────────────────────
// 2. Stream Providers (reactive data)
// ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Stream<List<Project>> projectList(Ref ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchAllProjects();
}

@Riverpod(keepAlive: true)
Stream<Project?> projectById(Ref ref, String id) {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.watchProjectById(int.parse(id));
}

// ─────────────────────────────────────────────────────────────
// 3. Filter State (if needed)
// ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ProjectListFilter extends _$ProjectListFilter {
  @override
  FilterState build() => const FilterState();

  void updateFilter({String? searchQuery, SortCriteria? sortCriteria}) {
    state = state.copyWith(
      searchQuery: searchQuery,
      sortCriteria: sortCriteria,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 4. Filtered Stream (combines filter + data)
// ─────────────────────────────────────────────────────────────

final filteredProjectListProvider = StreamProvider<List<Project>>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  final filter = ref.watch(projectListFilterProvider);

  return repository.watchFilteredProjects(
    searchQuery: filter.searchQuery,
    sortCriteria: filter.sortCriteria,
  );
});

// ─────────────────────────────────────────────────────────────
// 5. Notifier (mutations)
// ─────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier {
  late final ProjectService _service;

  @override
  AsyncValue<List<Project>> build() {
    _service = getIt<ProjectService>();
    _loadProjects();
    return const AsyncValue.loading();
  }

  Future<void> _loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _service.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Project> createProject({
    required String title,
    String? description,
  }) async {
    final result = await _service.createProject(
      title: title,
      description: description,
    );
    switch (result) {
      case Success(:final value):
        await _loadProjects();
        return value;
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
        throw failure;
    }
  }

  Future<void> updateProject(Project project) async {
    final result = await _service.updateProject(project);
    switch (result) {
      case Success():
        await _loadProjects();
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> deleteProject(int id) async {
    final result = await _service.deleteProject(id);
    switch (result) {
      case Success():
        await _loadProjects();
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
```

### Commands Class

```dart
// lib/features/<feature>/presentation/commands/<name>_commands.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/<entity>.dart';
import '../providers/<name>_provider.dart';

/// Static commands for <entity> user actions.
///
/// Commands encapsulate UI actions that involve navigation,
/// dialogs, or provider mutations.
class ProjectCommands {
  /// Navigate to create screen.
  static void create(BuildContext context) {
    context.push(AppRoutes.createProject);
  }

  /// Navigate to edit screen.
  static void edit(BuildContext context, Project project) {
    if (project.id == null) return;
    context.push(AppRoutes.editProjectPath(project.id!), extra: project);
  }

  /// Show delete confirmation and delete if confirmed.
  static Future<void> delete(
    BuildContext context,
    WidgetRef ref,
    Project project, {
    VoidCallback? onDeleted,
  }) async {
    if (project.id == null) return;

    await ConfirmationDialog.show(
      context,
      title: 'Delete Project',
      body: 'Are you sure you want to delete "${project.title}"? '
            'All tasks will also be deleted.',
      onConfirm: () {
        ref.read(projectProvider.notifier).deleteProject(project.id!);
        onDeleted?.call();
      },
    );
  }
}
```

---

## Widget Patterns

### List Screen

```dart
// lib/features/<feature>/presentation/screens/<name>_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../commands/<name>_commands.dart';
import '../providers/<name>_provider.dart';
import '../widgets/<name>_card.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredProjectListProvider);
    final filter = ref.watch(projectListFilterProvider);

    return fu.FScaffold(
      header: fu.FHeader.nested(
        prefixes: [
          fu.FHeaderAction.back(onPress: () => Navigator.of(context).pop()),
        ],
        title: Text(
          'Projects',
          style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      footer: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.large),
        child: fu.FButton(
          prefix: Icon(fu.FIcons.plus),
          child: const Text('Create New Project'),
          onPress: () => ProjectCommands.create(context),
        ),
      ),
      child: Column(
        children: [
          AppSearchBar(
            hint: 'Search projects...',
            onChanged: (query) {
              ref.read(projectListFilterProvider.notifier)
                  .updateFilter(searchQuery: query);
            },
          ),
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(child: fu.FCircularProgress()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (projects) {
                if (projects.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    vertical: AppConstants.spacing.regular,
                  ),
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      onTap: () => _navigateToDetail(context, project),
                      onEdit: () => ProjectCommands.edit(context, project),
                      onDelete: () => ProjectCommands.delete(context, ref, project),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppConstants.spacing.regular,
        children: [
          Icon(
            fu.FIcons.folderOpen,
            size: AppConstants.size.icon.extraExtraLarge,
            color: Theme.of(context).disabledColor,
          ),
          Text(
            'No projects found',
            style: context.typography.sm.copyWith(
              color: context.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Project project) {
    if (project.id != null) {
      context.push(AppRoutes.projectDetailPath(project.id!));
    }
  }
}
```

### Form Screen

```dart
// lib/features/<feature>/presentation/screens/create_<name>_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/base_form_screen.dart';
import '../providers/<name>_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormScreen(
      title: 'New Project',
      submitButtonText: 'Create Project',
      onSubmit: _submit,
      fields: [
        FTextFormField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Project Title',
          label: const Text('Title'),
          validator: (value) => AppFormValidator.isNotEmpty(value),
          autovalidateMode: AutovalidateMode.onUnfocus,
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        FDateField.calendar(
          label: const Text('Deadline'),
          hint: 'Select Deadline (Optional)',
          start: DateTime.now(),
          control: FDateFieldControl.managed(
            onChange: (date) => _deadline = date,
          ),
          clearable: true,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final project = await ref.read(projectProvider.notifier).createProject(
      title: title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    if (mounted && project.id != null) {
      context.pop();
      context.push(AppRoutes.projectDetailPath(project.id!));
    }
  }
}
```

### Card Widget

```dart
// lib/features/<feature>/presentation/widgets/<name>_card.dart

import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as fu;

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/action_menu_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/<entity>.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppConstants.spacing.regular),
      child: AppCard(
        onTap: onTap,
        title: Text(project.title),
        trailing: ActionMenuButton(onEdit: onEdit, onDelete: onDelete),
        subtitle: project.description != null
            ? Text(
                project.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.typography.sm.copyWith(
                  color: context.colors.mutedForeground,
                ),
              )
            : null,
        footerActions: [
          fu.FBadge(
            style: fu.FBadgeStyle.secondary(),
            child: Text(project.deadline?.toRelativeDueString() ?? 'No deadline'),
          ),
          const Spacer(),
          fu.FButton.icon(
            onPress: onTap,
            child: Icon(fu.FIcons.arrowRight, size: AppConstants.size.icon.regular),
          ),
        ],
      ),
    );
  }
}
```

---

## Utility Patterns

### Result Type Usage

```dart
// Returning results from services
Future<Result<Project>> createProject({required String title}) async {
  try {
    // Success case
    final project = await _repository.createProject(...);
    return Success(project);
  } catch (e, st) {
    // Failure case with appropriate failure type
    return Failure(DatabaseFailure('Failed to create project', error: e, stackTrace: st));
  }
}

// Consuming results with pattern matching
final result = await service.createProject(title: 'New');
switch (result) {
  case Success(:final value):
    // Handle success
    Navigator.of(context).pop();
    showSuccess('Created ${value.title}');
  case Failure(:final failure):
    // Handle failure
    showError(failure.message);
}

// Consuming with convenience methods
final project = result.getOrNull(); // Project? - null on failure
final projectOrDefault = result.getOrElse((_) => defaultProject);

// Chaining
result
  .onSuccess((project) => _log.info('Created: ${project.title}'))
  .onFailure((failure) => _log.error(failure.message));
```

### Extension Methods

```dart
// DateTime extensions (lib/core/utils/datetime_formatter.dart)
extension DateTimeFormattingExtensions on DateTime {
  String toDateString() {
    final m = DateTimeConstants.shortMonthNames[month - 1];
    return '$m $day, $year';
  }

  bool get isOverdue => isBefore(DateTime.now()) && !isToday;

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  String toRelativeDueString() {
    if (isToday) return 'Due today';
    if (isTomorrow) return 'Due tomorrow';
    final days = difference(DateTime.now()).inDays;
    if (days < 0) return 'Overdue ${days.abs()}d';
    return 'Due in ${days + 1}d';
  }
}
```

---

## Common Tasks

### Adding a New Feature Checklist

```markdown
1. [ ] Create feature directory: lib/features/<name>/
2. [ ] Create domain layer:
   - [ ] entities/<name>.dart
   - [ ] entities/<name>_extensions.dart
   - [ ] repositories/i_<name>_repository.dart
   - [ ] services/<name>_service.dart
3. [ ] Create data layer:
   - [ ] models/<name>_model.dart
   - [ ] datasources/<name>_local_datasource.dart
   - [ ] mappers/<name>_extensions.dart
   - [ ] repositories/<name>_repository_impl.dart
4. [ ] Add table to @DriftDatabase in db_service.dart
5. [ ] Run code generation
6. [ ] Register in lib/core/di/injection.dart
7. [ ] Create presentation layer:
   - [ ] providers/<name>_provider.dart
   - [ ] commands/<name>_commands.dart
   - [ ] screens/<name>_list_screen.dart
   - [ ] screens/create_<name>_screen.dart
   - [ ] widgets/<name>_card.dart
8. [ ] Add routes in `lib/core/routing/routes.dart`
9. [ ] Add route handling in `lib/core/routing/app_router.dart`
10. [ ] Use `context.go/context.push` in commands/widgets
11. [ ] Update AGENTS.md if significant patterns introduced
```

### Adding a New Drift Table Checklist

```markdown
1. [ ] Create model in data/models/<name>_model.dart
2. [ ] Add indexes for frequently queried columns
3. [ ] Add table to @DriftDatabase annotation in db_service.dart
4. [ ] Run: dart run build_runner build --delete-conflicting-outputs
5. [ ] Create mappers in data/mappers/
6. [ ] If schema change on existing table:
   - [ ] Increment schemaVersion in db_service.dart
   - [ ] Add migration in onUpgrade callback
   - [ ] Test migration with existing data
```
