import 'package:drift/drift.dart';

import '../../../../core/services/db_service.dart';
import '../../../../core/services/log_service.dart';

abstract interface class ITagLocalDataSource {
  Future<List<TagTableData>> getAllTags();

  Future<TagTableData?> getTagById(int id);

  Future<List<TagTableData>> getTagsForTask(int taskId);

  Future<int> createTag(TagTableCompanion companion);

  Future<void> updateTag(TagTableCompanion companion);

  Future<void> deleteTag(int id);

  Future<void> setTaskTags(int taskId, List<int> tagIds);

  Stream<List<TagTableData>> watchAllTags();
}

class TagLocalDataSourceImpl implements ITagLocalDataSource {
  TagLocalDataSourceImpl(this._db);

  final AppDatabase _db;
  final _log = LogService.instance;

  @override
  Future<List<TagTableData>> getAllTags() async {
    return await (_db.select(_db.tagTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  @override
  Future<TagTableData?> getTagById(int id) async {
    return await (_db.select(_db.tagTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
  }

  @override
  Future<List<TagTableData>> getTagsForTask(int taskId) async {
    final query =
        _db.select(_db.tagTable).join([innerJoin(_db.taskTagTable, _db.taskTagTable.tagId.equalsExp(_db.tagTable.id))])
          ..where(_db.taskTagTable.taskId.equals(taskId) & _db.tagTable.deletedAt.isNull())
          ..orderBy([OrderingTerm.asc(_db.tagTable.name)]);
    return query.map((row) => row.readTable(_db.tagTable)).get();
  }

  @override
  Future<int> createTag(TagTableCompanion companion) async {
    try {
      return await _db.into(_db.tagTable).insert(companion);
    } catch (e, st) {
      _log.error('createTag failed', tag: 'TagLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateTag(TagTableCompanion companion) async {
    try {
      await (_db.update(_db.tagTable)..where((t) => t.id.equals(companion.id.value))).write(companion);
    } catch (e, st) {
      _log.error('updateTag failed', tag: 'TagLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteTag(int id) async {
    try {
      await _db.transaction(() async {
        final now = DateTime.now();
        await (_db.delete(_db.taskTagTable)..where((t) => t.tagId.equals(id))).go();
        await (_db.update(_db.tagTable)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).write(
          TagTableCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      });
    } catch (e, st) {
      _log.error('deleteTag failed', tag: 'TagLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> setTaskTags(int taskId, List<int> tagIds) async {
    try {
      await _db.transaction(() async {
        await (_db.delete(_db.taskTagTable)..where((t) => t.taskId.equals(taskId))).go();
        for (final tagId in tagIds) {
          await _db.into(_db.taskTagTable).insert(TaskTagTableCompanion.insert(taskId: taskId, tagId: tagId));
        }
      });
    } catch (e, st) {
      _log.error('setTaskTags failed', tag: 'TagLocalDS', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<TagTableData>> watchAllTags() {
    return (_db.select(_db.tagTable)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }
}
