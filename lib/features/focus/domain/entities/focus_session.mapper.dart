// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'focus_session.dart';

class FocusSessionMapper extends ClassMapperBase<FocusSession> {
  FocusSessionMapper._();

  static FocusSessionMapper? _instance;
  static FocusSessionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FocusSessionMapper._());
      SessionStateMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'FocusSession';

  static BigInt? _$id(FocusSession v) => v.id;
  static const Field<FocusSession, BigInt> _f$id = Field('id', _$id, opt: true);
  static BigInt _$taskId(FocusSession v) => v.taskId;
  static const Field<FocusSession, BigInt> _f$taskId = Field(
    'taskId',
    _$taskId,
  );
  static int _$focusDurationMinutes(FocusSession v) => v.focusDurationMinutes;
  static const Field<FocusSession, int> _f$focusDurationMinutes = Field(
    'focusDurationMinutes',
    _$focusDurationMinutes,
  );
  static int _$breakDurationMinutes(FocusSession v) => v.breakDurationMinutes;
  static const Field<FocusSession, int> _f$breakDurationMinutes = Field(
    'breakDurationMinutes',
    _$breakDurationMinutes,
  );
  static DateTime _$startTime(FocusSession v) => v.startTime;
  static const Field<FocusSession, DateTime> _f$startTime = Field(
    'startTime',
    _$startTime,
  );
  static DateTime? _$endTime(FocusSession v) => v.endTime;
  static const Field<FocusSession, DateTime> _f$endTime = Field(
    'endTime',
    _$endTime,
    opt: true,
  );
  static SessionState _$state(FocusSession v) => v.state;
  static const Field<FocusSession, SessionState> _f$state = Field(
    'state',
    _$state,
  );
  static int _$elapsedSeconds(FocusSession v) => v.elapsedSeconds;
  static const Field<FocusSession, int> _f$elapsedSeconds = Field(
    'elapsedSeconds',
    _$elapsedSeconds,
    opt: true,
    def: 0,
  );

  @override
  final MappableFields<FocusSession> fields = const {
    #id: _f$id,
    #taskId: _f$taskId,
    #focusDurationMinutes: _f$focusDurationMinutes,
    #breakDurationMinutes: _f$breakDurationMinutes,
    #startTime: _f$startTime,
    #endTime: _f$endTime,
    #state: _f$state,
    #elapsedSeconds: _f$elapsedSeconds,
  };

  static FocusSession _instantiate(DecodingData data) {
    return FocusSession(
      id: data.dec(_f$id),
      taskId: data.dec(_f$taskId),
      focusDurationMinutes: data.dec(_f$focusDurationMinutes),
      breakDurationMinutes: data.dec(_f$breakDurationMinutes),
      startTime: data.dec(_f$startTime),
      endTime: data.dec(_f$endTime),
      state: data.dec(_f$state),
      elapsedSeconds: data.dec(_f$elapsedSeconds),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FocusSession fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FocusSession>(map);
  }

  static FocusSession fromJson(String json) {
    return ensureInitialized().decodeJson<FocusSession>(json);
  }
}

mixin FocusSessionMappable {
  String toJson() {
    return FocusSessionMapper.ensureInitialized().encodeJson<FocusSession>(
      this as FocusSession,
    );
  }

  Map<String, dynamic> toMap() {
    return FocusSessionMapper.ensureInitialized().encodeMap<FocusSession>(
      this as FocusSession,
    );
  }

  FocusSessionCopyWith<FocusSession, FocusSession, FocusSession> get copyWith =>
      _FocusSessionCopyWithImpl<FocusSession, FocusSession>(
        this as FocusSession,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FocusSessionMapper.ensureInitialized().stringifyValue(
      this as FocusSession,
    );
  }

  @override
  bool operator ==(Object other) {
    return FocusSessionMapper.ensureInitialized().equalsValue(
      this as FocusSession,
      other,
    );
  }

  @override
  int get hashCode {
    return FocusSessionMapper.ensureInitialized().hashValue(
      this as FocusSession,
    );
  }
}

extension FocusSessionValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FocusSession, $Out> {
  FocusSessionCopyWith<$R, FocusSession, $Out> get $asFocusSession =>
      $base.as((v, t, t2) => _FocusSessionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FocusSessionCopyWith<$R, $In extends FocusSession, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    BigInt? id,
    BigInt? taskId,
    int? focusDurationMinutes,
    int? breakDurationMinutes,
    DateTime? startTime,
    DateTime? endTime,
    SessionState? state,
    int? elapsedSeconds,
  });
  FocusSessionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FocusSessionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FocusSession, $Out>
    implements FocusSessionCopyWith<$R, FocusSession, $Out> {
  _FocusSessionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FocusSession> $mapper =
      FocusSessionMapper.ensureInitialized();
  @override
  $R call({
    Object? id = $none,
    BigInt? taskId,
    int? focusDurationMinutes,
    int? breakDurationMinutes,
    DateTime? startTime,
    Object? endTime = $none,
    SessionState? state,
    int? elapsedSeconds,
  }) => $apply(
    FieldCopyWithData({
      if (id != $none) #id: id,
      if (taskId != null) #taskId: taskId,
      if (focusDurationMinutes != null)
        #focusDurationMinutes: focusDurationMinutes,
      if (breakDurationMinutes != null)
        #breakDurationMinutes: breakDurationMinutes,
      if (startTime != null) #startTime: startTime,
      if (endTime != $none) #endTime: endTime,
      if (state != null) #state: state,
      if (elapsedSeconds != null) #elapsedSeconds: elapsedSeconds,
    }),
  );
  @override
  FocusSession $make(CopyWithData data) => FocusSession(
    id: data.get(#id, or: $value.id),
    taskId: data.get(#taskId, or: $value.taskId),
    focusDurationMinutes: data.get(
      #focusDurationMinutes,
      or: $value.focusDurationMinutes,
    ),
    breakDurationMinutes: data.get(
      #breakDurationMinutes,
      or: $value.breakDurationMinutes,
    ),
    startTime: data.get(#startTime, or: $value.startTime),
    endTime: data.get(#endTime, or: $value.endTime),
    state: data.get(#state, or: $value.state),
    elapsedSeconds: data.get(#elapsedSeconds, or: $value.elapsedSeconds),
  );

  @override
  FocusSessionCopyWith<$R2, FocusSession, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FocusSessionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

