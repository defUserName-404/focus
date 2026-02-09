import 'package:drift/drift.dart'
    show BuildGeneralColumn, DateTimeColumn, Table, TextColumn, Int64Column, BuildInt64Column, Column;

class ProjectTable extends Table {
  Int64Column get id => int64().autoIncrement()();

  TextColumn get title => text()();

  TextColumn get description => text().nullable()();

  DateTimeColumn get startDate => dateTime().nullable()();

  DateTimeColumn get deadline => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
