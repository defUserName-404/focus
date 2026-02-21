import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/form_validators.dart';
import '../../../../core/common/widgets/base_form_screen.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/project_provider.dart';

class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  ConsumerState<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
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
    return BaseFormScreen(
      title: 'New Project',
      submitButtonText: 'Create Project',
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
          hint: 'Select Start Date (Optional)',
          start: DateTime.now(),
          control: FDateFieldControl.managed(onChange: (date) => _startDate = date),
          clearable: true,
        ),
        FDateField.calendar(
          label: const Text('Deadline'),
          hint: 'Select Deadline (Optional)',
          start: DateTime.now(),
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

    final project = await ref
        .read(projectProvider.notifier)
        .createProject(
          title: title,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          startDate: _startDate,
          deadline: _deadline,
        );

    if (mounted && project.id != null) {
      // Pop this screen and navigate to the new project's detail page.
      Navigator.of(context)
        ..pop()
        ..pushNamed(RouteConstants.projectDetailRoute, arguments: project.id!);
    }
  }
}
