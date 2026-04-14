# Focus Feature Plans

This document tracks implementation priorities and planning guidance for coding agents.

## Planning Principles

- Prioritize features that reduce regression risk and maintenance cost.
- Keep architecture boundaries intact while adding capability.
- Persist user-facing preference state when users expect continuity across restarts.

## Near-Term Priorities

### 1. Testing Foundation (High)

Goal:
- Establish baseline unit/widget/integration tests for the highest-risk flows.

Suggested scope:
- Domain services for tasks/projects/session
- Provider behavior for key mutation paths
- Notification scheduling fallback behavior

### 2. Session Reliability Improvements (High)

Goal:
- Improve lifecycle accuracy and recovery behavior for active sessions.

Suggested scope:
- Resume/reconcile elapsed time on app foreground
- Strengthen persistence of phase transition metadata
- Validate behavior on Android/iOS lifecycle events

### 3. Task Enhancements (Medium)

Goal:
- Continue improving task scheduling and execution UX.

Suggested scope:
- Expand recurring task capabilities
- Improve reminder controls and statuses
- Add stronger validation and user feedback for invalid task inputs

### 4. Reporting and Insights (Medium)

Goal:
- Expand reporting value while keeping UI responsive and readable.

Suggested scope:
- Additional insight visualizations with persisted window modes
- Better empty states and no-data messaging
- Evaluate caching/aggregation improvements for heavier stats views

## Backlog Candidates

- Import/export and backup restore workflows
- Extended keyboard and desktop productivity shortcuts
- Advanced session analytics and trend surfacing

## Implementation Template

When adding a planned feature:

1. Define affected layers (`data`, `domain`, `presentation`).
2. List schema/migration impact explicitly.
3. List provider/codegen impact explicitly.
4. Define manual validation checklist.
5. Add/update patterns in `.agents/docs/patterns.md`.
6. Update `AGENTS.md` and docs references if workflows changed.

## Definition of Done

A feature plan item is done when:

- Implementation is merged and analyzer-clean.
- Code generation is current.
- Relevant tests are added/updated (or documented as gap).
- Agent docs are updated for any new patterns, commands, or constraints.
