import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';

abstract interface class IMilestoneLocalDataSource {
  Future<List<MilestoneTableData>> getMilestonesByProjectId(int projectId);

  Future<MilestoneTableData?> getMilestoneById(int id);

  Future<int> createMilestone(MilestoneTableCompanion companion);

  Future<void> updateMilestone(MilestoneTableCompanion companion);

  Future<void> deleteMilestone(int id);

  Stream<List<MilestoneTableData>> watchMilestonesByProjectId(int projectId);
}

class MilestoneLocalDataSourceImpl implements IMilestoneLocalDataSource {
  MilestoneLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<List<MilestoneTableData>> getMilestonesByProjectId(int projectId) async {
    return await (_db.select(_db.milestoneTable)
          ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.targetDate), (t) => OrderingTerm.asc(t.title)]))
        .get();
  }

  @override
  Future<MilestoneTableData?> getMilestoneById(int id) async {
    return await (_db.select(
      _db.milestoneTable,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  @override
  Future<int> createMilestone(MilestoneTableCompanion companion) async {
    try {
      return await _db.into(_db.milestoneTable).insert(companion);
    } catch (e, st) {
      _log.error('createMilestone failed', tag: 'MilestoneLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateMilestone(MilestoneTableCompanion companion) async {
    try {
      await (_db.update(_db.milestoneTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
    } catch (e, st) {
      _log.error('updateMilestone failed', tag: 'MilestoneLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteMilestone(int id) async {
    // Soft-delete the milestone and clear task.milestoneId references.
    try {
      await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.update(_db.taskTable)..where((t) => t.milestoneId.equals(id) & t.deletedAt.isNull())).write(
          TaskTableCompanion(milestoneId: const Value(null), updatedAt: Value(now)),
        );
        await (_db.update(_db.milestoneTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
          MilestoneTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      });
    } catch (e, st) {
      _log.error('deleteMilestone failed', tag: 'MilestoneLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<MilestoneTableData>> watchMilestonesByProjectId(int projectId) {
    return (_db.select(_db.milestoneTable)
          ..where((t) => t.projectId.equals(projectId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.targetDate), (t) => OrderingTerm.asc(t.title)]))
        .watch();
  }
}
