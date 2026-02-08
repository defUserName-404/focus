class Project {
  final BigInt? id;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    this.id,
    required this.title,
    this.description,
    this.startDate,
    this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });
}
