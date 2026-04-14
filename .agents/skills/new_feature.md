# New Feature Skill (Focus)

Use this skill when creating a new feature module in Focus.

## Goal

Create a feature that matches Focus clean architecture and project conventions.

## Scope

Apply when work includes one or more of:
- New feature folder under `lib/features/`
- New entities/repositories/services/providers/screens
- New routes and DI registrations
- New Drift tables or schema updates

## Required Structure

```text
lib/features/<feature>/
  data/
    datasources/
    mappers/
    models/
    repositories/
  domain/
    entities/
    repositories/
    services/
  presentation/
    commands/
    models/
    providers/
    screens/
    widgets/
```

## Workflow

1. Create domain contracts and entities first.
2. Implement data layer with datasource + repository impl.
3. Add service layer methods returning `Result<T>`.
4. Register dependencies in `lib/core/di/injection.dart`.
5. Add providers in `presentation/providers/`.
6. Add UI in screens/widgets and commands for actions.
7. Add routes in `lib/core/routing/routes.dart` and router setup.
8. If schema changed, update `db_service.dart` migration.
9. Run code generation.
10. Run analyze and format.
11. Update docs (`AGENTS.md`, `.agents/docs/*`) if architecture/process changed.

## Commands

```bash
bash .agents/commands/new_feature.command <feature_name>
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format . --line-length=120
```

## Done Criteria

- Feature compiles and analyzer is clean.
- DI, routing, and providers are wired.
- Codegen is up to date.
- Documentation updated for any new architecture/pattern/command.

## Mandatory Post-Task Git Workflow

After completing a user task, run:

1. `bash .agents/commands/commit_optimizer.command main`
2. `bash .agents/commands/git_commit_writer.command <type> <scope> "<summary>" "<why>"`
3. `bash .agents/commands/pr_description_generator.command main "<labels>" "<title>"`
