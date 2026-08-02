import '../../../../core/services/log_service.dart';
import '../../domain/entities/milestone.dart';
import '../../domain/entities/milestone_extensions.dart';
import '../../domain/repositories/i_milestone_repository.dart';
import '../datasources/milestone_local_datasource.dart';
import '../mappers/milestone_extensions.dart';

final _log = LogService.instance;

class MilestoneRepositoryImpl implements IMilestoneRepository {
  MilestoneRepositoryImpl(this._local);

  final IMilestoneLocalDataSource _local;

  @override
  Future<List<Milestone>> getMilestonesByProjectId(int projectId) async {
    final rows = await _local.getMilestonesByProjectId(projectId);
    return rows.map((r) => r.toDomain()).toList();
  }

  @override
  Future<Milestone?> getMilestoneById(int id) async {
    final row = await _local.getMilestoneById(id);
    return row?.toDomain();
  }

  @override
  Future<Milestone> createMilestone(Milestone milestone) async {
    try {
      final id = await _local.createMilestone(milestone.toCompanion());
      _log.debug('Milestone created (id=$id)', tag: 'MilestoneRepository');
      return milestone.copyWith(id: id);
    } catch (e, st) {
      _log.error('Failed to create milestone', tag: 'MilestoneRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> updateMilestone(Milestone milestone) async {
    try {
      await _local.updateMilestone(milestone.toCompanion());
    } catch (e, st) {
      _log.error(
        'Failed to update milestone (id=${milestone.id})',
        tag: 'MilestoneRepository',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteMilestone(int id) async {
    try {
      await _local.deleteMilestone(id);
    } catch (e, st) {
      _log.error('Failed to delete milestone (id=$id)', tag: 'MilestoneRepository', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Stream<List<Milestone>> watchMilestonesByProjectId(int projectId) {
    return _local.watchMilestonesByProjectId(projectId).map((rows) => rows.map((r) => r.toDomain()).toList());
  }
}
