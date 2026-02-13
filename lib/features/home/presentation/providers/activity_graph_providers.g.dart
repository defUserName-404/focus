// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_graph_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedYearNotifier)
final selectedYearProvider = SelectedYearNotifierProvider._();

final class SelectedYearNotifierProvider
    extends $NotifierProvider<SelectedYearNotifier, int> {
  SelectedYearNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedYearProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedYearNotifierHash();

  @$internal
  @override
  SelectedYearNotifier create() => SelectedYearNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectedYearNotifierHash() =>
    r'47e4f2f0dfb8fad5a5e4356133680bf6b2ee6fda';

abstract class _$SelectedYearNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TappedDateNotifier)
final tappedDateProvider = TappedDateNotifierProvider._();

final class TappedDateNotifierProvider
    extends $NotifierProvider<TappedDateNotifier, String?> {
  TappedDateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tappedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tappedDateNotifierHash();

  @$internal
  @override
  TappedDateNotifier create() => TappedDateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$tappedDateNotifierHash() =>
    r'509ef5204be26b45f5aab6b7ff1cfbe8c53cb3c3';

abstract class _$TappedDateNotifier extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
