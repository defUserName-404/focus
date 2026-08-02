enum ProjectDetailTab { overview, tasks, board, milestones, timeline }

extension ProjectDetailTabX on ProjectDetailTab {
  String get label => switch (this) {
    ProjectDetailTab.overview => 'Overview',
    ProjectDetailTab.tasks => 'Tasks',
    ProjectDetailTab.board => 'Board',
    ProjectDetailTab.milestones => 'Milestones',
    ProjectDetailTab.timeline => 'Timeline',
  };
}
