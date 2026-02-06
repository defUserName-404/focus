// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(taskRepository)
final taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends
        $FunctionalProvider<ITaskRepository, ITaskRepository, ITaskRepository>
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
  $ProviderElement<ITaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ITaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ITaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ITaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'da775b732415adca8ed0ee67aa5a687abc5d8dee';

@ProviderFor(tasksByProject)
final tasksByProjectProvider = TasksByProjectFamily._();

final class TasksByProjectProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Task>>,
          List<Task>,
          Stream<List<Task>>
        >
    with $FutureModifier<List<Task>>, $StreamProvider<List<Task>> {
  TasksByProjectProvider._({
    required TasksByProjectFamily super.from,
    required String super.argument,
  }) : super(
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
  $StreamProviderElement<List<Task>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

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

String _$tasksByProjectHash() => r'c7110d5b6d4961aa76c2d71157d42f4d8bc23dd1';

final class TasksByProjectFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Task>>, String> {
  TasksByProjectFamily._()
    : super(
        retry: null,
        name: r'tasksByProjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TasksByProjectProvider call(String projectId) =>
      TasksByProjectProvider._(argument: projectId, from: this);

  @override
  String toString() => r'tasksByProjectProvider';
}

@ProviderFor(TaskNotifier)
final taskProvider = TaskNotifierFamily._();

final class TaskNotifierProvider
    extends $NotifierProvider<TaskNotifier, AsyncValue<List<Task>>> {
  TaskNotifierProvider._({
    required TaskNotifierFamily super.from,
    required String super.argument,
  }) : super(
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
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Task>>>(value),
    );
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

String _$taskNotifierHash() => r'dcad4e3a54a033e055f06aba26de73a4f6333e2e';

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

  TaskNotifierProvider call(String projectId) =>
      TaskNotifierProvider._(argument: projectId, from: this);

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
    final ref =
        this.ref as $Ref<AsyncValue<List<Task>>, AsyncValue<List<Task>>>;
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
