import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/constants/animation_assets.dart';
import '../../../../core/constants/app_constants.dart';

/// A full-screen animated overlay shown when a task is completed.
///
/// Uses a Lottie animation for the completion effect and a fade-in
/// "Task Complete!" message. Auto-dismisses when the animation ends.
class CompletionOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const CompletionOverlay({super.key, required this.onDismiss});

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay> with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _textController;
  late final AnimationController _backdropController;

  late final Animation<double> _textOpacity;
  late final Animation<double> _backdropOpacity;

  @override
  void initState() {
    super.initState();

    _lottieController = AnimationController(vsync: this);

    _backdropController = AnimationController(vsync: this, duration: AppConstants.animation.medium);
    _backdropOpacity = CurvedAnimation(parent: _backdropController, curve: Curves.easeIn);

    _textController = AnimationController(vsync: this, duration: AppConstants.animation.long);
    _textOpacity = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    _startSequence();
  }

  Future<void> _startSequence() async {
    _backdropController.forward();
    await Future.delayed(AppConstants.animation.medium);
    _lottieController.forward();
    await Future.delayed(AppConstants.animation.long);
    _textController.forward();
  }

  void _onLottieLoaded(LottieComposition composition) {
    _lottieController.duration = composition.duration;
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _textController.dispose();
    _backdropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.background,
      child: Stack(
        children: [
          // Semi-transparent backdrop
          Positioned.fill(
            child: FadeTransition(
              opacity: _backdropOpacity,
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),

          // Lottie animation
          Center(
            child: Lottie.asset(
              AnimationAssets.taskCompletion,
              controller: _lottieController,
              onLoaded: _onLottieLoaded,
              width: 250,
              height: 250,
              repeat: false,
            ),
          ),

          // Text
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.3,
            child: FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  Text(
                    'Task Complete!',
                    textAlign: TextAlign.center,
                    style: context.typography.xl2.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                  SizedBox(height: AppConstants.spacing.small),
                  Text(
                    'Great work — keep the momentum going.',
                    textAlign: TextAlign.center,
                    style: context.typography.sm.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
