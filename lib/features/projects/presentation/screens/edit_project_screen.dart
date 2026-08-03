import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/utils/datetime_formatter.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/base_form_screen.dart';
import '../../../../core/widgets/time_field.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_extensions.dart';
import '../providers/project_provider.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final Project project;
  final bool isEmbedded;
  final VoidCallback? onDismiss;
  final ValueChanged<Project>? onSaved;

  const EditProjectScreen({super.key, required this.project, this.isEmbedded = false, this.onDismiss, this.onSaved});

  @override
  ConsumerState<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends ConsumerState<EditProjectScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime? _startDate;
  late DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.project.title);
    _descriptionController = TextEditingController(text: widget.project.description ?? '');
    _startDate = widget.project.startDate;
    _deadline = widget.project.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _finish(Project project) {
    if (widget.onSaved != null) {
      widget.onSaved!(project);
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
      title: 'Edit Project',
      submitButtonText: 'Save',
      isEmbedded: widget.isEmbedded,
      onDismiss: widget.onDismiss,
      onSubmit: _submit,
      fields: [
        FTextFormField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Project Title',
          label: const Text('Title'),
          validator: (value) => AppFormValidator.isNotEmpty(value),
          autovalidateMode: AutovalidateMode.onUnfocus,
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Project Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        FDateField.calendar(
          label: const Text('Start Date'),
          hint: _startDate?.toDateString() ?? 'Select Start Date (Optional)',
          selectionControl: FDateSelectionControl.liftedSingle(
            value: _startDate,
            onChange: (date) => setState(() => _startDate = DateTimeUtils.normalizeLocal(date)),
          ),
          clearable: true,
        ),
        TimeField(label: 'Start Time', value: _startDate, onChanged: (date) => setState(() => _startDate = date)),
        FDateField.calendar(
          label: const Text('Deadline'),
          hint: _deadline?.toDateString() ?? 'Select Deadline (Optional)',
          selectionControl: FDateSelectionControl.liftedSingle(
            value: _deadline,
            onChange: (date) => setState(() => _deadline = DateTimeUtils.normalizeLocal(date)),
          ),
          validator: (value) => AppFormValidator.startDateBeforeEndDate(_startDate, value),
          autovalidateMode: AutovalidateMode.onUnfocus,
          clearable: true,
        ),
        TimeField(label: 'Deadline Time', value: _deadline, onChanged: (date) => setState(() => _deadline = date)),
      ],
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = widget.project.copyWith(
      title: title,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      startDate: DateTimeUtils.normalizeLocal(_startDate),
      deadline: DateTimeUtils.normalizeLocal(_deadline),
      updatedAt: DateTimeUtils.now(),
    );

    await ref.read(projectProvider.notifier).updateProject(updated);
    if (mounted) _finish(updated);
  }
}
