import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/widget_extensions.dart';
import '../../../../core/common/widgets/base_modal_form.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/project_provider.dart';

class CreateProjectModalContent extends ConsumerStatefulWidget {
  const CreateProjectModalContent({super.key});

  @override
  ConsumerState<CreateProjectModalContent> createState() => _CreateProjectModalContentState();
}

class _CreateProjectModalContentState extends ConsumerState<CreateProjectModalContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _deadline;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseModalForm(
      title: 'Create New Project',
      fields: [
        FTextField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Project Title',
          label: const Text('Title'),
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Project Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        FDateField.calendar(
          label: const Text('Start Date'),
          hint: 'Select Start Date (Optional)',
          control: FDateFieldControl.managed(onChange: (date) => _startDate = date),
          clearable: true,
        ),
        FDateField.calendar(
          label: const Text('Deadline'),
          hint: 'Select Deadline (Optional)',
          control: FDateFieldControl.managed(onChange: (date) => _deadline = date),
          clearable: true,
        ),
      ].withSpacing(AppConstants.spacing.regular),
      onCancel: () => Navigator.pop(context),
      onSubmit: () async {
        if (_titleController.text.isNotEmpty) {
          await ref
              .read(projectProvider.notifier)
              .createProject(
                title: _titleController.text,
                description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                startDate: _startDate,
                deadline: _deadline,
              );
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      submitButtonText: 'Create',
    );
  }
}
