import '../../../../core/common/widgets/filter_select.dart';

enum TaskPriority implements FilterSelectable {
  critical,
  high,
  medium,
  low;

  @override
  String get label {
    switch (this) {
      case TaskPriority.critical:
        return 'Critical';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}
