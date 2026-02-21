import '../entities/focus_session.dart';
import '../entities/focus_session_extensions.dart';
import '../entities/session_state.dart';

// ---------------------------------------------------------------------------
// Transition results — tell the notifier what side effects to perform
// ---------------------------------------------------------------------------

/// Discriminated union describing the outcome of a state-machine operation.
///
/// The [FocusTimer] notifier pattern-matches on these to trigger
/// audio, notifications, and persistence — keeping side effects out
/// of the pure state logic.
sealed class SessionTransition {
  /// The new session snapshot after the transition.
  FocusSession get session;
  const SessionTransition();
}

/// The elapsed counter was incremented normally (no phase change).
final class TickUpdate extends SessionTransition {
  @override
  final FocusSession session;

  /// `true` every N seconds so the notifier persists to the DB.
  final bool shouldPersist;
  const TickUpdate(this.session, {this.shouldPersist = false});
}

/// The focus phase ended → session has transitioned to break.
final class FocusPhaseCompleted extends SessionTransition {
  @override
  final FocusSession session;
  const FocusPhaseCompleted(this.session);
}

/// The entire cycle (focus + break) is done.
final class CycleCompleted extends SessionTransition {
  @override
  final FocusSession session;
  const CycleCompleted(this.session);
}

// ---------------------------------------------------------------------------
// State machine
// ---------------------------------------------------------------------------

/// Pure state-transition engine for a Pomodoro focus session.
///
/// Encapsulates **all** logic that determines how a [FocusSession] evolves
/// over time:
///
/// - **Tick**: advance the elapsed counter by one second; detect the
///   focus→break and break→completed boundaries.
/// - **Skip**: jump to the next phase regardless of elapsed time.
/// - **Pause / Resume**: toggle between paused and the correct running state,
///   taking into account whether the session is in focus or break.
///
/// The class is intentionally free of side effects (no audio, DB, or
/// notifications). The [FocusTimer] notifier reads
/// the [SessionTransition] returned by each method and performs the
/// appropriate side effects.
class FocusSessionStateMachine {
  const FocusSessionStateMachine();

  /// How frequently (in seconds) the notifier should persist to the DB.
  static const int _persistIntervalSeconds = 10;

  // -- Tick ----------------------------------------------------------------

  /// Advance [session] by one second.
  ///
  /// Returns:
  /// - [TickUpdate] when the counter simply incremented.
  /// - [FocusPhaseCompleted] when focus time was exhausted → break begins.
  /// - [CycleCompleted] when the break timer ran out.
  SessionTransition tick(FocusSession session) {
    final newElapsed = session.elapsedSeconds + 1;

    if (session.state == SessionState.running) {
      final focusLimit = session.focusDurationMinutes * 60;
      if (newElapsed >= focusLimit) {
        return FocusPhaseCompleted(_toBreak(session, fromSkip: false));
      }
      return TickUpdate(
        session.copyWith(elapsedSeconds: newElapsed),
        shouldPersist: newElapsed % _persistIntervalSeconds == 0,
      );
    }

    if (session.state == SessionState.onBreak) {
      // focusEndElapsed accounts for skipped focus phases.
      final breakEnd = session.focusEndElapsed + session.breakDurationMinutes * 60;
      if (newElapsed >= breakEnd) {
        return CycleCompleted(
          session.copyWith(state: SessionState.completed, endTime: DateTime.now()),
        );
      }
      return TickUpdate(
        session.copyWith(elapsedSeconds: newElapsed),
        shouldPersist: newElapsed % _persistIntervalSeconds == 0,
      );
    }

    // Should not tick in other states.
    return TickUpdate(session);
  }

  // -- Skip ----------------------------------------------------------------

  /// Skip the current phase.
  ///
  /// Returns `null` when the session is in a non-skippable state
  /// (idle, completed, cancelled, incomplete).
  SessionTransition? skip(FocusSession session) {
    final bool isInFocusPhase;

    switch (session.state) {
      case SessionState.running:
        isInFocusPhase = true;
      case SessionState.onBreak:
        isInFocusPhase = false;
      case SessionState.paused:
        // When paused, determine the phase from the actual focus-end timestamp.
        isInFocusPhase = session.elapsedSeconds < session.focusEndElapsed;
      default:
        return null;
    }

    if (isInFocusPhase) {
      return FocusPhaseCompleted(_toBreak(session, fromSkip: true));
    }

    return CycleCompleted(
      session.copyWith(state: SessionState.completed, endTime: DateTime.now()),
    );
  }

  // -- Pause / Resume ------------------------------------------------------

  /// Compute the paused snapshot.
  ///
  /// Returns `null` when the session is not in a pausable state.
  FocusSession? pause(FocusSession session) {
    if (session.state != SessionState.running && session.state != SessionState.onBreak) {
      return null;
    }
    return session.copyWith(state: SessionState.paused);
  }

  /// Compute the resumed snapshot, restoring the correct phase.
  ///
  /// Returns `null` when the session is not paused.
  FocusSession? resume(FocusSession session) {
    if (session.state != SessionState.paused) return null;
    final wasOnBreak = session.elapsedSeconds >= session.focusEndElapsed;
    return session.copyWith(
      state: wasOnBreak ? SessionState.onBreak : SessionState.running,
    );
  }

  // -- Helpers -------------------------------------------------------------

  /// Build the focus → break transition.
  ///
  /// When [fromSkip] is `true`, the real elapsed is preserved so stats
  /// reflect actual focus effort. Otherwise, elapsed is aligned to the
  /// full focus duration for a clean boundary.
  FocusSession _toBreak(FocusSession session, {required bool fromSkip}) {
    final focusSeconds = session.focusDurationMinutes * 60;
    final newElapsed = fromSkip ? session.elapsedSeconds : focusSeconds;
    return session.copyWith(
      state: SessionState.onBreak,
      elapsedSeconds: newElapsed,
      focusPhaseEndedAt: newElapsed,
    );
  }
}
