// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod wrappers for GetIt-registered focus singletons.
///
/// These providers bridge the GetIt DI container into Riverpod's
/// dependency graph. This allows:
/// - `ref.watch()` in the `FocusTimer` notifier (proper Riverpod pattern)
/// - `overrideWithValue()` in tests for easy mocking

@ProviderFor(focusSessionService)
final focusSessionServiceProvider = FocusSessionServiceProvider._();

/// Riverpod wrappers for GetIt-registered focus singletons.
///
/// These providers bridge the GetIt DI container into Riverpod's
/// dependency graph. This allows:
/// - `ref.watch()` in the `FocusTimer` notifier (proper Riverpod pattern)
/// - `overrideWithValue()` in tests for easy mocking

final class FocusSessionServiceProvider
    extends
        $FunctionalProvider<
          FocusSessionService,
          FocusSessionService,
          FocusSessionService
        >
    with $Provider<FocusSessionService> {
  /// Riverpod wrappers for GetIt-registered focus singletons.
  ///
  /// These providers bridge the GetIt DI container into Riverpod's
  /// dependency graph. This allows:
  /// - `ref.watch()` in the `FocusTimer` notifier (proper Riverpod pattern)
  /// - `overrideWithValue()` in tests for easy mocking
  FocusSessionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusSessionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusSessionServiceHash();

  @$internal
  @override
  $ProviderElement<FocusSessionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FocusSessionService create(Ref ref) {
    return focusSessionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusSessionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusSessionService>(value),
    );
  }
}

String _$focusSessionServiceHash() =>
    r'ccf4da2960cc662c72c0d4e47e5392dd0cff209a';

@ProviderFor(focusAudioCoordinator)
final focusAudioCoordinatorProvider = FocusAudioCoordinatorProvider._();

final class FocusAudioCoordinatorProvider
    extends
        $FunctionalProvider<
          FocusAudioCoordinator,
          FocusAudioCoordinator,
          FocusAudioCoordinator
        >
    with $Provider<FocusAudioCoordinator> {
  FocusAudioCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusAudioCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusAudioCoordinatorHash();

  @$internal
  @override
  $ProviderElement<FocusAudioCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FocusAudioCoordinator create(Ref ref) {
    return focusAudioCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusAudioCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusAudioCoordinator>(value),
    );
  }
}

String _$focusAudioCoordinatorHash() =>
    r'3a4ac7e2e6b0eeb8237bec4df5b1b4af68504c02';

@ProviderFor(focusNotificationCoordinator)
final focusNotificationCoordinatorProvider =
    FocusNotificationCoordinatorProvider._();

final class FocusNotificationCoordinatorProvider
    extends
        $FunctionalProvider<
          FocusNotificationCoordinator,
          FocusNotificationCoordinator,
          FocusNotificationCoordinator
        >
    with $Provider<FocusNotificationCoordinator> {
  FocusNotificationCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusNotificationCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusNotificationCoordinatorHash();

  @$internal
  @override
  $ProviderElement<FocusNotificationCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FocusNotificationCoordinator create(Ref ref) {
    return focusNotificationCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusNotificationCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusNotificationCoordinator>(value),
    );
  }
}

String _$focusNotificationCoordinatorHash() =>
    r'82168247f5ae772a08137e9aa1e791b921f0295c';

@ProviderFor(focusMediaSessionCoordinator)
final focusMediaSessionCoordinatorProvider =
    FocusMediaSessionCoordinatorProvider._();

final class FocusMediaSessionCoordinatorProvider
    extends
        $FunctionalProvider<
          FocusMediaSessionCoordinator,
          FocusMediaSessionCoordinator,
          FocusMediaSessionCoordinator
        >
    with $Provider<FocusMediaSessionCoordinator> {
  FocusMediaSessionCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusMediaSessionCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusMediaSessionCoordinatorHash();

  @$internal
  @override
  $ProviderElement<FocusMediaSessionCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FocusMediaSessionCoordinator create(Ref ref) {
    return focusMediaSessionCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusMediaSessionCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusMediaSessionCoordinator>(value),
    );
  }
}

String _$focusMediaSessionCoordinatorHash() =>
    r'a4d030b1a0e255b29aa41a4bea558e7faeacc705';

@ProviderFor(focusSessionRepository)
final focusSessionRepositoryProvider = FocusSessionRepositoryProvider._();

final class FocusSessionRepositoryProvider
    extends
        $FunctionalProvider<
          IFocusSessionRepository,
          IFocusSessionRepository,
          IFocusSessionRepository
        >
    with $Provider<IFocusSessionRepository> {
  FocusSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusSessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<IFocusSessionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IFocusSessionRepository create(Ref ref) {
    return focusSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IFocusSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IFocusSessionRepository>(value),
    );
  }
}

String _$focusSessionRepositoryHash() =>
    r'39edbb69396c3cfd03db7a7c7bb5ccb5de7a9b7a';
