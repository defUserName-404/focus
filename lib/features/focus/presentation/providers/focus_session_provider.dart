import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/i_focus_session_repository.dart';

part 'focus_session_provider.g.dart';

@Riverpod(keepAlive: true)
class FocusTimer extends _$FocusTimer {
  late final IFocusSessionRepository _repository;
  Timer? _timer;

  @override
  FocusSession? build() {
    _repository = ref.watch(focusSessionRepositoryProvider);
    _loadActiveSession();
    return null;
  }

  Future<void> _loadActiveSession() async {
    final active = await _repository.getActiveSession();
    if (active != null) {
      state = active;
      if (active.state == SessionState.running ||
          active.state == SessionState.onBreak) {
        _startTimer();
      }
    }
  }

  Future<void> startNewSession({
    required BigInt taskId,
    required int focusMinutes,
    required int breakMinutes,
  }) async {
    _stopTimer();

    final session = FocusSession(
      taskId: taskId,
      focusDurationMinutes: focusMinutes,
      breakDurationMinutes: breakMinutes,
      startTime: DateTime.now(),
      state: SessionState.running,
      elapsedSeconds: 0,
    );

    final saved = await _repository.startSession(session);
    state = saved;
    _startTimer();
  }

  void pauseSession() {
    final current = state;
    if (current == null || current.state != SessionState.running) return;

    final updated = current.copyWith(state: SessionState.paused);
    state = updated;
    _repository.updateSession(updated);
    _stopTimer();
  }

  void resumeSession() {
    final current = state;
    if (current == null || current.state != SessionState.paused) return;

    final updated = current.copyWith(state: SessionState.running);
    state = updated;
    _repository.updateSession(updated);
    _startTimer();
  }

  void cancelSession() {
    final current = state;
    if (current == null) return;

    _stopTimer();
    _repository.deleteSession(current.id!);
    state = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    final current = state;
    if (current == null) {
      _stopTimer();
      return;
    }

    final newElapsed = current.elapsedSeconds + 1;
    final totalFocusSeconds = current.focusDurationMinutes * 60;

    if (current.state == SessionState.running) {
      if (newElapsed >= totalFocusSeconds) {
        _handleFocusCompleted();
      } else {
        state = current.copyWith(elapsedSeconds: newElapsed);
        if (newElapsed % 10 == 0) {
          _repository.updateSession(state!);
        }
      }
    } else if (current.state == SessionState.onBreak) {
      final totalBreakSeconds = current.breakDurationMinutes * 60;
      if (newElapsed >= (totalFocusSeconds + totalBreakSeconds)) {
        _handleSessionCompleted();
      } else {
        state = current.copyWith(elapsedSeconds: newElapsed);
        if (newElapsed % 10 == 0) {
          _repository.updateSession(state!);
        }
      }
    }
  }

  void _handleFocusCompleted() {
    final current = state;
    if (current == null) return;

    final updated = current.copyWith(state: SessionState.onBreak);
    state = updated;
    _repository.updateSession(updated);
  }

  void _handleSessionCompleted() {
    final current = state;
    if (current == null) return;

    _stopTimer();
    final updated = current.copyWith(
      state: SessionState.completed,
      endTime: DateTime.now(),
    );
    state = updated;
    _repository.updateSession(updated);
  }
}

@riverpod
IFocusSessionRepository focusSessionRepository(Ref ref) {
  return getIt<IFocusSessionRepository>();
}
