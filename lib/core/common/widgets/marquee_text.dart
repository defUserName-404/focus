import 'package:flutter/material.dart';

/// A continuously scrolling (marquee) single-line text widget.
///
/// The text scrolls horizontally in a loop, similar to ticker-text
/// seen in many audio / music player apps.
///
/// Set [isAnimating] to `false` to pause the scroll (the text fades
/// to half-opacity). When [isAnimating] switches back to `true` the
/// animation resumes from where it left off.
class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // pixels per second
  final bool isAnimating;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    this.velocity = 30.0,
    this.isAnimating = true,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _textWidth = 0;
  bool _needsScroll = false;
  static const _gap = 48.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _controller.stop();
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
    if (oldWidget.isAnimating != widget.isAnimating) {
      _syncAnimation();
    }
  }

  void _measure() {
    if (!mounted) return;
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    _textWidth = tp.width;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final containerWidth = box.size.width;

    _needsScroll = _textWidth > containerWidth;
    if (_needsScroll) {
      final scrollDistance = _textWidth + _gap;
      final durationMs = (scrollDistance / widget.velocity * 1000).round();
      _controller.duration = Duration(milliseconds: durationMs);
      _syncAnimation();
    } else {
      _controller.stop();
    }
    if (mounted) setState(() {});
  }

  void _syncAnimation() {
    if (!_needsScroll) return;
    if (widget.isAnimating) {
      if (!_controller.isAnimating) {
        _controller.forward(from: _controller.value);
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsScroll) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.isAnimating ? 1.0 : 0.5,
        child: Text(widget.text, style: widget.style, maxLines: 1, overflow: TextOverflow.ellipsis),
      );
    }

    final scrollDistance = _textWidth + _gap;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.isAnimating ? 1.0 : 0.5,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = _controller.value * scrollDistance;
            return Transform.translate(
              offset: Offset(-offset, 0),
              child: child,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
              SizedBox(width: _gap),
              Text(widget.text, style: widget.style, maxLines: 1, softWrap: false),
            ],
          ),
        ),
      ),
    );
  }
}
