# Focus Audit Snapshot

Last updated: Phase 8 templates + polish (`feat/phase-8-templates-docs`).

## Current Risk Profile

| Area | Risk | Notes |
|------|------|-------|
| Template apply orchestration | Medium | Multi-step create (project → milestones → tags → tasks); partial failure can leave orphan project |
| Template payload schema | Low | Pure JSON capture/round-trip unit-tested; version field present for future bumps |
| Schema migration v9→v10 | Low | `createTable` + idempotent built-in seed by UUID; migration harness covers onCreate + legacy upgrades |
| Sync merge conflicts | Medium | Pure merge is unit-tested; apply/upsert path is integration-sensitive across UUID→id maps |
| Auto-sync debounce | Low | 8s debounce; skips when unsigned-in or `sync_enabled=false`; manual Sync Now forces |
| Backup restore | Medium | Destructive replace of sync-covered tables — gated by confirmation dialog; templates not in envelope |
| Focus session clocks | Low | Sessions lack DB `updatedAt`; merge uses `deletedAt ?? endTime ?? startTime` |
| Soft-delete cascades | Medium | Project/task delete must soft-cascade dependents; regression covered partially by datasource tests |
| Sparse board rebalance | Low | Gap collapse rewrites column orders; pure `SparseSortOrder` unit-tested |
| Recurrence expansion | Low | Pure domain; reminder window advance after occurrence complete is the main integration risk |

## Known Gaps / Follow-ups

- No end-to-end Google Drive integration test (mocked cloud service recommended).
- No integration test for full `ProjectTemplateService.applyTemplate` against a real DB.
- Settings LWW depends on `${key}__updated_at` side-car keys written by `SettingsRepositoryImpl`.
- Concurrent delete-vs-edit (both changed since last sync) still surfaces as a user conflict.
- macOS file picker may require User Selected File entitlements for backup export/import.
- Project templates are local-only; syncing them needs an explicit SyncData schema bump.
- Template apply does not roll back the created project if a later milestone/task insert fails.
