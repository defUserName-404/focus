import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/date_formatter.dart';
import '../../../../core/common/widgets/base_modal_form.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_extensions.dart';
import '../providers/project_provider.dart';

class EditProjectModalContent extends ConsumerStatefulWidget {
  final Project project;

  const EditProjectModalContent({super.key, required this.project});

  @override
  ConsumerState<EditProjectModalContent> createState() => _EditProjectModalContentState();
}

class _EditProjectModalContentState extends ConsumerState<EditProjectModalContent> {
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
    return BaseModalForm(
      title: 'Edit Project',
      fields: [
        FTextField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Project Title',
          label: const Text('Title'),
        ),
        SizedBox(height: AppConstants.spacing.regular),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Project Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        SizedBox(height: AppConstants.spacing.regular),
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
          control: FDateFieldControl.managed(initial: _deadline, onChange: (date) => setState(() => _deadline = date)),
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
