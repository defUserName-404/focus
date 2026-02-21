import 'package:drift/drift.dart';

@TableIndex(name: 'project_created_at_idx', columns: {#createdAt})
@TableIndex(name: 'project_updated_at_idx', columns: {#updatedAt})
class ProjectTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get startDate => dateTime().nullable()();

  DateTimeColumn get deadline => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
