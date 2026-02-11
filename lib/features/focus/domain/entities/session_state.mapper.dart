// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'session_state.dart';

class SessionStateMapper extends EnumMapper<SessionState> {
  SessionStateMapper._();

  static SessionStateMapper? _instance;
  static SessionStateMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SessionStateMapper._());
    }
    return _instance!;
  }

  static SessionState fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  SessionState decode(dynamic value) {
    switch (value) {
      case r'idle':
        return SessionState.idle;
      case r'running':
        return SessionState.running;
      case r'paused':
        return SessionState.paused;
      case r'onBreak':
        return SessionState.onBreak;
      case r'completed':
        return SessionState.completed;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(SessionState self) {
    switch (self) {
      case SessionState.idle:
        return r'idle';
      case SessionState.running:
        return r'running';
      case SessionState.paused:
        return r'paused';
      case SessionState.onBreak:
        return r'onBreak';
      case SessionState.completed:
        return r'completed';
    }
  }
}

extension SessionStateMapperExtension on SessionState {
  String toValue() {
    SessionStateMapper.ensureInitialized();
    return MapperContainer.globals.toValue<SessionState>(this) as String;
  }
}

