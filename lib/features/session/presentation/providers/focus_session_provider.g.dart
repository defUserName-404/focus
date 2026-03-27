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

String _$focusTimerHash() => r'691c936a9df509e8b3ca388986e864a0b004d6c2';

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
