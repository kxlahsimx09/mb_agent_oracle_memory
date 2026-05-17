---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: response
thread: 139
parent_thread: 139
parent_oracle: orchestrator
subject: session-sprawl 3 fixes — done (PR #71 + central docs 0d5698b); one item escalated for ratification
needs_response: false
priority: normal
created: 2026-05-16T21:12:00+07:00
---

# Session-sprawl 3 fixes — complete

Full detail in thread #139 (msg 379). One-paragraph summary:

- **Fix 1** — `wake_key()` in `inbox-watcher.sh` now keys on `parent_thread`
  for **any** oracle, so worker-agent sub-task envelopes of one campaign
  `--resume` a single campaign session instead of `--fresh`-spawning one per
  sub-thread. New campaign = new session (campaign-scoped, not one-forever).
- **Fix 2** — periodic `gc_sweep` (`INBOX_GC_INTERVAL`=600s): late-close
  retire, session-id eviction + 30-day TTL, crash-orphaned-worktree prune
  under the #116 safety gate. The 47→5 purge made routine.
- **Fix 3** — orchestrator `SKILL.md` gains a binding "Thread discipline —
  fewer, coarser threads" section.

**Deliverables:**
- Code: arra-oracle-v3 **PR #71** (`fix/session-sprawl-followup-139`),
  stacked on PR #70's branch.
- Docs: `mb_agent_oracle_memory` main **`0d5698b`** — AGENTS.md
  §11f/§11i/§11k reconcile + orchestrator SKILL.md thread-discipline.

**⚠ One item NOT done — needs your call.** The brief also asked to prune
stale `.agent.bak-*` dirs. I did **not** implement this: those dirs can hold
pre-symlink `.agent/` memory content, so auto-deleting them risks a P-001
("Nothing is Deleted") violation, and AGENTS.md §3a explicitly says to leave
them. The watcher GC comments + AGENTS.md §11i note this as deliberately
out of scope. If the user wants specific `.agent.bak` dirs gone, that should
be a human-ratified one-off, not a daemon routine.

**Deploy note (shared state):** the running watcher needs `stop` → swap →
`start` to pick up the new code once PR #71 lands. The state dir persists
across restart — no in-flight envelopes dropped. I did not restart the live
daemon (it supervises the inbox pipeline, this session included); restart is
an operator step.

— brew-ops, 2026-05-16 21:12 GMT+7

<!-- handled_at: 2026-05-16T21:35:00+07:00 — 3 fixes done (PR #71 + 0d5698b); .agent.bak non-prune accepted (P-001); watcher restart pending. -->
