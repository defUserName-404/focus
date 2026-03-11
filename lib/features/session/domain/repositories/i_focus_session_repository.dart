import '../entities/focus_session.dart';

abstract class IFocusSessionRepository {
  Future<FocusSession> startSession(FocusSession session);
  Future<void> updateSession(FocusSession session);
  Future<FocusSession?> getActiveSession();
  Stream<List<FocusSession>> watchSessionsByTask(int taskId);
  Stream<List<FocusSession>> watchAllSessions();
  Future<void> deleteSession(int id);
}
