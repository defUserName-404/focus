// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'recurrence_rule.dart';

class RecurrenceFrequencyMapper extends EnumMapper<RecurrenceFrequency> {
  RecurrenceFrequencyMapper._();

  static RecurrenceFrequencyMapper? _instance;
  static RecurrenceFrequencyMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RecurrenceFrequencyMapper._());
    }
    return _instance!;
  }

  static RecurrenceFrequency fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  RecurrenceFrequency decode(dynamic value) {
    switch (value) {
      case r'daily':
        return RecurrenceFrequency.daily;
      case r'weekly':
        return RecurrenceFrequency.weekly;
      case r'monthly':
        return RecurrenceFrequency.monthly;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(RecurrenceFrequency self) {
    switch (self) {
      case RecurrenceFrequency.daily:
        return r'daily';
      case RecurrenceFrequency.weekly:
        return r'weekly';
      case RecurrenceFrequency.monthly:
        return r'monthly';
    }
  }
}

extension RecurrenceFrequencyMapperExtension on RecurrenceFrequency {
  String toValue() {
    RecurrenceFrequencyMapper.ensureInitialized();
    return MapperContainer.globals.toValue<RecurrenceFrequency>(this) as String;
  }
}

class RecurrenceRuleMapper extends ClassMapperBase<RecurrenceRule> {
  RecurrenceRuleMapper._();

  static RecurrenceRuleMapper? _instance;
  static RecurrenceRuleMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = RecurrenceRuleMapper._());
      RecurrenceFrequencyMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'RecurrenceRule';

  static RecurrenceFrequency _$frequency(RecurrenceRule v) => v.frequency;
  static const Field<RecurrenceRule, RecurrenceFrequency> _f$frequency = Field(
    'frequency',
    _$frequency,
  );
  static int _$interval(RecurrenceRule v) => v.interval;
  static const Field<RecurrenceRule, int> _f$interval = Field(
    'interval',
    _$interval,
    opt: true,
    def: 1,
  );
  static List<int>? _$byWeekday(RecurrenceRule v) => v.byWeekday;
  static const Field<RecurrenceRule, List<int>> _f$byWeekday = Field(
    'byWeekday',
    _$byWeekday,
    opt: true,
  );
  static int? _$byMonthDay(RecurrenceRule v) => v.byMonthDay;
  static const Field<RecurrenceRule, int> _f$byMonthDay = Field(
    'byMonthDay',
    _$byMonthDay,
    opt: true,
  );
  static int? _$timesPerPeriod(RecurrenceRule v) => v.timesPerPeriod;
  static const Field<RecurrenceRule, int> _f$timesPerPeriod = Field(
    'timesPerPeriod',
    _$timesPerPeriod,
    opt: true,
  );
  static DateTime? _$until(RecurrenceRule v) => v.until;
  static const Field<RecurrenceRule, DateTime> _f$until = Field(
    'until',
    _$until,
    opt: true,
  );
  static int? _$count(RecurrenceRule v) => v.count;
  static const Field<RecurrenceRule, int> _f$count = Field(
    'count',
    _$count,
    opt: true,
  );

  @override
  final MappableFields<RecurrenceRule> fields = const {
    #frequency: _f$frequency,
    #interval: _f$interval,
    #byWeekday: _f$byWeekday,
    #byMonthDay: _f$byMonthDay,
    #timesPerPeriod: _f$timesPerPeriod,
    #until: _f$until,
    #count: _f$count,
  };

  static RecurrenceRule _instantiate(DecodingData data) {
    return RecurrenceRule(
      frequency: data.dec(_f$frequency),
      interval: data.dec(_f$interval),
      byWeekday: data.dec(_f$byWeekday),
      byMonthDay: data.dec(_f$byMonthDay),
      timesPerPeriod: data.dec(_f$timesPerPeriod),
      until: data.dec(_f$until),
      count: data.dec(_f$count),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static RecurrenceRule fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<RecurrenceRule>(map);
  }

  static RecurrenceRule fromJson(String json) {
    return ensureInitialized().decodeJson<RecurrenceRule>(json);
  }
}

mixin RecurrenceRuleMappable {
  String toJson() {
    return RecurrenceRuleMapper.ensureInitialized().encodeJson<RecurrenceRule>(
      this as RecurrenceRule,
    );
  }

  Map<String, dynamic> toMap() {
    return RecurrenceRuleMapper.ensureInitialized().encodeMap<RecurrenceRule>(
      this as RecurrenceRule,
    );
  }

  RecurrenceRuleCopyWith<RecurrenceRule, RecurrenceRule, RecurrenceRule>
  get copyWith => _RecurrenceRuleCopyWithImpl<RecurrenceRule, RecurrenceRule>(
    this as RecurrenceRule,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return RecurrenceRuleMapper.ensureInitialized().stringifyValue(
      this as RecurrenceRule,
    );
  }

  @override
  bool operator ==(Object other) {
    return RecurrenceRuleMapper.ensureInitialized().equalsValue(
      this as RecurrenceRule,
      other,
    );
  }

  @override
  int get hashCode {
    return RecurrenceRuleMapper.ensureInitialized().hashValue(
      this as RecurrenceRule,
    );
  }
}

extension RecurrenceRuleValueCopy<$R, $Out>
    on ObjectCopyWith<$R, RecurrenceRule, $Out> {
  RecurrenceRuleCopyWith<$R, RecurrenceRule, $Out> get $asRecurrenceRule =>
      $base.as((v, t, t2) => _RecurrenceRuleCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class RecurrenceRuleCopyWith<$R, $In extends RecurrenceRule, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>>? get byWeekday;
  $R call({
    RecurrenceFrequency? frequency,
    int? interval,
    List<int>? byWeekday,
    int? byMonthDay,
    int? timesPerPeriod,
    DateTime? until,
    int? count,
  });
  RecurrenceRuleCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _RecurrenceRuleCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, RecurrenceRule, $Out>
    implements RecurrenceRuleCopyWith<$R, RecurrenceRule, $Out> {
  _RecurrenceRuleCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<RecurrenceRule> $mapper =
      RecurrenceRuleMapper.ensureInitialized();
  @override
  ListCopyWith<$R, int, ObjectCopyWith<$R, int, int>>? get byWeekday =>
      $value.byWeekday != null
      ? ListCopyWith(
          $value.byWeekday!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(byWeekday: v),
        )
      : null;
  @override
  $R call({
    RecurrenceFrequency? frequency,
    int? interval,
    Object? byWeekday = $none,
    Object? byMonthDay = $none,
    Object? timesPerPeriod = $none,
    Object? until = $none,
    Object? count = $none,
  }) => $apply(
    FieldCopyWithData({
      if (frequency != null) #frequency: frequency,
      if (interval != null) #interval: interval,
      if (byWeekday != $none) #byWeekday: byWeekday,
      if (byMonthDay != $none) #byMonthDay: byMonthDay,
      if (timesPerPeriod != $none) #timesPerPeriod: timesPerPeriod,
      if (until != $none) #until: until,
      if (count != $none) #count: count,
    }),
  );
  @override
  RecurrenceRule $make(CopyWithData data) => RecurrenceRule(
    frequency: data.get(#frequency, or: $value.frequency),
    interval: data.get(#interval, or: $value.interval),
    byWeekday: data.get(#byWeekday, or: $value.byWeekday),
    byMonthDay: data.get(#byMonthDay, or: $value.byMonthDay),
    timesPerPeriod: data.get(#timesPerPeriod, or: $value.timesPerPeriod),
    until: data.get(#until, or: $value.until),
    count: data.get(#count, or: $value.count),
  );

  @override
  RecurrenceRuleCopyWith<$R2, RecurrenceRule, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _RecurrenceRuleCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

