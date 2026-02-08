import 'package:drift/drift.dart'
    show
        BuildGeneralColumn,
        Column,
        DateTimeColumn,
        Table,
        TextColumn,
        IntColumn,
        BoolColumn,
        Constant,
        BuildColumn,
        Int64Column,
        BuildInt64Column;

import '../../domain/entities/task_priority.dart';

class TaskTable extends Table {
  Int64Column get id => int64().autoIncrement()();

  Int64Column get projectId => int64()();

  Int64Column get parentTaskId => int64().nullable().references(TaskTable, #id)();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  IntColumn get priority => intEnum<TaskPriority>()();

  DateTimeColumn get startDate => dateTime().nullable()();

  DateTimeColumn get endDate => dateTime().nullable()();

  IntColumn get depth => integer()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
