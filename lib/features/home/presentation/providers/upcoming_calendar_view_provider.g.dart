// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_calendar_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UpcomingCalendarViewModeNotifier)
final upcomingCalendarViewModeProvider =
    UpcomingCalendarViewModeNotifierProvider._();

final class UpcomingCalendarViewModeNotifierProvider
    extends
        $AsyncNotifierProvider<
          UpcomingCalendarViewModeNotifier,
          CalendarViewMode
        > {
  UpcomingCalendarViewModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingCalendarViewModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingCalendarViewModeNotifierHash();

  @$internal
  @override
  UpcomingCalendarViewModeNotifier create() =>
      UpcomingCalendarViewModeNotifier();
}

String _$upcomingCalendarViewModeNotifierHash() =>
    r'c696f0a24b487e24540135651f3e0874a58c56fd';

abstract class _$UpcomingCalendarViewModeNotifier
    extends $AsyncNotifier<CalendarViewMode> {
  FutureOr<CalendarViewMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<CalendarViewMode>, CalendarViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CalendarViewMode>, CalendarViewMode>,
              AsyncValue<CalendarViewMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
