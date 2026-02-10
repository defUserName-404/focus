import 'package:flutter/material.dart';

class InlineAddSubtask extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<String> onSubmit;

  const InlineAddSubtask({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

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
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E))),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Matching indent line
            SizedBox(
              width: 40,
              child: Center(
                child: Container(width: 1, color: const Color(0xFF333333)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          border: Border.all(color: const Color(0xFF333333)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onSubmitted: (_) => _submit(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFD0D0D0),
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Subtask title…',
                            hintStyle: TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 14,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: widget.onCancel,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.close,
                            size: 18, color: Color(0xFF666666)),
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
