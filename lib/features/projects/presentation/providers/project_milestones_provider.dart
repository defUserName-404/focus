import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../milestones/domain/entities/milestone.dart';
import '../../../milestones/domain/services/milestone_service.dart';

final milestoneServiceProvider = Provider<MilestoneService>((ref) {
  return getIt<MilestoneService>();
});

final projectMilestonesProvider = StreamProvider.family<List<Milestone>, int>((ref, projectId) {
  return ref.watch(milestoneServiceProvider).watchMilestonesByProjectId(projectId);
});
