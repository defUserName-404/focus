import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../../../core/common/utils/form_validators.dart';
import '../../../../core/common/widgets/base_modal_form.dart';
import '../../../../core/common/widgets/filter_select.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_provider.dart';
import '../../../tasks/domain/entities/task_priority.dart';
import '../../../tasks/presentation/providers/task_provider.dart';

/// A task-creation modal that also lets the user pick (or create) a project.
///
/// Used from the global "Tasks" tab where there is no implicit project context.
class CreateTaskWithProjectModal extends ConsumerStatefulWidget {
  const CreateTaskWithProjectModal({super.key});

  @override
  ConsumerState<CreateTaskWithProjectModal> createState() => _CreateTaskWithProjectModalState();
}

class _CreateTaskWithProjectModalState extends ConsumerState<CreateTaskWithProjectModal> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TaskPriority _priority = TaskPriority.medium;

  /// The selected existing project, if any.
  Project? _selectedProject;

  /// Whether the typed project name doesn't match any existing project.
  bool _isNewProject = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectListProvider);

    return BaseModalForm(
      title: 'Create New Task',
      fields: [
        projectsAsync.when(
          data: (projects) => _ProjectAutocomplete(
            controller: _projectController,
            projects: projects,
            onSelected: (project) {
              setState(() {
                _selectedProject = project;
                _isNewProject = false;
                _projectController.text = project.title;
              });
            },
            onChanged: (value) {
              final trimmed = value.trim();
              if (trimmed.isEmpty) {
                setState(() {
                  _selectedProject = null;
                  _isNewProject = false;
                });
                return;
              }
              final match = projects.where((p) => p.title.trim().toLowerCase() == trimmed.toLowerCase());
              setState(() {
                if (match.isNotEmpty) {
                  _selectedProject = match.first;
                  _isNewProject = false;
                } else {
                  _selectedProject = null;
                  _isNewProject = true;
                }
              });
            },
          ),
          loading: () => const FTextField(hint: 'Loading projects…', enabled: false, label: Text('Project')),
          error: (_, _) => const FTextField(hint: 'Error loading projects', enabled: false, label: Text('Project')),
        ),
        if (_isNewProject && _projectController.text.trim().isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: AppConstants.spacing.small),
            child: Row(
              children: [
                Icon(FIcons.info, size: 12, color: context.colors.mutedForeground),
                SizedBox(width: AppConstants.spacing.small),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppConstants.spacing.small),
                    child: Text(
                      'A new project "${_projectController.text.trim()}" will be created.',
                      style: context.typography.xs.copyWith(color: context.colors.mutedForeground),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Task fields (same as CreateTaskModalContent) ───────────────
        FTextFormField(
          control: FTextFieldControl.managed(controller: _titleController),
          hint: 'Task Title',
          label: const Text('Title'),
          validator: (value) => AppFormValidator.isNotEmpty(value),
          autovalidateMode: .onUnfocus,
        ),
        FTextField(
          control: FTextFieldControl.managed(controller: _descriptionController),
          hint: 'Task Description (Optional)',
          label: const Text('Description'),
          maxLines: 3,
        ),
        Align(
          alignment: .centerLeft,
          child: Text('Priority', style: context.typography.sm.copyWith(fontWeight: .w600)),
        ),
        FilterSelect<TaskPriority>(
          selected: _priority,
          onChanged: (value) => setState(() => _priority = value),
          options: TaskPriority.values,
          hint: 'Priority',
        ),
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
          autovalidateMode: .onUnfocus,
          clearable: true,
        ),
      ],
      onCancel: () => Navigator.pop(context),
      onSubmit: _submit,
      submitButtonText: 'Create',
    );
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final projectName = _projectController.text.trim();
    if (title.isEmpty || projectName.isEmpty) return;

    BigInt projectId;

    if (_selectedProject != null) {
      projectId = _selectedProject!.id!;
    } else {
      // Create a new project on the fly.
      final newProject = await ref.read(projectProvider.notifier).createProject(title: projectName);
      projectId = newProject.id!;
    }

    await ref
        .read(taskProvider(projectId.toString()).notifier)
        .createTask(
          projectId: projectId.toString(),
          title: title,
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          priority: _priority,
          startDate: _startDate,
          endDate: _endDate,
          depth: 0,
        );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

/// Autocomplete field that suggests existing projects.
class _ProjectAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final List<Project> projects;
  final ValueChanged<Project> onSelected;
  final ValueChanged<String> onChanged;

  const _ProjectAutocomplete({
    required this.controller,
    required this.projects,
    required this.onSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Project>(
      displayStringForOption: (project) => project.title,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.trim().toLowerCase();
        if (query.isEmpty) return projects;
        return projects.where((p) => p.title.toLowerCase().contains(query));
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        // Sync external controller with the Autocomplete field controller.
        textController.addListener(() {
          if (controller.text != textController.text) {
            controller.text = textController.text;
          }
          onChanged(textController.text);
        });
        // Seed from external if needed.
        if (textController.text != controller.text) {
          textController.text = controller.text;
        }

        return FTextField(
          control: FTextFieldControl.managed(controller: textController),
          focusNode: focusNode,
          hint: 'Search or type a project name',
          label: const Text('Project'),
        );
      },
      optionsViewBuilder: (context, onSelect, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final project = options.elementAt(index);
                  return ListTile(dense: true, title: Text(project.title), onTap: () => onSelect(project));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
