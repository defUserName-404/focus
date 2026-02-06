import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:focus/features/tasks/data/models/task_model.dart';

import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/domain/entities/task_priority.dart';

part 'db_service.g.dart';

@DriftDatabase(tables: [ProjectTable, TaskTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'focus.sqlite'));

  @override
  int get schemaVersion => 1;
}
