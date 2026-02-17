// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          ISettingsRepository,
          ISettingsRepository,
          ISettingsRepository
        >
    with $Provider<ISettingsRepository> {
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'5052ea063325a65f278eba0b62e210b9fa0e1c65';

@ProviderFor(PreviewingIdNotifier)
final previewingIdProvider = PreviewingIdNotifierProvider._();

final class PreviewingIdNotifierProvider
    extends $NotifierProvider<PreviewingIdNotifier, String?> {
  PreviewingIdNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewingIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewingIdNotifierHash();

  @$internal
  @override
  PreviewingIdNotifier create() => PreviewingIdNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$previewingIdNotifierHash() =>
    r'a64939388bf60e7a7e2ed7c109a48bf324c0fb3f';

abstract class _$PreviewingIdNotifier extends $Notifier<String?> {
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

@ProviderFor(SettingsNotifier)
final settingsProvider = SettingsNotifierProvider._();

final class SettingsNotifierProvider
    extends $AsyncNotifierProvider<SettingsNotifier, AudioPreferences> {
  SettingsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsNotifierHash();

  @$internal
  @override
  SettingsNotifier create() => SettingsNotifier();
}

String _$settingsNotifierHash() => r'90b0f2678537fc5cc0903df84ca04de9dcd114bb';

abstract class _$SettingsNotifier extends $AsyncNotifier<AudioPreferences> {
  FutureOr<AudioPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AudioPreferences>, AudioPreferences>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AudioPreferences>, AudioPreferences>,
              AsyncValue<AudioPreferences>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
