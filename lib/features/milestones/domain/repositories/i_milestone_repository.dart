import '../../domain/entities/milestone.dart';

abstract class IMilestoneRepository {
  Future<List<Milestone>> getMilestonesByProjectId(int projectId);

  Future<Milestone?> getMilestoneById(int id);

  Future<Milestone> createMilestone(Milestone milestone);

  Future<void> updateMilestone(Milestone milestone);

  Future<void> deleteMilestone(int id);

  Stream<List<Milestone>> watchMilestonesByProjectId(int projectId);
}
