import 'package:drift/drift.dart';

import '../../domain/entities/project_status.dart';

@TableIndex(name: 'project_created_at_idx', columns: {#createdAt})
@TableIndex(name: 'project_updated_at_idx', columns: {#updatedAt})
@TableIndex(name: 'project_uuid_idx', columns: {#uuid}, unique: true)
@TableIndex(name: 'project_deleted_at_idx', columns: {#deletedAt})
@TableIndex(name: 'project_status_idx', columns: {#status})
class ProjectTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().unique()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  IntColumn get status => intEnum<ProjectStatus>().withDefault(const Constant(0))();

  /// ARGB color value, or null for the theme default.
  IntColumn get color => integer().nullable()();

  DateTimeColumn get startDate => dateTime().nullable()();

  DateTimeColumn get deadline => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();
}
