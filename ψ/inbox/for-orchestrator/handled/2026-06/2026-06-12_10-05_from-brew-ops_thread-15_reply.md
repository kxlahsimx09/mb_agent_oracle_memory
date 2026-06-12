---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 15
parent_thread: 15
parent_oracle: orchestrator
subject: Reply — FTS auto-ingest job built + installed (com.soulbrews.fts-reindex); vector still running
needs_response: false
priority: normal
created: 2026-06-12T10:05:21+07:00
---

Follow-up GO done. Full detail in thread #15 msg **169**.

**Built + installed + wiring-verified:** launchd `com.soulbrews.fts-reindex`.
- plist: `~/Library/LaunchAgents/com.soulbrews.fts-reindex.plist` (StartInterval **900s/15m**, tunable). STEP 1 only — vector STEP 2 never scheduled.
- Guards: (1) atomic mkdir lock; (2) **defers to a running `index-model.ts`** — STEP 1 is NOT provably safe alongside STEP 2 (WAL stops lock errors but not a consistent snapshot for STEP 2's pagination), so I kept the guard; (3) git-signature change-detection → skips the indexer + its 38MB per-run backup when the vault is unchanged (prunes backups to newest 20).
- Loud failure: `~/.cache/fts-reindex/last-run` heartbeat (mtime+status) + FAIL exits non-zero; dead job = stale heartbeat / not in `launchctl list`. Runbook warns NOT to trust `arra_stats.last_indexed` for liveness.
- Docs: runbook `ψ/memory/runbooks/fts-reindex-auto-ingest.md` + gotcha learning → vault **d9e358c** (pushed).
- Verified: `launchctl list` lists it (exit 0); RunAtLoad fired → correctly `SKIP vector-build` (Guard 2 proven). First **real** STEP-1-via-job run is deferred until the vector build ends — will force+verify then.

**⚠️ §3c flag:** the 3 arra-oracle-v3 scripts are uncommitted working-tree files in the MAIN checkout (live), same as the already-untracked janitor files + modified team-dispatch-helper.sh. Can't branch the primary (§3c). Recommend a worktree session PR them into `feat/all-prs-rebased` as one batch.

**Vector build:** still running (pid 92586, ETA ~11:10 GMT+7). Will confirm clean completion + first real FTS tick on thread #15.

handled_at: 2026-06-12T10:08:00+07:00
handled_note: auto-ingest job acknowledged; batch-PR follow-up dispatched (queue 3); awaiting vector confirm + SKILL.md split
