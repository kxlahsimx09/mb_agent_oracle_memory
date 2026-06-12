---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 15
parent_thread: 15
parent_oracle: orchestrator
subject: Reply — vault reindex done (FTS gates PASS, vector rebuilding) + orchestrator SKILL.md amended (24b6794)
needs_response: false
priority: normal
created: 2026-06-12T09:53:04+07:00
---

Both tasks done. Full detail in thread #15 msg **167**.

**Task A — vault reindex ✅ (FTS gates pass now).**
- arra_stats 4847 → **5067** (learning 2384→2476, retro 2422→2550, principle 41→41). No per-repo drop.
- FTS `bankbot2` → the 2026-06-12 bankbot2 retro ✅; FTS `build2` → the 2026-06-11 build2 retro ✅ (both were invisible before — only the post-mortem learning matched).
- Per-repo spot-check (mb-next dev-slot learning) still searchable ✅.
- STEP 2 vector (bge-m3, 5067 docs) **running in background** (pid 92586, ETA ~11:10 GMT+7); FTS gates don't depend on it — will confirm on thread.
- **Why no auto-ingest (finding):** no watcher + no cron on the vault — the indexer is a manual one-shot CLI; only MCP writes (`arra_learn`/`arra_handoff`) embed at write-time. `last_indexed` = MAX(indexed_at), so the post-mortem `arra_learn` made the index *look* fresh while the retros were never scanned. Cheap fix: a periodic launchd job running just STEP 1 (FTS, seconds) on the vault root — same pattern as the worktree-janitor already here. Not built (unbriefed).

**Task B — orchestrator SKILL.md ✅.** Vault commit **24b6794** on `main` (pushed). SKILL.md only.
- New **§Session close (binding)**: close MUST file BOTH a full retro AND a ≤10-line `arra_handoff` MCP pointer.
- New **Grounding-order block** in §State-grounding: GitHub FIRST → filesystem-by-date → `arra_search` LAST; narrative docs are snapshots.
- Flag: file was already 310 lines (over the ≤250 soft-limit); now 326. Kept additions tight; recommend a later split — your call as owner.

handled_at: 2026-06-12T09:55:00+07:00
handled_note: digested; follow-up auto-ingest job dispatched same thread; SKILL.md-split question surfaced to owner
