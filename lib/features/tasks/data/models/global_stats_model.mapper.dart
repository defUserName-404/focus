// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'global_stats_model.dart';

class GlobalStatsModelMapper extends ClassMapperBase<GlobalStatsModel> {
  GlobalStatsModelMapper._();

  static GlobalStatsModelMapper? _instance;
  static GlobalStatsModelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GlobalStatsModelMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GlobalStatsModel';

  static int _$totalSeconds(GlobalStatsModel v) => v.totalSeconds;
  static const Field<GlobalStatsModel, int> _f$totalSeconds = Field(
    'totalSeconds',
    _$totalSeconds,
  );
  static int _$totalSessions(GlobalStatsModel v) => v.totalSessions;
  static const Field<GlobalStatsModel, int> _f$totalSessions = Field(
    'totalSessions',
    _$totalSessions,
  );
  static int _$completedSessions(GlobalStatsModel v) => v.completedSessions;
  static const Field<GlobalStatsModel, int> _f$completedSessions = Field(
    'completedSessions',
    _$completedSessions,
  );
  static int _$totalTasks(GlobalStatsModel v) => v.totalTasks;
  static const Field<GlobalStatsModel, int> _f$totalTasks = Field(
    'totalTasks',
    _$totalTasks,
  );
  static int _$completedTasks(GlobalStatsModel v) => v.completedTasks;
  static const Field<GlobalStatsModel, int> _f$completedTasks = Field(
    'completedTasks',
    _$completedTasks,
  );
  static int _$todaySessions(GlobalStatsModel v) => v.todaySessions;
  static const Field<GlobalStatsModel, int> _f$todaySessions = Field(
    'todaySessions',
    _$todaySessions,
  );
  static int _$todaySeconds(GlobalStatsModel v) => v.todaySeconds;
  static const Field<GlobalStatsModel, int> _f$todaySeconds = Field(
    'todaySeconds',
    _$todaySeconds,
  );
  static int _$currentStreak(GlobalStatsModel v) => v.currentStreak;
  static const Field<GlobalStatsModel, int> _f$currentStreak = Field(
    'currentStreak',
    _$currentStreak,
  );

  @override
  final MappableFields<GlobalStatsModel> fields = const {
    #totalSeconds: _f$totalSeconds,
    #totalSessions: _f$totalSessions,
    #completedSessions: _f$completedSessions,
    #totalTasks: _f$totalTasks,
    #completedTasks: _f$completedTasks,
    #todaySessions: _f$todaySessions,
    #todaySeconds: _f$todaySeconds,
    #currentStreak: _f$currentStreak,
  };

  static GlobalStatsModel _instantiate(DecodingData data) {
    return GlobalStatsModel(
      totalSeconds: data.dec(_f$totalSeconds),
      totalSessions: data.dec(_f$totalSessions),
      completedSessions: data.dec(_f$completedSessions),
      totalTasks: data.dec(_f$totalTasks),
      completedTasks: data.dec(_f$completedTasks),
      todaySessions: data.dec(_f$todaySessions),
      todaySeconds: data.dec(_f$todaySeconds),
      currentStreak: data.dec(_f$currentStreak),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GlobalStatsModel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GlobalStatsModel>(map);
  }

  static GlobalStatsModel fromJson(String json) {
    return ensureInitialized().decodeJson<GlobalStatsModel>(json);
  }
}

mixin GlobalStatsModelMappable {
  String toJson() {
    return GlobalStatsModelMapper.ensureInitialized()
        .encodeJson<GlobalStatsModel>(this as GlobalStatsModel);
  }

  Map<String, dynamic> toMap() {
    return GlobalStatsModelMapper.ensureInitialized()
        .encodeMap<GlobalStatsModel>(this as GlobalStatsModel);
  }

  GlobalStatsModelCopyWith<GlobalStatsModel, GlobalStatsModel, GlobalStatsModel>
  get copyWith =>
      _GlobalStatsModelCopyWithImpl<GlobalStatsModel, GlobalStatsModel>(
        this as GlobalStatsModel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GlobalStatsModelMapper.ensureInitialized().stringifyValue(
      this as GlobalStatsModel,
    );
  }

  @override
  bool operator ==(Object other) {
    return GlobalStatsModelMapper.ensureInitialized().equalsValue(
      this as GlobalStatsModel,
      other,
    );
  }

  @override
  int get hashCode {
    return GlobalStatsModelMapper.ensureInitialized().hashValue(
      this as GlobalStatsModel,
    );
  }
}

extension GlobalStatsModelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, GlobalStatsModel, $Out> {
  GlobalStatsModelCopyWith<$R, GlobalStatsModel, $Out>
  get $asGlobalStatsModel =>
      $base.as((v, t, t2) => _GlobalStatsModelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GlobalStatsModelCopyWith<$R, $In extends GlobalStatsModel, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    int? totalSeconds,
    int? totalSessions,
    int? completedSessions,
    int? totalTasks,
    int? completedTasks,
    int? todaySessions,
    int? todaySeconds,
    int? currentStreak,
  });
  GlobalStatsModelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _GlobalStatsModelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, GlobalStatsModel, $Out>
    implements GlobalStatsModelCopyWith<$R, GlobalStatsModel, $Out> {
  _GlobalStatsModelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GlobalStatsModel> $mapper =
      GlobalStatsModelMapper.ensureInitialized();
  @override
  $R call({
    int? totalSeconds,
    int? totalSessions,
    int? completedSessions,
    int? totalTasks,
    int? completedTasks,
    int? todaySessions,
    int? todaySeconds,
    int? currentStreak,
  }) => $apply(
    FieldCopyWithData({
      if (totalSeconds != null) #totalSeconds: totalSeconds,
      if (totalSessions != null) #totalSessions: totalSessions,
      if (completedSessions != null) #completedSessions: completedSessions,
      if (totalTasks != null) #totalTasks: totalTasks,
      if (completedTasks != null) #completedTasks: completedTasks,
      if (todaySessions != null) #todaySessions: todaySessions,
      if (todaySeconds != null) #todaySeconds: todaySeconds,
      if (currentStreak != null) #currentStreak: currentStreak,
    }),
  );
  @override
  GlobalStatsModel $make(CopyWithData data) => GlobalStatsModel(
    totalSeconds: data.get(#totalSeconds, or: $value.totalSeconds),
    totalSessions: data.get(#totalSessions, or: $value.totalSessions),
    completedSessions: data.get(
      #completedSessions,
      or: $value.completedSessions,
    ),
    totalTasks: data.get(#totalTasks, or: $value.totalTasks),
    completedTasks: data.get(#completedTasks, or: $value.completedTasks),
    todaySessions: data.get(#todaySessions, or: $value.todaySessions),
    todaySeconds: data.get(#todaySeconds, or: $value.todaySeconds),
    currentStreak: data.get(#currentStreak, or: $value.currentStreak),
  );

  @override
  GlobalStatsModelCopyWith<$R2, GlobalStatsModel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _GlobalStatsModelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

