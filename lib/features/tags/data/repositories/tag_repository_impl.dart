import '../../../../core/services/data_change_bus.dart';
import '../../../../core/services/log_service.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/tag_extensions.dart';
import '../../domain/repositories/i_tag_repository.dart';
import '../datasources/tag_local_datasource.dart';
import '../mappers/tag_extensions.dart';

final _log = LogService.instance;

class TagRepositoryImpl implements ITagRepository {
  TagRepositoryImpl(this._local, [this._dataChangeBus]);

  final ITagLocalDataSource _local;
  final DataChangeBus? _dataChangeBus;

  void _emitChange() => _dataChangeBus?.notify();

  @override
  Future<List<Tag>> getAllTags() async {
    final rows = await _local.getAllTags();
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Tag?> getTagById(int id) async {
    final row = await _local.getTagById(id);
    return row?.toDomain();
  }

  @override
  Future<List<Tag>> getTagsForTask(int taskId) async {
    final rows = await _local.getTagsForTask(taskId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Tag> createTag(Tag tag) async {
    try {
      final id = await _local.createTag(tag.toCompanion());
      _log.debug('Tag created (id=$id)', tag: 'TagRepository');
      _emitChange();
      return tag.copyWith(id: id);
    } catch (e, st) {
      _log.error('Failed to create tag', tag: 'TagRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateTag(Tag tag) async {
    try {
      await _local.updateTag(tag.toCompanion());
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to update tag (id=${tag.id})', tag: 'TagRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> deleteTag(int id) async {
    try {
      await _local.deleteTag(id);
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to delete tag (id=$id)', tag: 'TagRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> setTaskTags(int taskId, List<int> tagIds) async {
    try {
      await _local.setTaskTags(taskId, tagIds);
      _emitChange();
    } catch (e, st) {
      _log.error('Failed to set tags for task $taskId', tag: 'TagRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<Tag>> watchAllTags() {
    return _local.watchAllTags().map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
