import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:focus/features/tasks/domain/entities/task.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_list_filter_state.dart';
import '../../domain/entities/project_progress.dart';
import '../../domain/repositories/i_project_repository.dart';
import '../../domain/services/project_service.dart';

part 'project_provider.g.dart';
part 'filtered_project_list_provider.part.dart';
part 'project_by_id_provider.part.dart';
part 'project_list_filter_provider.part.dart';
part 'project_list_provider.part.dart';
part 'project_notifier_provider.part.dart';
part 'project_progress_provider.part.dart';

@Riverpod(keepAlive: true)
IProjectRepository projectRepository(Ref ref) {
  return getIt<IProjectRepository>();
}
