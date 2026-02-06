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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // If upgrading from schema version 1, create the new `task_table`.
      if (from < 2) {
        await m.createTable(taskTable);
      }
    },
  );
}
