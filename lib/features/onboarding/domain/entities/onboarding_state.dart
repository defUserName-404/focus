import 'package:equatable/equatable.dart';

import 'onboarding_step.dart';

/// Immutable state of the onboarding flow.
class OnboardingState extends Equatable {
  final OnboardingStep current;
  final String enteredName;
  final bool isSubmitting;

  const OnboardingState({this.current = OnboardingStep.welcome, this.enteredName = '', this.isSubmitting = false});

  /// 1-based index for progress display.
  int get currentIndex => OnboardingStep.values.indexOf(current) + 1;

  /// Total number of steps.
  int get totalSteps => OnboardingStep.values.length;

  /// Progress fraction in [0.0, 1.0].
  double get progress => currentIndex / totalSteps;

  /// Whether a "Back" button should be shown (not on the first step).
  bool get canGoBack => current != OnboardingStep.welcome;

  /// True on the final step.
  bool get isFinal => current == OnboardingStep.name;

  OnboardingState copyWith({OnboardingStep? current, String? enteredName, bool? isSubmitting}) {
    return OnboardingState(
      current: current ?? this.current,
      enteredName: enteredName ?? this.enteredName,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [current, enteredName, isSubmitting];
}
