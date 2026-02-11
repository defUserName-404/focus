import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ProjectSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;

  const ProjectSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    required this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends State<ProjectSearchBar> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  Timer? _debounce;

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
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FTextField(
      control: FTextFieldControl.managed(controller: _controller),
      focusNode: widget.focusNode,
      hint: 'Search...',
      prefixBuilder: (_, _, _) =>
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(FIcons.search)),
      clearable: (value) => value.text.isNotEmpty,
    );
  }
}
