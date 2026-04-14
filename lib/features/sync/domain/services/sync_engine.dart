import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../../../projects/domain/repositories/i_project_repository.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/repositories/i_task_repository.dart';
import '../../domain/entities/sync_data.dart';
import '../../domain/entities/sync_state.dart';
import '../../domain/services/i_cloud_storage_service.dart';
import '../../../settings/domain/repositories/i_settings_repository.dart';

final _log = LogService.instance;

/// Settings keys for sync metadata.
abstract final class SyncSettingsKeys {
  static const String lastSyncedAt = 'sync_last_synced_at';
  static const String syncEnabled = 'sync_enabled';
}

/// The core sync engine that coordinates data synchronization between
/// local storage and cloud storage.
///
/// Handles:
/// - Gathering all local projects and tasks
/// - Comparing with remote data
/// - Detecting conflicts (both sides changed since last sync)
/// - Merging non-conflicting changes
/// - Uploading the merged result
class SyncEngine {
  final ICloudStorageService _cloudService;
  final IProjectRepository _projectRepository;
  final ITaskRepository _taskRepository;
  final ISettingsRepository _settingsRepository;

  SyncEngine(this._cloudService, this._projectRepository, this._taskRepository, this._settingsRepository);

  /// Get the last sync timestamp from settings.
  Future<DateTime?> getLastSyncedAt() async {
    final value = await _settingsRepository.getValue(SyncSettingsKeys.lastSyncedAt);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Save the last sync timestamp.
  Future<void> _saveLastSyncedAt(DateTime timestamp) async {
    await _settingsRepository.setValue(SyncSettingsKeys.lastSyncedAt, timestamp.toIso8601String());
  }

  /// Gather all local data into a [SyncData] object.
  Future<SyncData> _gatherLocalData() async {
    final projects = await _projectRepository.getAllProjects();
    final allTasks = <Task>[];

    for (final project in projects) {
      if (project.id != null) {
        final tasks = await _taskRepository.getTasksByProjectId(project.id!);
        allTasks.addAll(tasks);
      }
    }

    return SyncData(
      syncTimestamp: DateTime.now(),
      projects: projects.where((p) => p.id != null).map((p) => SyncProjectData.fromProject(p)).toList(),
      tasks: allTasks.where((t) => t.id != null).map((t) => SyncTaskData.fromTask(t)).toList(),
    );
  }

  /// Perform a full sync operation.
  ///
  /// Returns a [SyncState] with conflicts if any are detected.
  /// The caller must resolve conflicts and call [applyResolutions] before
  /// the sync is complete.
  Future<Result<SyncState>> performSync() async {
    try {
      _log.info('Starting sync...', tag: 'SyncEngine');

      // 1. Download remote data.
      final downloadResult = await _cloudService.downloadSyncData();
      switch (downloadResult) {
        case Failure(:final failure):
          return Failure(failure);
        case Success(:final value):
          final remoteData = value;
          final localData = await _gatherLocalData();
          final lastSyncedAt = await getLastSyncedAt();

          // 2. If no remote data, just upload local.
          if (remoteData == null) {
            _log.info('No remote data found, uploading local data', tag: 'SyncEngine');
            final uploadResult = await _cloudService.uploadSyncData(localData);
            switch (uploadResult) {
              case Failure(:final failure):
                return Failure(failure);
              case Success():
                final now = DateTime.now();
                await _saveLastSyncedAt(now);
                return Success(
                  SyncState(
                    status: SyncStatus.success,
                    lastSyncedAt: now,
                    accountEmail: await _cloudService.getAccountEmail(),
                  ),
                );
            }
          }

          // 3. Detect conflicts and merge.
          final mergeResult = _mergeData(localData, remoteData, lastSyncedAt);

          // 4. If conflicts exist, return them for resolution.
          if (mergeResult.conflicts.isNotEmpty) {
            _log.info('${mergeResult.conflicts.length} conflicts detected', tag: 'SyncEngine');
            return Success(
              SyncState(
                status: SyncStatus.conflictsDetected,
                lastSyncedAt: lastSyncedAt,
                accountEmail: await _cloudService.getAccountEmail(),
                conflicts: mergeResult.conflicts,
              ),
            );
          }

          // 5. Apply the merged data.
          await _applyMergedData(mergeResult);

          // 6. Upload the final merged state.
          final finalData = await _gatherLocalData();
          final uploadResult = await _cloudService.uploadSyncData(finalData);
          switch (uploadResult) {
            case Failure(:final failure):
              return Failure(failure);
            case Success():
              final now = DateTime.now();
              await _saveLastSyncedAt(now);
              _log.info('Sync completed successfully', tag: 'SyncEngine');
              return Success(
                SyncState(
                  status: SyncStatus.success,
                  lastSyncedAt: now,
                  accountEmail: await _cloudService.getAccountEmail(),
                ),
              );
          }
      }
    } catch (e, st) {
      _log.error('Sync failed', tag: 'SyncEngine', error: e, stackTrace: st);
      return Failure(SyncFailure('Sync failed unexpectedly', error: e, stackTrace: st));
    }
  }

  /// Apply conflict resolutions and complete the sync.
  Future<Result<SyncState>> applyResolutions(List<SyncConflict> resolvedConflicts) async {
    try {
      final downloadResult = await _cloudService.downloadSyncData();
      switch (downloadResult) {
        case Failure(:final failure):
          return Failure(failure);
        case Success(:final value):
          final remoteData = value;
          if (remoteData == null) {
            return const Failure(SyncFailure('Remote data disappeared during conflict resolution'));
          }

          final localData = await _gatherLocalData();
          final lastSyncedAt = await getLastSyncedAt();
          final mergeResult = _mergeData(localData, remoteData, lastSyncedAt);

          // Apply non-conflicting changes first.
          await _applyMergedData(mergeResult);

          // Apply conflict resolutions.
          for (final conflict in resolvedConflicts) {
            if (conflict.resolution == null) continue;

            if (conflict.resolution == ConflictResolution.keepRemote) {
              // Apply the remote version.
              if (conflict.entityType == 'project') {
                final remoteProject = remoteData.projects.where((p) => p.id == conflict.entityId).firstOrNull;
                if (remoteProject != null) {
                  final existing = await _projectRepository.getProjectById(remoteProject.id);
                  if (existing != null) {
                    await _projectRepository.updateProject(remoteProject.toProject());
                  } else {
                    await _projectRepository.createProject(remoteProject.toProject());
                  }
                }
              } else if (conflict.entityType == 'task') {
                final remoteTask = remoteData.tasks.where((t) => t.id == conflict.entityId).firstOrNull;
                if (remoteTask != null) {
                  final existing = await _taskRepository.getTaskById(remoteTask.id);
                  if (existing != null) {
                    await _taskRepository.updateTask(remoteTask.toTask());
                  } else {
                    await _taskRepository.createTask(remoteTask.toTask());
                  }
                }
              }
            }
            // keepLocal means we do nothing — local is already correct.
          }

          // Upload the final state.
          final finalData = await _gatherLocalData();
          final uploadResult = await _cloudService.uploadSyncData(finalData);
          switch (uploadResult) {
            case Failure(:final failure):
              return Failure(failure);
            case Success():
              final now = DateTime.now();
              await _saveLastSyncedAt(now);
              _log.info('Sync with conflict resolution completed', tag: 'SyncEngine');
              return Success(
                SyncState(
                  status: SyncStatus.success,
                  lastSyncedAt: now,
                  accountEmail: await _cloudService.getAccountEmail(),
                ),
              );
          }
      }
    } catch (e, st) {
      _log.error('Apply resolutions failed', tag: 'SyncEngine', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to apply conflict resolutions', error: e, stackTrace: st));
    }
  }

  /// Merge local and remote data, detecting conflicts.
  _MergeResult _mergeData(SyncData local, SyncData remote, DateTime? lastSyncedAt) {
    final conflicts = <SyncConflict>[];
    final projectsToCreate = <SyncProjectData>[];
    final projectsToUpdate = <SyncProjectData>[];
    final tasksToCreate = <SyncTaskData>[];
    final tasksToUpdate = <SyncTaskData>[];

    final localProjectMap = {for (final p in local.projects) p.id: p};
    final localTaskMap = {for (final t in local.tasks) t.id: t};

    // --- Merge Projects ---

    // Remote projects not in local → create locally.
    for (final remoteProject in remote.projects) {
      final localProject = localProjectMap[remoteProject.id];
      if (localProject == null) {
        projectsToCreate.add(remoteProject);
        continue;
      }

      // Both exist — check for conflicts.
      if (lastSyncedAt != null) {
        final localChanged = localProject.updatedAt.isAfter(lastSyncedAt);
        final remoteChanged = remoteProject.updatedAt.isAfter(lastSyncedAt);

        if (localChanged && remoteChanged) {
          // Both changed since last sync — CONFLICT.
          conflicts.add(
            SyncConflict(
              entityType: 'project',
              entityId: remoteProject.id,
              entityTitle: remoteProject.title,
              localUpdatedAt: localProject.updatedAt,
              remoteUpdatedAt: remoteProject.updatedAt,
            ),
          );
        } else if (remoteChanged && !localChanged) {
          // Only remote changed — update local.
          projectsToUpdate.add(remoteProject);
        }
        // Only local changed or neither changed → keep local (nothing to do).
      } else {
        // First sync ever — prefer whichever is newer.
        if (remoteProject.updatedAt.isAfter(localProject.updatedAt)) {
          projectsToUpdate.add(remoteProject);
        }
      }
    }

    // --- Merge Tasks ---

    // Remote tasks not in local → create locally.
    for (final remoteTask in remote.tasks) {
      final localTask = localTaskMap[remoteTask.id];
      if (localTask == null) {
        tasksToCreate.add(remoteTask);
        continue;
      }

      // Both exist — check for conflicts.
      if (lastSyncedAt != null) {
        final localChanged = localTask.updatedAt.isAfter(lastSyncedAt);
        final remoteChanged = remoteTask.updatedAt.isAfter(lastSyncedAt);

        if (localChanged && remoteChanged) {
          conflicts.add(
            SyncConflict(
              entityType: 'task',
              entityId: remoteTask.id,
              entityTitle: remoteTask.title,
              localUpdatedAt: localTask.updatedAt,
              remoteUpdatedAt: remoteTask.updatedAt,
            ),
          );
        } else if (remoteChanged && !localChanged) {
          tasksToUpdate.add(remoteTask);
        }
      } else {
        if (remoteTask.updatedAt.isAfter(localTask.updatedAt)) {
          tasksToUpdate.add(remoteTask);
        }
      }
    }

    return _MergeResult(
      conflicts: conflicts,
      projectsToCreate: projectsToCreate,
      projectsToUpdate: projectsToUpdate,
      tasksToCreate: tasksToCreate,
      tasksToUpdate: tasksToUpdate,
    );
  }

  /// Apply the non-conflicting merge results to the local database.
  Future<void> _applyMergedData(_MergeResult mergeResult) async {
    // Create new projects first (tasks depend on them).
    for (final project in mergeResult.projectsToCreate) {
      try {
        await _projectRepository.createProject(project.toProject());
      } catch (e, st) {
        _log.warning('Failed to create synced project ${project.id}', tag: 'SyncEngine', error: e, stackTrace: st);
      }
    }

    // Update existing projects.
    for (final project in mergeResult.projectsToUpdate) {
      try {
        await _projectRepository.updateProject(project.toProject());
      } catch (e, st) {
        _log.warning('Failed to update synced project ${project.id}', tag: 'SyncEngine', error: e, stackTrace: st);
      }
    }

    // Create new tasks.
    for (final task in mergeResult.tasksToCreate) {
      try {
        await _taskRepository.createTask(task.toTask());
      } catch (e, st) {
        _log.warning('Failed to create synced task ${task.id}', tag: 'SyncEngine', error: e, stackTrace: st);
      }
    }

    // Update existing tasks.
    for (final task in mergeResult.tasksToUpdate) {
      try {
        await _taskRepository.updateTask(task.toTask());
      } catch (e, st) {
        _log.warning('Failed to update synced task ${task.id}', tag: 'SyncEngine', error: e, stackTrace: st);
      }
    }
  }
}

/// Internal result of the merge operation.
class _MergeResult {
  final List<SyncConflict> conflicts;
  final List<SyncProjectData> projectsToCreate;
  final List<SyncProjectData> projectsToUpdate;
  final List<SyncTaskData> tasksToCreate;
  final List<SyncTaskData> tasksToUpdate;

  const _MergeResult({
    required this.conflicts,
    required this.projectsToCreate,
    required this.projectsToUpdate,
    required this.tasksToCreate,
    required this.tasksToUpdate,
  });
}
