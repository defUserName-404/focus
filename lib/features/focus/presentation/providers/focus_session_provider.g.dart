// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'focus_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FocusTimer)
final focusTimerProvider = FocusTimerProvider._();

final class FocusTimerProvider
    extends $NotifierProvider<FocusTimer, FocusSession?> {
  FocusTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'focusTimerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$focusTimerHash();

  @$internal
  @override
  FocusTimer create() => FocusTimer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FocusSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FocusSession?>(value),
    );
  }
}

String _$focusTimerHash() => r'6fda00a095ce643fc27e0fc1d58b6fbb4ee1f00b';

abstract class _$FocusTimer extends $Notifier<FocusSession?> {
  FocusSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FocusSession?, FocusSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FocusSession?, FocusSession?>,
              FocusSession?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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
        isAutoDispose: true,
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
    r'c99f6a30413b6fc286777bf90fd2097437fa16fe';

@ProviderFor(focusProgress)
final focusProgressProvider = FocusProgressProvider._();

final class FocusProgressProvider
    extends
        $FunctionalProvider<
          AsyncValue<FocusProgress?>,
          FocusProgress?,
          FutureOr<FocusProgress?>
        >
    with $FutureModifier<FocusProgress?>, $FutureProvider<FocusProgress?> {
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
  $FutureProviderElement<FocusProgress?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FocusProgress?> create(Ref ref) {
    return focusProgress(ref);
  }
}

String _$focusProgressHash() => r'dddeecba10eef6dddbca575bbb5f374e8d3eac7f';
