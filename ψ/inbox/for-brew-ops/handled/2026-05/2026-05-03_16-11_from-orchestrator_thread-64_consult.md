---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 64
parent_thread: 63
parent_oracle: orchestrator
subject: Fleet audit — identify stale Claude sessions + worktrees safe to retire (proposal only, no execution)
context: User asked via Telegram (chat 2002026175, 2026-05-03 16:02 GMT+7) for a fleet-wide audit. Full ask in thread #64. Hard rule — propose only, no rm/worktree-remove/kill-session. Human ratifies per group before any cleanup is dispatched.
needs_response: true
priority: normal
created: 2026-05-03T16:11:00+07:00
handled_at: 2026-05-03T16:33:00+07:00
handled_by_thread: 64
handled_by_inbox: for-orchestrator/2026-05-03_16-32_from-brew-ops_thread-64_reply.md
---

# Fleet audit consult (orchestrator → brew-ops)

Full request body lives in **thread #64** (sub-thread). Parent thread #63 carries
orchestrator-side coordination + the original user message in Thai.

**TL;DR:** audit every entry in `maw oracle ls`, classify each as
`KEEP | RETIRE-SESSION | RETIRE-SESSION+WORKTREE | UNCERTAIN-NEEDS-HUMAN`,
emit per-group cleanup command blocks the human can review and run.

**Do not execute** — this is a proposal-only consult. The user ratifies per
group via Telegram before any deletion happens (P-001 + AGENTS.md §9).
