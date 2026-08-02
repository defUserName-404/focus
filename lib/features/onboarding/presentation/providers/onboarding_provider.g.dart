// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingService)
final onboardingServiceProvider = OnboardingServiceProvider._();

final class OnboardingServiceProvider
    extends $FunctionalProvider<OnboardingService, OnboardingService, OnboardingService>
    with $Provider<OnboardingService> {
  OnboardingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingServiceHash();

  @$internal
  @override
  $ProviderElement<OnboardingService> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  OnboardingService create(Ref ref) {
    return onboardingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingService value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<OnboardingService>(value));
  }
}

String _$onboardingServiceHash() => r'144483b4763f02bed5f3639a4038c600191a6362';

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

final class OnboardingControllerProvider extends $NotifierProvider<OnboardingController, OnboardingState> {
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<OnboardingState>(value));
  }
}

String _$onboardingControllerHash() => r'425fd3c0bddef1e5d88bf19d5f2f3f61962c9317';

abstract class _$OnboardingController extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<AnyNotifier<OnboardingState, OnboardingState>, OnboardingState, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
