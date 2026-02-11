// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(projectRepository)
final projectRepositoryProvider = ProjectRepositoryProvider._();

final class ProjectRepositoryProvider
    extends
        $FunctionalProvider<
          IProjectRepository,
          IProjectRepository,
          IProjectRepository
        >
    with $Provider<IProjectRepository> {
  ProjectRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectRepositoryHash();

  @$internal
  @override
  $ProviderElement<IProjectRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IProjectRepository create(Ref ref) {
    return projectRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IProjectRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IProjectRepository>(value),
    );
  }
}

String _$projectRepositoryHash() => r'2ea2b8d143bc9e84730588e39440be11f1650fdd';

@ProviderFor(projectList)
final projectListProvider = ProjectListProvider._();

final class ProjectListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          Stream<List<Project>>
        >
    with $FutureModifier<List<Project>>, $StreamProvider<List<Project>> {
  ProjectListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectListHash();

  @$internal
  @override
  $StreamProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Project>> create(Ref ref) {
    return projectList(ref);
  }
}

String _$projectListHash() => r'c6c5a795744f5e0937c863f15e03b133d11bd437';

@ProviderFor(ProjectListFilter)
final projectListFilterProvider = ProjectListFilterProvider._();

final class ProjectListFilterProvider
    extends $NotifierProvider<ProjectListFilter, ProjectListFilterState> {
  ProjectListFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectListFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectListFilterHash();

  @$internal
  @override
  ProjectListFilter create() => ProjectListFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectListFilterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectListFilterState>(value),
    );
  }
}

String _$projectListFilterHash() => r'bf70dd9ac92f93cf0f1ca6408d6af5d5f05771f8';

abstract class _$ProjectListFilter extends $Notifier<ProjectListFilterState> {
  ProjectListFilterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ProjectListFilterState, ProjectListFilterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProjectListFilterState, ProjectListFilterState>,
              ProjectListFilterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ProjectNotifier)
final projectProvider = ProjectNotifierProvider._();

final class ProjectNotifierProvider
    extends $NotifierProvider<ProjectNotifier, AsyncValue<List<Project>>> {
  ProjectNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectNotifierHash();

  @$internal
  @override
  ProjectNotifier create() => ProjectNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Project>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Project>>>(value),
    );
  }
}

String _$projectNotifierHash() => r'617d58331ed1eb07bb67cbfc29f06705d71ecf85';

abstract class _$ProjectNotifier extends $Notifier<AsyncValue<List<Project>>> {
  AsyncValue<List<Project>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<Project>>, AsyncValue<List<Project>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Project>>, AsyncValue<List<Project>>>,
              AsyncValue<List<Project>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
