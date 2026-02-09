import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/layout_constants.dart';
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
    return Container(
      color: Theme.of(context).canvasColor,
      child: Padding(
        padding: EdgeInsets.all(LayoutConstants.spacing.paddingRegular),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Create New Project', textAlign: TextAlign.center),
            SizedBox(height: LayoutConstants.spacing.paddingLarge),
            FTextField(
              control: FTextFieldControl.managed(controller: _titleController),
              hint: 'Project Title',
              label: Text('Title'), // Corrected to String
            ),
            SizedBox(height: LayoutConstants.spacing.paddingRegular),
            FTextField(
              control: FTextFieldControl.managed(controller: _descriptionController),
              hint: 'Project Description (Optional)',
              label: Text('Description'), // Corrected to String
              maxLines: 3,
            ),
            SizedBox(height: LayoutConstants.spacing.paddingRegular),
            FDateField.calendar(
              label: Text('Start Date'), // Corrected to String
              hint: 'Select Start Date (Optional)',
              start: _startDate,
              onSaved: (date) => setState(() => _startDate = date),
            ),
            SizedBox(height: LayoutConstants.spacing.paddingRegular),
            FDateField.calendar(
              label: Text('Deadline'), // Corrected to String
              hint: 'Select Deadline (Optional)',
              start: _deadline,
              onSaved: (date) => setState(() => _deadline = date),
            ),
            SizedBox(height: LayoutConstants.spacing.paddingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton(
                  onPress: () => Navigator.pop(context),
                  style: FButtonStyle.ghost(),
                  child: const Text('Cancel'),
                ),
                FButton(
                  onPress: () async {
                    if (_titleController.text.isNotEmpty) {
                      final newProject = await ref
                          .read(projectProvider.notifier)
                          .createProject(
                            title: _titleController.text,
                            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                            startDate: _startDate,
                            deadline: _deadline,
                          );
                      if (context.mounted) {
                        Navigator.of(context).pop(newProject);
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
