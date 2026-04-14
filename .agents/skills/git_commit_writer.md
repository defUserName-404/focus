# Git Commit Writer Skill (Focus)

Use this skill after changes are staged to produce a high-quality commit message.

## Objective

Generate clear, conventional commit messages that support semantic versioning and release automation.

## Required Format

Use Conventional Commits:

- `feat(scope): summary`
- `fix(scope): summary`
- `refactor(scope): summary`
- `docs(scope): summary`
- `test(scope): summary`
- `chore(scope): summary`

## Input

- Staged file set (`git diff --cached --name-only`)
- Staged diff (`git diff --cached`)

## Workflow

1. Inspect staged changes and identify the main intent.
2. Select commit type (`feat`, `fix`, `refactor`, `docs`, `test`, `chore`).
3. Select concise scope (feature/module, for example `tasks`, `reports`, `agents`).
4. Write one-line title in imperative mood.
5. Add a body with:
   - What changed
   - Why it changed
   - Any migration/risk/testing notes
6. Ensure commit is atomic (one logical change only).

## Quality Rules

- Do not mix unrelated changes in a single commit.
- Keep subject line concise and actionable.
- Ensure the body explains reasoning, not just file list.

## Suggested Helper

```bash
bash .agents/commands/git_commit_writer.command feat agents "add core git workflow skills"
```

## Output

- One commit message title
- Optional detailed body
- Commit created from staged changes
