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

  /// Hard-deletes projects, tasks, and focus sessions whose [deletedAt]
  /// is older than [retention].
  Future<Result<int>> purgeExpiredTombstones({DateTime? now}) async {
    try {
      final cutoff = (now ?? DateTime.now()).subtract(retention);
      return await _db.transaction(() async {
        // Sessions first (FK dependents), then tasks, then projects.
        final sessions = await (_db.delete(
          _db.focusSessionTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final tasks = await (_db.delete(
          _db.taskTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final projects = await (_db.delete(
          _db.projectTable,
        )..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff))).go();
        final total = sessions + tasks + projects;
        _log.info(
          'Purged $total expired tombstones (sessions=$sessions, tasks=$tasks, projects=$projects)',
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
