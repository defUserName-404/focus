// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_screen_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FocusScreenNotifier)
final focusScreenProvider = FocusScreenNotifierProvider._();

final class FocusScreenNotifierProvider
    extends $NotifierProvider<FocusScreenNotifier, FocusScreenState> {
  FocusScreenNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusScreenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusScreenNotifierHash();

  @$internal
  @override
  FocusScreenNotifier create() => FocusScreenNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusScreenState>(value),
    );
  }
}

String _$focusScreenNotifierHash() =>
    r'8c7dc770beaa902a6520b0559e68fb7999841b05';

abstract class _$FocusScreenNotifier extends $Notifier<FocusScreenState> {
  FocusScreenState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FocusScreenState, FocusScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FocusScreenState, FocusScreenState>,
              FocusScreenState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
