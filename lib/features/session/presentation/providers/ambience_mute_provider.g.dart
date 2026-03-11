// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambience_mute_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the focus-session ambience audio is currently muted.
///
/// Toggling this pauses / resumes the ambient player via [AudioService]
/// without stopping the session or losing the current sound preset.

@ProviderFor(AmbienceMute)
final ambienceMuteProvider = AmbienceMuteProvider._();

/// Whether the focus-session ambience audio is currently muted.
///
/// Toggling this pauses / resumes the ambient player via [AudioService]
/// without stopping the session or losing the current sound preset.
final class AmbienceMuteProvider extends $NotifierProvider<AmbienceMute, bool> {
  /// Whether the focus-session ambience audio is currently muted.
  ///
  /// Toggling this pauses / resumes the ambient player via [AudioService]
  /// without stopping the session or losing the current sound preset.
  AmbienceMuteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ambienceMuteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ambienceMuteHash();

  @$internal
  @override
  AmbienceMute create() => AmbienceMute();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$ambienceMuteHash() => r'8bdb0a07448da919589dfe6f71e8187e2c9ec16e';

/// Whether the focus-session ambience audio is currently muted.
///
/// Toggling this pauses / resumes the ambient player via [AudioService]
/// without stopping the session or losing the current sound preset.

abstract class _$AmbienceMute extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ambienceMarquee)
final ambienceMarqueeProvider = AmbienceMarqueeProvider._();

final class AmbienceMarqueeProvider
    extends
        $FunctionalProvider<
          AmbienceMarqueeState,
          AmbienceMarqueeState,
          AmbienceMarqueeState
        >
    with $Provider<AmbienceMarqueeState> {
  AmbienceMarqueeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ambienceMarqueeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ambienceMarqueeHash();

  @$internal
  @override
  $ProviderElement<AmbienceMarqueeState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AmbienceMarqueeState create(Ref ref) {
    return ambienceMarquee(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AmbienceMarqueeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AmbienceMarqueeState>(value),
    );
  }
}

String _$ambienceMarqueeHash() => r'e40167084c48750bf67c4ff6216331130edbd8b0';
