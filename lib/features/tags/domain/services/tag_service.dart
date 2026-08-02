import '../../../../core/services/log_service.dart';
import '../../../../core/utils/id_utils.dart';
import '../../../../core/utils/result.dart';
import '../entities/tag.dart';
import '../entities/tag_extensions.dart';
import '../repositories/i_tag_repository.dart';

final _log = LogService.instance;

/// Domain service for tag CRUD and task↔tag associations.
class TagService {
  TagService(this._repository);

  final ITagRepository _repository;

  Future<List<Tag>> getAllTags() => _repository.getAllTags();

  Future<Tag?> getTagById(int id) => _repository.getTagById(id);

  Future<List<Tag>> getTagsForTask(int taskId) => _repository.getTagsForTask(taskId);

  Stream<List<Tag>> watchAllTags() => _repository.watchAllTags();

  Future<Result<Tag>> createTag({required String name, int? color}) async {
    try {
      final now = DateTime.now();
      final tag = Tag(uuid: generateUuid(), name: name, color: color, createdAt: now, updatedAt: now);
      final created = await _repository.createTag(tag);
      _log.info('Tag created: "$name" (id=${created.id})', tag: 'TagService');
      return Success(created);
    } catch (e, st) {
      _log.error('Failed to create tag "$name"', tag: 'TagService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to create tag', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> updateTag(Tag tag) async {
    try {
      await _repository.updateTag(tag.copyWith(updatedAt: DateTime.now()));
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to update tag ${tag.id}', tag: 'TagService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to update tag', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> deleteTag(int id) async {
    try {
      await _repository.deleteTag(id);
      _log.info('Tag $id soft-deleted', tag: 'TagService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to delete tag $id', tag: 'TagService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to delete tag', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> setTaskTags(int taskId, List<int> tagIds) async {
    try {
      await _repository.setTaskTags(taskId, tagIds);
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to set tags for task $taskId', tag: 'TagService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to set task tags', error: e, stackTrace: st));
    }
  }
}
