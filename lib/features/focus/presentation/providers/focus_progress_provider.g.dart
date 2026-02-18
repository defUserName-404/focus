// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(focusProgress)
final focusProgressProvider = FocusProgressProvider._();

final class FocusProgressProvider extends $FunctionalProvider<FocusProgress?, FocusProgress?, FocusProgress?>
    with $Provider<FocusProgress?> {
  FocusProgressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusProgressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusProgressHash();

  @$internal
  @override
  $ProviderElement<FocusProgress?> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  FocusProgress? create(Ref ref) {
    return focusProgress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusProgress? value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<FocusProgress?>(value));
  }
}

String _$focusProgressHash() => r'24b8c695df9e8bdf189bef77e2f17eb1f57ff941';
