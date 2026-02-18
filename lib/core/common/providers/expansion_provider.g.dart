// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expansion_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Expansion)
final expansionProvider = ExpansionProvider._();

final class ExpansionProvider extends $NotifierProvider<Expansion, Map<String, bool>> {
  ExpansionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expansionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expansionHash();

  @$internal
  @override
  Expansion create() => Expansion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Map<String, bool>>(value));
  }
}

String _$expansionHash() => r'83c64b9271641d07238a8f34f80b9b625fbdabfd';

abstract class _$Expansion extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, bool>, Map<String, bool>>,
              Map<String, bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
