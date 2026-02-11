import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_extensions.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/task_provider.dart';

class EditTaskModalContent extends ConsumerStatefulWidget {
  final Task task;

  const EditTaskModalContent({super.key, required this.task});

  @override
  ConsumerState<EditTaskModalContent> createState() => _EditTaskModalContentState();
}

class _EditTaskModalContentState extends ConsumerState<EditTaskModalContent> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late TaskPriority _priority;

  static final Map<String, TaskPriority> _priorityItems = {
    for (final priority in TaskPriority.values) priority.label: priority,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(text: widget.task.description ?? '');
    _startDate = widget.task.startDate;
    _endDate = widget.task.endDate;
    _priority = widget.task.priority;
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
              const Text('Edit Task', textAlign: TextAlign.center),
              SizedBox(height: AppConstants.spacing.large),
              FTextField(
                control: FTextFieldControl.managed(controller: _titleController),
                hint: 'Task Title',
                label: const Text('Title'),
              ),
              SizedBox(height: AppConstants.spacing.regular),
              FTextField(
                control: FTextFieldControl.managed(controller: _descriptionController),
                hint: 'Task Description (Optional)',
                label: const Text('Description'),
                maxLines: 3,
              ),
              SizedBox(height: AppConstants.spacing.regular),
              FSelect<TaskPriority>(
                control: FSelectControl.managed(
                  initial: _priority,
                  onChange: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
                items: _priorityItems,
                label: const Text('Priority'),
              ),
              SizedBox(height: AppConstants.spacing.regular),
              FDateField.calendar(
                label: const Text('Start Date'),
                hint: _startDate != null ? _fmtDate(_startDate) : 'Select Start Date (Optional)',
                control: FDateFieldControl.managed(initial: _startDate, onChange: (date) => _startDate = date),
                clearable: true,
              ),
              SizedBox(height: AppConstants.spacing.regular),
              FDateField.calendar(
                label: const Text('End Date'),
                hint: _endDate != null ? _fmtDate(_endDate) : 'Select End Date (Optional)',
                control: FDateFieldControl.managed(initial: _endDate, onChange: (date) => _endDate = date),
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

    final updated = widget.task.copyWith(
      title: title,
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      priority: _priority,
      startDate: _startDate,
      endDate: _endDate,
      updatedAt: DateTime.now(),
    );

    await ref.read(taskProvider(widget.task.projectId.toString()).notifier).updateTask(updated);
    if (mounted) Navigator.of(context).pop();
  }
}
