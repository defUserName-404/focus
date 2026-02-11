import 'package:dart_mappable/dart_mappable.dart';

part 'session_state.mapper.dart';

@MappableEnum()
enum SessionState { idle, running, paused, onBreak, completed }
