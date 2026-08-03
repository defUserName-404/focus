import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../providers/keyboard_action_provider.dart';

class AppSearchBar extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onChanged;
  final String hint;
  final Duration debounceDuration;

  const AppSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    required this.onChanged,
    this.hint = 'Search...',
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  ConsumerState<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends ConsumerState<AppSearchBar> {
  late final TextEditingController _controller;
  late final bool _ownsController;
  late final FocusNode _focusNode;
  late final bool _ownsFocusNode;
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

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _ownsFocusNode = false;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
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
    // Watch the search focus toggle — keyboard shortcut triggers this.
    ref.listen(searchFocusToggleProvider, (prev, next) {
      if (prev == next) return;
      _focusNode.requestFocus();
    });

    return FTextField(
      control: FTextFieldControl.managed(controller: _controller),
      focusNode: _focusNode,
      hint: widget.hint,
      prefixBuilder: (_, _, _) =>
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Icon(FLucideIcons.search)),
      clearable: (value) => value.text.isNotEmpty,
    );
  }
}
