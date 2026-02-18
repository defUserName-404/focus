// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider extends $FunctionalProvider<ITaskRepository, ITaskRepository, ITaskRepository>
    with $Provider<ITaskRepository> {
  TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<ITaskRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  ITaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ITaskRepository value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<ITaskRepository>(value));
  }
}

String _$taskRepositoryHash() => r'da775b732415adca8ed0ee67aa5a687abc5d8dee';

@ProviderFor(tasksByProject)
final tasksByProjectProvider = TasksByProjectFamily._();

final class TasksByProjectProvider extends $FunctionalProvider<AsyncValue<List<Task>>, List<Task>, Stream<List<Task>>>
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  TasksByProjectProvider._({required TasksByProjectFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'tasksByProjectProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksByProjectHash();

  @override
  String toString() {
    return r'tasksByProjectProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) => $StreamProviderElement(pointer);

  @override
  Stream<List<Task>> create(Ref ref) {
    final argument = this.argument as String;
    return tasksByProject(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TasksByProjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tasksByProjectHash() => r'3b31ea9bcdc3b502c70e25f4a31881f684a5b8a1';

final class TasksByProjectFamily extends $Family with $FunctionalFamilyOverride<Stream<List<Task>>, String> {
  TasksByProjectFamily._()
    : super(
        retry: null,
        name: r'tasksByProjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TasksByProjectProvider call(String projectId) => TasksByProjectProvider._(argument: projectId, from: this);

  @override
  String toString() => r'tasksByProjectProvider';
}

@ProviderFor(taskById)
final taskByIdProvider = TaskByIdFamily._();

final class TaskByIdProvider extends $FunctionalProvider<AsyncValue<Task>, Task, FutureOr<Task>>
    with $FutureModifier<Task>, $FutureProvider<Task> {
  TaskByIdProvider._({required TaskByIdFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'taskByIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskByIdHash();

  @override
  String toString() {
    return r'taskByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Task> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<Task> create(Ref ref) {
    final argument = this.argument as String;
    return taskById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskByIdHash() => r'c63653908a63a1c3ba2059ac85c7b004e792aeca';

final class TaskByIdFamily extends $Family with $FunctionalFamilyOverride<FutureOr<Task>, String> {
  TaskByIdFamily._()
    : super(
        retry: null,
        name: r'taskByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TaskByIdProvider call(String taskId) => TaskByIdProvider._(argument: taskId, from: this);

  @override
  String toString() => r'taskByIdProvider';
}

@ProviderFor(TaskListFilter)
final taskListFilterProvider = TaskListFilterFamily._();

final class TaskListFilterProvider extends $NotifierProvider<TaskListFilter, TaskListFilterState> {
  TaskListFilterProvider._({required TaskListFilterFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'taskListFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListFilterHash();

  @override
  String toString() {
    return r'taskListFilterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskListFilter create() => TaskListFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskListFilterState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<TaskListFilterState>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is TaskListFilterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskListFilterHash() => r'c9c9888cd7ef523366f250f5033f241a09e141ae';

final class TaskListFilterFamily extends $Family
    with $ClassFamilyOverride<TaskListFilter, TaskListFilterState, TaskListFilterState, TaskListFilterState, String> {
  TaskListFilterFamily._()
    : super(
        retry: null,
        name: r'taskListFilterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TaskListFilterProvider call(String projectId) => TaskListFilterProvider._(argument: projectId, from: this);

  @override
  String toString() => r'taskListFilterProvider';
}

abstract class _$TaskListFilter extends $Notifier<TaskListFilterState> {
  late final _$args = ref.$arg as String;
  String get projectId => _$args;

  TaskListFilterState build(String projectId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TaskListFilterState, TaskListFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskListFilterState, TaskListFilterState>,
              TaskListFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(TaskNotifier)
final taskProvider = TaskNotifierFamily._();

final class TaskNotifierProvider extends $NotifierProvider<TaskNotifier, AsyncValue<List<Task>>> {
  TaskNotifierProvider._({required TaskNotifierFamily super.from, required String super.argument})
    : super(
        retry: null,
        name: r'taskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskNotifierHash();

  @override
  String toString() {
    return r'taskProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskNotifier create() => TaskNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Task>> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<AsyncValue<List<Task>>>(value));
  }

  @override
  bool operator ==(Object other) {
    return other is TaskNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskNotifierHash() => r'add93e1696fb7cea3c4c20dfc525666a19d47cd9';

final class TaskNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskNotifier,
          AsyncValue<List<Task>>,
          AsyncValue<List<Task>>,
          AsyncValue<List<Task>>,
          String
        > {
  TaskNotifierFamily._()
    : super(
        retry: null,
        name: r'taskProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TaskNotifierProvider call(String projectId) => TaskNotifierProvider._(argument: projectId, from: this);

  @override
  String toString() => r'taskProvider';
}

abstract class _$TaskNotifier extends $Notifier<AsyncValue<List<Task>>> {
  late final _$args = ref.$arg as String;
  String get projectId => _$args;

  AsyncValue<List<Task>> build(String projectId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Task>>, AsyncValue<List<Task>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Task>>, AsyncValue<List<Task>>>,
              AsyncValue<List<Task>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
