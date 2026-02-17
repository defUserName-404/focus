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
    r'd1aceaa364732510ae079a02406fffff8b81bebd';

/// Injected so the notifier never calls getIt directly.

@ProviderFor(audioService)
final audioServiceProvider = AudioServiceProvider._();

/// Injected so the notifier never calls getIt directly.

final class AudioServiceProvider
    extends $FunctionalProvider<AudioService, AudioService, AudioService>
    with $Provider<AudioService> {
  /// Injected so the notifier never calls getIt directly.
  AudioServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioServiceHash();

  @$internal
  @override
  $ProviderElement<AudioService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AudioService create(Ref ref) {
    return audioService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioService>(value),
    );
  }
}

String _$audioServiceHash() => r'15f96b139b86f1ab5e758ea86ce2bc6a8ff8eb39';

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
    r'467c9301fa04f18df4394dc18217da44e98a56ca';

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

@ProviderFor(AccordionExpandedNotifier)
final accordionExpandedProvider = AccordionExpandedNotifierProvider._();

final class AccordionExpandedNotifierProvider
    extends $NotifierProvider<AccordionExpandedNotifier, AccordionState> {
  AccordionExpandedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accordionExpandedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accordionExpandedNotifierHash();

  @$internal
  @override
  AccordionExpandedNotifier create() => AccordionExpandedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccordionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccordionState>(value),
    );
  }
}

String _$accordionExpandedNotifierHash() =>
    r'8110d2ad75914dfaa14135b566be97f29c82298a';

abstract class _$AccordionExpandedNotifier extends $Notifier<AccordionState> {
  AccordionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AccordionState, AccordionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccordionState, AccordionState>,
              AccordionState,
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

String _$settingsNotifierHash() => r'1d6f2300acc1f0e9541c61b28fd5f9843e5db594';

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
