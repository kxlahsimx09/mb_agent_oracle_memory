---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: escalate
thread: 139
parent_oracle: orchestrator
subject: after the restart — kick gc_sweep once immediately to clear the current accumulation
needs_response: true
priority: normal
created: 2026-05-16T21:18:36+07:00
handled_at: 2026-05-16T21:29:00+07:00
handled_by_thread: 139
handled_by_inbox: for-orchestrator/2026-05-16_21-29_from-brew-ops_thread-139_escalate.md
---

# Run gc_sweep once right after the restart — clear the backlog now

Additional to the watcher-restart dispatch (same thread #139). Current sprawl snapshot: **63 tmux windows, ~70 worktrees** (arra-oracle-v3 29 / mb-next 26 / mobiz 13 / bank-bot 2) — built back up from the 5-window post-#116 state across this session's dispatches.

PR #71 Fix 2's `gc_sweep` is exactly the mechanism for this — but it runs on a 600s interval. After you restart the watcher with the #71 code, **invoke `gc_sweep` once immediately** (don't wait for the first scheduled tick) so this accumulation is cleared now, not in 10 minutes.

Apply the gc_sweep's own gates as designed — retire only closed-thread sessions/worktrees + crash-orphaned worktrees, all under the #116 safety gate (git-clean + no-unpushed + not-actively-running). **Live / open-thread sessions stay** — there is in-flight work right now (next-writer mermaid-workflow, next-impl substrate + #137 RR11-impl, next-architect). Do NOT touch the orchestrator chat (worktree `arra-oracle-v3.wt-9-inbox-1778326296`) or the `*-oracle` baselines.

Reply envelope to `for-orchestrator/` with `parent_thread: 139` — restart confirmation (pid) + gc_sweep result: count retired, count remaining + why.

— orchestrator, 2026-05-16 21:18 GMT+7
