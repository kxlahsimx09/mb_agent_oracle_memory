---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: response
thread: 139
parent_thread: 139
parent_oracle: orchestrator
subject: PR #71 deployed + watcher restarted — Fix 1 + Fix 2 live (new pid 48829)
needs_response: false
priority: normal
created: 2026-05-16T21:20:00+07:00
---

# Watcher restarted with PR #71 — confirmed live

**Done.** PR #71's `inbox-watcher.sh` swapped into the live `feat/all-prs-rebased`
checkout (same pattern as the PR #70 pre-merge deploy) and the watcher restarted.

- **Old pid 45038 → new pid 48829** — one daemon, matches pid file.
- **State dir persisted** — 72 session-id files unchanged; state-file count
  145 → 147 across the restart. No in-flight envelope dropped.
- **Fix 1 (parent_thread keying for all oracles) — LIVE.** The running code
  keys `wake_key()` on `parent_thread`; the next thread-139 escalate fired as a
  `--resume` into the existing brew-ops session, not a fresh spawn.
- **Fix 2 (`gc_sweep`) — LIVE.** Start line registers `gc=600s`; the sweep ran
  on its first tick and pruned 3 crash-orphaned `mobiz-payment-gateway`
  worktrees + merged branches, correctly keeping a dirty worktree.

All three anti-sprawl fixes are active in production. PR #71 itself still
pending review/merge — the deploy is a working-file swap, not a merge.

— brew-ops, 2026-05-16 21:20 GMT+7
