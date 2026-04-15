import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../projects/domain/entities/project.dart';
import 'create_task_new_project_hint.dart';

class CreateTaskProjectAutocomplete extends StatefulWidget {
  final FAutocompleteController controller;
  final List<Project> projects;
  final ValueChanged<Project> onSelected;
  final ValueChanged<String> onQueryChanged;
  final ValueNotifier<bool> isNewProject;

  const CreateTaskProjectAutocomplete({
    super.key,
    required this.controller,
    required this.projects,
    required this.onSelected,
    required this.onQueryChanged,
    required this.isNewProject,
  });

  @override
  State<CreateTaskProjectAutocomplete> createState() => _CreateTaskProjectAutocompleteState();
}

class _CreateTaskProjectAutocompleteState extends State<CreateTaskProjectAutocomplete> {
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
        CreateTaskNewProjectHint(isNewProject: widget.isNewProject, controller: widget.controller),
      ],
    );
  }
}
