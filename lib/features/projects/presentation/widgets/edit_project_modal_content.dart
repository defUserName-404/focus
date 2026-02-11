import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

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

  String _fmtDate(DateTime? dt) => dt != null ? DateFormat('MMM d, yyyy').format(dt) : '';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: Padding(
        padding: EdgeInsets.all(AppConstants.spacing.regular),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Edit Project', textAlign: TextAlign.center),
              SizedBox(height: AppConstants.spacing.large),
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
                hint: _startDate != null ? _fmtDate(_startDate) : 'Select Start Date (Optional)',
                control: FDateFieldControl.managed(
                  initial: _startDate,
                  onChange: (date) => setState(() => _startDate = date),
                ),
                clearable: true,
              ),
              SizedBox(height: AppConstants.spacing.regular),
              FDateField.calendar(
                label: const Text('Deadline'),
                hint: _deadline != null ? _fmtDate(_deadline) : 'Select Deadline (Optional)',
                control: FDateFieldControl.managed(
                  initial: _deadline,
                  onChange: (date) => setState(() => _deadline = date),
                ),
                clearable: true,
              ),
              SizedBox(height: AppConstants.spacing.large),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FButton(
                    onPress: () => Navigator.pop(context),
                    style: FButtonStyle.ghost(),
                    child: const Text('Cancel'),
                  ),
                  FButton(onPress: _submit, child: const Text('Save')),
                ],
              ),
            ],
          ),
        ),
      ),
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
