import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/constants/layout_constants.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/task_provider.dart'; // Placeholder for task provider

class CreateTaskModalContent extends ConsumerStatefulWidget {
  final BigInt projectId;
  const CreateTaskModalContent({super.key, required this.projectId});

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
              Text('Create New Task', textAlign: .center),
              SizedBox(height: LayoutConstants.spacing.paddingLarge),
              FTextField(
                control: FTextFieldControl.managed(controller: _titleController),
                hint: 'Task Title',
                label: Text('Title'),
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FTextField(
                control: FTextFieldControl.managed(controller: _descriptionController),
                hint: 'Task Description (Optional)',
                label: Text('Description'),
                maxLines: 3,
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FSelect<TaskPriority>(
                onSaved: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _priority = newValue;
                    });
                  }
                },
                items: _priorityItems,
                label: Text('Priority'),
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FDateField.calendar(
                label: Text('Start Date'),
                hint: 'Select Start Date (Optional)',
                start: _startDate,
                onSaved: (date) => setState(() => _startDate = date),
              ),
              SizedBox(height: LayoutConstants.spacing.paddingRegular),
              FDateField.calendar(
                label: Text('End Date'),
                hint: 'Select End Date (Optional)',
                start: _endDate,
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
                  FButton(
                    onPress: () async {
                      if (_titleController.text.isNotEmpty) {
                        await ref
                            .read(taskProvider(widget.projectId.toString()).notifier)
                            .createTask(
                              projectId: widget.projectId.toString(),
                              title: _titleController.text,
                              description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                              priority: _priority,
                              startDate: _startDate,
                              endDate: _endDate,
                              depth: 1,
                            );
                        if (context.mounted) {
                          Navigator.of(context).pop();
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
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
