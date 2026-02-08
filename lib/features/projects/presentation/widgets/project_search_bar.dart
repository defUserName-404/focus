import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Search bar for filtering projects by title or description
class ProjectSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const ProjectSearchBar({super.key, required this.controller, required this.onChanged});

  @override
  State<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends State<ProjectSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged(widget.controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: FTextFieldControl.managed(controller: widget.controller),
      hint: 'Search projects...',
      prefixBuilder: (_, _, _) => const Icon(FIcons.search),
      clearable: (value) => value.text.isNotEmpty,
    );
  }
}
