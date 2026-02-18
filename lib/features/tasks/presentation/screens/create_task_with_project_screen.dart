import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/form_validators.dart';
import '../../../../core/common/widgets/base_form_screen.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../domain/entities/task_priority.dart';
import '../providers/task_provider.dart';

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
  final _projectController = FAutocompleteController();
  DateTime? _startDate;
  DateTime? _endDate;
  final ValueNotifier<TaskPriority> _priority = ValueNotifier(TaskPriority.medium);
  final ValueNotifier<Project?> _selectedProject = ValueNotifier(null);
  final ValueNotifier<bool> _isNewProject = ValueNotifier(false);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
          data: (projects) => _ProjectAutocomplete(
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
        _PrioritySelector(priority: _priority),
        FDateField.calendar(
          label: const Text('Start Date'),
          hint: 'Select Start Date (Optional)',
          control: FDateFieldControl.managed(onChange: (date) => _startDate = date),
          clearable: true,
        ),
        FDateField.calendar(
          label: const Text('End Date'),
          hint: 'Select End Date (Optional)',
          control: FDateFieldControl.managed(
            onChange: (date) => _endDate = date,
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
    final projectName = _projectController.text.trim();
    if (title.isEmpty || projectName.isEmpty) return;

    BigInt projectId;

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
          startDate: _startDate,
          endDate: _endDate,
          depth: 0,
        );

    if (mounted) Navigator.of(context).pop();
  }
}

//  Private helper widgets

class _PrioritySelector extends StatelessWidget {
  final ValueNotifier<TaskPriority> priority;

  const _PrioritySelector({required this.priority});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TaskPriority>(
      valueListenable: priority,
      builder: (context, selected, _) {
        return FilterSelect<TaskPriority>(
          selected: selected,
          onChanged: (value) => priority.value = value,
          options: TaskPriority.values,
          hint: 'Priority',
        );
      },
    );
  }
}

class _ProjectAutocomplete extends StatefulWidget {
  final FAutocompleteController controller;
  final List<Project> projects;
  final ValueChanged<Project> onSelected;
  final ValueChanged<String> onQueryChanged;
  final ValueNotifier<bool> isNewProject;

  const _ProjectAutocomplete({
    required this.controller,
    required this.projects,
    required this.onSelected,
    required this.onQueryChanged,
    required this.isNewProject,
  });

  @override
  State<_ProjectAutocomplete> createState() => _ProjectAutocompleteState();
}

class _ProjectAutocompleteState extends State<_ProjectAutocomplete> {
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    _lastText = widget.controller.text;
    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    final text = widget.controller.text;
    if (text == _lastText) return;
    _lastText = text;
    widget.onQueryChanged(text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FAutocomplete.builder(
          control: FAutocompleteControl.managed(controller: widget.controller),
          hint: 'Search or type a project name',
          label: const Text('Project'),
          validator: (value) => AppFormValidator.isNotEmpty(value),
          filter: (query) {
            final trimmed = query.trim().toLowerCase();
            if (trimmed.isEmpty) return widget.projects.map((p) => p.title);
            return widget.projects.where((p) => p.title.toLowerCase().contains(trimmed)).map((p) => p.title);
          },
          contentBuilder: (context, query, values) => [
            for (final title in values) FAutocompleteItem(value: title, title: Text(title)),
          ],
        ),
        _NewProjectHint(isNewProject: widget.isNewProject, controller: widget.controller),
      ],
    );
  }
}

class _NewProjectHint extends StatelessWidget {
  final ValueNotifier<bool> isNewProject;
  final FAutocompleteController controller;

  const _NewProjectHint({required this.isNewProject, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([isNewProject, controller]),
      builder: (context, _) {
        final isNew = isNewProject.value;
        final projectName = controller.text.trim();
        if (!isNew || projectName.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(top: AppConstants.spacing.small),
          child: Row(
            children: [
              Icon(FIcons.info, size: 12, color: context.colors.mutedForeground),
              SizedBox(width: AppConstants.spacing.small),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: AppConstants.spacing.small),
                  child: Text(
                    'A new project "$projectName" will be created.',
                    style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
