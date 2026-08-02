// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_view_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TasksViewModeNotifier)
final tasksViewModeProvider = TasksViewModeNotifierProvider._();

final class TasksViewModeNotifierProvider extends $AsyncNotifierProvider<TasksViewModeNotifier, TasksViewMode> {
  TasksViewModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksViewModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksViewModeNotifierHash();

  @$internal
  @override
  TasksViewModeNotifier create() => TasksViewModeNotifier();
}

String _$tasksViewModeNotifierHash() => r'a02651c0f7a4405fd9402d8f189e16679db218bc';

abstract class _$TasksViewModeNotifier extends $AsyncNotifier<TasksViewMode> {
  FutureOr<TasksViewMode> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TasksViewMode>, TasksViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TasksViewMode>, TasksViewMode>,
              AsyncValue<TasksViewMode>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
