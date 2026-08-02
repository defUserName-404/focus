import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/base_form_screen.dart';
import '../../../../core/widgets/time_field.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/project_template.dart';
import '../providers/project_provider.dart';
import '../providers/project_template_provider.dart';
import '../widgets/project_template_picker.dart';

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
  ProjectTemplate? _selectedTemplate;
  bool _titleTouched = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onTemplateChanged(ProjectTemplate? template) {
    setState(() {
      _selectedTemplate = template;
      if (template == null) return;
      if (!_titleTouched || _titleController.text.trim().isEmpty) {
        _titleController.text = template.payload.defaultTitle ?? template.name;
      }
      if (_descriptionController.text.trim().isEmpty && template.payload.defaultDescription != null) {
        _descriptionController.text = template.payload.defaultDescription!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseFormScreen(
      title: 'New Project',
      submitButtonText: _selectedTemplate == null ? 'Create Project' : 'Create from Template',
      onSubmit: _submit,
      fields: [
        ProjectTemplatePicker(selected: _selectedTemplate, onChanged: _onTemplateChanged),
        FTextFormField(
          control: FTextFieldControl.managed(controller: _titleController, onChange: (_) => _titleTouched = true),
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
          selectionControl: FDateSelectionControl.liftedSingle(
            value: _startDate,
            onChange: (date) => setState(() => _startDate = date),
          ),
          clearable: true,
        ),
        TimeField(label: 'Start Time', value: _startDate, onChanged: (date) => setState(() => _startDate = date)),
        FDateField.calendar(
          label: const Text('Deadline'),
          hint: 'Select Deadline (Optional)',
          selectionControl: FDateSelectionControl.liftedSingle(
            value: _deadline,
            onChange: (date) => setState(() => _deadline = date),
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
    final description = _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim();
    final template = _selectedTemplate;
    if (template != null) {
      final result = await ref
          .read(projectTemplateServiceProvider)
          .applyTemplate(
            template: template,
            title: title,
            description: description,
            startDate: _startDate,
            deadline: _deadline,
          );
      if (!mounted) return;
      switch (result) {
        case Success(:final value):
          await ref.read(projectProvider.notifier).reload();
          if (!mounted) return;
          if (value.id != null) {
            context.pop();
            context.push(AppRoutes.projectDetailPath(value.id!));
          }
        case Failure(:final failure):
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      }
      return;
    }
    final project = await ref
        .read(projectProvider.notifier)
        .createProject(title: title, description: description, startDate: _startDate, deadline: _deadline);
    if (mounted && project.id != null) {
      context.pop();
      context.push(AppRoutes.projectDetailPath(project.id!));
    }
  }
}
