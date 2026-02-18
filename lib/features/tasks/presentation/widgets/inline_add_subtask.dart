import 'package:flutter/material.dart';
import 'package:focus/core/config/theme/app_theme.dart';
import 'package:focus/core/constants/app_constants.dart';
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
    const double leadingWidth = 32.0;

    return Container(
      decoration: BoxDecoration(
        color: context.colors.background,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Matching indent line from SubtaskRow
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Container(
                width: 1.5,
                decoration: BoxDecoration(
                  color: context.colors.border,
                  borderRadius: BorderRadius.circular(AppConstants.border.radius.small),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppConstants.spacing.small),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: leadingWidth),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.colors.muted,
                            border: Border.all(color: context.colors.border),
                            borderRadius: BorderRadius.circular(AppConstants.border.radius.regular),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              onSubmitted: (_) => _submit(),
                              style: context.typography.sm.copyWith(color: context.colors.foreground),
                              decoration: InputDecoration(
                                hintText: 'Subtask title…',
                                hintStyle: context.typography.sm.copyWith(color: context.colors.mutedForeground),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacing.regular,
                                  vertical: AppConstants.spacing.small,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppConstants.spacing.small),
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppConstants.spacing.regular),
                        child: Icon(
                          fu.FIcons.x,
                          size: AppConstants.size.icon.regular,
                          color: context.colors.mutedForeground,
                        ),
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
