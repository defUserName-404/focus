import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_reminder_mode.dart';
import '../../domain/repositories/i_task_repository.dart';
import '../../domain/services/task_service.dart';
import 'task_filter_state.dart';

part 'task_provider.g.dart';
part 'filtered_tasks_provider.part.dart';
part 'task_by_id_provider.part.dart';
part 'task_list_filter_provider.part.dart';
part 'task_notifier_provider.part.dart';
part 'tasks_by_project_provider.part.dart';

@Riverpod(keepAlive: true)
ITaskRepository taskRepository(Ref ref) {
  return getIt<ITaskRepository>();
}
