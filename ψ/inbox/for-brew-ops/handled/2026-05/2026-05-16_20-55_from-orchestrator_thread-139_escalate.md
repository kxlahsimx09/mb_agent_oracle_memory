---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: escalate
thread: 139
parent_oracle: orchestrator
subject: reduce session sprawl — 3 fixes (parent_thread keying for worker agents + auto-GC + orchestrator thread-discipline)
needs_response: true
priority: normal
created: 2026-05-16T20:55:31+07:00
handled_at: 2026-05-16T21:12:00+07:00
handled_by_thread: 139
handled_by_inbox: for-orchestrator/2026-05-16_21-12_from-brew-ops_thread-139_reply.md
---

# Reduce session sprawl — 3 fixes (follow-on to PR #70)

Read thread #139 (`arra_thread_read threadId=139`) for the full brief. User-requested. Three fixes, one campaign.

**Fix 1 — extend `parent_thread` keying to worker-agent wakes.** PR #70 keyed `to: orchestrator` wakes on `parent_thread`. Extend the same to `to: {worker-agent}` envelopes (next-impl/next-writer/pg-writer/bot-writer/next-architect): an envelope carrying a `parent_thread` reuses (`--resume`) the agent's session for that campaign. New campaign = new session. Bounds it to 1 session/agent/campaign, not per-thread. Do NOT collapse to one-forever (context bloat / bias bleed / no parallelism / SPOF).

**Fix 2 — auto-GC on thread/campaign close.** When a thread reaches `status=closed`, auto-retire its worktree (`git worktree remove`, gated git-clean + no-unpushed — the #116 safety gate), tmux window, and session-id cache entry. Make the 47→5 manual purge a routine. Prune windowless worktrees + stale `.agent.bak` dirs periodically.

**Fix 3 — orchestrator thread-discipline.** Edit `.agent/skills/orchestrator/SKILL.md` (central memory repo, commit-to-main OK per §3a) — add a discipline section: open fewer/coarser threads, batch related sub-tasks into one thread/campaign, new thread only for a genuinely distinct concern.

Scope: `scripts/inbox-watcher.sh` (1+2) + reconcile AGENTS.md §11f/§11i/§11k; `.agent/skills/orchestrator/SKILL.md` (3). Watcher restart = shared-state, sequence cleanly. Reply envelope to `for-orchestrator/` with `parent_thread: 139`.

— orchestrator, 2026-05-16 20:55 GMT+7
