import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:forui/forui.dart' as fu;

class InlineAddSubtask extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<String> onSubmit;

  const InlineAddSubtask({super.key, required this.onCancel, required this.onSubmit});

  @override
  State<InlineAddSubtask> createState() => _InlineAddSubtaskState();
}

class _InlineAddSubtaskState extends State<InlineAddSubtask> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) widget.onSubmit(text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Matching indent line
            SizedBox(
              width: 40,
              child: Center(child: Container(width: 1, color: context.colors.border)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.colors.muted,
                          border: Border.all(color: context.colors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            onSubmitted: (_) => _submit(),
                            style: context.typography.sm.copyWith(color: context.colors.foreground),
                            decoration: InputDecoration(
                              hintText: 'Subtask title…',
                              hintStyle: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(fu.FIcons.x, size: 18, color: context.colors.mutedForeground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
