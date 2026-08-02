import '../../../../core/services/log_service.dart';
import '../../../../core/utils/id_utils.dart';
import '../../../../core/utils/result.dart';
import '../entities/milestone.dart';
import '../entities/milestone_extensions.dart';
import '../repositories/i_milestone_repository.dart';

final _log = LogService.instance;

/// Domain service for project milestone operations.
class MilestoneService {
  MilestoneService(this._repository);

  final IMilestoneRepository _repository;

  Future<List<Milestone>> getMilestonesByProjectId(int projectId) => _repository.getMilestonesByProjectId(projectId);

  Future<Milestone?> getMilestoneById(int id) => _repository.getMilestoneById(id);

  Stream<List<Milestone>> watchMilestonesByProjectId(int projectId) =>
      _repository.watchMilestonesByProjectId(projectId);

  Future<Result<Milestone>> createMilestone({
    required int projectId,
    required String title,
    DateTime? targetDate,
  }) async {
    try {
      final now = DateTime.now();
      final milestone = Milestone(
        uuid: generateUuid(),
        projectId: projectId,
        title: title,
        targetDate: targetDate,
        createdAt: now,
        updatedAt: now,
      );
      final created = await _repository.createMilestone(milestone);
      _log.info('Milestone created: "$title" (id=${created.id})', tag: 'MilestoneService');
      return Success(created);
    } catch (e, st) {
      _log.error('Failed to create milestone "$title"', tag: 'MilestoneService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to create milestone', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> updateMilestone(Milestone milestone) async {
    try {
      await _repository.updateMilestone(milestone.copyWith(updatedAt: DateTime.now()));
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to update milestone ${milestone.id}', tag: 'MilestoneService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to update milestone', error: e, stackTrace: st));
    }
  }

  Future<Result<void>> deleteMilestone(int id) async {
    try {
      await _repository.deleteMilestone(id);
      _log.info('Milestone $id soft-deleted', tag: 'MilestoneService');
      return const Success(null);
    } catch (e, st) {
      _log.error('Failed to delete milestone $id', tag: 'MilestoneService', error: e, stackTrace: st);
      return Failure(DatabaseFailure('Failed to delete milestone', error: e, stackTrace: st));
    }
  }
}
