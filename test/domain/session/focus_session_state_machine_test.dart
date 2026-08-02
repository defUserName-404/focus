import 'package:flutter_test/flutter_test.dart';
import 'package:focus/features/session/domain/entities/session_state.dart';
import 'package:focus/features/session/domain/services/focus_session_state_machine.dart';

import '../../helpers/fixtures.dart';

void main() {
  const machine = FocusSessionStateMachine();

  group('tick', () {
    test('increments elapsed during a running focus phase', () {
      final session = buildSession(elapsedSeconds: 10);
      final result = machine.tick(session);
      expect(result, isA<TickUpdate>());
      final update = result as TickUpdate;
      expect(update.session.elapsedSeconds, 11);
      expect(update.shouldPersist, isFalse);
    });

    test('requests persistence every 10 seconds', () {
      final session = buildSession(elapsedSeconds: 19);
      final result = machine.tick(session) as TickUpdate;
      expect(result.shouldPersist, isTrue);
      expect(result.session.elapsedSeconds, 20);
    });

    test('transitions to break when focus duration is exhausted', () {
      final session = buildSession(focusDurationMinutes: 1, elapsedSeconds: 59);
      final result = machine.tick(session);
      expect(result, isA<FocusPhaseCompleted>());
      final completed = result as FocusPhaseCompleted;
      expect(completed.session.state, SessionState.onBreak);
      expect(completed.session.elapsedSeconds, 60);
      expect(completed.session.focusPhaseEndedAt, 60);
    });

    test('completes the cycle when break duration ends', () {
      final session = buildSession(
        focusDurationMinutes: 1,
        breakDurationMinutes: 1,
        state: SessionState.onBreak,
        elapsedSeconds: 119,
        focusPhaseEndedAt: 60,
      );
      final result = machine.tick(session);
      expect(result, isA<CycleCompleted>());
      expect(result.session.state, SessionState.completed);
      expect(result.session.endTime, isNotNull);
    });

    test('is a no-op tick in idle', () {
      final session = buildSession(state: SessionState.idle, elapsedSeconds: 0);
      final result = machine.tick(session) as TickUpdate;
      expect(result.session.elapsedSeconds, 0);
    });
  });

  group('skip', () {
    test('skips focus into break while preserving elapsed', () {
      final session = buildSession(focusDurationMinutes: 25, elapsedSeconds: 30);
      final result = machine.skip(session);
      expect(result, isA<FocusPhaseCompleted>());
      expect(result!.session.state, SessionState.onBreak);
      expect(result.session.elapsedSeconds, 30);
      expect(result.session.focusPhaseEndedAt, 30);
    });

    test('skips break into completed', () {
      final session = buildSession(state: SessionState.onBreak, elapsedSeconds: 70, focusPhaseEndedAt: 60);
      final result = machine.skip(session);
      expect(result, isA<CycleCompleted>());
      expect(result!.session.state, SessionState.completed);
    });

    test('returns null for non-skippable states', () {
      expect(machine.skip(buildSession(state: SessionState.idle)), isNull);
      expect(machine.skip(buildSession(state: SessionState.completed)), isNull);
      expect(machine.skip(buildSession(state: SessionState.cancelled)), isNull);
    });
  });

  group('pause and resume', () {
    test('pauses a running session', () {
      final paused = machine.pause(buildSession(state: SessionState.running));
      expect(paused?.state, SessionState.paused);
    });

    test('pauses an on-break session', () {
      final paused = machine.pause(buildSession(state: SessionState.onBreak, focusPhaseEndedAt: 60));
      expect(paused?.state, SessionState.paused);
    });

    test('refuses to pause idle sessions', () {
      expect(machine.pause(buildSession(state: SessionState.idle)), isNull);
    });

    test('resumes into running when still in focus window', () {
      final resumed = machine.resume(
        buildSession(state: SessionState.paused, elapsedSeconds: 20, focusPhaseEndedAt: 60),
      );
      expect(resumed?.state, SessionState.running);
    });

    test('resumes into onBreak when past focus end', () {
      final resumed = machine.resume(
        buildSession(state: SessionState.paused, elapsedSeconds: 70, focusPhaseEndedAt: 60),
      );
      expect(resumed?.state, SessionState.onBreak);
    });

    test('refuses to resume non-paused sessions', () {
      expect(machine.resume(buildSession(state: SessionState.running)), isNull);
    });
  });
}
