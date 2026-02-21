// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'task_stats_model.dart';

class TaskStatsModelMapper extends ClassMapperBase<TaskStatsModel> {
  TaskStatsModelMapper._();

  static TaskStatsModelMapper? _instance;
  static TaskStatsModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TaskStatsModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'TaskStatsModel';

  static int _$totalSeconds(TaskStatsModel v) => v.totalSeconds;
  static const Field<TaskStatsModel, int> _f$totalSeconds = Field(
    'totalSeconds',
    _$totalSeconds,
  );
  static int _$totalSessions(TaskStatsModel v) => v.totalSessions;
  static const Field<TaskStatsModel, int> _f$totalSessions = Field(
    'totalSessions',
    _$totalSessions,
  );
  static int _$completedSessions(TaskStatsModel v) => v.completedSessions;
  static const Field<TaskStatsModel, int> _f$completedSessions = Field(
    'completedSessions',
    _$completedSessions,
  );
  static Map<String, int> _$dailyCompletedSessions(TaskStatsModel v) =>
      v.dailyCompletedSessions;
  static const Field<TaskStatsModel, Map<String, int>>
  _f$dailyCompletedSessions = Field(
    'dailyCompletedSessions',
    _$dailyCompletedSessions,
  );

  @override
  final MappableFields<TaskStatsModel> fields = const {
    #totalSeconds: _f$totalSeconds,
    #totalSessions: _f$totalSessions,
    #completedSessions: _f$completedSessions,
    #dailyCompletedSessions: _f$dailyCompletedSessions,
  };

  static TaskStatsModel _instantiate(DecodingData data) {
    return TaskStatsModel(
      totalSeconds: data.dec(_f$totalSeconds),
      totalSessions: data.dec(_f$totalSessions),
      completedSessions: data.dec(_f$completedSessions),
      dailyCompletedSessions: data.dec(_f$dailyCompletedSessions),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TaskStatsModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TaskStatsModel>(map);
  }

  static TaskStatsModel fromJson(String json) {
    return ensureInitialized().decodeJson<TaskStatsModel>(json);
  }
}

mixin TaskStatsModelMappable {
  String toJson() {
    return TaskStatsModelMapper.ensureInitialized().encodeJson<TaskStatsModel>(
      this as TaskStatsModel,
    );
  }

  Map<String, dynamic> toMap() {
    return TaskStatsModelMapper.ensureInitialized().encodeMap<TaskStatsModel>(
      this as TaskStatsModel,
    );
  }

  TaskStatsModelCopyWith<TaskStatsModel, TaskStatsModel, TaskStatsModel>
  get copyWith => _TaskStatsModelCopyWithImpl<TaskStatsModel, TaskStatsModel>(
    this as TaskStatsModel,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TaskStatsModelMapper.ensureInitialized().stringifyValue(
      this as TaskStatsModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return TaskStatsModelMapper.ensureInitialized().equalsValue(
      this as TaskStatsModel,
      other,
    );
  }

  @override
  int get hashCode {
    return TaskStatsModelMapper.ensureInitialized().hashValue(
      this as TaskStatsModel,
    );
  }
}

extension TaskStatsModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TaskStatsModel, $Out> {
  TaskStatsModelCopyWith<$R, TaskStatsModel, $Out> get $asTaskStatsModel =>
      $base.as((v, t, t2) => _TaskStatsModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TaskStatsModelCopyWith<$R, $In extends TaskStatsModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get dailyCompletedSessions;
  $R call({
    int? totalSeconds,
    int? totalSessions,
    int? completedSessions,
    Map<String, int>? dailyCompletedSessions,
  });
  TaskStatsModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TaskStatsModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TaskStatsModel, $Out>
    implements TaskStatsModelCopyWith<$R, TaskStatsModel, $Out> {
  _TaskStatsModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TaskStatsModel> $mapper =
      TaskStatsModelMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, int, ObjectCopyWith<$R, int, int>>
  get dailyCompletedSessions => MapCopyWith(
    $value.dailyCompletedSessions,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(dailyCompletedSessions: v),
  );
  @override
  $R call({
    int? totalSeconds,
    int? totalSessions,
    int? completedSessions,
    Map<String, int>? dailyCompletedSessions,
  }) => $apply(
    FieldCopyWithData({
      if (totalSeconds != null) #totalSeconds: totalSeconds,
      if (totalSessions != null) #totalSessions: totalSessions,
      if (completedSessions != null) #completedSessions: completedSessions,
      if (dailyCompletedSessions != null)
        #dailyCompletedSessions: dailyCompletedSessions,
    }),
  );
  @override
  TaskStatsModel $make(CopyWithData data) => TaskStatsModel(
    totalSeconds: data.get(#totalSeconds, or: $value.totalSeconds),
    totalSessions: data.get(#totalSessions, or: $value.totalSessions),
    completedSessions: data.get(
      #completedSessions,
      or: $value.completedSessions,
    ),
    dailyCompletedSessions: data.get(
      #dailyCompletedSessions,
      or: $value.dailyCompletedSessions,
    ),
  );

  @override
  TaskStatsModelCopyWith<$R2, TaskStatsModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TaskStatsModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

