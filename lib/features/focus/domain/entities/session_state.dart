enum SessionState {
  idle,
  running,
  paused,
  onBreak,
  completed,
  cancelled;

  String get label => switch (this) {
    SessionState.completed => 'Completed',
    SessionState.cancelled => 'Cancelled',
    SessionState.running => 'Running',
    SessionState.paused => 'Paused',
    SessionState.onBreak => 'On Break',
    SessionState.idle => 'Idle',
  };
}
