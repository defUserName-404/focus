// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_calendar_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpcomingCalendarUiStateNotifier)
final upcomingCalendarUiStateProvider =
    UpcomingCalendarUiStateNotifierProvider._();

final class UpcomingCalendarUiStateNotifierProvider
    extends
        $NotifierProvider<
          UpcomingCalendarUiStateNotifier,
          UpcomingCalendarUiState
        > {
  UpcomingCalendarUiStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingCalendarUiStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingCalendarUiStateNotifierHash();

  @$internal
  @override
  UpcomingCalendarUiStateNotifier create() => UpcomingCalendarUiStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpcomingCalendarUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpcomingCalendarUiState>(value),
    );
  }
}

String _$upcomingCalendarUiStateNotifierHash() =>
    r'7585d1f24a59f550ca82472d47fbd0f7682281b7';

abstract class _$UpcomingCalendarUiStateNotifier
    extends $Notifier<UpcomingCalendarUiState> {
  UpcomingCalendarUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<UpcomingCalendarUiState, UpcomingCalendarUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UpcomingCalendarUiState, UpcomingCalendarUiState>,
              UpcomingCalendarUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
