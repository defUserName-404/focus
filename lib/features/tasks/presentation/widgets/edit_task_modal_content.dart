import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/date_formatter.dart';
import '../../../../core/common/utils/form_validators.dart';
import '../../../../core/common/widgets/base_modal_form.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/task_provider.dart';

class EditTaskModalContent extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskModalContent({super.key, required this.task});

  @override
  ConsumerState<EditTaskModalContent> createState() => _EditTaskModalContentState();
}

class _EditTaskModalContentState extends ConsumerState<EditTaskModalContent> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late TaskPriority _priority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
    _priority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModalForm(
      title: 'Edit Task',
      fields: [
        FTextFormField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Task Title',
          label: const Text('Title'),
          validator: (value) => AppFormValidator.isNotEmpty(value),
          autovalidateMode: .onUnfocus,
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Task Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        Align(
          alignment: .centerLeft,
          child: Text('Priority', style: context.typography.sm.copyWith(fontWeight: .w600)),
        ),
        FilterSelect<TaskPriority>(
          selected: _priority,
          onChanged: (value) {
            setState(() => _priority = value);
          },
          options: TaskPriority.values,
          hint: 'Priority',
        ),
        FDateField.calendar(
          label: const Text('Start Date'),
          hint: _startDate?.toDateString() ?? 'Select Start Date (Optional)',
          control: FDateFieldControl.managed(initial: _startDate, onChange: (date) => _startDate = date),
          clearable: true,
        ),
        FDateField.calendar(
          label: const Text('End Date'),
          hint: _endDate?.toDateString() ?? 'Select End Date (Optional)',
          control: FDateFieldControl.managed(
            onChange: (date) => _endDate = date,
            validator: (value) => AppFormValidator.startDateBeforeEndDate(_startDate, value),
          ),
          autovalidateMode: .onUnfocus,
          clearable: true,
        ),
      ],
      onCancel: () => Navigator.pop(context),
      onSubmit: _submit,
      submitButtonText: 'Save',
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = widget.task.copyWith(
      title: title,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      priority: _priority,
      startDate: _startDate,
      endDate: _endDate,
      updatedAt: DateTime.now(),
    );

    await ref.read(taskProvider(widget.task.projectId.toString()).notifier).updateTask(updated);
    if (mounted) Navigator.of(context).pop();
  }
}
