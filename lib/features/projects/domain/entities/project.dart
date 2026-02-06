class Project {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });
}
