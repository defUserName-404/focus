import 'package:drift/drift.dart' show Value;

import '../../../../core/services/db_service.dart';
import '../../domain/entities/focus_session.dart';

extension DbFocusSessionToDomain on FocusSessionData {
  FocusSession toDomain() => FocusSession(
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
  );
}

extension DomainFocusSessionToCompanion on FocusSession {
  FocusSessionTableCompanion toCompanion() {
    if (id != null) {
      return FocusSessionTableCompanion(
        id: Value(id!),
        uuid: Value(uuid),
        taskId: Value(taskId),
        focusDurationMinutes: Value(focusDurationMinutes),
        breakDurationMinutes: Value(breakDurationMinutes),
        startTime: Value(startTime),
        endTime: Value(endTime),
        state: Value(state),
        elapsedSeconds: Value(elapsedSeconds),
        focusPhaseEndedAt: Value(focusPhaseEndedAt),
        deletedAt: Value(deletedAt),
      );
    }
    return FocusSessionTableCompanion.insert(
      uuid: uuid,
      taskId: Value(taskId),
      focusDurationMinutes: focusDurationMinutes,
      breakDurationMinutes: breakDurationMinutes,
      startTime: startTime,
      endTime: Value(endTime),
      state: state,
      elapsedSeconds: Value(elapsedSeconds),
      focusPhaseEndedAt: Value(focusPhaseEndedAt),
      deletedAt: Value(deletedAt),
    );
  }
}
