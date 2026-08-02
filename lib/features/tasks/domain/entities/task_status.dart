/// Lifecycle status of a task.
///
/// Persisted via Drift `intEnum` — enum declaration order is a schema contract.
enum TaskStatus {
  todo,
  inProgress,
  blocked,
  done;

  String get label => switch (this) {
    TaskStatus.todo => 'To Do',
    TaskStatus.inProgress => 'In Progress',
    TaskStatus.blocked => 'Blocked',
    TaskStatus.done => 'Done',
  };
}
