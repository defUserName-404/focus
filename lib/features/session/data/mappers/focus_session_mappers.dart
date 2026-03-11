import 'package:drift/drift.dart' show Value;

import '../../../../core/services/db_service.dart';
import '../../domain/entities/focus_session.dart';

extension DbFocusSessionToDomain on FocusSessionData {
  FocusSession toDomain() => FocusSession(
    id: id,
    taskId: taskId,
    focusDurationMinutes: focusDurationMinutes,
    breakDurationMinutes: breakDurationMinutes,
    startTime: startTime,
    endTime: endTime,
    state: state,
    elapsedSeconds: elapsedSeconds,
  );
}

extension DomainFocusSessionToCompanion on FocusSession {
  FocusSessionTableCompanion toCompanion() {
    if (id != null) {
      return FocusSessionTableCompanion(
        id: Value(id!),
        taskId: Value(taskId),
        focusDurationMinutes: Value(focusDurationMinutes),
        breakDurationMinutes: Value(breakDurationMinutes),
        startTime: Value(startTime),
        endTime: Value(endTime),
        state: Value(state),
        elapsedSeconds: Value(elapsedSeconds),
      );
    }
    return FocusSessionTableCompanion.insert(
      taskId: Value(taskId),
      focusDurationMinutes: focusDurationMinutes,
      breakDurationMinutes: breakDurationMinutes,
      startTime: startTime,
      endTime: Value(endTime),
      state: state,
      elapsedSeconds: Value(elapsedSeconds),
    );
  }
}
