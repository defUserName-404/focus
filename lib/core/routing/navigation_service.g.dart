// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for the navigation service.
///
/// Prefer injecting this via `ref.read(navigationServiceProvider)` in
/// commands and providers rather than calling `Navigator.of` directly.

@ProviderFor(navigationService)
final navigationServiceProvider = NavigationServiceProvider._();

/// Riverpod provider for the navigation service.
///
/// Prefer injecting this via `ref.read(navigationServiceProvider)` in
/// commands and providers rather than calling `Navigator.of` directly.

final class NavigationServiceProvider
    extends
        $FunctionalProvider<
          NavigationService,
          NavigationService,
          NavigationService
        >
    with $Provider<NavigationService> {
  /// Riverpod provider for the navigation service.
  ///
  /// Prefer injecting this via `ref.read(navigationServiceProvider)` in
  /// commands and providers rather than calling `Navigator.of` directly.
  NavigationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationServiceHash();

  @$internal
  @override
  $ProviderElement<NavigationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NavigationService create(Ref ref) {
    return navigationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationService>(value),
    );
  }
}

String _$navigationServiceHash() => r'9d3523c960ef75297848e936524cd037259c0a0a';
