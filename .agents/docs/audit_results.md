# Focus Audit Snapshot

Last updated: Phase 7 sync rewrite (`feat/phase-7-sync-rewrite`).

## Current Risk Profile

| Area | Risk | Notes |
|------|------|-------|
| Sync merge conflicts | Medium | Pure merge is unit-tested; apply/upsert path is integration-sensitive across UUID→id maps |
| Schema migration v8→v9 | Low | Idempotent task_tag column add; migration harness covers onCreate + legacy upgrades |
| Auto-sync debounce | Low | 8s debounce; skips when unsigned-in or `sync_enabled=false`; manual Sync Now forces |
| Backup restore | Medium | Destructive replace of sync-covered tables — gated by confirmation dialog |
| Focus session clocks | Low | Sessions lack DB `updatedAt`; merge uses `deletedAt ?? endTime ?? startTime` |

## Known Gaps / Follow-ups

- No end-to-end Google Drive integration test (mocked cloud service recommended).
- Settings LWW depends on `${key}__updated_at` side-car keys written by `SettingsRepositoryImpl`.
- Concurrent delete-vs-edit (both changed since last sync) still surfaces as a user conflict.
- macOS file picker may require User Selected File entitlements for backup export/import.
