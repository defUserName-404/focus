# Focus - AI Agent Guidelines

This is the primary onboarding file for coding agents working in Focus.
Canonical agent documentation now lives in structured paths under `.agents/`.

## Quick Reference

| Category | Path |
|----------|------|
| Architecture | [.agents/docs/architecture.md](.agents/docs/architecture.md) |
| Coding Style | [.agents/docs/coding_style.md](.agents/docs/coding_style.md) |
| Commands | [.agents/docs/commands.md](.agents/docs/commands.md) |
| Patterns | [.agents/docs/patterns.md](.agents/docs/patterns.md) |
| Audit Snapshot | [.agents/docs/audit_results.md](.agents/docs/audit_results.md) |
| Feature Plans | [.agents/docs/feature_plans.md](.agents/docs/feature_plans.md) |
| Feature Skill | [.agents/skills/new_feature.md](.agents/skills/new_feature.md) |
| Review Skill | [.agents/skills/review.md](.agents/skills/review.md) |
| Regression Skill | [.agents/skills/regression_test.md](.agents/skills/regression_test.md) |
| Commit Writer Skill | [.agents/skills/git_commit_writer.md](.agents/skills/git_commit_writer.md) |
| PR Description Skill | [.agents/skills/pr_description_generator.md](.agents/skills/pr_description_generator.md) |
| Commit Optimizer Skill | [.agents/skills/commit_optimizer.md](.agents/skills/commit_optimizer.md) |

## Project Overview

Focus is a cross-platform Flutter productivity app for deep work sessions, projects, and tasks.

Key principles:
- Offline-first and privacy-first (local device data)
- Feature-first clean architecture
- Riverpod + GetIt + Drift
- ForUI-first component styling

## Core Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter (Dart SDK >=3.10.0 <4.0.0) |
| State | Riverpod with code generation |
| DI | GetIt |
| Local DB | Drift (SQLite) |
| Routing | go_router |
| UI | ForUI (`forui`) |
| Notifications | flutter_local_notifications |
| Audio | audioplayers, audio_service, audio_session |

## `.agents` Layout

```text
.agents/
  docs/
    architecture.md
    coding_style.md
    commands.md
    patterns.md
    audit_results.md
    feature_plans.md
  commands/
    new_feature.command
    review.command
    regression_test.command
      commit_optimizer.command
      git_commit_writer.command
      pr_description_generator.command
  skills/
    new_feature.md
    review.md
    regression_test.md
      commit_optimizer.md
      git_commit_writer.md
      pr_description_generator.md
  tools/
    README.md
```

## Essential Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format . --line-length=120
flutter test
flutter run
```

Agent helper scripts:

```bash
bash .agents/commands/new_feature.command <feature_name>
bash .agents/commands/review.command
bash .agents/commands/regression_test.command
bash .agents/commands/commit_optimizer.command main
bash .agents/commands/git_commit_writer.command <type> <scope> "<summary>" "<why>"
bash .agents/commands/pr_description_generator.command main "<labels>" "<title>"
```

## Critical Rules For Agents

### 1) Run Codegen When Required

Run this after changing Riverpod annotations, Drift schema/queries, or `part '*.g.dart'` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 2) Preserve Architecture Boundaries

- Domain does not depend on data or presentation.
- Data implements domain contracts.
- Presentation owns UI state and interaction models.

### 3) Use `Result<T>` For Service-Level Failures

Service methods should return `Result<T>` for fallible operations and avoid throwing for expected failures.

### 4) Use `LogService` For Logging

Do not use `print` or `debugPrint`.

### 5) Use GetIt For DI Registration

Register dependencies in `lib/core/di/injection.dart` and bridge to Riverpod providers as needed.

### 6) Keep Domain Entities Immutable

- `@immutable`
- `Equatable`
- `const` constructors
- `copyWith` extension support

### 7) Handle Drift Migrations Explicitly

When schema changes:
1. Increment `schemaVersion`.
2. Add `onUpgrade` migration logic.
3. Validate behavior with existing data.

### 8) Persist Durable UI Preferences Via Providers + Settings

If users expect a switcher/filter/view mode to survive restarts, persist it via settings-backed provider patterns (not ad-hoc widget `setState`).

### 9) Run Core Git Skills After Every User Task

After each user task is completed, agents must run this sequence for the change group:

1. Optimize commit grouping (atomic, one logical concern per commit):
   `bash .agents/commands/commit_optimizer.command main`
2. Write a Conventional Commit message and commit staged files:
   `bash .agents/commands/git_commit_writer.command <type> <scope> "<summary>" "<why>"`
3. Generate PR description and create PR using GitHub CLI:
   `bash .agents/commands/pr_description_generator.command main "<labels>" "<title>"`

PR creation must include:
- `--assignee @me`
- `--label`
- `--title`
- Description via `--body` or `--body-file`

Commit titles should default to Conventional Commit types (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`) to support semantic versioning.

## Important Source Files

| File | Purpose |
|------|---------|
| `lib/core/di/injection.dart` | DI registration |
| `lib/core/services/db_service.dart` | Drift database and migrations |
| `lib/core/services/log_service.dart` | Centralized logging |
| `lib/core/utils/result.dart` | `Result<T>` and failure types |
| `lib/core/routing/app_router.dart` | go_router config |
| `lib/core/routing/routes.dart` | Route constants/helpers |
| `lib/core/constants/app_constants.dart` | Shared spacing/sizing constants |

## Agent Self-Update Protocol (Mandatory)

When making significant codebase changes, update agent docs in the same change.

Required updates by change type:

1. Architecture change:
   update `.agents/docs/architecture.md` and `.agents/docs/patterns.md`
2. Code style/convention change:
   update `.agents/docs/coding_style.md`
3. Build/test workflow change:
   update `.agents/docs/commands.md` and relevant `.agents/commands/*.command`
4. Risk profile or known issues changed:
   update `.agents/docs/audit_results.md`
5. Roadmap/priorities changed:
   update `.agents/docs/feature_plans.md`
6. Any significant change:
   ensure this `AGENTS.md` remains accurate

Significant changes include:
- New architecture patterns or layers
- New core services or DI registration strategy
- Routing model changes
- Drift schema/migration changes
- Notification/audio/lifecycle behavior changes
- New persistent state patterns

## Platform Notes

| Platform | Status |
|----------|--------|
| Android | Supported |
| iOS | Supported |
| macOS | Supported |
| Linux | Supported |
| Windows | Supported |
| Web | Not supported target |

Use platform guards via `PlatformUtils` for platform-specific behavior.

## License

CC BY-NC 4.0 - Creative Commons Attribution-NonCommercial 4.0 International
