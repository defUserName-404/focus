import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';
import '../../../../core/utils/result.dart';

final _log = LogService.instance;

/// Permanently removes soft-deleted rows older than a retention window.
///
/// Tombstones must stick around long enough for sync peers to observe them.
/// After [retention], they are hard-deleted so the local DB does not grow
/// unbounded.
class SyncPurgeService {
  SyncPurgeService(this._db, {this.retention = const Duration(days: 30)});

  final AppDatabase _db;

  /// How long soft-deleted rows are kept before permanent purge.
  final Duration retention;

  /// Hard-deletes soft-deleted rows whose [deletedAt] is older than [retention].
  ///
  /// Order respects FK dependents: completions → task_tag → sessions → tasks →
  /// milestones → tags → projects.
  Future<Result<int>> purgeExpiredTombstones({DateTime? now}) async {
    try {
      final cutoff = (now ?? DateTime.now()).subtract(retention);
      return await _db.transaction(() async {
        final completions = await (_db.delete(
          _db.taskCompletionTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();

        // Purge expired task↔tag link tombstones independently.
        var taskTags = await (_db.delete(
          _db.taskTagTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();

        // Remove junction rows for tasks about to be purged.
        final expiredTaskIds =
            await (_db.selectOnly(_db.taskTable)
                  ..addColumns([_db.taskTable.id])
                  ..where(_db.taskTable.deletedAt.isNotNull() & _db.taskTable.deletedAt.isSmallerThanValue(cutoff)))
                .map((row) => row.read(_db.taskTable.id)!)
                .get();
        if (expiredTaskIds.isNotEmpty) {
          // Also hard-delete any remaining completions for purged tasks.
          await (_db.delete(_db.taskCompletionTable)..where((t) => t.taskId.isIn(expiredTaskIds))).go();
          taskTags += await (_db.delete(_db.taskTagTable)..where((t) => t.taskId.isIn(expiredTaskIds))).go();
        }

        final expiredTagIds =
            await (_db.selectOnly(_db.tagTable)
                  ..addColumns([_db.tagTable.id])
                  ..where(_db.tagTable.deletedAt.isNotNull() & _db.tagTable.deletedAt.isSmallerThanValue(cutoff)))
                .map((row) => row.read(_db.tagTable.id)!)
                .get();
        if (expiredTagIds.isNotEmpty) {
          taskTags += await (_db.delete(_db.taskTagTable)..where((t) => t.tagId.isIn(expiredTagIds))).go();
        }

        final sessions = await (_db.delete(
          _db.focusSessionTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final tasks = await (_db.delete(
          _db.taskTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final milestones = await (_db.delete(
          _db.milestoneTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final tags = await (_db.delete(
          _db.tagTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final projects = await (_db.delete(
          _db.projectTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final total = completions + taskTags + sessions + tasks + milestones + tags + projects;
        _log.info(
          'Purged $total expired tombstones '
          '(completions=$completions, taskTags=$taskTags, sessions=$sessions, tasks=$tasks, '
          'milestones=$milestones, tags=$tags, projects=$projects)',
          tag: 'SyncPurgeService',
        );
        return Success(total);
      });
    } catch (e, st) {
      _log.error('Failed to purge expired tombstones', tag: 'SyncPurgeService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to purge expired tombstones', error: e, stackTrace: st));
    }
  }
}
