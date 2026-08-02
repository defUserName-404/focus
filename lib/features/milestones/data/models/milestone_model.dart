import 'package:drift/drift.dart';

import '../../../projects/data/models/project_model.dart';

@TableIndex(name: 'milestone_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'milestone_project_id_idx', columns: {#projectId})
@TableIndex(name: 'milestone_deleted_at_idx', columns: {#deletedAt})
class MilestoneTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  IntColumn get projectId => integer().references(ProjectTable, #id, onDelete: KeyAction.cascade)();

  TextColumn get title => text()();

  DateTimeColumn get targetDate => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();
}
