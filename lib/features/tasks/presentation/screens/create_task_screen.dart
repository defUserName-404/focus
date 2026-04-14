import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/base_form_screen.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../../../core/widgets/time_field.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_reminder_mode.dart';
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
  final _customReminderHoursController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TaskPriority _priority = TaskPriority.medium;
  TaskReminderMode _reminderMode = TaskReminderMode.smart;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customReminderHoursController.dispose();
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
          control: FDateFieldControl.lifted(date: _startDate, onChange: (date) => setState(() => _startDate = date)),
          clearable: true,
        ),
        TimeField(label: 'Start Time', value: _startDate, onChanged: (date) => setState(() => _startDate = date)),
        FDateField.calendar(
          label: const Text('End Date'),
          hint: 'Select End Date (Optional)',
          start: DateTime.now(),
          control: FDateFieldControl.lifted(
            date: _endDate,
            onChange: (date) => setState(() => _endDate = date),
            validator: (value) => AppFormValidator.startDateBeforeEndDate(_startDate, value),
          ),
          autovalidateMode: AutovalidateMode.onUnfocus,
          clearable: true,
        ),
        TimeField(label: 'End Time', value: _endDate, onChanged: (date) => setState(() => _endDate = date)),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Reminder', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        ),
        FilterSelect<TaskReminderMode>(
          selected: _reminderMode,
          onChanged: (value) => setState(() => _reminderMode = value),
          options: TaskReminderMode.values,
          hint: 'Reminder',
        ),
        if (_reminderMode == TaskReminderMode.custom)
          FTextFormField(
            control: FTextFieldControl.managed(controller: _customReminderHoursController),
            label: const Text('Custom Reminder (Hours Before Deadline)'),
            hint: 'e.g. 6',
            keyboardType: TextInputType.number,
            validator: (value) {
              final parsed = int.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return 'Enter a positive number of hours';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUnfocus,
          ),
      ],
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final customMinutesBefore = _reminderMode == TaskReminderMode.custom
        ? int.tryParse(_customReminderHoursController.text.trim())
        : null;
    if (_reminderMode == TaskReminderMode.custom && (customMinutesBefore == null || customMinutesBefore <= 0)) {
      return;
    }

    await ref
        .read(taskProvider(widget.projectId.toString()).notifier)
        .createTask(
          projectId: widget.projectId.toString(),
          parentTaskId: widget.parentTaskId,
          title: title,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority,
          reminderMode: _reminderMode,
          customReminderMinutesBefore: customMinutesBefore == null ? null : customMinutesBefore * 60,
          startDate: _startDate,
          endDate: _endDate,
          depth: widget.depth,
        );

    if (mounted) context.pop();
  }
}
