import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/task_provider.dart';

class CreateTaskModalContent extends ConsumerStatefulWidget {
  final BigInt projectId;
  final BigInt? parentTaskId;
  final int depth;

  const CreateTaskModalContent({super.key, required this.projectId, this.parentTaskId, this.depth = 0});

  @override
  ConsumerState<CreateTaskModalContent> createState() => _CreateTaskModalContentState();
}

class _CreateTaskModalContentState extends ConsumerState<CreateTaskModalContent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TaskPriority _priority = TaskPriority.medium;

  static final Map<String, TaskPriority> _priorityItems = {
    for (final priority in TaskPriority.values) priority.label: priority,
  };

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .stretch,
            children: [
              Text(widget.parentTaskId != null ? 'Create Subtask' : 'Create New Task', textAlign: .center),
              SizedBox(height: LayoutConstants.spacing.paddingLarge),
              FTextField(
                control: FTextFieldControl.managed(controller: _titleController),
                hint: 'Task Title',
                label: const Text('Title'),
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FTextField(
                control: FTextFieldControl.managed(controller: _descriptionController),
                hint: 'Task Description (Optional)',
                label: const Text('Description'),
                maxLines: 3,
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FSelect<TaskPriority>(
                onSaved: (value) {
                  if (value != null) {
                    setState(() => _priority = value);
                  }
                },
                items: _priorityItems,
                label: const Text('Priority'),
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FDateField.calendar(
                label: const Text('Start Date'),
                hint: 'Select Start Date (Optional)',
                onSaved: (date) => setState(() => _startDate = date),
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FDateField.calendar(
                label: const Text('End Date'),
                hint: 'Select End Date (Optional)',
                onSaved: (date) => setState(() => _endDate = date),
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
                  FButton(onPress: _submit, child: const Text('Create')),
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

    await ref
        .read(taskProvider(widget.projectId.toString()).notifier)
        .createTask(
          projectId: widget.projectId.toString(),
          parentTaskId: widget.parentTaskId,
          title: title,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority,
          startDate: _startDate,
          endDate: _endDate,
          depth: widget.depth,
        );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
