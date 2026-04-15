part of 'project_provider.dart';

@Riverpod(keepAlive: true)
class ProjectNotifier extends _$ProjectNotifier {
  late final ProjectService _service;

  @override
  AsyncValue<List<Project>> build() {
    _service = getIt<ProjectService>();
    _loadProjects();
    return const AsyncValue.loading();
  }

  Future<void> _loadProjects() async {
    state = const AsyncValue.loading();
    try {
      final projects = await _service.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Project> createProject({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? deadline,
  }) async {
    final result = await _service.createProject(
      title: title,
      description: description,
      startDate: startDate,
      deadline: deadline,
    );
    switch (result) {
      case Success(:final value):
        await _loadProjects();
        return value;
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
        throw failure;
    }
  }

  Future<void> updateProject(Project project) async {
    final result = await _service.updateProject(project);
    switch (result) {
      case Success():
        await _loadProjects();
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  Future<void> deleteProject(int id) async {
    final result = await _service.deleteProject(id);
    switch (result) {
      case Success():
        await _loadProjects();
      case Failure(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }
}
