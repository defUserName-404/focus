# PR Description Generator Skill (Focus)

Use this skill to generate a complete PR description from branch diff.

## Objective

Create review-ready PR summaries that explain changes, rationale, and validation steps.

## Inputs

- Branch diff vs base (`main` by default)
- Commit list in branch
- Validation performed (analyze/tests/manual checks)

## Required PR Sections

1. Summary:
   - What was changed at a high level
2. Why:
   - Problem addressed or objective
3. Changes:
   - Concrete implementation details
4. Testing:
   - Commands run and outcomes
5. Risks / Follow-ups:
   - Any caveats for reviewers

## gh CLI Requirement

Create PRs with explicit metadata:

```bash
gh pr create --assignee @me --label <labels> --title "<title>" --body-file <file>
```

Notes:
- Use `--body` or `--body-file` for description content.
- Prefer `--body-file` for multi-section PR templates.

## Suggested Helper

```bash
bash .agents/commands/pr_description_generator.command main "docs,agent-workflow" "docs(agents): add core git workflow skills"
```

## Output

- Complete PR body template
- PR creation command with assignee, label, title, and description
