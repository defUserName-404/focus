import '../../domain/entities/tag.dart';

abstract class ITagRepository {
  Future<List<Tag>> getAllTags();

  Future<Tag?> getTagById(int id);

  Future<List<Tag>> getTagsForTask(int taskId);

  Future<Tag> createTag(Tag tag);

  Future<void> updateTag(Tag tag);

  Future<void> deleteTag(int id);

  Future<void> setTaskTags(int taskId, List<int> tagIds);

  Stream<List<Tag>> watchAllTags();
}
