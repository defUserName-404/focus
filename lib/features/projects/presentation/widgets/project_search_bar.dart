import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Search bar for filtering by title or description.
/// Manages its own controller; reports changes via [onChanged].
class ProjectSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  const ProjectSearchBar({super.key, this.controller, required this.onChanged});

  @override
  State<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends State<ProjectSearchBar> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: FTextFieldControl.managed(controller: _controller),
      hint: 'Search...',
      prefixBuilder: (_, _, _) =>
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(FIcons.search)),
      clearable: (value) => value.text.isNotEmpty,
    );
  }
}
