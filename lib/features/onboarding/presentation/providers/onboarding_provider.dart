import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/onboarding_state.dart';
import '../../domain/entities/onboarding_step.dart';
import '../../domain/services/onboarding_service.dart';

part 'onboarding_provider.g.dart';

@Riverpod(keepAlive: false)
OnboardingService onboardingService(Ref ref) => getIt<OnboardingService>();

@riverpod
class OnboardingController extends _$OnboardingController {
  late final OnboardingService _service;

  @override
  OnboardingState build() {
    _service = ref.watch(onboardingServiceProvider);
    return const OnboardingState();
  }

  void next() {
    if (state.isFinal) return;
    final steps = OnboardingStep.values;
    final nextIndex = steps.indexOf(state.current) + 1;
    state = state.copyWith(current: steps[nextIndex]);
  }

  void back() {
    if (!state.canGoBack) return;
    final steps = OnboardingStep.values;
    final prevIndex = steps.indexOf(state.current) - 1;
    state = state.copyWith(current: steps[prevIndex]);
  }

  void updateName(String value) {
    state = state.copyWith(enteredName: value);
  }

  /// Completes onboarding with the entered name (may be empty).
  /// Sets `isSubmitting` while in flight; on success returns normally,
  /// on failure rethrows the failure for the UI to handle.
  Future<void> complete() async {
    state = state.copyWith(isSubmitting: true);
    final result = await _service.complete(name: state.enteredName);
    state = state.copyWith(isSubmitting: false);
    if (result case Failure(:final failure)) throw failure;
  }

  /// Skips onboarding entirely. Sets `isSubmitting` while in flight.
  Future<void> skip() async {
    state = state.copyWith(isSubmitting: true);
    final result = await _service.skip();
    state = state.copyWith(isSubmitting: false);
    if (result case Failure(:final failure)) throw failure;
  }
}
