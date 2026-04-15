import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import 'package:focus/core/utils/date_time_utils.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../../core/widgets/base_form_screen.dart';
import '../../../../core/widgets/filter_select.dart';
import '../../../../core/widgets/time_field.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_reminder_mode.dart';
import '../providers/task_provider.dart';
import '../widgets/create_task_priority_selector.dart';
import '../widgets/create_task_project_autocomplete.dart';

/// Full-screen form that creates a task and optionally a new project.
///
/// Used from the global "Tasks" tab where there is no implicit project.
class CreateTaskWithProjectScreen extends ConsumerStatefulWidget {
  const CreateTaskWithProjectScreen({super.key});

  @override
  ConsumerState<CreateTaskWithProjectScreen> createState() => _CreateTaskWithProjectScreenState();
}

class _CreateTaskWithProjectScreenState extends ConsumerState<CreateTaskWithProjectScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _customReminderHoursController = TextEditingController();
  final _projectController = FAutocompleteController();
  DateTime? _startDate;
  DateTime? _endDate;
  TaskReminderMode _reminderMode = TaskReminderMode.smart;
  final ValueNotifier<TaskPriority> _priority = ValueNotifier(TaskPriority.medium);
  final ValueNotifier<Project?> _selectedProject = ValueNotifier(null);
  final ValueNotifier<bool> _isNewProject = ValueNotifier(false);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customReminderHoursController.dispose();
    _projectController.dispose();
    _priority.dispose();
    _selectedProject.dispose();
    _isNewProject.dispose();
    super.dispose();
  }

  void _handleProjectQueryChange(String value, List<Project> projects) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      _selectedProject.value = null;
      _isNewProject.value = false;
      return;
    }
    final match = projects.where((p) => p.title.trim().toLowerCase() == trimmed.toLowerCase());
    if (match.isNotEmpty) {
      _selectedProject.value = match.first;
      _isNewProject.value = false;
    } else {
      _selectedProject.value = null;
      _isNewProject.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return BaseFormScreen(
      title: 'New Task',
      submitButtonText: 'Create Task',
      onSubmit: _submit,
      fields: [
        projectsAsync.when(
          data: (projects) => CreateTaskProjectAutocomplete(
            controller: _projectController,
            projects: projects,
            onSelected: (project) {
              _selectedProject.value = project;
              _isNewProject.value = false;
              _projectController.text = project.title;
            },
            onQueryChanged: (value) => _handleProjectQueryChange(value, projects),
            isNewProject: _isNewProject,
          ),
          loading: () => const FTextField(hint: 'Loading projects…', enabled: false, label: Text('Project')),
          error: (_, _) => const FTextField(hint: 'Error loading projects', enabled: false, label: Text('Project')),
        ),
        FTextFormField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Task Title',
          label: const Text('Title'),
          validator: (value) => AppFormValidator.isNotEmpty(value),
          autovalidateMode: AutovalidateMode.onUnfocus,
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Task Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Priority', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        ),
        CreateTaskPrioritySelector(priority: _priority),
        FDateField.calendar(
          label: const Text('Start Date'),
          hint: 'Select Start Date (Optional)',
          start: DateTimeUtils.now(),
          control: FDateFieldControl.lifted(date: _startDate, onChange: (date) => setState(() => _startDate = date)),
          clearable: true,
        ),
        TimeField(label: 'Start Time', value: _startDate, onChanged: (date) => setState(() => _startDate = date)),
        FDateField.calendar(
          label: const Text('End Date'),
          hint: 'Select End Date (Optional)',
          start: DateTimeUtils.now(),
          control: FDateFieldControl.lifted(
            date: _endDate,
            onChange: (date) => setState(() => _endDate = date),
            validator: (value) => AppFormValidator.startDateBeforeEndDate(_startDate, value),
          ),
          autovalidateMode: AutovalidateMode.onUnfocus,
          clearable: true,
        ),
        TimeField(label: 'End Time', value: _endDate, onChanged: (date) => setState(() => _endDate = date)),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Reminder', style: context.typography.sm.copyWith(fontWeight: FontWeight.w600)),
        ),
        FilterSelect<TaskReminderMode>(
          selected: _reminderMode,
          onChanged: (value) => setState(() => _reminderMode = value),
          options: TaskReminderMode.values,
          hint: 'Reminder',
        ),
        if (_reminderMode == TaskReminderMode.custom)
          FTextFormField(
            control: FTextFieldControl.managed(controller: _customReminderHoursController),
            label: const Text('Custom Reminder (Hours Before Deadline)'),
            hint: 'e.g. 6',
            keyboardType: TextInputType.number,
            validator: (value) {
              final parsed = int.tryParse(value ?? '');
              if (parsed == null || parsed <= 0) {
                return 'Enter a positive number of hours';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUnfocus,
          ),
      ],
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final projectName = _projectController.text.trim();
    if (title.isEmpty || projectName.isEmpty) return;

    final customMinutesBefore = _reminderMode == TaskReminderMode.custom
        ? int.tryParse(_customReminderHoursController.text.trim())
        : null;
    if (_reminderMode == TaskReminderMode.custom && (customMinutesBefore == null || customMinutesBefore <= 0)) {
      return;
    }

    int projectId;

    if (_selectedProject.value != null) {
      projectId = _selectedProject.value!.id!;
    } else {
      final newProject = await ref.read(projectProvider.notifier).createProject(title: projectName);
      projectId = newProject.id!;
    }

    await ref
        .read(taskProvider(projectId.toString()).notifier)
        .createTask(
          projectId: projectId.toString(),
          title: title,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority.value,
          reminderMode: _reminderMode,
          customReminderMinutesBefore: customMinutesBefore == null ? null : customMinutesBefore * 60,
          startDate: _startDate,
          endDate: _endDate,
          depth: 0,
        );

    if (mounted) context.pop();
  }
}
