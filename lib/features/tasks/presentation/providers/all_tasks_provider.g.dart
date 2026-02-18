// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AllTasksFilter)
final allTasksFilterProvider = AllTasksFilterProvider._();

final class AllTasksFilterProvider extends $NotifierProvider<AllTasksFilter, AllTasksFilterState> {
  AllTasksFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTasksFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTasksFilterHash();

  @$internal
  @override
  AllTasksFilter create() => AllTasksFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AllTasksFilterState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AllTasksFilterState>(value));
  }
}

String _$allTasksFilterHash() => r'e930d19380f83611a13065e043682afecca3ae08';

abstract class _$AllTasksFilter extends $Notifier<AllTasksFilterState> {
  AllTasksFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AllTasksFilterState, AllTasksFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AllTasksFilterState, AllTasksFilterState>,
              AllTasksFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
