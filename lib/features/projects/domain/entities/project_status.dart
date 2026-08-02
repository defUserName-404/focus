/// Lifecycle status of a project.
///
/// Persisted via Drift `intEnum` — enum declaration order is a schema contract.
enum ProjectStatus {
  active,
  onHold,
  completed,
  archived;

  String get label => switch (this) {
    ProjectStatus.active => 'Active',
    ProjectStatus.onHold => 'On Hold',
    ProjectStatus.completed => 'Completed',
    ProjectStatus.archived => 'Archived',
  };
}
