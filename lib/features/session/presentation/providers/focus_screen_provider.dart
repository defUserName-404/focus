import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/platform_utils.dart';
import '../../domain/entities/session_state.dart';
import '../models/focus_screen_state.dart';
import 'focus_session_provider.dart';

part 'focus_screen_provider.g.dart';

@riverpod
class FocusScreenNotifier extends _$FocusScreenNotifier {
  Timer? _inactivityTimer;
  static const _inactivityDuration = Duration(seconds: 5);

  @override
  FocusScreenState build() {
    // Listen for session state changes to start/stop the inactivity timer.
    // Immersive hide is mobile-only so desktop always keeps transport visible.
    ref.listen(focusTimerProvider.select((s) => s?.state), (prev, next) {
      final isRunning = next == SessionState.running || next == SessionState.onBreak;
      if (isRunning && !PlatformUtils.isDesktop) {
        _startInactivityTimer();
      } else {
        _inactivityTimer?.cancel();
        if (!state.isControlsVisible) {
          state = state.copyWith(isControlsVisible: true);
        }
      }
    });

    final session = ref.read(focusTimerProvider);
    final isRunning = session?.state == SessionState.running || session?.state == SessionState.onBreak;
    if (isRunning && !PlatformUtils.isDesktop) {
      _startInactivityTimer();
    }

    ref.onDispose(() {
      _inactivityTimer?.cancel();
    });

    return const FocusScreenState();
  }

  void _startInactivityTimer() {
    if (PlatformUtils.isDesktop) return;
    _inactivityTimer?.cancel();
    final session = ref.read(focusTimerProvider);
    final isRunning = session?.state == SessionState.running || session?.state == SessionState.onBreak;

    if (isRunning) {
      _inactivityTimer = Timer(_inactivityDuration, () {
        if (state.isControlsVisible) {
          state = state.copyWith(isControlsVisible: false);
        }
      });
    }
  }

  /// Call this when the user taps or interacts with the screen.
  void onUserInteraction() {
    if (!state.isControlsVisible) {
      state = state.copyWith(isControlsVisible: true);
    }
    _startInactivityTimer();
  }

  /// Show the completion overlay.
  void showCompletion() {
    state = state.copyWith(showCompletion: true);
  }

  /// Mark the screen as popped to prevent duplicate pops.
  void markAsPopped() {
    state = state.copyWith(hasPopped: true);
  }
}
