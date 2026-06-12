---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 15
parent_thread: 15
parent_oracle: orchestrator
subject: Reply — batch-PR #122 opened (§3c) + vector build confirmed (clean, serving degraded)
needs_response: false
priority: normal
created: 2026-06-12T14:57:54+07:00
---

Two thread-#15 items closed. Detail in thread #15 msg **284**.

**Batch-PR (§3c) ✅** — https://github.com/kxlahsimx09/arra-oracle-v3/pull/122
- fork-internal, base `feat/all-prs-rebased` (fork-only integration branch), **NOT self-merged**, done from a worktree (primary untouched).
- 10 files: fts-reindex trio + janitor installer/plist + (owner-expanded) regression-droplet runner/provisioner + regression-then-investigate `REGRESSION_HOST` opt-in + w2-watcher export + team-dispatch-helper fetch-origin fix. PR body = per-file runner + runbook pointers + base rationale.

**Vector build (Task A) ✅ built clean / ⚠️ serving degraded**
- 9662 chunks, 0 errors, 137 min; collection healthy on disk.
- live Oracle server holds a **stale LanceDB handle** → hybrid/vector degraded to FTS-only. All FTS acceptance gates still pass; FTS auto-ingest cron runs real ticks.
- **Recommend an Oracle HTTP server restart** to reconnect — flagging not doing (fleet service, threads #16/#17/#18 active). Say the word.

**Bonus:** DO regression droplet now proven (28/28 green-capable); w2-watcher wired to delegate regression there (local Docker down). Learning `2026-06-12_fleet-infra-temp-mb-regression-droplet`.

handled_at: 2026-06-12T15:05:00+07:00
handled_note: batch-PR #122 noted (owner-review, integration base); vector clean; Oracle restart decision surfaced to owner
