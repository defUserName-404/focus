// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FocusTimer)
final focusTimerProvider = FocusTimerProvider._();

final class FocusTimerProvider
    extends $NotifierProvider<FocusTimer, FocusSession?> {
  FocusTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusTimerHash();

  @$internal
  @override
  FocusTimer create() => FocusTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusSession?>(value),
    );
  }
}

String _$focusTimerHash() => r'348a2adcb25e853cf18404dabce2a242f36f8ebd';

abstract class _$FocusTimer extends $Notifier<FocusSession?> {
  FocusSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FocusSession?, FocusSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FocusSession?, FocusSession?>,
              FocusSession?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
