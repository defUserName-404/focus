// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_service.dart';

// ignore_for_file: type=lint
class $ProjectTableTable extends ProjectTable with TableInfo<$ProjectTableTable, ProjectTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ProjectStatus, int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<ProjectStatus>($ProjectTableTable.$converterstatus);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    title,
    description,
    status,
    color,
    startDate,
    deadline,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_table';
  @override
  VerificationContext validateIntegrity(Insertable<ProjectTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta, deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectTableData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: $ProjectTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      ),
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color']),
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      deadline: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $ProjectTableTable createAlias(String alias) {
    return $ProjectTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ProjectStatus, int, int> $converterstatus = const EnumIndexConverter<ProjectStatus>(
    ProjectStatus.values,
  );
}

class ProjectTableData extends DataClass implements Insertable<ProjectTableData> {
  final int id;
  final String uuid;
  final String title;
  final String? description;
  final ProjectStatus status;

  /// ARGB color value, or null for the theme default.
  final int? color;
  final DateTime? startDate;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ProjectTableData({
    required this.id,
    required this.uuid,
    required this.title,
    this.description,
    required this.status,
    this.color,
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['status'] = Variable<int>($ProjectTableTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ProjectTableCompanion toCompanion(bool nullToAbsent) {
    return ProjectTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      title: Value(title),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      status: Value(status),
      color: color == null && nullToAbsent ? const Value.absent() : Value(color),
      startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),
      deadline: deadline == null && nullToAbsent ? const Value.absent() : Value(deadline),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory ProjectTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectTableData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: $ProjectTableTable.$converterstatus.fromJson(serializer.fromJson<int>(json['status'])),
      color: serializer.fromJson<int?>(json['color']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<int>($ProjectTableTable.$converterstatus.toJson(status)),
      'color': serializer.toJson<int?>(color),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ProjectTableData copyWith({
    int? id,
    String? uuid,
    String? title,
    Value<String?> description = const Value.absent(),
    ProjectStatus? status,
    Value<int?> color = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> deadline = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ProjectTableData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    color: color.present ? color.value : this.color,
    startDate: startDate.present ? startDate.value : this.startDate,
    deadline: deadline.present ? deadline.value : this.deadline,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ProjectTableData copyWithCompanion(ProjectTableCompanion data) {
    return ProjectTableData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      color: data.color.present ? data.color.value : this.color,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTableData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('startDate: $startDate, ')
          ..write('deadline: $deadline, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, uuid, title, description, status, color, startDate, deadline, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectTableData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.color == this.color &&
          other.startDate == this.startDate &&
          other.deadline == this.deadline &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ProjectTableCompanion extends UpdateCompanion<ProjectTableData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> title;
  final Value<String?> description;
  final Value<ProjectStatus> status;
  final Value<int?> color;
  final Value<DateTime?> startDate;
  final Value<DateTime?> deadline;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const ProjectTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.color = const Value.absent(),
    this.startDate = const Value.absent(),
    this.deadline = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ProjectTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.color = const Value.absent(),
    this.startDate = const Value.absent(),
    this.deadline = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectTableData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? status,
    Expression<int>? color,
    Expression<DateTime>? startDate,
    Expression<DateTime>? deadline,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (color != null) 'color': color,
      if (startDate != null) 'start_date': startDate,
      if (deadline != null) 'deadline': deadline,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ProjectTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? title,
    Value<String?>? description,
    Value<ProjectStatus>? status,
    Value<int?>? color,
    Value<DateTime?>? startDate,
    Value<DateTime?>? deadline,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ProjectTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      color: color ?? this.color,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<int>($ProjectTableTable.$converterstatus.toSql(status.value));
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('color: $color, ')
          ..write('startDate: $startDate, ')
          ..write('deadline: $deadline, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $MilestoneTableTable extends MilestoneTable with TableInfo<$MilestoneTableTable, MilestoneTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestoneTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES project_table (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta('targetDate');
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, uuid, projectId, title, targetDate, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestone_table';
  @override
  VerificationContext validateIntegrity(Insertable<MilestoneTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta, projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(_targetDateMeta, targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MilestoneTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MilestoneTableData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      projectId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      targetDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}target_date']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $MilestoneTableTable createAlias(String alias) {
    return $MilestoneTableTable(attachedDatabase, alias);
  }
}

class MilestoneTableData extends DataClass implements Insertable<MilestoneTableData> {
  final int id;
  final String uuid;
  final int projectId;
  final String title;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const MilestoneTableData({
    required this.id,
    required this.uuid,
    required this.projectId,
    required this.title,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['project_id'] = Variable<int>(projectId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  MilestoneTableCompanion toCompanion(bool nullToAbsent) {
    return MilestoneTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      projectId: Value(projectId),
      title: Value(title),
      targetDate: targetDate == null && nullToAbsent ? const Value.absent() : Value(targetDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory MilestoneTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MilestoneTableData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      projectId: serializer.fromJson<int>(json['projectId']),
      title: serializer.fromJson<String>(json['title']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'projectId': serializer.toJson<int>(projectId),
      'title': serializer.toJson<String>(title),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  MilestoneTableData copyWith({
    int? id,
    String? uuid,
    int? projectId,
    String? title,
    Value<DateTime?> targetDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => MilestoneTableData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  MilestoneTableData copyWithCompanion(MilestoneTableCompanion data) {
    return MilestoneTableData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      title: data.title.present ? data.title.value : this.title,
      targetDate: data.targetDate.present ? data.targetDate.value : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneTableData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, projectId, title, targetDate, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MilestoneTableData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.projectId == this.projectId &&
          other.title == this.title &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class MilestoneTableCompanion extends UpdateCompanion<MilestoneTableData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> projectId;
  final Value<String> title;
  final Value<DateTime?> targetDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const MilestoneTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.projectId = const Value.absent(),
    this.title = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  MilestoneTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required int projectId,
    required String title,
    this.targetDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       projectId = Value(projectId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MilestoneTableData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? projectId,
    Expression<String>? title,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (projectId != null) 'project_id': projectId,
      if (title != null) 'title': title,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  MilestoneTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int>? projectId,
    Value<String>? title,
    Value<DateTime?>? targetDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return MilestoneTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestoneTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('projectId: $projectId, ')
          ..write('title: $title, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $TaskTableTable extends TaskTable with TableInfo<$TaskTableTable, TaskTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES project_table (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _parentTaskIdMeta = const VerificationMeta('parentTaskId');
  @override
  late final GeneratedColumn<int> parentTaskId = GeneratedColumn<int>(
    'parent_task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES task_table (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskPriority, int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<TaskPriority>($TaskTableTable.$converterpriority);
  @override
  late final GeneratedColumnWithTypeConverter<TaskStatus, int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<TaskStatus>($TaskTableTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TaskReminderMode, int> reminderMode = GeneratedColumn<int>(
    'reminder_mode',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  ).withConverter<TaskReminderMode>($TaskTableTable.$converterreminderMode);
  static const VerificationMeta _customReminderMinutesBeforeMeta = const VerificationMeta(
    'customReminderMinutesBefore',
  );
  @override
  late final GeneratedColumn<int> customReminderMinutesBefore = GeneratedColumn<int>(
    'custom_reminder_minutes_before',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depthMeta = const VerificationMeta('depth');
  @override
  late final GeneratedColumn<int> depth = GeneratedColumn<int>(
    'depth',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta('estimatedMinutes');
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<double> sortOrder = GeneratedColumn<double>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _milestoneIdMeta = const VerificationMeta('milestoneId');
  @override
  late final GeneratedColumn<int> milestoneId = GeneratedColumn<int>(
    'milestone_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES milestone_table (id) ON DELETE SET NULL'),
  );
  static const VerificationMeta _recurrenceRuleMeta = const VerificationMeta('recurrenceRule');
  @override
  late final GeneratedColumn<String> recurrenceRule = GeneratedColumn<String>(
    'recurrence_rule',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurrenceAnchorDateMeta = const VerificationMeta('recurrenceAnchorDate');
  @override
  late final GeneratedColumn<DateTime> recurrenceAnchorDate = GeneratedColumn<DateTime>(
    'recurrence_anchor_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isHabitMeta = const VerificationMeta('isHabit');
  @override
  late final GeneratedColumn<bool> isHabit = GeneratedColumn<bool>(
    'is_habit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_habit" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_completed" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    projectId,
    parentTaskId,
    title,
    description,
    priority,
    status,
    reminderMode,
    customReminderMinutesBefore,
    startDate,
    endDate,
    depth,
    estimatedMinutes,
    sortOrder,
    milestoneId,
    recurrenceRule,
    recurrenceAnchorDate,
    isHabit,
    isCompleted,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_table';
  @override
  VerificationContext validateIntegrity(Insertable<TaskTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta, projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('parent_task_id')) {
      context.handle(_parentTaskIdMeta, parentTaskId.isAcceptableOrUnknown(data['parent_task_id']!, _parentTaskIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(_descriptionMeta, description.isAcceptableOrUnknown(data['description']!, _descriptionMeta));
    }
    if (data.containsKey('custom_reminder_minutes_before')) {
      context.handle(
        _customReminderMinutesBeforeMeta,
        customReminderMinutesBefore.isAcceptableOrUnknown(
          data['custom_reminder_minutes_before']!,
          _customReminderMinutesBeforeMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta, startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta, endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('depth')) {
      context.handle(_depthMeta, depth.isAcceptableOrUnknown(data['depth']!, _depthMeta));
    } else if (isInserting) {
      context.missing(_depthMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(data['estimated_minutes']!, _estimatedMinutesMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta, sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('milestone_id')) {
      context.handle(_milestoneIdMeta, milestoneId.isAcceptableOrUnknown(data['milestone_id']!, _milestoneIdMeta));
    }
    if (data.containsKey('recurrence_rule')) {
      context.handle(
        _recurrenceRuleMeta,
        recurrenceRule.isAcceptableOrUnknown(data['recurrence_rule']!, _recurrenceRuleMeta),
      );
    }
    if (data.containsKey('recurrence_anchor_date')) {
      context.handle(
        _recurrenceAnchorDateMeta,
        recurrenceAnchorDate.isAcceptableOrUnknown(data['recurrence_anchor_date']!, _recurrenceAnchorDateMeta),
      );
    }
    if (data.containsKey('is_habit')) {
      context.handle(_isHabitMeta, isHabit.isAcceptableOrUnknown(data['is_habit']!, _isHabitMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(_isCompletedMeta, isCompleted.isAcceptableOrUnknown(data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTableData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      projectId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      parentTaskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}parent_task_id']),
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}description']),
      priority: $TaskTableTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      ),
      status: $TaskTableTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      ),
      reminderMode: $TaskTableTable.$converterreminderMode.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}reminder_mode'])!,
      ),
      customReminderMinutesBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_reminder_minutes_before'],
      ),
      startDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_date']),
      endDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      depth: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}depth'])!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}sort_order'])!,
      milestoneId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}milestone_id']),
      recurrenceRule: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}recurrence_rule']),
      recurrenceAnchorDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recurrence_anchor_date'],
      ),
      isHabit: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_habit'])!,
      isCompleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TaskTableTable createAlias(String alias) {
    return $TaskTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskPriority, int, int> $converterpriority = const EnumIndexConverter<TaskPriority>(
    TaskPriority.values,
  );
  static JsonTypeConverter2<TaskStatus, int, int> $converterstatus = const EnumIndexConverter<TaskStatus>(
    TaskStatus.values,
  );
  static JsonTypeConverter2<TaskReminderMode, int, int> $converterreminderMode =
      const EnumIndexConverter<TaskReminderMode>(TaskReminderMode.values);
}

class TaskTableData extends DataClass implements Insertable<TaskTableData> {
  final int id;
  final String uuid;
  final int projectId;
  final int? parentTaskId;
  final String title;
  final String? description;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskReminderMode reminderMode;
  final int? customReminderMinutesBefore;
  final DateTime? startDate;
  final DateTime? endDate;
  final int depth;
  final int? estimatedMinutes;
  final double sortOrder;
  final int? milestoneId;

  /// JSON-encoded [RecurrenceRule], or null for one-shot tasks.
  final String? recurrenceRule;

  /// Series start used by [RecurrenceExpander]; defaults to start/created when null.
  final DateTime? recurrenceAnchorDate;

  /// When true, the recurring task is surfaced as a habit (streaks / agenda).
  final bool isHabit;

  /// Kept in sync with [status] == done for one migration cycle (v7).
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TaskTableData({
    required this.id,
    required this.uuid,
    required this.projectId,
    this.parentTaskId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.reminderMode,
    this.customReminderMinutesBefore,
    this.startDate,
    this.endDate,
    required this.depth,
    this.estimatedMinutes,
    required this.sortOrder,
    this.milestoneId,
    this.recurrenceRule,
    this.recurrenceAnchorDate,
    required this.isHabit,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['project_id'] = Variable<int>(projectId);
    if (!nullToAbsent || parentTaskId != null) {
      map['parent_task_id'] = Variable<int>(parentTaskId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['priority'] = Variable<int>($TaskTableTable.$converterpriority.toSql(priority));
    }
    {
      map['status'] = Variable<int>($TaskTableTable.$converterstatus.toSql(status));
    }
    {
      map['reminder_mode'] = Variable<int>($TaskTableTable.$converterreminderMode.toSql(reminderMode));
    }
    if (!nullToAbsent || customReminderMinutesBefore != null) {
      map['custom_reminder_minutes_before'] = Variable<int>(customReminderMinutesBefore);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    map['depth'] = Variable<int>(depth);
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    map['sort_order'] = Variable<double>(sortOrder);
    if (!nullToAbsent || milestoneId != null) {
      map['milestone_id'] = Variable<int>(milestoneId);
    }
    if (!nullToAbsent || recurrenceRule != null) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule);
    }
    if (!nullToAbsent || recurrenceAnchorDate != null) {
      map['recurrence_anchor_date'] = Variable<DateTime>(recurrenceAnchorDate);
    }
    map['is_habit'] = Variable<bool>(isHabit);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaskTableCompanion toCompanion(bool nullToAbsent) {
    return TaskTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      projectId: Value(projectId),
      parentTaskId: parentTaskId == null && nullToAbsent ? const Value.absent() : Value(parentTaskId),
      title: Value(title),
      description: description == null && nullToAbsent ? const Value.absent() : Value(description),
      priority: Value(priority),
      status: Value(status),
      reminderMode: Value(reminderMode),
      customReminderMinutesBefore: customReminderMinutesBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(customReminderMinutesBefore),
      startDate: startDate == null && nullToAbsent ? const Value.absent() : Value(startDate),
      endDate: endDate == null && nullToAbsent ? const Value.absent() : Value(endDate),
      depth: Value(depth),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent ? const Value.absent() : Value(estimatedMinutes),
      sortOrder: Value(sortOrder),
      milestoneId: milestoneId == null && nullToAbsent ? const Value.absent() : Value(milestoneId),
      recurrenceRule: recurrenceRule == null && nullToAbsent ? const Value.absent() : Value(recurrenceRule),
      recurrenceAnchorDate: recurrenceAnchorDate == null && nullToAbsent
          ? const Value.absent()
          : Value(recurrenceAnchorDate),
      isHabit: Value(isHabit),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory TaskTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTableData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      projectId: serializer.fromJson<int>(json['projectId']),
      parentTaskId: serializer.fromJson<int?>(json['parentTaskId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      priority: $TaskTableTable.$converterpriority.fromJson(serializer.fromJson<int>(json['priority'])),
      status: $TaskTableTable.$converterstatus.fromJson(serializer.fromJson<int>(json['status'])),
      reminderMode: $TaskTableTable.$converterreminderMode.fromJson(serializer.fromJson<int>(json['reminderMode'])),
      customReminderMinutesBefore: serializer.fromJson<int?>(json['customReminderMinutesBefore']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      depth: serializer.fromJson<int>(json['depth']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      sortOrder: serializer.fromJson<double>(json['sortOrder']),
      milestoneId: serializer.fromJson<int?>(json['milestoneId']),
      recurrenceRule: serializer.fromJson<String?>(json['recurrenceRule']),
      recurrenceAnchorDate: serializer.fromJson<DateTime?>(json['recurrenceAnchorDate']),
      isHabit: serializer.fromJson<bool>(json['isHabit']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'projectId': serializer.toJson<int>(projectId),
      'parentTaskId': serializer.toJson<int?>(parentTaskId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'priority': serializer.toJson<int>($TaskTableTable.$converterpriority.toJson(priority)),
      'status': serializer.toJson<int>($TaskTableTable.$converterstatus.toJson(status)),
      'reminderMode': serializer.toJson<int>($TaskTableTable.$converterreminderMode.toJson(reminderMode)),
      'customReminderMinutesBefore': serializer.toJson<int?>(customReminderMinutesBefore),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'depth': serializer.toJson<int>(depth),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'sortOrder': serializer.toJson<double>(sortOrder),
      'milestoneId': serializer.toJson<int?>(milestoneId),
      'recurrenceRule': serializer.toJson<String?>(recurrenceRule),
      'recurrenceAnchorDate': serializer.toJson<DateTime?>(recurrenceAnchorDate),
      'isHabit': serializer.toJson<bool>(isHabit),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskTableData copyWith({
    int? id,
    String? uuid,
    int? projectId,
    Value<int?> parentTaskId = const Value.absent(),
    String? title,
    Value<String?> description = const Value.absent(),
    TaskPriority? priority,
    TaskStatus? status,
    TaskReminderMode? reminderMode,
    Value<int?> customReminderMinutesBefore = const Value.absent(),
    Value<DateTime?> startDate = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
    int? depth,
    Value<int?> estimatedMinutes = const Value.absent(),
    double? sortOrder,
    Value<int?> milestoneId = const Value.absent(),
    Value<String?> recurrenceRule = const Value.absent(),
    Value<DateTime?> recurrenceAnchorDate = const Value.absent(),
    bool? isHabit,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskTableData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    projectId: projectId ?? this.projectId,
    parentTaskId: parentTaskId.present ? parentTaskId.value : this.parentTaskId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    reminderMode: reminderMode ?? this.reminderMode,
    customReminderMinutesBefore: customReminderMinutesBefore.present
        ? customReminderMinutesBefore.value
        : this.customReminderMinutesBefore,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    depth: depth ?? this.depth,
    estimatedMinutes: estimatedMinutes.present ? estimatedMinutes.value : this.estimatedMinutes,
    sortOrder: sortOrder ?? this.sortOrder,
    milestoneId: milestoneId.present ? milestoneId.value : this.milestoneId,
    recurrenceRule: recurrenceRule.present ? recurrenceRule.value : this.recurrenceRule,
    recurrenceAnchorDate: recurrenceAnchorDate.present ? recurrenceAnchorDate.value : this.recurrenceAnchorDate,
    isHabit: isHabit ?? this.isHabit,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskTableData copyWithCompanion(TaskTableCompanion data) {
    return TaskTableData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      parentTaskId: data.parentTaskId.present ? data.parentTaskId.value : this.parentTaskId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present ? data.description.value : this.description,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      reminderMode: data.reminderMode.present ? data.reminderMode.value : this.reminderMode,
      customReminderMinutesBefore: data.customReminderMinutesBefore.present
          ? data.customReminderMinutesBefore.value
          : this.customReminderMinutesBefore,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      depth: data.depth.present ? data.depth.value : this.depth,
      estimatedMinutes: data.estimatedMinutes.present ? data.estimatedMinutes.value : this.estimatedMinutes,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      milestoneId: data.milestoneId.present ? data.milestoneId.value : this.milestoneId,
      recurrenceRule: data.recurrenceRule.present ? data.recurrenceRule.value : this.recurrenceRule,
      recurrenceAnchorDate: data.recurrenceAnchorDate.present
          ? data.recurrenceAnchorDate.value
          : this.recurrenceAnchorDate,
      isHabit: data.isHabit.present ? data.isHabit.value : this.isHabit,
      isCompleted: data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTableData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('projectId: $projectId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('reminderMode: $reminderMode, ')
          ..write('customReminderMinutesBefore: $customReminderMinutesBefore, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('depth: $depth, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('recurrenceAnchorDate: $recurrenceAnchorDate, ')
          ..write('isHabit: $isHabit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    uuid,
    projectId,
    parentTaskId,
    title,
    description,
    priority,
    status,
    reminderMode,
    customReminderMinutesBefore,
    startDate,
    endDate,
    depth,
    estimatedMinutes,
    sortOrder,
    milestoneId,
    recurrenceRule,
    recurrenceAnchorDate,
    isHabit,
    isCompleted,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTableData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.projectId == this.projectId &&
          other.parentTaskId == this.parentTaskId &&
          other.title == this.title &&
          other.description == this.description &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.reminderMode == this.reminderMode &&
          other.customReminderMinutesBefore == this.customReminderMinutesBefore &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.depth == this.depth &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.sortOrder == this.sortOrder &&
          other.milestoneId == this.milestoneId &&
          other.recurrenceRule == this.recurrenceRule &&
          other.recurrenceAnchorDate == this.recurrenceAnchorDate &&
          other.isHabit == this.isHabit &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TaskTableCompanion extends UpdateCompanion<TaskTableData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> projectId;
  final Value<int?> parentTaskId;
  final Value<String> title;
  final Value<String?> description;
  final Value<TaskPriority> priority;
  final Value<TaskStatus> status;
  final Value<TaskReminderMode> reminderMode;
  final Value<int?> customReminderMinutesBefore;
  final Value<DateTime?> startDate;
  final Value<DateTime?> endDate;
  final Value<int> depth;
  final Value<int?> estimatedMinutes;
  final Value<double> sortOrder;
  final Value<int?> milestoneId;
  final Value<String?> recurrenceRule;
  final Value<DateTime?> recurrenceAnchorDate;
  final Value<bool> isHabit;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const TaskTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.projectId = const Value.absent(),
    this.parentTaskId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.reminderMode = const Value.absent(),
    this.customReminderMinutesBefore = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.depth = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.milestoneId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.recurrenceAnchorDate = const Value.absent(),
    this.isHabit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TaskTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required int projectId,
    this.parentTaskId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required TaskPriority priority,
    this.status = const Value.absent(),
    this.reminderMode = const Value.absent(),
    this.customReminderMinutesBefore = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    required int depth,
    this.estimatedMinutes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.milestoneId = const Value.absent(),
    this.recurrenceRule = const Value.absent(),
    this.recurrenceAnchorDate = const Value.absent(),
    this.isHabit = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       projectId = Value(projectId),
       title = Value(title),
       priority = Value(priority),
       depth = Value(depth),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskTableData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? projectId,
    Expression<int>? parentTaskId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<int>? reminderMode,
    Expression<int>? customReminderMinutesBefore,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? depth,
    Expression<int>? estimatedMinutes,
    Expression<double>? sortOrder,
    Expression<int>? milestoneId,
    Expression<String>? recurrenceRule,
    Expression<DateTime>? recurrenceAnchorDate,
    Expression<bool>? isHabit,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (projectId != null) 'project_id': projectId,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (reminderMode != null) 'reminder_mode': reminderMode,
      if (customReminderMinutesBefore != null) 'custom_reminder_minutes_before': customReminderMinutesBefore,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (depth != null) 'depth': depth,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (milestoneId != null) 'milestone_id': milestoneId,
      if (recurrenceRule != null) 'recurrence_rule': recurrenceRule,
      if (recurrenceAnchorDate != null) 'recurrence_anchor_date': recurrenceAnchorDate,
      if (isHabit != null) 'is_habit': isHabit,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TaskTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int>? projectId,
    Value<int?>? parentTaskId,
    Value<String>? title,
    Value<String?>? description,
    Value<TaskPriority>? priority,
    Value<TaskStatus>? status,
    Value<TaskReminderMode>? reminderMode,
    Value<int?>? customReminderMinutesBefore,
    Value<DateTime?>? startDate,
    Value<DateTime?>? endDate,
    Value<int>? depth,
    Value<int?>? estimatedMinutes,
    Value<double>? sortOrder,
    Value<int?>? milestoneId,
    Value<String?>? recurrenceRule,
    Value<DateTime?>? recurrenceAnchorDate,
    Value<bool>? isHabit,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return TaskTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      projectId: projectId ?? this.projectId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      reminderMode: reminderMode ?? this.reminderMode,
      customReminderMinutesBefore: customReminderMinutesBefore ?? this.customReminderMinutesBefore,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      depth: depth ?? this.depth,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      sortOrder: sortOrder ?? this.sortOrder,
      milestoneId: milestoneId ?? this.milestoneId,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceAnchorDate: recurrenceAnchorDate ?? this.recurrenceAnchorDate,
      isHabit: isHabit ?? this.isHabit,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (parentTaskId.present) {
      map['parent_task_id'] = Variable<int>(parentTaskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>($TaskTableTable.$converterpriority.toSql(priority.value));
    }
    if (status.present) {
      map['status'] = Variable<int>($TaskTableTable.$converterstatus.toSql(status.value));
    }
    if (reminderMode.present) {
      map['reminder_mode'] = Variable<int>($TaskTableTable.$converterreminderMode.toSql(reminderMode.value));
    }
    if (customReminderMinutesBefore.present) {
      map['custom_reminder_minutes_before'] = Variable<int>(customReminderMinutesBefore.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (depth.present) {
      map['depth'] = Variable<int>(depth.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<double>(sortOrder.value);
    }
    if (milestoneId.present) {
      map['milestone_id'] = Variable<int>(milestoneId.value);
    }
    if (recurrenceRule.present) {
      map['recurrence_rule'] = Variable<String>(recurrenceRule.value);
    }
    if (recurrenceAnchorDate.present) {
      map['recurrence_anchor_date'] = Variable<DateTime>(recurrenceAnchorDate.value);
    }
    if (isHabit.present) {
      map['is_habit'] = Variable<bool>(isHabit.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('projectId: $projectId, ')
          ..write('parentTaskId: $parentTaskId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('reminderMode: $reminderMode, ')
          ..write('customReminderMinutesBefore: $customReminderMinutesBefore, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('depth: $depth, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('milestoneId: $milestoneId, ')
          ..write('recurrenceRule: $recurrenceRule, ')
          ..write('recurrenceAnchorDate: $recurrenceAnchorDate, ')
          ..write('isHabit: $isHabit, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionTableTable extends FocusSessionTable with TableInfo<$FocusSessionTableTable, FocusSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES task_table (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _focusDurationMinutesMeta = const VerificationMeta('focusDurationMinutes');
  @override
  late final GeneratedColumn<int> focusDurationMinutes = GeneratedColumn<int>(
    'focus_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _breakDurationMinutesMeta = const VerificationMeta('breakDurationMinutes');
  @override
  late final GeneratedColumn<int> breakDurationMinutes = GeneratedColumn<int>(
    'break_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SessionState, int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<SessionState>($FocusSessionTableTable.$converterstate);
  static const VerificationMeta _elapsedSecondsMeta = const VerificationMeta('elapsedSeconds');
  @override
  late final GeneratedColumn<int> elapsedSeconds = GeneratedColumn<int>(
    'elapsed_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _focusPhaseEndedAtMeta = const VerificationMeta('focusPhaseEndedAt');
  @override
  late final GeneratedColumn<int> focusPhaseEndedAt = GeneratedColumn<int>(
    'focus_phase_ended_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    taskId,
    focusDurationMinutes,
    breakDurationMinutes,
    startTime,
    endTime,
    state,
    elapsedSeconds,
    focusPhaseEndedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_session_table';
  @override
  VerificationContext validateIntegrity(Insertable<FocusSessionData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('focus_duration_minutes')) {
      context.handle(
        _focusDurationMinutesMeta,
        focusDurationMinutes.isAcceptableOrUnknown(data['focus_duration_minutes']!, _focusDurationMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_focusDurationMinutesMeta);
    }
    if (data.containsKey('break_duration_minutes')) {
      context.handle(
        _breakDurationMinutesMeta,
        breakDurationMinutes.isAcceptableOrUnknown(data['break_duration_minutes']!, _breakDurationMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_breakDurationMinutesMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta, startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta, endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('elapsed_seconds')) {
      context.handle(
        _elapsedSecondsMeta,
        elapsedSeconds.isAcceptableOrUnknown(data['elapsed_seconds']!, _elapsedSecondsMeta),
      );
    }
    if (data.containsKey('focus_phase_ended_at')) {
      context.handle(
        _focusPhaseEndedAtMeta,
        focusPhaseEndedAt.isAcceptableOrUnknown(data['focus_phase_ended_at']!, _focusPhaseEndedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      focusDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_duration_minutes'],
      )!,
      breakDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_duration_minutes'],
      )!,
      startTime: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      state: $FocusSessionTableTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}state'])!,
      ),
      elapsedSeconds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}elapsed_seconds'])!,
      focusPhaseEndedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}focus_phase_ended_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $FocusSessionTableTable createAlias(String alias) {
    return $FocusSessionTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SessionState, int, int> $converterstate = const EnumIndexConverter<SessionState>(
    SessionState.values,
  );
}

class FocusSessionData extends DataClass implements Insertable<FocusSessionData> {
  final int id;
  final String uuid;
  final int? taskId;
  final int focusDurationMinutes;
  final int breakDurationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionState state;
  final int elapsedSeconds;

  /// Elapsed seconds at which the focus phase ended.
  /// Stored to preserve accurate focus time across app restarts.
  /// Null while focus is still running; set when transitioning to break.
  final int? focusPhaseEndedAt;
  final DateTime? deletedAt;
  const FocusSessionData({
    required this.id,
    required this.uuid,
    this.taskId,
    required this.focusDurationMinutes,
    required this.breakDurationMinutes,
    required this.startTime,
    this.endTime,
    required this.state,
    required this.elapsedSeconds,
    this.focusPhaseEndedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    map['focus_duration_minutes'] = Variable<int>(focusDurationMinutes);
    map['break_duration_minutes'] = Variable<int>(breakDurationMinutes);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    {
      map['state'] = Variable<int>($FocusSessionTableTable.$converterstate.toSql(state));
    }
    map['elapsed_seconds'] = Variable<int>(elapsedSeconds);
    if (!nullToAbsent || focusPhaseEndedAt != null) {
      map['focus_phase_ended_at'] = Variable<int>(focusPhaseEndedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  FocusSessionTableCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      taskId: taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      focusDurationMinutes: Value(focusDurationMinutes),
      breakDurationMinutes: Value(breakDurationMinutes),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent ? const Value.absent() : Value(endTime),
      state: Value(state),
      elapsedSeconds: Value(elapsedSeconds),
      focusPhaseEndedAt: focusPhaseEndedAt == null && nullToAbsent ? const Value.absent() : Value(focusPhaseEndedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory FocusSessionData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      focusDurationMinutes: serializer.fromJson<int>(json['focusDurationMinutes']),
      breakDurationMinutes: serializer.fromJson<int>(json['breakDurationMinutes']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      state: $FocusSessionTableTable.$converterstate.fromJson(serializer.fromJson<int>(json['state'])),
      elapsedSeconds: serializer.fromJson<int>(json['elapsedSeconds']),
      focusPhaseEndedAt: serializer.fromJson<int?>(json['focusPhaseEndedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'taskId': serializer.toJson<int?>(taskId),
      'focusDurationMinutes': serializer.toJson<int>(focusDurationMinutes),
      'breakDurationMinutes': serializer.toJson<int>(breakDurationMinutes),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'state': serializer.toJson<int>($FocusSessionTableTable.$converterstate.toJson(state)),
      'elapsedSeconds': serializer.toJson<int>(elapsedSeconds),
      'focusPhaseEndedAt': serializer.toJson<int?>(focusPhaseEndedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  FocusSessionData copyWith({
    int? id,
    String? uuid,
    Value<int?> taskId = const Value.absent(),
    int? focusDurationMinutes,
    int? breakDurationMinutes,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    SessionState? state,
    int? elapsedSeconds,
    Value<int?> focusPhaseEndedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => FocusSessionData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    taskId: taskId.present ? taskId.value : this.taskId,
    focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
    breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    state: state ?? this.state,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    focusPhaseEndedAt: focusPhaseEndedAt.present ? focusPhaseEndedAt.value : this.focusPhaseEndedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  FocusSessionData copyWithCompanion(FocusSessionTableCompanion data) {
    return FocusSessionData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      focusDurationMinutes: data.focusDurationMinutes.present
          ? data.focusDurationMinutes.value
          : this.focusDurationMinutes,
      breakDurationMinutes: data.breakDurationMinutes.present
          ? data.breakDurationMinutes.value
          : this.breakDurationMinutes,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      state: data.state.present ? data.state.value : this.state,
      elapsedSeconds: data.elapsedSeconds.present ? data.elapsedSeconds.value : this.elapsedSeconds,
      focusPhaseEndedAt: data.focusPhaseEndedAt.present ? data.focusPhaseEndedAt.value : this.focusPhaseEndedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('taskId: $taskId, ')
          ..write('focusDurationMinutes: $focusDurationMinutes, ')
          ..write('breakDurationMinutes: $breakDurationMinutes, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('state: $state, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('focusPhaseEndedAt: $focusPhaseEndedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uuid,
    taskId,
    focusDurationMinutes,
    breakDurationMinutes,
    startTime,
    endTime,
    state,
    elapsedSeconds,
    focusPhaseEndedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.taskId == this.taskId &&
          other.focusDurationMinutes == this.focusDurationMinutes &&
          other.breakDurationMinutes == this.breakDurationMinutes &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.state == this.state &&
          other.elapsedSeconds == this.elapsedSeconds &&
          other.focusPhaseEndedAt == this.focusPhaseEndedAt &&
          other.deletedAt == this.deletedAt);
}

class FocusSessionTableCompanion extends UpdateCompanion<FocusSessionData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int?> taskId;
  final Value<int> focusDurationMinutes;
  final Value<int> breakDurationMinutes;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<SessionState> state;
  final Value<int> elapsedSeconds;
  final Value<int?> focusPhaseEndedAt;
  final Value<DateTime?> deletedAt;
  const FocusSessionTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.taskId = const Value.absent(),
    this.focusDurationMinutes = const Value.absent(),
    this.breakDurationMinutes = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.state = const Value.absent(),
    this.elapsedSeconds = const Value.absent(),
    this.focusPhaseEndedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  FocusSessionTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    this.taskId = const Value.absent(),
    required int focusDurationMinutes,
    required int breakDurationMinutes,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    required SessionState state,
    this.elapsedSeconds = const Value.absent(),
    this.focusPhaseEndedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       focusDurationMinutes = Value(focusDurationMinutes),
       breakDurationMinutes = Value(breakDurationMinutes),
       startTime = Value(startTime),
       state = Value(state);
  static Insertable<FocusSessionData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? taskId,
    Expression<int>? focusDurationMinutes,
    Expression<int>? breakDurationMinutes,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? state,
    Expression<int>? elapsedSeconds,
    Expression<int>? focusPhaseEndedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (taskId != null) 'task_id': taskId,
      if (focusDurationMinutes != null) 'focus_duration_minutes': focusDurationMinutes,
      if (breakDurationMinutes != null) 'break_duration_minutes': breakDurationMinutes,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (state != null) 'state': state,
      if (elapsedSeconds != null) 'elapsed_seconds': elapsedSeconds,
      if (focusPhaseEndedAt != null) 'focus_phase_ended_at': focusPhaseEndedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  FocusSessionTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int?>? taskId,
    Value<int>? focusDurationMinutes,
    Value<int>? breakDurationMinutes,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<SessionState>? state,
    Value<int>? elapsedSeconds,
    Value<int?>? focusPhaseEndedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return FocusSessionTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      taskId: taskId ?? this.taskId,
      focusDurationMinutes: focusDurationMinutes ?? this.focusDurationMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      state: state ?? this.state,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      focusPhaseEndedAt: focusPhaseEndedAt ?? this.focusPhaseEndedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (focusDurationMinutes.present) {
      map['focus_duration_minutes'] = Variable<int>(focusDurationMinutes.value);
    }
    if (breakDurationMinutes.present) {
      map['break_duration_minutes'] = Variable<int>(breakDurationMinutes.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (state.present) {
      map['state'] = Variable<int>($FocusSessionTableTable.$converterstate.toSql(state.value));
    }
    if (elapsedSeconds.present) {
      map['elapsed_seconds'] = Variable<int>(elapsedSeconds.value);
    }
    if (focusPhaseEndedAt.present) {
      map['focus_phase_ended_at'] = Variable<int>(focusPhaseEndedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('taskId: $taskId, ')
          ..write('focusDurationMinutes: $focusDurationMinutes, ')
          ..write('breakDurationMinutes: $breakDurationMinutes, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('state: $state, ')
          ..write('elapsedSeconds: $elapsedSeconds, ')
          ..write('focusPhaseEndedAt: $focusPhaseEndedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $DailySessionStatsTableTable extends DailySessionStatsTable
    with TableInfo<$DailySessionStatsTableTable, DailySessionStatsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySessionStatsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedSessionsMeta = const VerificationMeta('completedSessions');
  @override
  late final GeneratedColumn<int> completedSessions = GeneratedColumn<int>(
    'completed_sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSessionsMeta = const VerificationMeta('totalSessions');
  @override
  late final GeneratedColumn<int> totalSessions = GeneratedColumn<int>(
    'total_sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _focusSecondsMeta = const VerificationMeta('focusSeconds');
  @override
  late final GeneratedColumn<int> focusSeconds = GeneratedColumn<int>(
    'focus_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [date, completedSessions, totalSessions, focusSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_session_stats_table';
  @override
  VerificationContext validateIntegrity(Insertable<DailySessionStatsData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(_dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed_sessions')) {
      context.handle(
        _completedSessionsMeta,
        completedSessions.isAcceptableOrUnknown(data['completed_sessions']!, _completedSessionsMeta),
      );
    }
    if (data.containsKey('total_sessions')) {
      context.handle(
        _totalSessionsMeta,
        totalSessions.isAcceptableOrUnknown(data['total_sessions']!, _totalSessionsMeta),
      );
    }
    if (data.containsKey('focus_seconds')) {
      context.handle(_focusSecondsMeta, focusSeconds.isAcceptableOrUnknown(data['focus_seconds']!, _focusSecondsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailySessionStatsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySessionStatsData(
      date: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      completedSessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_sessions'],
      )!,
      totalSessions: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}total_sessions'])!,
      focusSeconds: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}focus_seconds'])!,
    );
  }

  @override
  $DailySessionStatsTableTable createAlias(String alias) {
    return $DailySessionStatsTableTable(attachedDatabase, alias);
  }
}

class DailySessionStatsData extends DataClass implements Insertable<DailySessionStatsData> {
  /// ISO-8601 local date, e.g. `'2026-02-12'`. Acts as the primary key.
  final String date;
  final int completedSessions;
  final int totalSessions;
  final int focusSeconds;
  const DailySessionStatsData({
    required this.date,
    required this.completedSessions,
    required this.totalSessions,
    required this.focusSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['completed_sessions'] = Variable<int>(completedSessions);
    map['total_sessions'] = Variable<int>(totalSessions);
    map['focus_seconds'] = Variable<int>(focusSeconds);
    return map;
  }

  DailySessionStatsTableCompanion toCompanion(bool nullToAbsent) {
    return DailySessionStatsTableCompanion(
      date: Value(date),
      completedSessions: Value(completedSessions),
      totalSessions: Value(totalSessions),
      focusSeconds: Value(focusSeconds),
    );
  }

  factory DailySessionStatsData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySessionStatsData(
      date: serializer.fromJson<String>(json['date']),
      completedSessions: serializer.fromJson<int>(json['completedSessions']),
      totalSessions: serializer.fromJson<int>(json['totalSessions']),
      focusSeconds: serializer.fromJson<int>(json['focusSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'completedSessions': serializer.toJson<int>(completedSessions),
      'totalSessions': serializer.toJson<int>(totalSessions),
      'focusSeconds': serializer.toJson<int>(focusSeconds),
    };
  }

  DailySessionStatsData copyWith({String? date, int? completedSessions, int? totalSessions, int? focusSeconds}) =>
      DailySessionStatsData(
        date: date ?? this.date,
        completedSessions: completedSessions ?? this.completedSessions,
        totalSessions: totalSessions ?? this.totalSessions,
        focusSeconds: focusSeconds ?? this.focusSeconds,
      );
  DailySessionStatsData copyWithCompanion(DailySessionStatsTableCompanion data) {
    return DailySessionStatsData(
      date: data.date.present ? data.date.value : this.date,
      completedSessions: data.completedSessions.present ? data.completedSessions.value : this.completedSessions,
      totalSessions: data.totalSessions.present ? data.totalSessions.value : this.totalSessions,
      focusSeconds: data.focusSeconds.present ? data.focusSeconds.value : this.focusSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySessionStatsData(')
          ..write('date: $date, ')
          ..write('completedSessions: $completedSessions, ')
          ..write('totalSessions: $totalSessions, ')
          ..write('focusSeconds: $focusSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, completedSessions, totalSessions, focusSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySessionStatsData &&
          other.date == this.date &&
          other.completedSessions == this.completedSessions &&
          other.totalSessions == this.totalSessions &&
          other.focusSeconds == this.focusSeconds);
}

class DailySessionStatsTableCompanion extends UpdateCompanion<DailySessionStatsData> {
  final Value<String> date;
  final Value<int> completedSessions;
  final Value<int> totalSessions;
  final Value<int> focusSeconds;
  final Value<int> rowid;
  const DailySessionStatsTableCompanion({
    this.date = const Value.absent(),
    this.completedSessions = const Value.absent(),
    this.totalSessions = const Value.absent(),
    this.focusSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailySessionStatsTableCompanion.insert({
    required String date,
    this.completedSessions = const Value.absent(),
    this.totalSessions = const Value.absent(),
    this.focusSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailySessionStatsData> custom({
    Expression<String>? date,
    Expression<int>? completedSessions,
    Expression<int>? totalSessions,
    Expression<int>? focusSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (completedSessions != null) 'completed_sessions': completedSessions,
      if (totalSessions != null) 'total_sessions': totalSessions,
      if (focusSeconds != null) 'focus_seconds': focusSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailySessionStatsTableCompanion copyWith({
    Value<String>? date,
    Value<int>? completedSessions,
    Value<int>? totalSessions,
    Value<int>? focusSeconds,
    Value<int>? rowid,
  }) {
    return DailySessionStatsTableCompanion(
      date: date ?? this.date,
      completedSessions: completedSessions ?? this.completedSessions,
      totalSessions: totalSessions ?? this.totalSessions,
      focusSeconds: focusSeconds ?? this.focusSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (completedSessions.present) {
      map['completed_sessions'] = Variable<int>(completedSessions.value);
    }
    if (totalSessions.present) {
      map['total_sessions'] = Variable<int>(totalSessions.value);
    }
    if (focusSeconds.present) {
      map['focus_seconds'] = Variable<int>(focusSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySessionStatsTableCompanion(')
          ..write('date: $date, ')
          ..write('completedSessions: $completedSessions, ')
          ..write('totalSessions: $totalSessions, ')
          ..write('focusSeconds: $focusSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable with TableInfo<$SettingsTableTable, SettingsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(Insertable<SettingsData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsData(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsData extends DataClass implements Insertable<SettingsData> {
  /// Unique setting key, e.g. `'alarm_sound_id'`, `'ambience_sound_id'`.
  final String key;

  /// The setting value stored as a string.
  final String value;
  const SettingsData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(key: Value(key), value: Value(value));
  }

  factory SettingsData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'key': serializer.toJson<String>(key), 'value': serializer.toJson<String>(value)};
  }

  SettingsData copyWith({String? key, String? value}) => SettingsData(key: key ?? this.key, value: value ?? this.value);
  SettingsData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SettingsData && other.key == this.key && other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({required String key, required String value, this.rowid = const Value.absent()})
    : key = Value(key),
      value = Value(value);
  static Insertable<SettingsData> custom({Expression<String>? key, Expression<String>? value, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsTableCompanion(key: key ?? this.key, value: value ?? this.value, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationInboxTableTable extends NotificationInboxTable
    with TableInfo<$NotificationInboxTableTable, NotificationInboxTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationInboxTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta('notificationId');
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NotificationInboxType, int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<NotificationInboxType>($NotificationInboxTableTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<NotificationInboxState, int> state = GeneratedColumn<int>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  ).withConverter<NotificationInboxState>($NotificationInboxTableTable.$converterstate);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta('scheduledFor');
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notificationId,
    type,
    state,
    title,
    body,
    payload,
    taskId,
    projectId,
    scheduledFor,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_inbox_table';
  @override
  VerificationContext validateIntegrity(Insertable<NotificationInboxTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(data['notification_id']!, _notificationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta, payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta, projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(_scheduledForMeta, scheduledFor.isAcceptableOrUnknown(data['scheduled_for']!, _scheduledForMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {notificationId, type},
  ];
  @override
  NotificationInboxTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationInboxTableData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      notificationId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}notification_id'])!,
      type: $NotificationInboxTableTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}type'])!,
      ),
      state: $NotificationInboxTableTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}state'])!,
      ),
      title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body']),
      payload: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}payload']),
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id']),
      projectId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}project_id']),
      scheduledFor: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_for']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotificationInboxTableTable createAlias(String alias) {
    return $NotificationInboxTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<NotificationInboxType, int, int> $convertertype =
      const EnumIndexConverter<NotificationInboxType>(NotificationInboxType.values);
  static JsonTypeConverter2<NotificationInboxState, int, int> $converterstate =
      const EnumIndexConverter<NotificationInboxState>(NotificationInboxState.values);
}

class NotificationInboxTableData extends DataClass implements Insertable<NotificationInboxTableData> {
  final int id;
  final int notificationId;
  final NotificationInboxType type;
  final NotificationInboxState state;
  final String title;
  final String? body;
  final String? payload;
  final int? taskId;
  final int? projectId;
  final DateTime? scheduledFor;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NotificationInboxTableData({
    required this.id,
    required this.notificationId,
    required this.type,
    required this.state,
    required this.title,
    this.body,
    this.payload,
    this.taskId,
    this.projectId,
    this.scheduledFor,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['notification_id'] = Variable<int>(notificationId);
    {
      map['type'] = Variable<int>($NotificationInboxTableTable.$convertertype.toSql(type));
    }
    {
      map['state'] = Variable<int>($NotificationInboxTableTable.$converterstate.toSql(state));
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<int>(taskId);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<int>(projectId);
    }
    if (!nullToAbsent || scheduledFor != null) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotificationInboxTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationInboxTableCompanion(
      id: Value(id),
      notificationId: Value(notificationId),
      type: Value(type),
      state: Value(state),
      title: Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      payload: payload == null && nullToAbsent ? const Value.absent() : Value(payload),
      taskId: taskId == null && nullToAbsent ? const Value.absent() : Value(taskId),
      projectId: projectId == null && nullToAbsent ? const Value.absent() : Value(projectId),
      scheduledFor: scheduledFor == null && nullToAbsent ? const Value.absent() : Value(scheduledFor),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NotificationInboxTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationInboxTableData(
      id: serializer.fromJson<int>(json['id']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      type: $NotificationInboxTableTable.$convertertype.fromJson(serializer.fromJson<int>(json['type'])),
      state: $NotificationInboxTableTable.$converterstate.fromJson(serializer.fromJson<int>(json['state'])),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      payload: serializer.fromJson<String?>(json['payload']),
      taskId: serializer.fromJson<int?>(json['taskId']),
      projectId: serializer.fromJson<int?>(json['projectId']),
      scheduledFor: serializer.fromJson<DateTime?>(json['scheduledFor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'notificationId': serializer.toJson<int>(notificationId),
      'type': serializer.toJson<int>($NotificationInboxTableTable.$convertertype.toJson(type)),
      'state': serializer.toJson<int>($NotificationInboxTableTable.$converterstate.toJson(state)),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String?>(body),
      'payload': serializer.toJson<String?>(payload),
      'taskId': serializer.toJson<int?>(taskId),
      'projectId': serializer.toJson<int?>(projectId),
      'scheduledFor': serializer.toJson<DateTime?>(scheduledFor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NotificationInboxTableData copyWith({
    int? id,
    int? notificationId,
    NotificationInboxType? type,
    NotificationInboxState? state,
    String? title,
    Value<String?> body = const Value.absent(),
    Value<String?> payload = const Value.absent(),
    Value<int?> taskId = const Value.absent(),
    Value<int?> projectId = const Value.absent(),
    Value<DateTime?> scheduledFor = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NotificationInboxTableData(
    id: id ?? this.id,
    notificationId: notificationId ?? this.notificationId,
    type: type ?? this.type,
    state: state ?? this.state,
    title: title ?? this.title,
    body: body.present ? body.value : this.body,
    payload: payload.present ? payload.value : this.payload,
    taskId: taskId.present ? taskId.value : this.taskId,
    projectId: projectId.present ? projectId.value : this.projectId,
    scheduledFor: scheduledFor.present ? scheduledFor.value : this.scheduledFor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NotificationInboxTableData copyWithCompanion(NotificationInboxTableCompanion data) {
    return NotificationInboxTableData(
      id: data.id.present ? data.id.value : this.id,
      notificationId: data.notificationId.present ? data.notificationId.value : this.notificationId,
      type: data.type.present ? data.type.value : this.type,
      state: data.state.present ? data.state.value : this.state,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      payload: data.payload.present ? data.payload.value : this.payload,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      scheduledFor: data.scheduledFor.present ? data.scheduledFor.value : this.scheduledFor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationInboxTableData(')
          ..write('id: $id, ')
          ..write('notificationId: $notificationId, ')
          ..write('type: $type, ')
          ..write('state: $state, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('taskId: $taskId, ')
          ..write('projectId: $projectId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    notificationId,
    type,
    state,
    title,
    body,
    payload,
    taskId,
    projectId,
    scheduledFor,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationInboxTableData &&
          other.id == this.id &&
          other.notificationId == this.notificationId &&
          other.type == this.type &&
          other.state == this.state &&
          other.title == this.title &&
          other.body == this.body &&
          other.payload == this.payload &&
          other.taskId == this.taskId &&
          other.projectId == this.projectId &&
          other.scheduledFor == this.scheduledFor &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotificationInboxTableCompanion extends UpdateCompanion<NotificationInboxTableData> {
  final Value<int> id;
  final Value<int> notificationId;
  final Value<NotificationInboxType> type;
  final Value<NotificationInboxState> state;
  final Value<String> title;
  final Value<String?> body;
  final Value<String?> payload;
  final Value<int?> taskId;
  final Value<int?> projectId;
  final Value<DateTime?> scheduledFor;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotificationInboxTableCompanion({
    this.id = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.type = const Value.absent(),
    this.state = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.payload = const Value.absent(),
    this.taskId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotificationInboxTableCompanion.insert({
    this.id = const Value.absent(),
    required int notificationId,
    required NotificationInboxType type,
    required NotificationInboxState state,
    required String title,
    this.body = const Value.absent(),
    this.payload = const Value.absent(),
    this.taskId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : notificationId = Value(notificationId),
       type = Value(type),
       state = Value(state),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NotificationInboxTableData> custom({
    Expression<int>? id,
    Expression<int>? notificationId,
    Expression<int>? type,
    Expression<int>? state,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? payload,
    Expression<int>? taskId,
    Expression<int>? projectId,
    Expression<DateTime>? scheduledFor,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notificationId != null) 'notification_id': notificationId,
      if (type != null) 'type': type,
      if (state != null) 'state': state,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (payload != null) 'payload': payload,
      if (taskId != null) 'task_id': taskId,
      if (projectId != null) 'project_id': projectId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotificationInboxTableCompanion copyWith({
    Value<int>? id,
    Value<int>? notificationId,
    Value<NotificationInboxType>? type,
    Value<NotificationInboxState>? state,
    Value<String>? title,
    Value<String?>? body,
    Value<String?>? payload,
    Value<int?>? taskId,
    Value<int?>? projectId,
    Value<DateTime?>? scheduledFor,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return NotificationInboxTableCompanion(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      type: type ?? this.type,
      state: state ?? this.state,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      taskId: taskId ?? this.taskId,
      projectId: projectId ?? this.projectId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>($NotificationInboxTableTable.$convertertype.toSql(type.value));
    }
    if (state.present) {
      map['state'] = Variable<int>($NotificationInboxTableTable.$converterstate.toSql(state.value));
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationInboxTableCompanion(')
          ..write('id: $id, ')
          ..write('notificationId: $notificationId, ')
          ..write('type: $type, ')
          ..write('state: $state, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payload: $payload, ')
          ..write('taskId: $taskId, ')
          ..write('projectId: $projectId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TagTableTable extends TagTable with TableInfo<$TagTableTable, TagTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, uuid, name, color, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_table';
  @override
  VerificationContext validateIntegrity(Insertable<TagTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(_colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagTableData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      color: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color']),
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TagTableTable createAlias(String alias) {
    return $TagTableTable(attachedDatabase, alias);
  }
}

class TagTableData extends DataClass implements Insertable<TagTableData> {
  final int id;
  final String uuid;
  final String name;

  /// ARGB color value, or null for the theme default.
  final int? color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TagTableData({
    required this.id,
    required this.uuid,
    required this.name,
    this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<int>(color);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TagTableCompanion toCompanion(bool nullToAbsent) {
    return TagTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      name: Value(name),
      color: color == null && nullToAbsent ? const Value.absent() : Value(color),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory TagTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagTableData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int?>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int?>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TagTableData copyWith({
    int? id,
    String? uuid,
    String? name,
    Value<int?> color = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TagTableData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TagTableData copyWithCompanion(TagTableCompanion data) {
    return TagTableData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagTableData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, name, color, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagTableData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.name == this.name &&
          other.color == this.color &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TagTableCompanion extends UpdateCompanion<TagTableData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<String> name;
  final Value<int?> color;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const TagTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TagTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required String name,
    this.color = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TagTableData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<String>? name,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TagTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<String>? name,
    Value<int?>? color,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return TagTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $TaskTagTableTable extends TaskTagTable with TableInfo<$TaskTagTableTable, TaskTagData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTagTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES task_table (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES tag_table (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [taskId, tagId, uuid, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_tag_table';
  @override
  VerificationContext validateIntegrity(Insertable<TaskTagData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(_tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId, tagId};
  @override
  TaskTagData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTagData(
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      tagId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}tag_id'])!,
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TaskTagTableTable createAlias(String alias) {
    return $TaskTagTableTable(attachedDatabase, alias);
  }
}

class TaskTagData extends DataClass implements Insertable<TaskTagData> {
  final int taskId;
  final int tagId;
  final String uuid;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TaskTagData({
    required this.taskId,
    required this.tagId,
    required this.uuid,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<int>(taskId);
    map['tag_id'] = Variable<int>(tagId);
    map['uuid'] = Variable<String>(uuid);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaskTagTableCompanion toCompanion(bool nullToAbsent) {
    return TaskTagTableCompanion(
      taskId: Value(taskId),
      tagId: Value(tagId),
      uuid: Value(uuid),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory TaskTagData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTagData(
      taskId: serializer.fromJson<int>(json['taskId']),
      tagId: serializer.fromJson<int>(json['tagId']),
      uuid: serializer.fromJson<String>(json['uuid']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<int>(taskId),
      'tagId': serializer.toJson<int>(tagId),
      'uuid': serializer.toJson<String>(uuid),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskTagData copyWith({
    int? taskId,
    int? tagId,
    String? uuid,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskTagData(
    taskId: taskId ?? this.taskId,
    tagId: tagId ?? this.tagId,
    uuid: uuid ?? this.uuid,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskTagData copyWithCompanion(TaskTagTableCompanion data) {
    return TaskTagData(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagData(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId, ')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(taskId, tagId, uuid, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTagData &&
          other.taskId == this.taskId &&
          other.tagId == this.tagId &&
          other.uuid == this.uuid &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TaskTagTableCompanion extends UpdateCompanion<TaskTagData> {
  final Value<int> taskId;
  final Value<int> tagId;
  final Value<String> uuid;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TaskTagTableCompanion({
    this.taskId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.uuid = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTagTableCompanion.insert({
    required int taskId,
    required int tagId,
    required String uuid,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       tagId = Value(tagId),
       uuid = Value(uuid),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskTagData> custom({
    Expression<int>? taskId,
    Expression<int>? tagId,
    Expression<String>? uuid,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (tagId != null) 'tag_id': tagId,
      if (uuid != null) 'uuid': uuid,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTagTableCompanion copyWith({
    Value<int>? taskId,
    Value<int>? tagId,
    Value<String>? uuid,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TaskTagTableCompanion(
      taskId: taskId ?? this.taskId,
      tagId: tagId ?? this.tagId,
      uuid: uuid ?? this.uuid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagTableCompanion(')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId, ')
          ..write('uuid: $uuid, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskCompletionTableTable extends TaskCompletionTable
    with TableInfo<$TaskCompletionTableTable, TaskCompletionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskCompletionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'),
  );
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('REFERENCES task_table (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _occurrenceDateMeta = const VerificationMeta('occurrenceDate');
  @override
  late final GeneratedColumn<String> occurrenceDate = GeneratedColumn<String>(
    'occurrence_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uuid,
    taskId,
    occurrenceDate,
    completedAt,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_completion_table';
  @override
  VerificationContext validateIntegrity(Insertable<TaskCompletionTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(_taskIdMeta, taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta));
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('occurrence_date')) {
      context.handle(
        _occurrenceDateMeta,
        occurrenceDate.isAcceptableOrUnknown(data['occurrence_date']!, _occurrenceDateMeta),
      );
    } else if (isInserting) {
      context.missing(_occurrenceDateMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(_completedAtMeta, completedAt.isAcceptableOrUnknown(data['completed_at']!, _completedAtMeta));
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta, createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta, deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskCompletionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskCompletionTableData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      taskId: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}task_id'])!,
      occurrenceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_date'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
      createdAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TaskCompletionTableTable createAlias(String alias) {
    return $TaskCompletionTableTable(attachedDatabase, alias);
  }
}

class TaskCompletionTableData extends DataClass implements Insertable<TaskCompletionTableData> {
  final int id;
  final String uuid;
  final int taskId;

  /// Local calendar date as `YYYY-MM-DD` (date-only, no time component).
  final String occurrenceDate;
  final DateTime completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const TaskCompletionTableData({
    required this.id,
    required this.uuid,
    required this.taskId,
    required this.occurrenceDate,
    required this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uuid'] = Variable<String>(uuid);
    map['task_id'] = Variable<int>(taskId);
    map['occurrence_date'] = Variable<String>(occurrenceDate);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaskCompletionTableCompanion toCompanion(bool nullToAbsent) {
    return TaskCompletionTableCompanion(
      id: Value(id),
      uuid: Value(uuid),
      taskId: Value(taskId),
      occurrenceDate: Value(occurrenceDate),
      completedAt: Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
    );
  }

  factory TaskCompletionTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskCompletionTableData(
      id: serializer.fromJson<int>(json['id']),
      uuid: serializer.fromJson<String>(json['uuid']),
      taskId: serializer.fromJson<int>(json['taskId']),
      occurrenceDate: serializer.fromJson<String>(json['occurrenceDate']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uuid': serializer.toJson<String>(uuid),
      'taskId': serializer.toJson<int>(taskId),
      'occurrenceDate': serializer.toJson<String>(occurrenceDate),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskCompletionTableData copyWith({
    int? id,
    String? uuid,
    int? taskId,
    String? occurrenceDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskCompletionTableData(
    id: id ?? this.id,
    uuid: uuid ?? this.uuid,
    taskId: taskId ?? this.taskId,
    occurrenceDate: occurrenceDate ?? this.occurrenceDate,
    completedAt: completedAt ?? this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskCompletionTableData copyWithCompanion(TaskCompletionTableCompanion data) {
    return TaskCompletionTableData(
      id: data.id.present ? data.id.value : this.id,
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      occurrenceDate: data.occurrenceDate.present ? data.occurrenceDate.value : this.occurrenceDate,
      completedAt: data.completedAt.present ? data.completedAt.value : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompletionTableData(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, uuid, taskId, occurrenceDate, completedAt, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskCompletionTableData &&
          other.id == this.id &&
          other.uuid == this.uuid &&
          other.taskId == this.taskId &&
          other.occurrenceDate == this.occurrenceDate &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TaskCompletionTableCompanion extends UpdateCompanion<TaskCompletionTableData> {
  final Value<int> id;
  final Value<String> uuid;
  final Value<int> taskId;
  final Value<String> occurrenceDate;
  final Value<DateTime> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const TaskCompletionTableCompanion({
    this.id = const Value.absent(),
    this.uuid = const Value.absent(),
    this.taskId = const Value.absent(),
    this.occurrenceDate = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TaskCompletionTableCompanion.insert({
    this.id = const Value.absent(),
    required String uuid,
    required int taskId,
    required String occurrenceDate,
    required DateTime completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : uuid = Value(uuid),
       taskId = Value(taskId),
       occurrenceDate = Value(occurrenceDate),
       completedAt = Value(completedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskCompletionTableData> custom({
    Expression<int>? id,
    Expression<String>? uuid,
    Expression<int>? taskId,
    Expression<String>? occurrenceDate,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uuid != null) 'uuid': uuid,
      if (taskId != null) 'task_id': taskId,
      if (occurrenceDate != null) 'occurrence_date': occurrenceDate,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TaskCompletionTableCompanion copyWith({
    Value<int>? id,
    Value<String>? uuid,
    Value<int>? taskId,
    Value<String>? occurrenceDate,
    Value<DateTime>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return TaskCompletionTableCompanion(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      taskId: taskId ?? this.taskId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (occurrenceDate.present) {
      map['occurrence_date'] = Variable<String>(occurrenceDate.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskCompletionTableCompanion(')
          ..write('id: $id, ')
          ..write('uuid: $uuid, ')
          ..write('taskId: $taskId, ')
          ..write('occurrenceDate: $occurrenceDate, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectTableTable projectTable = $ProjectTableTable(this);
  late final $MilestoneTableTable milestoneTable = $MilestoneTableTable(this);
  late final $TaskTableTable taskTable = $TaskTableTable(this);
  late final $FocusSessionTableTable focusSessionTable = $FocusSessionTableTable(this);
  late final $DailySessionStatsTableTable dailySessionStatsTable = $DailySessionStatsTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $NotificationInboxTableTable notificationInboxTable = $NotificationInboxTableTable(this);
  late final $TagTableTable tagTable = $TagTableTable(this);
  late final $TaskTagTableTable taskTagTable = $TaskTagTableTable(this);
  late final $TaskCompletionTableTable taskCompletionTable = $TaskCompletionTableTable(this);
  late final Index projectCreatedAtIdx = Index(
    'project_created_at_idx',
    'CREATE INDEX project_created_at_idx ON project_table (created_at)',
  );
  late final Index projectUpdatedAtIdx = Index(
    'project_updated_at_idx',
    'CREATE INDEX project_updated_at_idx ON project_table (updated_at)',
  );
  late final Index projectUuidIdx = Index(
    'project_uuid_idx',
    'CREATE UNIQUE INDEX project_uuid_idx ON project_table (uuid)',
  );
  late final Index projectDeletedAtIdx = Index(
    'project_deleted_at_idx',
    'CREATE INDEX project_deleted_at_idx ON project_table (deleted_at)',
  );
  late final Index projectStatusIdx = Index(
    'project_status_idx',
    'CREATE INDEX project_status_idx ON project_table (status)',
  );
  late final Index taskProjectIdIdx = Index(
    'task_project_id_idx',
    'CREATE INDEX task_project_id_idx ON task_table (project_id)',
  );
  late final Index taskParentIdIdx = Index(
    'task_parent_id_idx',
    'CREATE INDEX task_parent_id_idx ON task_table (parent_task_id)',
  );
  late final Index taskPriorityIdx = Index(
    'task_priority_idx',
    'CREATE INDEX task_priority_idx ON task_table (priority)',
  );
  late final Index taskDeadlineIdx = Index(
    'task_deadline_idx',
    'CREATE INDEX task_deadline_idx ON task_table (end_date)',
  );
  late final Index taskCompletedIdx = Index(
    'task_completed_idx',
    'CREATE INDEX task_completed_idx ON task_table (is_completed)',
  );
  late final Index taskStatusIdx = Index('task_status_idx', 'CREATE INDEX task_status_idx ON task_table (status)');
  late final Index taskSortOrderIdx = Index(
    'task_sort_order_idx',
    'CREATE INDEX task_sort_order_idx ON task_table (sort_order)',
  );
  late final Index taskMilestoneIdIdx = Index(
    'task_milestone_id_idx',
    'CREATE INDEX task_milestone_id_idx ON task_table (milestone_id)',
  );
  late final Index taskUpdatedAtIdx = Index(
    'task_updated_at_idx',
    'CREATE INDEX task_updated_at_idx ON task_table (updated_at)',
  );
  late final Index taskUuidIdx = Index('task_uuid_idx', 'CREATE UNIQUE INDEX task_uuid_idx ON task_table (uuid)');
  late final Index taskDeletedAtIdx = Index(
    'task_deleted_at_idx',
    'CREATE INDEX task_deleted_at_idx ON task_table (deleted_at)',
  );
  late final Index focusSessionTaskIdIdx = Index(
    'focus_session_task_id_idx',
    'CREATE INDEX focus_session_task_id_idx ON focus_session_table (task_id)',
  );
  late final Index focusSessionStartTimeIdx = Index(
    'focus_session_start_time_idx',
    'CREATE INDEX focus_session_start_time_idx ON focus_session_table (start_time)',
  );
  late final Index focusSessionUuidIdx = Index(
    'focus_session_uuid_idx',
    'CREATE UNIQUE INDEX focus_session_uuid_idx ON focus_session_table (uuid)',
  );
  late final Index focusSessionDeletedAtIdx = Index(
    'focus_session_deleted_at_idx',
    'CREATE INDEX focus_session_deleted_at_idx ON focus_session_table (deleted_at)',
  );
  late final Index dailyStatsDateIdx = Index(
    'daily_stats_date_idx',
    'CREATE INDEX daily_stats_date_idx ON daily_session_stats_table (date)',
  );
  late final Index notificationInboxNotificationIdIdx = Index(
    'notification_inbox_notification_id_idx',
    'CREATE INDEX notification_inbox_notification_id_idx ON notification_inbox_table (notification_id)',
  );
  late final Index notificationInboxUpdatedAtIdx = Index(
    'notification_inbox_updated_at_idx',
    'CREATE INDEX notification_inbox_updated_at_idx ON notification_inbox_table (updated_at)',
  );
  late final Index notificationInboxScheduledForIdx = Index(
    'notification_inbox_scheduled_for_idx',
    'CREATE INDEX notification_inbox_scheduled_for_idx ON notification_inbox_table (scheduled_for)',
  );
  late final Index tagUuidIdx = Index('tag_uuid_idx', 'CREATE UNIQUE INDEX tag_uuid_idx ON tag_table (uuid)');
  late final Index tagDeletedAtIdx = Index(
    'tag_deleted_at_idx',
    'CREATE INDEX tag_deleted_at_idx ON tag_table (deleted_at)',
  );
  late final Index tagNameIdx = Index('tag_name_idx', 'CREATE INDEX tag_name_idx ON tag_table (name)');
  late final Index taskTagUuidIdx = Index(
    'task_tag_uuid_idx',
    'CREATE UNIQUE INDEX task_tag_uuid_idx ON task_tag_table (uuid)',
  );
  late final Index taskTagDeletedAtIdx = Index(
    'task_tag_deleted_at_idx',
    'CREATE INDEX task_tag_deleted_at_idx ON task_tag_table (deleted_at)',
  );
  late final Index milestoneUuidIdx = Index(
    'milestone_uuid_idx',
    'CREATE UNIQUE INDEX milestone_uuid_idx ON milestone_table (uuid)',
  );
  late final Index milestoneProjectIdIdx = Index(
    'milestone_project_id_idx',
    'CREATE INDEX milestone_project_id_idx ON milestone_table (project_id)',
  );
  late final Index milestoneDeletedAtIdx = Index(
    'milestone_deleted_at_idx',
    'CREATE INDEX milestone_deleted_at_idx ON milestone_table (deleted_at)',
  );
  late final Index taskCompletionUuidIdx = Index(
    'task_completion_uuid_idx',
    'CREATE UNIQUE INDEX task_completion_uuid_idx ON task_completion_table (uuid)',
  );
  late final Index taskCompletionTaskIdIdx = Index(
    'task_completion_task_id_idx',
    'CREATE INDEX task_completion_task_id_idx ON task_completion_table (task_id)',
  );
  late final Index taskCompletionOccurrenceDateIdx = Index(
    'task_completion_occurrence_date_idx',
    'CREATE INDEX task_completion_occurrence_date_idx ON task_completion_table (occurrence_date)',
  );
  late final Index taskCompletionDeletedAtIdx = Index(
    'task_completion_deleted_at_idx',
    'CREATE INDEX task_completion_deleted_at_idx ON task_completion_table (deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projectTable,
    milestoneTable,
    taskTable,
    focusSessionTable,
    dailySessionStatsTable,
    settingsTable,
    notificationInboxTable,
    tagTable,
    taskTagTable,
    taskCompletionTable,
    projectCreatedAtIdx,
    projectUpdatedAtIdx,
    projectUuidIdx,
    projectDeletedAtIdx,
    projectStatusIdx,
    taskProjectIdIdx,
    taskParentIdIdx,
    taskPriorityIdx,
    taskDeadlineIdx,
    taskCompletedIdx,
    taskStatusIdx,
    taskSortOrderIdx,
    taskMilestoneIdIdx,
    taskUpdatedAtIdx,
    taskUuidIdx,
    taskDeletedAtIdx,
    focusSessionTaskIdIdx,
    focusSessionStartTimeIdx,
    focusSessionUuidIdx,
    focusSessionDeletedAtIdx,
    dailyStatsDateIdx,
    notificationInboxNotificationIdIdx,
    notificationInboxUpdatedAtIdx,
    notificationInboxScheduledForIdx,
    tagUuidIdx,
    tagDeletedAtIdx,
    tagNameIdx,
    taskTagUuidIdx,
    taskTagDeletedAtIdx,
    milestoneUuidIdx,
    milestoneProjectIdIdx,
    milestoneDeletedAtIdx,
    taskCompletionUuidIdx,
    taskCompletionTaskIdIdx,
    taskCompletionOccurrenceDateIdx,
    taskCompletionDeletedAtIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName('project_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('milestone_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('project_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('task_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('task_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('task_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('milestone_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('task_table', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('task_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('focus_session_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('task_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('task_tag_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('tag_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('task_tag_table', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName('task_table', limitUpdateKind: UpdateKind.delete),
      result: [TableUpdate('task_completion_table', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProjectTableTableCreateCompanionBuilder =
    ProjectTableCompanion Function({
      Value<int> id,
      required String uuid,
      required String title,
      Value<String?> description,
      Value<ProjectStatus> status,
      Value<int?> color,
      Value<DateTime?> startDate,
      Value<DateTime?> deadline,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$ProjectTableTableUpdateCompanionBuilder =
    ProjectTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> title,
      Value<String?> description,
      Value<ProjectStatus> status,
      Value<int?> color,
      Value<DateTime?> startDate,
      Value<DateTime?> deadline,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$ProjectTableTableReferences extends BaseReferences<_$AppDatabase, $ProjectTableTable, ProjectTableData> {
  $$ProjectTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MilestoneTableTable, List<MilestoneTableData>> _milestoneTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.milestoneTable, aliasName: 'project_table__id__milestone_table__project_id');

  $$MilestoneTableTableProcessedTableManager get milestoneTableRefs {
    final manager = $$MilestoneTableTableTableManager(
      $_db,
      $_db.milestoneTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_milestoneTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TaskTableTable, List<TaskTableData>> _taskTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.taskTable, aliasName: 'project_table__id__task_table__project_id');

  $$TaskTableTableProcessedTableManager get taskTableRefs {
    final manager = $$TaskTableTableTableManager(
      $_db,
      $_db.taskTable,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProjectTableTableFilterComposer extends Composer<_$AppDatabase, $ProjectTableTable> {
  $$ProjectTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ProjectStatus, ProjectStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> milestoneTableRefs(Expression<bool> Function($$MilestoneTableTableFilterComposer f) f) {
    final $$MilestoneTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestoneTable,
      getReferencedColumn: (t) => t.projectId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MilestoneTableTableFilterComposer(
            $db: $db,
            $table: $db.milestoneTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskTableRefs(Expression<bool> Function($$TaskTableTableFilterComposer f) f) {
    final $$TaskTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.projectId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectTableTableOrderingComposer extends Composer<_$AppDatabase, $ProjectTableTable> {
  $$ProjectTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProjectTableTableAnnotationComposer extends Composer<_$AppDatabase, $ProjectTableTable> {
  $$ProjectTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ProjectStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline => $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> milestoneTableRefs<T extends Object>(
    Expression<T> Function($$MilestoneTableTableAnnotationComposer a) f,
  ) {
    final $$MilestoneTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestoneTable,
      getReferencedColumn: (t) => t.projectId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MilestoneTableTableAnnotationComposer(
            $db: $db,
            $table: $db.milestoneTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskTableRefs<T extends Object>(Expression<T> Function($$TaskTableTableAnnotationComposer a) f) {
    final $$TaskTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.projectId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectTableTable,
          ProjectTableData,
          $$ProjectTableTableFilterComposer,
          $$ProjectTableTableOrderingComposer,
          $$ProjectTableTableAnnotationComposer,
          $$ProjectTableTableCreateCompanionBuilder,
          $$ProjectTableTableUpdateCompanionBuilder,
          (ProjectTableData, $$ProjectTableTableReferences),
          ProjectTableData,
          PrefetchHooks Function({bool milestoneTableRefs, bool taskTableRefs})
        > {
  $$ProjectTableTableTableManager(_$AppDatabase db, $ProjectTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProjectTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProjectTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$ProjectTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<ProjectStatus> status = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProjectTableCompanion(
                id: id,
                uuid: uuid,
                title: title,
                description: description,
                status: status,
                color: color,
                startDate: startDate,
                deadline: deadline,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<ProjectStatus> status = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ProjectTableCompanion.insert(
                id: id,
                uuid: uuid,
                title: title,
                description: description,
                status: status,
                color: color,
                startDate: startDate,
                deadline: deadline,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$ProjectTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({milestoneTableRefs = false, taskTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (milestoneTableRefs) db.milestoneTable, if (taskTableRefs) db.taskTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (milestoneTableRefs)
                    await $_getPrefetchedData<ProjectTableData, $ProjectTableTable, MilestoneTableData>(
                      currentTable: table,
                      referencedTable: $$ProjectTableTableReferences._milestoneTableRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProjectTableTableReferences(db, table, p0).milestoneTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                  if (taskTableRefs)
                    await $_getPrefetchedData<ProjectTableData, $ProjectTableTable, TaskTableData>(
                      currentTable: table,
                      referencedTable: $$ProjectTableTableReferences._taskTableRefsTable(db),
                      managerFromTypedResult: (p0) => $$ProjectTableTableReferences(db, table, p0).taskTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectTableTable,
      ProjectTableData,
      $$ProjectTableTableFilterComposer,
      $$ProjectTableTableOrderingComposer,
      $$ProjectTableTableAnnotationComposer,
      $$ProjectTableTableCreateCompanionBuilder,
      $$ProjectTableTableUpdateCompanionBuilder,
      (ProjectTableData, $$ProjectTableTableReferences),
      ProjectTableData,
      PrefetchHooks Function({bool milestoneTableRefs, bool taskTableRefs})
    >;
typedef $$MilestoneTableTableCreateCompanionBuilder =
    MilestoneTableCompanion Function({
      Value<int> id,
      required String uuid,
      required int projectId,
      required String title,
      Value<DateTime?> targetDate,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$MilestoneTableTableUpdateCompanionBuilder =
    MilestoneTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int> projectId,
      Value<String> title,
      Value<DateTime?> targetDate,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$MilestoneTableTableReferences
    extends BaseReferences<_$AppDatabase, $MilestoneTableTable, MilestoneTableData> {
  $$MilestoneTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectTable.createAlias('milestone_table__project_id__project_table__id');

  $$ProjectTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectTableTableTableManager($_db, $_db.projectTable).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TaskTableTable, List<TaskTableData>> _taskTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.taskTable, aliasName: 'milestone_table__id__task_table__milestone_id');

  $$TaskTableTableProcessedTableManager get taskTableRefs {
    final manager = $$TaskTableTableTableManager(
      $_db,
      $_db.taskTable,
    ).filter((f) => f.milestoneId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MilestoneTableTableFilterComposer extends Composer<_$AppDatabase, $MilestoneTableTable> {
  $$MilestoneTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$ProjectTableTableFilterComposer get projectId {
    final $$ProjectTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProjectTableTableFilterComposer(
            $db: $db,
            $table: $db.projectTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> taskTableRefs(Expression<bool> Function($$TaskTableTableFilterComposer f) f) {
    final $$TaskTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.milestoneId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilestoneTableTableOrderingComposer extends Composer<_$AppDatabase, $MilestoneTableTable> {
  $$MilestoneTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectTableTableOrderingComposer get projectId {
    final $$ProjectTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProjectTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestoneTableTableAnnotationComposer extends Composer<_$AppDatabase, $MilestoneTableTable> {
  $$MilestoneTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate =>
      $composableBuilder(column: $table.targetDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProjectTableTableAnnotationComposer get projectId {
    final $$ProjectTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProjectTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> taskTableRefs<T extends Object>(Expression<T> Function($$TaskTableTableAnnotationComposer a) f) {
    final $$TaskTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.milestoneId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MilestoneTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestoneTableTable,
          MilestoneTableData,
          $$MilestoneTableTableFilterComposer,
          $$MilestoneTableTableOrderingComposer,
          $$MilestoneTableTableAnnotationComposer,
          $$MilestoneTableTableCreateCompanionBuilder,
          $$MilestoneTableTableUpdateCompanionBuilder,
          (MilestoneTableData, $$MilestoneTableTableReferences),
          MilestoneTableData,
          PrefetchHooks Function({bool projectId, bool taskTableRefs})
        > {
  $$MilestoneTableTableTableManager(_$AppDatabase db, $MilestoneTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MilestoneTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MilestoneTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MilestoneTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => MilestoneTableCompanion(
                id: id,
                uuid: uuid,
                projectId: projectId,
                title: title,
                targetDate: targetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required int projectId,
                required String title,
                Value<DateTime?> targetDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => MilestoneTableCompanion.insert(
                id: id,
                uuid: uuid,
                projectId: projectId,
                title: title,
                targetDate: targetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$MilestoneTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({projectId = false, taskTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskTableRefs) db.taskTable],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$MilestoneTableTableReferences._projectIdTable(db),
                                referencedColumn: $$MilestoneTableTableReferences._projectIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskTableRefs)
                    await $_getPrefetchedData<MilestoneTableData, $MilestoneTableTable, TaskTableData>(
                      currentTable: table,
                      referencedTable: $$MilestoneTableTableReferences._taskTableRefsTable(db),
                      managerFromTypedResult: (p0) => $$MilestoneTableTableReferences(db, table, p0).taskTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.milestoneId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MilestoneTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestoneTableTable,
      MilestoneTableData,
      $$MilestoneTableTableFilterComposer,
      $$MilestoneTableTableOrderingComposer,
      $$MilestoneTableTableAnnotationComposer,
      $$MilestoneTableTableCreateCompanionBuilder,
      $$MilestoneTableTableUpdateCompanionBuilder,
      (MilestoneTableData, $$MilestoneTableTableReferences),
      MilestoneTableData,
      PrefetchHooks Function({bool projectId, bool taskTableRefs})
    >;
typedef $$TaskTableTableCreateCompanionBuilder =
    TaskTableCompanion Function({
      Value<int> id,
      required String uuid,
      required int projectId,
      Value<int?> parentTaskId,
      required String title,
      Value<String?> description,
      required TaskPriority priority,
      Value<TaskStatus> status,
      Value<TaskReminderMode> reminderMode,
      Value<int?> customReminderMinutesBefore,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      required int depth,
      Value<int?> estimatedMinutes,
      Value<double> sortOrder,
      Value<int?> milestoneId,
      Value<String?> recurrenceRule,
      Value<DateTime?> recurrenceAnchorDate,
      Value<bool> isHabit,
      Value<bool> isCompleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$TaskTableTableUpdateCompanionBuilder =
    TaskTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int> projectId,
      Value<int?> parentTaskId,
      Value<String> title,
      Value<String?> description,
      Value<TaskPriority> priority,
      Value<TaskStatus> status,
      Value<TaskReminderMode> reminderMode,
      Value<int?> customReminderMinutesBefore,
      Value<DateTime?> startDate,
      Value<DateTime?> endDate,
      Value<int> depth,
      Value<int?> estimatedMinutes,
      Value<double> sortOrder,
      Value<int?> milestoneId,
      Value<String?> recurrenceRule,
      Value<DateTime?> recurrenceAnchorDate,
      Value<bool> isHabit,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$TaskTableTableReferences extends BaseReferences<_$AppDatabase, $TaskTableTable, TaskTableData> {
  $$TaskTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectTableTable _projectIdTable(_$AppDatabase db) =>
      db.projectTable.createAlias('task_table__project_id__project_table__id');

  $$ProjectTableTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectTableTableTableManager($_db, $_db.projectTable).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TaskTableTable _parentTaskIdTable(_$AppDatabase db) =>
      db.taskTable.createAlias('task_table__parent_task_id__task_table__id');

  $$TaskTableTableProcessedTableManager? get parentTaskId {
    final $_column = $_itemColumn<int>('parent_task_id');
    if ($_column == null) return null;
    final manager = $$TaskTableTableTableManager($_db, $_db.taskTable).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentTaskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $MilestoneTableTable _milestoneIdTable(_$AppDatabase db) =>
      db.milestoneTable.createAlias('task_table__milestone_id__milestone_table__id');

  $$MilestoneTableTableProcessedTableManager? get milestoneId {
    final $_column = $_itemColumn<int>('milestone_id');
    if ($_column == null) return null;
    final manager = $$MilestoneTableTableTableManager(
      $_db,
      $_db.milestoneTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_milestoneIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$FocusSessionTableTable, List<FocusSessionData>> _focusSessionTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(db.focusSessionTable, aliasName: 'task_table__id__focus_session_table__task_id');

  $$FocusSessionTableTableProcessedTableManager get focusSessionTableRefs {
    final manager = $$FocusSessionTableTableTableManager(
      $_db,
      $_db.focusSessionTable,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_focusSessionTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TaskTagTableTable, List<TaskTagData>> _taskTagTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.taskTagTable, aliasName: 'task_table__id__task_tag_table__task_id');

  $$TaskTagTableTableProcessedTableManager get taskTagTableRefs {
    final manager = $$TaskTagTableTableTableManager(
      $_db,
      $_db.taskTagTable,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTagTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$TaskCompletionTableTable, List<TaskCompletionTableData>> _taskCompletionTableRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.taskCompletionTable,
    aliasName: 'task_table__id__task_completion_table__task_id',
  );

  $$TaskCompletionTableTableProcessedTableManager get taskCompletionTableRefs {
    final manager = $$TaskCompletionTableTableTableManager(
      $_db,
      $_db.taskCompletionTable,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskCompletionTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TaskTableTableFilterComposer extends Composer<_$AppDatabase, $TaskTableTable> {
  $$TaskTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<TaskPriority, TaskPriority, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TaskStatus, TaskStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<TaskReminderMode, TaskReminderMode, int> get reminderMode =>
      $composableBuilder(column: $table.reminderMode, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get customReminderMinutesBefore =>
      $composableBuilder(column: $table.customReminderMinutesBefore, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get depth => $composableBuilder(column: $table.depth, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedMinutes =>
      $composableBuilder(column: $table.estimatedMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurrenceRule =>
      $composableBuilder(column: $table.recurrenceRule, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recurrenceAnchorDate =>
      $composableBuilder(column: $table.recurrenceAnchorDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isHabit =>
      $composableBuilder(column: $table.isHabit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted =>
      $composableBuilder(column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$ProjectTableTableFilterComposer get projectId {
    final $$ProjectTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProjectTableTableFilterComposer(
            $db: $db,
            $table: $db.projectTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TaskTableTableFilterComposer get parentTaskId {
    final $$TaskTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTaskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MilestoneTableTableFilterComposer get milestoneId {
    final $$MilestoneTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestoneTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MilestoneTableTableFilterComposer(
            $db: $db,
            $table: $db.milestoneTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> focusSessionTableRefs(Expression<bool> Function($$FocusSessionTableTableFilterComposer f) f) {
    final $$FocusSessionTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessionTable,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionTableTableFilterComposer(
            $db: $db,
            $table: $db.focusSessionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskTagTableRefs(Expression<bool> Function($$TaskTagTableTableFilterComposer f) f) {
    final $$TaskTagTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTagTable,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTagTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTagTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskCompletionTableRefs(Expression<bool> Function($$TaskCompletionTableTableFilterComposer f) f) {
    final $$TaskCompletionTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskCompletionTable,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskCompletionTableTableFilterComposer(
            $db: $db,
            $table: $db.taskCompletionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskTableTableOrderingComposer extends Composer<_$AppDatabase, $TaskTableTable> {
  $$TaskTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reminderMode =>
      $composableBuilder(column: $table.reminderMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customReminderMinutesBefore =>
      $composableBuilder(column: $table.customReminderMinutesBefore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get depth =>
      $composableBuilder(column: $table.depth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedMinutes =>
      $composableBuilder(column: $table.estimatedMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurrenceRule =>
      $composableBuilder(column: $table.recurrenceRule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recurrenceAnchorDate =>
      $composableBuilder(column: $table.recurrenceAnchorDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isHabit =>
      $composableBuilder(column: $table.isHabit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted =>
      $composableBuilder(column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$ProjectTableTableOrderingComposer get projectId {
    final $$ProjectTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProjectTableTableOrderingComposer(
            $db: $db,
            $table: $db.projectTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TaskTableTableOrderingComposer get parentTaskId {
    final $$TaskTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTaskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableOrderingComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MilestoneTableTableOrderingComposer get milestoneId {
    final $$MilestoneTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestoneTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MilestoneTableTableOrderingComposer(
            $db: $db,
            $table: $db.milestoneTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskTableTableAnnotationComposer extends Composer<_$AppDatabase, $TaskTableTable> {
  $$TaskTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description =>
      $composableBuilder(column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskPriority, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskReminderMode, int> get reminderMode =>
      $composableBuilder(column: $table.reminderMode, builder: (column) => column);

  GeneratedColumn<int> get customReminderMinutesBefore =>
      $composableBuilder(column: $table.customReminderMinutesBefore, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate => $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate => $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get depth => $composableBuilder(column: $table.depth, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes =>
      $composableBuilder(column: $table.estimatedMinutes, builder: (column) => column);

  GeneratedColumn<double> get sortOrder => $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get recurrenceRule =>
      $composableBuilder(column: $table.recurrenceRule, builder: (column) => column);

  GeneratedColumn<DateTime> get recurrenceAnchorDate =>
      $composableBuilder(column: $table.recurrenceAnchorDate, builder: (column) => column);

  GeneratedColumn<bool> get isHabit => $composableBuilder(column: $table.isHabit, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$ProjectTableTableAnnotationComposer get projectId {
    final $$ProjectTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projectTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$ProjectTableTableAnnotationComposer(
            $db: $db,
            $table: $db.projectTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TaskTableTableAnnotationComposer get parentTaskId {
    final $$TaskTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentTaskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MilestoneTableTableAnnotationComposer get milestoneId {
    final $$MilestoneTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.milestoneId,
      referencedTable: $db.milestoneTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$MilestoneTableTableAnnotationComposer(
            $db: $db,
            $table: $db.milestoneTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> focusSessionTableRefs<T extends Object>(
    Expression<T> Function($$FocusSessionTableTableAnnotationComposer a) f,
  ) {
    final $$FocusSessionTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.focusSessionTable,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$FocusSessionTableTableAnnotationComposer(
            $db: $db,
            $table: $db.focusSessionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskTagTableRefs<T extends Object>(Expression<T> Function($$TaskTagTableTableAnnotationComposer a) f) {
    final $$TaskTagTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTagTable,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTagTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTagTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskCompletionTableRefs<T extends Object>(
    Expression<T> Function($$TaskCompletionTableTableAnnotationComposer a) f,
  ) {
    final $$TaskCompletionTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskCompletionTable,
      getReferencedColumn: (t) => t.taskId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskCompletionTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskCompletionTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TaskTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskTableTable,
          TaskTableData,
          $$TaskTableTableFilterComposer,
          $$TaskTableTableOrderingComposer,
          $$TaskTableTableAnnotationComposer,
          $$TaskTableTableCreateCompanionBuilder,
          $$TaskTableTableUpdateCompanionBuilder,
          (TaskTableData, $$TaskTableTableReferences),
          TaskTableData,
          PrefetchHooks Function({
            bool projectId,
            bool parentTaskId,
            bool milestoneId,
            bool focusSessionTableRefs,
            bool taskTagTableRefs,
            bool taskCompletionTableRefs,
          })
        > {
  $$TaskTableTableTableManager(_$AppDatabase db, $TaskTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TaskTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TaskTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TaskTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<int?> parentTaskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<TaskPriority> priority = const Value.absent(),
                Value<TaskStatus> status = const Value.absent(),
                Value<TaskReminderMode> reminderMode = const Value.absent(),
                Value<int?> customReminderMinutesBefore = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> depth = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<int?> milestoneId = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<DateTime?> recurrenceAnchorDate = const Value.absent(),
                Value<bool> isHabit = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TaskTableCompanion(
                id: id,
                uuid: uuid,
                projectId: projectId,
                parentTaskId: parentTaskId,
                title: title,
                description: description,
                priority: priority,
                status: status,
                reminderMode: reminderMode,
                customReminderMinutesBefore: customReminderMinutesBefore,
                startDate: startDate,
                endDate: endDate,
                depth: depth,
                estimatedMinutes: estimatedMinutes,
                sortOrder: sortOrder,
                milestoneId: milestoneId,
                recurrenceRule: recurrenceRule,
                recurrenceAnchorDate: recurrenceAnchorDate,
                isHabit: isHabit,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required int projectId,
                Value<int?> parentTaskId = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required TaskPriority priority,
                Value<TaskStatus> status = const Value.absent(),
                Value<TaskReminderMode> reminderMode = const Value.absent(),
                Value<int?> customReminderMinutesBefore = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                required int depth,
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<double> sortOrder = const Value.absent(),
                Value<int?> milestoneId = const Value.absent(),
                Value<String?> recurrenceRule = const Value.absent(),
                Value<DateTime?> recurrenceAnchorDate = const Value.absent(),
                Value<bool> isHabit = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TaskTableCompanion.insert(
                id: id,
                uuid: uuid,
                projectId: projectId,
                parentTaskId: parentTaskId,
                title: title,
                description: description,
                priority: priority,
                status: status,
                reminderMode: reminderMode,
                customReminderMinutesBefore: customReminderMinutesBefore,
                startDate: startDate,
                endDate: endDate,
                depth: depth,
                estimatedMinutes: estimatedMinutes,
                sortOrder: sortOrder,
                milestoneId: milestoneId,
                recurrenceRule: recurrenceRule,
                recurrenceAnchorDate: recurrenceAnchorDate,
                isHabit: isHabit,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$TaskTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback:
              ({
                projectId = false,
                parentTaskId = false,
                milestoneId = false,
                focusSessionTableRefs = false,
                taskTagTableRefs = false,
                taskCompletionTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (focusSessionTableRefs) db.focusSessionTable,
                    if (taskTagTableRefs) db.taskTagTable,
                    if (taskCompletionTableRefs) db.taskCompletionTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (projectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.projectId,
                                    referencedTable: $$TaskTableTableReferences._projectIdTable(db),
                                    referencedColumn: $$TaskTableTableReferences._projectIdTable(db).id,
                                  )
                                  as T;
                        }
                        if (parentTaskId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentTaskId,
                                    referencedTable: $$TaskTableTableReferences._parentTaskIdTable(db),
                                    referencedColumn: $$TaskTableTableReferences._parentTaskIdTable(db).id,
                                  )
                                  as T;
                        }
                        if (milestoneId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.milestoneId,
                                    referencedTable: $$TaskTableTableReferences._milestoneIdTable(db),
                                    referencedColumn: $$TaskTableTableReferences._milestoneIdTable(db).id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (focusSessionTableRefs)
                        await $_getPrefetchedData<TaskTableData, $TaskTableTable, FocusSessionData>(
                          currentTable: table,
                          referencedTable: $$TaskTableTableReferences._focusSessionTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TaskTableTableReferences(db, table, p0).focusSessionTableRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.taskId == item.id),
                          typedResults: items,
                        ),
                      if (taskTagTableRefs)
                        await $_getPrefetchedData<TaskTableData, $TaskTableTable, TaskTagData>(
                          currentTable: table,
                          referencedTable: $$TaskTableTableReferences._taskTagTableRefsTable(db),
                          managerFromTypedResult: (p0) => $$TaskTableTableReferences(db, table, p0).taskTagTableRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.taskId == item.id),
                          typedResults: items,
                        ),
                      if (taskCompletionTableRefs)
                        await $_getPrefetchedData<TaskTableData, $TaskTableTable, TaskCompletionTableData>(
                          currentTable: table,
                          referencedTable: $$TaskTableTableReferences._taskCompletionTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TaskTableTableReferences(db, table, p0).taskCompletionTableRefs,
                          referencedItemsForCurrentItem: (item, referencedItems) =>
                              referencedItems.where((e) => e.taskId == item.id),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TaskTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskTableTable,
      TaskTableData,
      $$TaskTableTableFilterComposer,
      $$TaskTableTableOrderingComposer,
      $$TaskTableTableAnnotationComposer,
      $$TaskTableTableCreateCompanionBuilder,
      $$TaskTableTableUpdateCompanionBuilder,
      (TaskTableData, $$TaskTableTableReferences),
      TaskTableData,
      PrefetchHooks Function({
        bool projectId,
        bool parentTaskId,
        bool milestoneId,
        bool focusSessionTableRefs,
        bool taskTagTableRefs,
        bool taskCompletionTableRefs,
      })
    >;
typedef $$FocusSessionTableTableCreateCompanionBuilder =
    FocusSessionTableCompanion Function({
      Value<int> id,
      required String uuid,
      Value<int?> taskId,
      required int focusDurationMinutes,
      required int breakDurationMinutes,
      required DateTime startTime,
      Value<DateTime?> endTime,
      required SessionState state,
      Value<int> elapsedSeconds,
      Value<int?> focusPhaseEndedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$FocusSessionTableTableUpdateCompanionBuilder =
    FocusSessionTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int?> taskId,
      Value<int> focusDurationMinutes,
      Value<int> breakDurationMinutes,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<SessionState> state,
      Value<int> elapsedSeconds,
      Value<int?> focusPhaseEndedAt,
      Value<DateTime?> deletedAt,
    });

final class $$FocusSessionTableTableReferences
    extends BaseReferences<_$AppDatabase, $FocusSessionTableTable, FocusSessionData> {
  $$FocusSessionTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskTableTable _taskIdTable(_$AppDatabase db) =>
      db.taskTable.createAlias('focus_session_table__task_id__task_table__id');

  $$TaskTableTableProcessedTableManager? get taskId {
    final $_column = $_itemColumn<int>('task_id');
    if ($_column == null) return null;
    final manager = $$TaskTableTableTableManager($_db, $_db.taskTable).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FocusSessionTableTableFilterComposer extends Composer<_$AppDatabase, $FocusSessionTableTable> {
  $$FocusSessionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusDurationMinutes =>
      $composableBuilder(column: $table.focusDurationMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get breakDurationMinutes =>
      $composableBuilder(column: $table.breakDurationMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<SessionState, SessionState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get elapsedSeconds =>
      $composableBuilder(column: $table.elapsedSeconds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusPhaseEndedAt =>
      $composableBuilder(column: $table.focusPhaseEndedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$TaskTableTableFilterComposer get taskId {
    final $$TaskTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionTableTableOrderingComposer extends Composer<_$AppDatabase, $FocusSessionTableTable> {
  $$FocusSessionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusDurationMinutes =>
      $composableBuilder(column: $table.focusDurationMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get breakDurationMinutes =>
      $composableBuilder(column: $table.breakDurationMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedSeconds =>
      $composableBuilder(column: $table.elapsedSeconds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusPhaseEndedAt =>
      $composableBuilder(column: $table.focusPhaseEndedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$TaskTableTableOrderingComposer get taskId {
    final $$TaskTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableOrderingComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionTableTableAnnotationComposer extends Composer<_$AppDatabase, $FocusSessionTableTable> {
  $$FocusSessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<int> get focusDurationMinutes =>
      $composableBuilder(column: $table.focusDurationMinutes, builder: (column) => column);

  GeneratedColumn<int> get breakDurationMinutes =>
      $composableBuilder(column: $table.breakDurationMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime => $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime => $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SessionState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get elapsedSeconds =>
      $composableBuilder(column: $table.elapsedSeconds, builder: (column) => column);

  GeneratedColumn<int> get focusPhaseEndedAt =>
      $composableBuilder(column: $table.focusPhaseEndedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TaskTableTableAnnotationComposer get taskId {
    final $$TaskTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FocusSessionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionTableTable,
          FocusSessionData,
          $$FocusSessionTableTableFilterComposer,
          $$FocusSessionTableTableOrderingComposer,
          $$FocusSessionTableTableAnnotationComposer,
          $$FocusSessionTableTableCreateCompanionBuilder,
          $$FocusSessionTableTableUpdateCompanionBuilder,
          (FocusSessionData, $$FocusSessionTableTableReferences),
          FocusSessionData,
          PrefetchHooks Function({bool taskId})
        > {
  $$FocusSessionTableTableTableManager(_$AppDatabase db, $FocusSessionTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FocusSessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FocusSessionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FocusSessionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<int> focusDurationMinutes = const Value.absent(),
                Value<int> breakDurationMinutes = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<SessionState> state = const Value.absent(),
                Value<int> elapsedSeconds = const Value.absent(),
                Value<int?> focusPhaseEndedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => FocusSessionTableCompanion(
                id: id,
                uuid: uuid,
                taskId: taskId,
                focusDurationMinutes: focusDurationMinutes,
                breakDurationMinutes: breakDurationMinutes,
                startTime: startTime,
                endTime: endTime,
                state: state,
                elapsedSeconds: elapsedSeconds,
                focusPhaseEndedAt: focusPhaseEndedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                Value<int?> taskId = const Value.absent(),
                required int focusDurationMinutes,
                required int breakDurationMinutes,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                required SessionState state,
                Value<int> elapsedSeconds = const Value.absent(),
                Value<int?> focusPhaseEndedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => FocusSessionTableCompanion.insert(
                id: id,
                uuid: uuid,
                taskId: taskId,
                focusDurationMinutes: focusDurationMinutes,
                breakDurationMinutes: breakDurationMinutes,
                startTime: startTime,
                endTime: endTime,
                state: state,
                elapsedSeconds: elapsedSeconds,
                focusPhaseEndedAt: focusPhaseEndedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$FocusSessionTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$FocusSessionTableTableReferences._taskIdTable(db),
                                referencedColumn: $$FocusSessionTableTableReferences._taskIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FocusSessionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionTableTable,
      FocusSessionData,
      $$FocusSessionTableTableFilterComposer,
      $$FocusSessionTableTableOrderingComposer,
      $$FocusSessionTableTableAnnotationComposer,
      $$FocusSessionTableTableCreateCompanionBuilder,
      $$FocusSessionTableTableUpdateCompanionBuilder,
      (FocusSessionData, $$FocusSessionTableTableReferences),
      FocusSessionData,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$DailySessionStatsTableTableCreateCompanionBuilder =
    DailySessionStatsTableCompanion Function({
      required String date,
      Value<int> completedSessions,
      Value<int> totalSessions,
      Value<int> focusSeconds,
      Value<int> rowid,
    });
typedef $$DailySessionStatsTableTableUpdateCompanionBuilder =
    DailySessionStatsTableCompanion Function({
      Value<String> date,
      Value<int> completedSessions,
      Value<int> totalSessions,
      Value<int> focusSeconds,
      Value<int> rowid,
    });

class $$DailySessionStatsTableTableFilterComposer extends Composer<_$AppDatabase, $DailySessionStatsTableTable> {
  $$DailySessionStatsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedSessions =>
      $composableBuilder(column: $table.completedSessions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalSessions =>
      $composableBuilder(column: $table.totalSessions, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusSeconds =>
      $composableBuilder(column: $table.focusSeconds, builder: (column) => ColumnFilters(column));
}

class $$DailySessionStatsTableTableOrderingComposer extends Composer<_$AppDatabase, $DailySessionStatsTableTable> {
  $$DailySessionStatsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedSessions =>
      $composableBuilder(column: $table.completedSessions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSessions =>
      $composableBuilder(column: $table.totalSessions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusSeconds =>
      $composableBuilder(column: $table.focusSeconds, builder: (column) => ColumnOrderings(column));
}

class $$DailySessionStatsTableTableAnnotationComposer extends Composer<_$AppDatabase, $DailySessionStatsTableTable> {
  $$DailySessionStatsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date => $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get completedSessions =>
      $composableBuilder(column: $table.completedSessions, builder: (column) => column);

  GeneratedColumn<int> get totalSessions =>
      $composableBuilder(column: $table.totalSessions, builder: (column) => column);

  GeneratedColumn<int> get focusSeconds => $composableBuilder(column: $table.focusSeconds, builder: (column) => column);
}

class $$DailySessionStatsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySessionStatsTableTable,
          DailySessionStatsData,
          $$DailySessionStatsTableTableFilterComposer,
          $$DailySessionStatsTableTableOrderingComposer,
          $$DailySessionStatsTableTableAnnotationComposer,
          $$DailySessionStatsTableTableCreateCompanionBuilder,
          $$DailySessionStatsTableTableUpdateCompanionBuilder,
          (DailySessionStatsData, BaseReferences<_$AppDatabase, $DailySessionStatsTableTable, DailySessionStatsData>),
          DailySessionStatsData,
          PrefetchHooks Function()
        > {
  $$DailySessionStatsTableTableTableManager(_$AppDatabase db, $DailySessionStatsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$DailySessionStatsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$DailySessionStatsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$DailySessionStatsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<int> completedSessions = const Value.absent(),
                Value<int> totalSessions = const Value.absent(),
                Value<int> focusSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySessionStatsTableCompanion(
                date: date,
                completedSessions: completedSessions,
                totalSessions: totalSessions,
                focusSeconds: focusSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                Value<int> completedSessions = const Value.absent(),
                Value<int> totalSessions = const Value.absent(),
                Value<int> focusSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailySessionStatsTableCompanion.insert(
                date: date,
                completedSessions: completedSessions,
                totalSessions: totalSessions,
                focusSeconds: focusSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySessionStatsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySessionStatsTableTable,
      DailySessionStatsData,
      $$DailySessionStatsTableTableFilterComposer,
      $$DailySessionStatsTableTableOrderingComposer,
      $$DailySessionStatsTableTableAnnotationComposer,
      $$DailySessionStatsTableTableCreateCompanionBuilder,
      $$DailySessionStatsTableTableUpdateCompanionBuilder,
      (DailySessionStatsData, BaseReferences<_$AppDatabase, $DailySessionStatsTableTable, DailySessionStatsData>),
      DailySessionStatsData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({required String key, required String value, Value<int> rowid});
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({Value<String> key, Value<String> value, Value<int> rowid});

class $$SettingsTableTableFilterComposer extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableTableOrderingComposer extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableTableAnnotationComposer extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key => $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value => $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (SettingsData, BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsData>),
          SettingsData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({required String key, required String value, Value<int> rowid = const Value.absent()}) =>
                  SettingsTableCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (SettingsData, BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsData>),
      SettingsData,
      PrefetchHooks Function()
    >;
typedef $$NotificationInboxTableTableCreateCompanionBuilder =
    NotificationInboxTableCompanion Function({
      Value<int> id,
      required int notificationId,
      required NotificationInboxType type,
      required NotificationInboxState state,
      required String title,
      Value<String?> body,
      Value<String?> payload,
      Value<int?> taskId,
      Value<int?> projectId,
      Value<DateTime?> scheduledFor,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$NotificationInboxTableTableUpdateCompanionBuilder =
    NotificationInboxTableCompanion Function({
      Value<int> id,
      Value<int> notificationId,
      Value<NotificationInboxType> type,
      Value<NotificationInboxState> state,
      Value<String> title,
      Value<String?> body,
      Value<String?> payload,
      Value<int?> taskId,
      Value<int?> projectId,
      Value<DateTime?> scheduledFor,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$NotificationInboxTableTableFilterComposer extends Composer<_$AppDatabase, $NotificationInboxTableTable> {
  $$NotificationInboxTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get notificationId =>
      $composableBuilder(column: $table.notificationId, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<NotificationInboxType, NotificationInboxType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<NotificationInboxState, NotificationInboxState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledFor =>
      $composableBuilder(column: $table.scheduledFor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$NotificationInboxTableTableOrderingComposer extends Composer<_$AppDatabase, $NotificationInboxTableTable> {
  $$NotificationInboxTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get notificationId =>
      $composableBuilder(column: $table.notificationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledFor =>
      $composableBuilder(column: $table.scheduledFor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$NotificationInboxTableTableAnnotationComposer extends Composer<_$AppDatabase, $NotificationInboxTableTable> {
  $$NotificationInboxTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get notificationId =>
      $composableBuilder(column: $table.notificationId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotificationInboxType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NotificationInboxState, int> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get title => $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body => $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get payload => $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get taskId => $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<int> get projectId => $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor =>
      $composableBuilder(column: $table.scheduledFor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotificationInboxTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationInboxTableTable,
          NotificationInboxTableData,
          $$NotificationInboxTableTableFilterComposer,
          $$NotificationInboxTableTableOrderingComposer,
          $$NotificationInboxTableTableAnnotationComposer,
          $$NotificationInboxTableTableCreateCompanionBuilder,
          $$NotificationInboxTableTableUpdateCompanionBuilder,
          (
            NotificationInboxTableData,
            BaseReferences<_$AppDatabase, $NotificationInboxTableTable, NotificationInboxTableData>,
          ),
          NotificationInboxTableData,
          PrefetchHooks Function()
        > {
  $$NotificationInboxTableTableTableManager(_$AppDatabase db, $NotificationInboxTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$NotificationInboxTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$NotificationInboxTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$NotificationInboxTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<NotificationInboxType> type = const Value.absent(),
                Value<NotificationInboxState> state = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> body = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<DateTime?> scheduledFor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => NotificationInboxTableCompanion(
                id: id,
                notificationId: notificationId,
                type: type,
                state: state,
                title: title,
                body: body,
                payload: payload,
                taskId: taskId,
                projectId: projectId,
                scheduledFor: scheduledFor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int notificationId,
                required NotificationInboxType type,
                required NotificationInboxState state,
                required String title,
                Value<String?> body = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<int?> taskId = const Value.absent(),
                Value<int?> projectId = const Value.absent(),
                Value<DateTime?> scheduledFor = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => NotificationInboxTableCompanion.insert(
                id: id,
                notificationId: notificationId,
                type: type,
                state: state,
                title: title,
                body: body,
                payload: payload,
                taskId: taskId,
                projectId: projectId,
                scheduledFor: scheduledFor,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationInboxTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationInboxTableTable,
      NotificationInboxTableData,
      $$NotificationInboxTableTableFilterComposer,
      $$NotificationInboxTableTableOrderingComposer,
      $$NotificationInboxTableTableAnnotationComposer,
      $$NotificationInboxTableTableCreateCompanionBuilder,
      $$NotificationInboxTableTableUpdateCompanionBuilder,
      (
        NotificationInboxTableData,
        BaseReferences<_$AppDatabase, $NotificationInboxTableTable, NotificationInboxTableData>,
      ),
      NotificationInboxTableData,
      PrefetchHooks Function()
    >;
typedef $$TagTableTableCreateCompanionBuilder =
    TagTableCompanion Function({
      Value<int> id,
      required String uuid,
      required String name,
      Value<int?> color,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$TagTableTableUpdateCompanionBuilder =
    TagTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<String> name,
      Value<int?> color,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$TagTableTableReferences extends BaseReferences<_$AppDatabase, $TagTableTable, TagTableData> {
  $$TagTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskTagTableTable, List<TaskTagData>> _taskTagTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.taskTagTable, aliasName: 'tag_table__id__task_tag_table__tag_id');

  $$TaskTagTableTableProcessedTableManager get taskTagTableRefs {
    final manager = $$TaskTagTableTableTableManager(
      $_db,
      $_db.taskTagTable,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskTagTableRefsTable($_db));
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TagTableTableFilterComposer extends Composer<_$AppDatabase, $TagTableTable> {
  $$TagTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> taskTagTableRefs(Expression<bool> Function($$TaskTagTableTableFilterComposer f) f) {
    final $$TaskTagTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTagTable,
      getReferencedColumn: (t) => t.tagId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTagTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTagTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagTableTableOrderingComposer extends Composer<_$AppDatabase, $TagTableTable> {
  $$TagTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TagTableTableAnnotationComposer extends Composer<_$AppDatabase, $TagTableTable> {
  $$TagTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color => $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> taskTagTableRefs<T extends Object>(Expression<T> Function($$TaskTagTableTableAnnotationComposer a) f) {
    final $$TaskTagTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskTagTable,
      getReferencedColumn: (t) => t.tagId,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTagTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTagTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagTableTable,
          TagTableData,
          $$TagTableTableFilterComposer,
          $$TagTableTableOrderingComposer,
          $$TagTableTableAnnotationComposer,
          $$TagTableTableCreateCompanionBuilder,
          $$TagTableTableUpdateCompanionBuilder,
          (TagTableData, $$TagTableTableReferences),
          TagTableData,
          PrefetchHooks Function({bool taskTagTableRefs})
        > {
  $$TagTableTableTableManager(_$AppDatabase db, $TagTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TagTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TagTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TagTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TagTableCompanion(
                id: id,
                uuid: uuid,
                name: name,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required String name,
                Value<int?> color = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TagTableCompanion.insert(
                id: id,
                uuid: uuid,
                name: name,
                color: color,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$TagTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({taskTagTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (taskTagTableRefs) db.taskTagTable],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (taskTagTableRefs)
                    await $_getPrefetchedData<TagTableData, $TagTableTable, TaskTagData>(
                      currentTable: table,
                      referencedTable: $$TagTableTableReferences._taskTagTableRefsTable(db),
                      managerFromTypedResult: (p0) => $$TagTableTableReferences(db, table, p0).taskTagTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagTableTable,
      TagTableData,
      $$TagTableTableFilterComposer,
      $$TagTableTableOrderingComposer,
      $$TagTableTableAnnotationComposer,
      $$TagTableTableCreateCompanionBuilder,
      $$TagTableTableUpdateCompanionBuilder,
      (TagTableData, $$TagTableTableReferences),
      TagTableData,
      PrefetchHooks Function({bool taskTagTableRefs})
    >;
typedef $$TaskTagTableTableCreateCompanionBuilder =
    TaskTagTableCompanion Function({
      required int taskId,
      required int tagId,
      required String uuid,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TaskTagTableTableUpdateCompanionBuilder =
    TaskTagTableCompanion Function({
      Value<int> taskId,
      Value<int> tagId,
      Value<String> uuid,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TaskTagTableTableReferences extends BaseReferences<_$AppDatabase, $TaskTagTableTable, TaskTagData> {
  $$TaskTagTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskTableTable _taskIdTable(_$AppDatabase db) =>
      db.taskTable.createAlias('task_tag_table__task_id__task_table__id');

  $$TaskTableTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TaskTableTableTableManager($_db, $_db.taskTable).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }

  static $TagTableTable _tagIdTable(_$AppDatabase db) =>
      db.tagTable.createAlias('task_tag_table__tag_id__tag_table__id');

  $$TagTableTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$TagTableTableTableManager($_db, $_db.tagTable).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TaskTagTableTableFilterComposer extends Composer<_$AppDatabase, $TaskTagTableTable> {
  $$TaskTagTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$TaskTableTableFilterComposer get taskId {
    final $$TaskTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagTableTableFilterComposer get tagId {
    final $$TagTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tagTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TagTableTableFilterComposer(
            $db: $db,
            $table: $db.tagTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskTagTableTableOrderingComposer extends Composer<_$AppDatabase, $TaskTagTableTable> {
  $$TaskTagTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$TaskTableTableOrderingComposer get taskId {
    final $$TaskTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableOrderingComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagTableTableOrderingComposer get tagId {
    final $$TagTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tagTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TagTableTableOrderingComposer(
            $db: $db,
            $table: $db.tagTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskTagTableTableAnnotationComposer extends Composer<_$AppDatabase, $TaskTagTableTable> {
  $$TaskTagTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TaskTableTableAnnotationComposer get taskId {
    final $$TaskTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagTableTableAnnotationComposer get tagId {
    final $$TagTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tagTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TagTableTableAnnotationComposer(
            $db: $db,
            $table: $db.tagTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskTagTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskTagTableTable,
          TaskTagData,
          $$TaskTagTableTableFilterComposer,
          $$TaskTagTableTableOrderingComposer,
          $$TaskTagTableTableAnnotationComposer,
          $$TaskTagTableTableCreateCompanionBuilder,
          $$TaskTagTableTableUpdateCompanionBuilder,
          (TaskTagData, $$TaskTagTableTableReferences),
          TaskTagData,
          PrefetchHooks Function({bool taskId, bool tagId})
        > {
  $$TaskTagTableTableTableManager(_$AppDatabase db, $TaskTagTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TaskTagTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TaskTagTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TaskTagTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> taskId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTagTableCompanion(
                taskId: taskId,
                tagId: tagId,
                uuid: uuid,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int taskId,
                required int tagId,
                required String uuid,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTagTableCompanion.insert(
                taskId: taskId,
                tagId: tagId,
                uuid: uuid,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$TaskTagTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({taskId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskTagTableTableReferences._taskIdTable(db),
                                referencedColumn: $$TaskTagTableTableReferences._taskIdTable(db).id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$TaskTagTableTableReferences._tagIdTable(db),
                                referencedColumn: $$TaskTagTableTableReferences._tagIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskTagTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskTagTableTable,
      TaskTagData,
      $$TaskTagTableTableFilterComposer,
      $$TaskTagTableTableOrderingComposer,
      $$TaskTagTableTableAnnotationComposer,
      $$TaskTagTableTableCreateCompanionBuilder,
      $$TaskTagTableTableUpdateCompanionBuilder,
      (TaskTagData, $$TaskTagTableTableReferences),
      TaskTagData,
      PrefetchHooks Function({bool taskId, bool tagId})
    >;
typedef $$TaskCompletionTableTableCreateCompanionBuilder =
    TaskCompletionTableCompanion Function({
      Value<int> id,
      required String uuid,
      required int taskId,
      required String occurrenceDate,
      required DateTime completedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$TaskCompletionTableTableUpdateCompanionBuilder =
    TaskCompletionTableCompanion Function({
      Value<int> id,
      Value<String> uuid,
      Value<int> taskId,
      Value<String> occurrenceDate,
      Value<DateTime> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$TaskCompletionTableTableReferences
    extends BaseReferences<_$AppDatabase, $TaskCompletionTableTable, TaskCompletionTableData> {
  $$TaskCompletionTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TaskTableTable _taskIdTable(_$AppDatabase db) =>
      db.taskTable.createAlias('task_completion_table__task_id__task_table__id');

  $$TaskTableTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TaskTableTableTableManager($_db, $_db.taskTable).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TaskCompletionTableTableFilterComposer extends Composer<_$AppDatabase, $TaskCompletionTableTable> {
  $$TaskCompletionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get occurrenceDate =>
      $composableBuilder(column: $table.occurrenceDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  $$TaskTableTableFilterComposer get taskId {
    final $$TaskTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableFilterComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskCompletionTableTableOrderingComposer extends Composer<_$AppDatabase, $TaskCompletionTableTable> {
  $$TaskCompletionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occurrenceDate =>
      $composableBuilder(column: $table.occurrenceDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  $$TaskTableTableOrderingComposer get taskId {
    final $$TaskTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableOrderingComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskCompletionTableTableAnnotationComposer extends Composer<_$AppDatabase, $TaskCompletionTableTable> {
  $$TaskCompletionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get occurrenceDate =>
      $composableBuilder(column: $table.occurrenceDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt =>
      $composableBuilder(column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt => $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt => $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt => $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$TaskTableTableAnnotationComposer get taskId {
    final $$TaskTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.taskTable,
      getReferencedColumn: (t) => t.id,
      builder: (joinBuilder, {$addJoinBuilderToRootComposer, $removeJoinBuilderFromRootComposer}) =>
          $$TaskTableTableAnnotationComposer(
            $db: $db,
            $table: $db.taskTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer: $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskCompletionTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskCompletionTableTable,
          TaskCompletionTableData,
          $$TaskCompletionTableTableFilterComposer,
          $$TaskCompletionTableTableOrderingComposer,
          $$TaskCompletionTableTableAnnotationComposer,
          $$TaskCompletionTableTableCreateCompanionBuilder,
          $$TaskCompletionTableTableUpdateCompanionBuilder,
          (TaskCompletionTableData, $$TaskCompletionTableTableReferences),
          TaskCompletionTableData,
          PrefetchHooks Function({bool taskId})
        > {
  $$TaskCompletionTableTableTableManager(_$AppDatabase db, $TaskCompletionTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TaskCompletionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TaskCompletionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$TaskCompletionTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uuid = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> occurrenceDate = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TaskCompletionTableCompanion(
                id: id,
                uuid: uuid,
                taskId: taskId,
                occurrenceDate: occurrenceDate,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uuid,
                required int taskId,
                required String occurrenceDate,
                required DateTime completedAt,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TaskCompletionTableCompanion.insert(
                id: id,
                uuid: uuid,
                taskId: taskId,
                occurrenceDate: occurrenceDate,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), $$TaskCompletionTableTableReferences(db, table, e))).toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskCompletionTableTableReferences._taskIdTable(db),
                                referencedColumn: $$TaskCompletionTableTableReferences._taskIdTable(db).id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskCompletionTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskCompletionTableTable,
      TaskCompletionTableData,
      $$TaskCompletionTableTableFilterComposer,
      $$TaskCompletionTableTableOrderingComposer,
      $$TaskCompletionTableTableAnnotationComposer,
      $$TaskCompletionTableTableCreateCompanionBuilder,
      $$TaskCompletionTableTableUpdateCompanionBuilder,
      (TaskCompletionTableData, $$TaskCompletionTableTableReferences),
      TaskCompletionTableData,
      PrefetchHooks Function({bool taskId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectTableTableTableManager get projectTable => $$ProjectTableTableTableManager(_db, _db.projectTable);
  $$MilestoneTableTableTableManager get milestoneTable => $$MilestoneTableTableTableManager(_db, _db.milestoneTable);
  $$TaskTableTableTableManager get taskTable => $$TaskTableTableTableManager(_db, _db.taskTable);
  $$FocusSessionTableTableTableManager get focusSessionTable =>
      $$FocusSessionTableTableTableManager(_db, _db.focusSessionTable);
  $$DailySessionStatsTableTableTableManager get dailySessionStatsTable =>
      $$DailySessionStatsTableTableTableManager(_db, _db.dailySessionStatsTable);
  $$SettingsTableTableTableManager get settingsTable => $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$NotificationInboxTableTableTableManager get notificationInboxTable =>
      $$NotificationInboxTableTableTableManager(_db, _db.notificationInboxTable);
  $$TagTableTableTableManager get tagTable => $$TagTableTableTableManager(_db, _db.tagTable);
  $$TaskTagTableTableTableManager get taskTagTable => $$TaskTagTableTableTableManager(_db, _db.taskTagTable);
  $$TaskCompletionTableTableTableManager get taskCompletionTable =>
      $$TaskCompletionTableTableTableManager(_db, _db.taskCompletionTable);
}
