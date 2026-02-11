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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Version 2: Added task table
      if (from < 2) {
        await m.createTable(taskTable);
      }
      // Version 3: Revamped task table (projectId, description)
      if (from < 3) {
        await m.deleteTable('task_table');
        await m.createTable(taskTable);
      }
      // Version 4: Revamped task table again (id, dates, parentId)
      if (from < 4) {
        await m.deleteTable('task_table');
        await m.createTable(taskTable);
      }
      // Version 5: Added indexes
      if (from < 5) {
        await m.createIndex(projectCreatedAtIdx);
        await m.createIndex(projectUpdatedAtIdx);
        await m.createIndex(taskProjectIdIdx);
        await m.createIndex(taskParentIdIdx);
        await m.createIndex(taskPriorityIdx);
        await m.createIndex(taskDeadlineIdx);
        await m.createIndex(taskCompletedIdx);
        await m.createIndex(taskUpdatedAtIdx);
      }
    },
  );
}
