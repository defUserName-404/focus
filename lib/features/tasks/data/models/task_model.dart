import 'package:drift/drift.dart'
    show BuildGeneralColumn, Column, DateTimeColumn, Table, TextColumn, IntColumn, BoolColumn, Constant, BuildColumn, Int64Column;

import '../../domain/entities/task_priority.dart';

class TaskTable extends Table {
  TextColumn get id => text()();

  Int64Column get projectId => int64()();

  TextColumn get parentTaskId => text().nullable()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  IntColumn get priority => intEnum<TaskPriority>()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime()();

  IntColumn get depth => integer()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
