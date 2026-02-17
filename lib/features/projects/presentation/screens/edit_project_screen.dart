import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/datetime_formatter.dart';
import '../../../../core/common/utils/form_validators.dart';
import '../../../../core/common/widgets/base_form_screen.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_extensions.dart';
import '../providers/project_provider.dart';

class EditProjectScreen extends ConsumerStatefulWidget {
  final Project project;

  const EditProjectScreen({super.key, required this.project});

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

  @override
  Widget build(BuildContext context) {
    return BaseFormScreen(
      title: 'Edit Project',
      submitButtonText: 'Save',
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
          control: FDateFieldControl.managed(
            initial: _startDate,
            onChange: (date) => setState(() => _startDate = date),
          ),
          clearable: true,
        ),
        FDateField.calendar(
          label: const Text('Deadline'),
          hint: _deadline?.toDateString() ?? 'Select Deadline (Optional)',
          control: FDateFieldControl.managed(
            onChange: (date) => _deadline = date,
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

    final updated = widget.project.copyWith(
      title: title,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      startDate: _startDate,
      deadline: _deadline,
      updatedAt: DateTime.now(),
    );

    await ref.read(projectProvider.notifier).updateProject(updated);
    if (mounted) Navigator.of(context).pop();
  }
}
