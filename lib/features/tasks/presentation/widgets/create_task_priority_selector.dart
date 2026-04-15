import 'package:flutter/material.dart';

import '../../../../core/widgets/filter_select.dart';
import '../../domain/entities/task_priority.dart';

class CreateTaskPrioritySelector extends StatelessWidget {
  final ValueNotifier<TaskPriority> priority;

  const CreateTaskPrioritySelector({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TaskPriority>(
      valueListenable: priority,
      builder: (context, selected, _) {
        return FilterSelect<TaskPriority>(
          selected: selected,
          onChanged: (value) => priority.value = value,
          options: TaskPriority.values,
          hint: 'Priority',
        );
      },
    );
  }
}
