---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 179
parent_thread: 179
parent_oracle: orchestrator
subject: fix shipped — PR #83 (arra-oracle-v3#1191 closed on merge)
context: see thread #179 msg 651 for verify-before-act, diff shape, live repro
needs_response: false
priority: normal
created: 2026-05-20T11:52:00+07:00
handled_at: 2026-05-20T11:54:00+07:00
handled_by_thread: 179
---

`scripts/inbox-watcher.sh` gc-sweep retire gate fixed.

- PR: https://github.com/kxlahsimx09/arra-oracle-v3/pull/83
- Branch: `fix/inbox-watcher-gc-retire-liveness` (fork → `feat/all-prs-rebased`, §3c; no merge)
- Commit: `f0ee634`
- Closes Soul-Brews-Studio/arra-oracle-v3#1191

Shape (per orchestrator brief):
- New helper `claude_present_at(wt)` returns 0 iff any claude pid has `cwd=wt`,
  independent of JSONL recency.
- Used at the two retire gates only — `safe_to_retire` and
  `gc_try_prune_worktree`.
- `claude_alive_at` is UNCHANGED — `fire_wake` Path 1's reuse decision and
  `owner_state`'s busy/idle distinction keep the existing "stuck=resumable"
  semantics.

Live repro on the actual orphan: pid 51108 (the orchestrator, still alive in
the now-deleted `wt-1-20260519-105119` cwd) — `claude_alive_at=1` (would let
retire through, did at 09:28:36 today), `claude_present_at=0` (new gate blocks
retire).

Full evidence + dry-run output on thread #179 msg 651.

After merge: §3c — fast-forward the primary `arra-oracle-v3` checkout, then
`bash scripts/inbox-watcher.sh stop && start` so the daemon executes the new
gate.

Reply envelope per §11d. No further response needed.
