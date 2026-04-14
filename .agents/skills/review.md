# Review Skill (Focus)

Use this skill for code review and quality validation in Focus.

## Review Priorities

1. Behavioral correctness and regressions
2. Architecture boundary violations
3. State persistence correctness (especially view mode/filter state)
4. Migration and data integrity risks
5. Platform-specific behavior (notifications/audio/lifecycle)

## Required Checks

- Formatting: `dart format . --line-length=120 --set-exit-if-changed`
- Static analysis: `flutter analyze`
- Codegen freshness when relevant
- Logging policy (`LogService`, no `print`/`debugPrint`)
- Result-pattern usage in service layer

## Architecture Checks

- Domain imports only domain/core dependencies.
- Presentation-only models are not placed in domain.
- Repository interfaces are in domain; implementations are in data.
- Route-level screens are under `presentation/screens`.

## UI/UX Checks

- Avoid hardcoded spacing if app constants exist.
- Avoid duplicate page padding from nested wrappers.
- Keep date/time control behavior consistent across create/edit screens.

## Reporting Format

If findings exist, report in severity order with file and line references.
If no findings exist, state that explicitly and list residual risk.

## Helper Command

```bash
bash .agents/commands/review.command
```

## Mandatory Post-Task Git Workflow

After review fixes for a user task are complete, run:

1. `bash .agents/commands/commit_optimizer.command main`
2. `bash .agents/commands/git_commit_writer.command <type> <scope> "<summary>" "<why>"`
3. `bash .agents/commands/pr_description_generator.command main "<labels>" "<title>"`
