import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/sync_local_datasource.dart';
import '../entities/sync_data.dart';
import '../entities/sync_state.dart';
import 'i_cloud_storage_service.dart';
import 'sync_merge_engine.dart';
import '../../../settings/domain/repositories/i_settings_repository.dart';

final _log = LogService.instance;

/// Settings keys for sync metadata.
abstract final class SyncSettingsKeys {
  static const String lastSyncedAt = 'sync_last_synced_at';
  static const String syncEnabled = 'sync_enabled';
}

/// Coordinates local ↔ cloud synchronization.
///
/// Merge logic lives in [SyncMergeEngine] (pure / unit-tested). This class
/// owns I/O: gather, download, upload, apply, and schema-version gating.
class SyncEngine {
  final ICloudStorageService _cloudService;
  final ISyncLocalDataSource _localDataSource;
  final ISettingsRepository _settingsRepository;
  final SyncMergeEngine _mergeEngine;

  SyncEngine(
    this._cloudService,
    this._localDataSource,
    this._settingsRepository, {
    SyncMergeEngine mergeEngine = const SyncMergeEngine(),
  }) : _mergeEngine = mergeEngine;

  Future<DateTime?> getLastSyncedAt() async {
    final value = await _settingsRepository.getValue(SyncSettingsKeys.lastSyncedAt);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  Future<bool> isSyncEnabled() async {
    final value = await _settingsRepository.getValue(SyncSettingsKeys.syncEnabled);
    // Default to enabled when connected so existing installs keep working.
    if (value == null) return true;
    return value == 'true';
  }

  Future<void> setSyncEnabled(bool enabled) async {
    await _settingsRepository.setValue(SyncSettingsKeys.syncEnabled, enabled ? 'true' : 'false');
  }

  Future<void> _saveLastSyncedAt(DateTime timestamp) async {
    await _settingsRepository.setValue(SyncSettingsKeys.lastSyncedAt, timestamp.toIso8601String());
  }

  /// Export a SyncData-shaped bundle of the current local database.
  Future<SyncData> exportLocalBackup() => _localDataSource.gatherLocalData();

  /// Replace local sync-covered data with [data] (after schema check).
  Future<Result<void>> restoreFromBackup(SyncData data) async {
    try {
      if (data.schemaVersion > kSyncSchemaVersion) {
        return Failure(
          SyncFailure(
            'Backup schema v${data.schemaVersion} is newer than this app (v$kSyncSchemaVersion). Upgrade Focus to restore.',
          ),
        );
      }
      await _localDataSource.replaceAllWith(data.copyWith(schemaVersion: kSyncSchemaVersion));
      return const Success(null);
    } catch (e, st) {
      _log.error('Restore failed', tag: 'SyncEngine', error: e, stackTrace: st);
      return Failure(SyncFailure('Failed to restore backup', error: e, stackTrace: st));
    }
  }

  /// Perform a full sync operation.
  Future<Result<SyncState>> performSync({bool force = false}) async {
    try {
      if (!force && !await isSyncEnabled()) {
        _log.info('Sync skipped — auto sync disabled', tag: 'SyncEngine');
        final email = await _cloudService.getAccountEmail();
        return Success(SyncState(status: SyncStatus.idle, lastSyncedAt: await getLastSyncedAt(), accountEmail: email));
      }

      _log.info('Starting sync...', tag: 'SyncEngine');

      final downloadResult = await _cloudService.downloadSyncData();
      switch (downloadResult) {
        case Failure(:final failure):
          return Failure(failure);
        case Success(:final value):
          final remoteData = value;
          final localData = await _localDataSource.gatherLocalData();
          final lastSyncedAt = await getLastSyncedAt();

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

          if (remoteData.schemaVersion > kSyncSchemaVersion) {
            return Failure(
              SyncFailure(
                'Remote sync schema v${remoteData.schemaVersion} is newer than this app '
                '(v$kSyncSchemaVersion). Upgrade Focus to sync.',
              ),
            );
          }

          final SyncMergeResult mergeResult;
          try {
            mergeResult = _mergeEngine.merge(localData, remoteData, lastSyncedAt);
          } on SyncSchemaTooNewException catch (e) {
            return Failure(SyncFailure(e.toString()));
          }

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

          await _localDataSource.applyMergedData(mergeResult.merged);

          final finalData = await _localDataSource.gatherLocalData();
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
          if (remoteData.schemaVersion > kSyncSchemaVersion) {
            return Failure(
              SyncFailure(
                'Remote sync schema v${remoteData.schemaVersion} is newer than this app '
                '(v$kSyncSchemaVersion). Upgrade Focus to sync.',
              ),
            );
          }

          final localData = await _localDataSource.gatherLocalData();
          final lastSyncedAt = await getLastSyncedAt();

          final SyncMergeResult mergeResult;
          try {
            mergeResult = _mergeEngine.merge(localData, remoteData, lastSyncedAt);
          } on SyncSchemaTooNewException catch (e) {
            return Failure(SyncFailure(e.toString()));
          }

          // Start from the non-conflicting merge, then overlay resolutions.
          var resolved = mergeResult.merged;
          final remoteByType = _indexRemote(remoteData);
          final localByType = _indexLocal(localData);

          for (final conflict in resolvedConflicts) {
            if (conflict.resolution == null) continue;
            final source = conflict.resolution == ConflictResolution.keepRemote ? remoteByType : localByType;
            resolved = _applyConflictChoice(resolved, conflict, source);
          }

          await _localDataSource.applyMergedData(resolved);

          final finalData = await _localDataSource.gatherLocalData();
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

  Map<String, Map<String, Object>> _indexRemote(SyncData data) => {
    'project': {for (final e in data.projects) e.uuid: e},
    'milestone': {for (final e in data.milestones) e.uuid: e},
    'tag': {for (final e in data.tags) e.uuid: e},
    'task': {for (final e in data.tasks) e.uuid: e},
    'taskTag': {for (final e in data.taskTags) e.uuid: e},
    'completion': {for (final e in data.completions) e.uuid: e},
    'session': {for (final e in data.sessions) e.uuid: e},
    'setting': {for (final e in data.settings) e.key: e},
  };

  Map<String, Map<String, Object>> _indexLocal(SyncData data) => _indexRemote(data);

  SyncData _applyConflictChoice(SyncData base, SyncConflict conflict, Map<String, Map<String, Object>> source) {
    final entity = source[conflict.entityType]?[conflict.entityId];
    if (entity == null) return base;

    return switch (conflict.entityType) {
      'project' => base.copyWith(projects: _replaceByUuid(base.projects, entity as SyncProjectData, (e) => e.uuid)),
      'milestone' => base.copyWith(
        milestones: _replaceByUuid(base.milestones, entity as SyncMilestoneData, (e) => e.uuid),
      ),
      'tag' => base.copyWith(tags: _replaceByUuid(base.tags, entity as SyncTagData, (e) => e.uuid)),
      'task' => base.copyWith(tasks: _replaceByUuid(base.tasks, entity as SyncTaskData, (e) => e.uuid)),
      'taskTag' => base.copyWith(taskTags: _replaceByUuid(base.taskTags, entity as SyncTaskTagData, (e) => e.uuid)),
      'completion' => base.copyWith(
        completions: _replaceByUuid(base.completions, entity as SyncTaskCompletionData, (e) => e.uuid),
      ),
      'session' => base.copyWith(
        sessions: _replaceByUuid(base.sessions, entity as SyncFocusSessionData, (e) => e.uuid),
      ),
      'setting' => base.copyWith(settings: _replaceByKey(base.settings, entity as SyncSettingData)),
      _ => base,
    };
  }

  List<T> _replaceByUuid<T>(List<T> list, T replacement, String Function(T) uuidOf) {
    final uuid = uuidOf(replacement);
    final without = list.where((e) => uuidOf(e) != uuid).toList();
    return [...without, replacement];
  }

  List<SyncSettingData> _replaceByKey(List<SyncSettingData> list, SyncSettingData replacement) {
    final without = list.where((e) => e.key != replacement.key).toList();
    return [...without, replacement];
  }
}
