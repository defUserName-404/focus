import '../entities/sync_data.dart';
import '../entities/sync_state.dart';

/// Pure last-write / conflict merge for [SyncData] envelopes.
///
/// Keys every entity by `uuid` (settings by `key`). Iterates the **union** of
/// local and remote identities so local-only rows (including tombstones) are
/// preserved for upload. Tombstones beat live rows when the tombstone's
/// `updatedAt` is newer.
class SyncMergeEngine {
  const SyncMergeEngine();

  /// Merge [local] and [remote] relative to [lastSyncedAt].
  ///
  /// Throws [SyncSchemaTooNewException] when [remote.schemaVersion] exceeds
  /// [kSyncSchemaVersion].
  SyncMergeResult merge(SyncData local, SyncData remote, DateTime? lastSyncedAt) {
    if (remote.schemaVersion > kSyncSchemaVersion) {
      throw SyncSchemaTooNewException(remote.schemaVersion, kSyncSchemaVersion);
    }

    final conflicts = <SyncConflict>[];

    final projects = _mergeEntities<SyncProjectData>(
      local: local.projects,
      remote: remote.projects,
      lastSyncedAt: lastSyncedAt,
      uuidOf: (e) => e.uuid,
      updatedAtOf: (e) => e.updatedAt,
      deletedAtOf: (e) => e.deletedAt,
      titleOf: (e) => e.title,
      entityType: 'project',
      conflicts: conflicts,
    );

    final milestones = _mergeEntities<SyncMilestoneData>(
      local: local.milestones,
      remote: remote.milestones,
      lastSyncedAt: lastSyncedAt,
      uuidOf: (e) => e.uuid,
      updatedAtOf: (e) => e.updatedAt,
      deletedAtOf: (e) => e.deletedAt,
      titleOf: (e) => e.title,
      entityType: 'milestone',
      conflicts: conflicts,
    );

    final tags = _mergeEntities<SyncTagData>(
      local: local.tags,
      remote: remote.tags,
      lastSyncedAt: lastSyncedAt,
      uuidOf: (e) => e.uuid,
      updatedAtOf: (e) => e.updatedAt,
      deletedAtOf: (e) => e.deletedAt,
      titleOf: (e) => e.name,
      entityType: 'tag',
      conflicts: conflicts,
    );

    final tasks = _mergeEntities<SyncTaskData>(
      local: local.tasks,
      remote: remote.tasks,
      lastSyncedAt: lastSyncedAt,
      uuidOf: (e) => e.uuid,
      updatedAtOf: (e) => e.updatedAt,
      deletedAtOf: (e) => e.deletedAt,
      titleOf: (e) => e.title,
      entityType: 'task',
      conflicts: conflicts,
    );

    // Parents before children by depth for stable apply ordering.
    tasks.sort((a, b) => a.depth.compareTo(b.depth));

    final taskTags = _mergeEntities<SyncTaskTagData>(
      local: local.taskTags,
      remote: remote.taskTags,
      lastSyncedAt: lastSyncedAt,
      uuidOf: (e) => e.uuid,
      updatedAtOf: (e) => e.updatedAt,
      deletedAtOf: (e) => e.deletedAt,
      titleOf: (e) => '${e.taskUuid}:${e.tagUuid}',
      entityType: 'taskTag',
      conflicts: conflicts,
    );

    final completions = _mergeEntities<SyncTaskCompletionData>(
      local: local.completions,
      remote: remote.completions,
      lastSyncedAt: lastSyncedAt,
      uuidOf: (e) => e.uuid,
      updatedAtOf: (e) => e.updatedAt,
      deletedAtOf: (e) => e.deletedAt,
      titleOf: (e) => e.occurrenceDate.toIso8601String(),
      entityType: 'completion',
      conflicts: conflicts,
    );

    final sessions = _mergeEntities<SyncFocusSessionData>(
      local: local.sessions,
      remote: remote.sessions,
      lastSyncedAt: lastSyncedAt,
      uuidOf: (e) => e.uuid,
      updatedAtOf: (e) => e.updatedAt,
      deletedAtOf: (e) => e.deletedAt,
      titleOf: (e) => e.startTime.toIso8601String(),
      entityType: 'session',
      conflicts: conflicts,
    );

    final settings = _mergeSettings(local.settings, remote.settings, lastSyncedAt, conflicts);

    return SyncMergeResult(
      conflicts: conflicts,
      merged: SyncData(
        schemaVersion: kSyncSchemaVersion,
        syncTimestamp: DateTime.now(),
        projects: projects,
        milestones: milestones,
        tags: tags,
        tasks: tasks,
        taskTags: taskTags,
        completions: completions,
        sessions: sessions,
        settings: settings,
      ),
    );
  }

  List<T> _mergeEntities<T>({
    required List<T> local,
    required List<T> remote,
    required DateTime? lastSyncedAt,
    required String Function(T) uuidOf,
    required DateTime Function(T) updatedAtOf,
    required DateTime? Function(T) deletedAtOf,
    required String Function(T) titleOf,
    required String entityType,
    required List<SyncConflict> conflicts,
  }) {
    final localMap = {for (final e in local) uuidOf(e): e};
    final remoteMap = {for (final e in remote) uuidOf(e): e};
    final allUuids = {...localMap.keys, ...remoteMap.keys};
    final result = <T>[];

    for (final uuid in allUuids) {
      final localRow = localMap[uuid];
      final remoteRow = remoteMap[uuid];

      if (localRow == null && remoteRow != null) {
        result.add(remoteRow);
        continue;
      }
      if (remoteRow == null && localRow != null) {
        result.add(localRow);
        continue;
      }
      if (localRow == null || remoteRow == null) continue;

      final winner = _pickWinner(
        local: localRow,
        remote: remoteRow,
        lastSyncedAt: lastSyncedAt,
        updatedAtOf: updatedAtOf,
        deletedAtOf: deletedAtOf,
        onConflict: () {
          conflicts.add(
            SyncConflict(
              entityType: entityType,
              entityId: uuid,
              entityTitle: titleOf(localRow),
              localUpdatedAt: updatedAtOf(localRow),
              remoteUpdatedAt: updatedAtOf(remoteRow),
            ),
          );
        },
      );
      if (winner != null) result.add(winner);
    }

    return result;
  }

  List<SyncSettingData> _mergeSettings(
    List<SyncSettingData> local,
    List<SyncSettingData> remote,
    DateTime? lastSyncedAt,
    List<SyncConflict> conflicts,
  ) {
    final localMap = {for (final s in local) s.key: s};
    final remoteMap = {for (final s in remote) s.key: s};
    final allKeys = {...localMap.keys, ...remoteMap.keys};
    final result = <SyncSettingData>[];

    for (final key in allKeys) {
      if (!kSyncableSettingsKeys.contains(key)) continue;
      final localRow = localMap[key];
      final remoteRow = remoteMap[key];

      if (localRow == null && remoteRow != null) {
        result.add(remoteRow);
        continue;
      }
      if (remoteRow == null && localRow != null) {
        result.add(localRow);
        continue;
      }
      if (localRow == null || remoteRow == null) continue;

      if (localRow.value == remoteRow.value) {
        result.add(localRow.updatedAt.isAfter(remoteRow.updatedAt) ? localRow : remoteRow);
        continue;
      }

      final winner = _pickWinner(
        local: localRow,
        remote: remoteRow,
        lastSyncedAt: lastSyncedAt,
        updatedAtOf: (s) => s.updatedAt,
        deletedAtOf: (_) => null,
        onConflict: () {
          conflicts.add(
            SyncConflict(
              entityType: 'setting',
              entityId: key,
              entityTitle: key,
              localUpdatedAt: localRow.updatedAt,
              remoteUpdatedAt: remoteRow.updatedAt,
            ),
          );
        },
      );
      if (winner != null) result.add(winner);
    }

    return result;
  }

  /// Returns the row to keep, or `null` when a conflict is recorded and the
  /// caller should leave the local DB untouched for that entity until the
  /// user resolves it.
  T? _pickWinner<T>({
    required T local,
    required T remote,
    required DateTime? lastSyncedAt,
    required DateTime Function(T) updatedAtOf,
    required DateTime? Function(T) deletedAtOf,
    required void Function() onConflict,
  }) {
    final localDeleted = deletedAtOf(local);
    final remoteDeleted = deletedAtOf(remote);
    final localUpdated = updatedAtOf(local);
    final remoteUpdated = updatedAtOf(remote);

    // Tombstone beats live when the tombstone clock is newer.
    if (localDeleted != null && remoteDeleted == null) {
      if (!localUpdated.isBefore(remoteUpdated)) return local;
      // Remote live edit is newer than local tombstone — conflict or take remote.
    }
    if (remoteDeleted != null && localDeleted == null) {
      if (!remoteUpdated.isBefore(localUpdated)) return remote;
    }

    if (lastSyncedAt != null) {
      final localChanged = localUpdated.isAfter(lastSyncedAt);
      final remoteChanged = remoteUpdated.isAfter(lastSyncedAt);

      if (localChanged && remoteChanged) {
        // Identical clocks / values are not conflicts — prefer newer.
        if (localUpdated == remoteUpdated) {
          return localDeleted != null
              ? local
              : remoteDeleted != null
              ? remote
              : local;
        }
        onConflict();
        return null;
      }
      if (remoteChanged && !localChanged) return remote;
      return local;
    }

    // First sync: newest wins; tombstone preferred on tie when present.
    if (remoteUpdated.isAfter(localUpdated)) return remote;
    if (localUpdated.isAfter(remoteUpdated)) return local;
    if (remoteDeleted != null) return remote;
    if (localDeleted != null) return local;
    return local;
  }
}

/// Raised when a remote payload was written by a newer app build.
class SyncSchemaTooNewException implements Exception {
  final int remoteVersion;
  final int localVersion;

  const SyncSchemaTooNewException(this.remoteVersion, this.localVersion);

  @override
  String toString() =>
      'Remote sync schema v$remoteVersion is newer than this app (v$localVersion). Upgrade Focus to sync.';
}

/// Result of a pure merge pass.
class SyncMergeResult {
  final List<SyncConflict> conflicts;
  final SyncData merged;

  const SyncMergeResult({required this.conflicts, required this.merged});
}
