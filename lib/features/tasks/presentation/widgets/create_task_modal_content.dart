import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/widgets/base_modal_form.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/task_provider.dart';

class CreateTaskModalContent extends ConsumerStatefulWidget {
  final BigInt projectId;
  final BigInt? parentTaskId;
  final int depth;

  const CreateTaskModalContent({super.key, required this.projectId, this.parentTaskId, this.depth = 0});

  @override
  ConsumerState<CreateTaskModalContent> createState() => _CreateTaskModalContentState();
}

class _CreateTaskModalContentState extends ConsumerState<CreateTaskModalContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModalForm(
      title: widget.parentTaskId != null ? 'Create Subtask' : 'Create New Task',
      fields: [
        FTextField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Task Title',
          label: const Text('Title'),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Task Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        SizedBox(height: AppConstants.spacing.regular),
        FilterSelect<TaskPriority>(
          selected: _priority,
          onChanged: (value) {
            if (value != null) {
              setState(() => _priority = value);
            }
          },
          options: TaskPriority.values,
          hint: 'Priority',
        ),
        SizedBox(height: AppConstants.spacing.regular),
        FDateField.calendar(
          label: const Text('Start Date'),
          hint: 'Select Start Date (Optional)',
          control: FDateFieldControl.managed(onChange: (date) => _startDate = date),
          clearable: true,
        ),
        SizedBox(height: AppConstants.spacing.regular),
        FDateField.calendar(
          label: const Text('End Date'),
          hint: 'Select End Date (Optional)',
          control: FDateFieldControl.managed(onChange: (date) => _endDate = date),
          clearable: true,
        ),
      ],
      onCancel: () => Navigator.pop(context),
      onSubmit: _submit,
      submitButtonText: 'Create',
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    await ref
        .read(taskProvider(widget.projectId.toString()).notifier)
        .createTask(
          projectId: widget.projectId.toString(),
          parentTaskId: widget.parentTaskId,
          title: title,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority,
          startDate: _startDate,
          endDate: _endDate,
          depth: widget.depth,
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
