// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedProjectId)
final selectedProjectIdProvider = SelectedProjectIdProvider._();

final class SelectedProjectIdProvider
    extends $NotifierProvider<SelectedProjectId, int?> {
  SelectedProjectIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedProjectIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedProjectIdHash();

  @$internal
  @override
  SelectedProjectId create() => SelectedProjectId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$selectedProjectIdHash() => r'3166035efe4f9dd62302aa4f9af9065c10a66c58';

abstract class _$SelectedProjectId extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
