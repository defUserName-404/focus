import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:focus/core/utils/date_time_utils.dart';

import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/base_form_screen.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../../../core/widgets/time_field.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_reminder_mode.dart';
import '../providers/task_provider.dart';
import '../widgets/task_recurrence_fields.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  final Task task;
  final bool isEmbedded;
  final VoidCallback? onDismiss;
  final ValueChanged<Task>? onSaved;

  const EditTaskScreen({super.key, required this.task, this.isEmbedded = false, this.onDismiss, this.onSaved});

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customReminderHoursController;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late TaskPriority _priority;
  late TaskReminderMode _reminderMode;
  late bool _isHabit;
  late RecurrencePreset _recurrencePreset;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _customReminderHoursController = TextEditingController(
      text: widget.task.customReminderMinutesBefore == null
          ? ''
          : (widget.task.customReminderMinutesBefore! ~/ 60).toString(),
    );
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
    _priority = widget.task.priority;
    _reminderMode = widget.task.reminderMode;
    _isHabit = widget.task.isHabit;
    _recurrencePreset = TaskRecurrenceFields.presetFromRule(widget.task.recurrenceRule);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customReminderHoursController.dispose();
    super.dispose();
  }

  void _finish(Task task) {
    if (widget.onSaved != null) {
      widget.onSaved!(task);
      return;
    }
    if (widget.onDismiss != null) {
      widget.onDismiss!();
      return;
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormScreen(
      title: 'Edit Task',
      submitButtonText: 'Save',
      isEmbedded: widget.isEmbedded,
      onDismiss: widget.onDismiss,
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
          hint: _startDate?.toDateString() ?? 'Select Start Date (Optional)',
          selectionControl: FDateSelectionControl.liftedSingle(
            value: _startDate,
            onChange: (date) => setState(() => _startDate = date),
          ),
          clearable: true,
        ),
        TimeField(label: 'Start Time', value: _startDate, onChanged: (date) => setState(() => _startDate = date)),
        FDateField.calendar(
          label: const Text('End Date'),
          hint: _endDate?.toDateString() ?? 'Select End Date (Optional)',
          selectionControl: FDateSelectionControl.liftedSingle(
            value: _endDate,
            onChange: (date) => setState(() => _endDate = date),
          ),
          validator: (value) => AppFormValidator.startDateBeforeEndDate(_startDate, value),
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
        TaskRecurrenceFields(
          isHabit: _isHabit,
          preset: _recurrencePreset,
          onHabitChanged: (value) => setState(() => _isHabit = value),
          onPresetChanged: (value) => setState(() {
            _recurrencePreset = value;
            if (value != RecurrencePreset.none && !_isHabit) {
              _isHabit = true;
            }
          }),
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

    final recurrenceRule = TaskRecurrenceFields.ruleForPreset(_recurrencePreset, anchor: _startDate);

    final updated = widget.task.copyWith(
      title: title,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      priority: _priority,
      reminderMode: _reminderMode,
      customReminderMinutesBefore: customMinutesBefore == null ? null : customMinutesBefore * 60,
      startDate: _startDate,
      endDate: _endDate,
      recurrenceRule: recurrenceRule,
      recurrenceAnchorDate: recurrenceRule != null
          ? (_startDate ?? widget.task.recurrenceAnchorDate ?? DateTimeUtils.now())
          : null,
      isHabit: _isHabit || recurrenceRule != null,
      updatedAt: DateTimeUtils.now(),
    );

    await ref.read(taskProvider(widget.task.projectId.toString()).notifier).updateTask(updated);
    if (mounted) _finish(updated);
  }
}
