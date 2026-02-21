import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/form_validators.dart';
import '../../../../core/common/widgets/base_form_screen.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/task_provider.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final int projectId;
  final int? parentTaskId;
  final int depth;

  const CreateTaskScreen({super.key, required this.projectId, this.parentTaskId, this.depth = 0});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
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
    return BaseFormScreen(
      title: widget.parentTaskId != null ? 'New Subtask' : 'New Task',
      submitButtonText: 'Create Task',
      onSubmit: _submit,
      fields: [
        FTextFormField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Task Title',
          label: const Text('Title'),
          validator: (value) => AppFormValidator.isNotEmpty(value),
          autovalidateMode: AutovalidateMode.onUnfocus,
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Task Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Priority', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        ),
        FilterSelect<TaskPriority>(
          selected: _priority,
          onChanged: (value) => setState(() => _priority = value),
          options: TaskPriority.values,
          hint: 'Priority',
        ),
        FDateField.calendar(
          label: const Text('Start Date'),
          hint: 'Select Start Date (Optional)',
          start: DateTime.now(),
          control: FDateFieldControl.managed(onChange: (date) => _startDate = date),
          clearable: true,
        ),
        FDateField.calendar(
          label: const Text('End Date'),
          hint: 'Select End Date (Optional)',
          start: DateTime.now(),
          control: FDateFieldControl.managed(
            onChange: (date) => _endDate = date,
            validator: (value) => AppFormValidator.startDateBeforeEndDate(_startDate, value),
          ),
          autovalidateMode: AutovalidateMode.onUnfocus,
          clearable: true,
        ),
      ],
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

    if (mounted) Navigator.of(context).pop();
  }
}
