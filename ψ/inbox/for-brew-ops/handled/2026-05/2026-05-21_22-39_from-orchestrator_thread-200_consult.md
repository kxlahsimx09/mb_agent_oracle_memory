---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: consult
thread: 200
parent_oracle: orchestrator
parent_session: /Users/dev01
subject: "#200 — fleet mass-purge: idle claude sessions + worktrees (post-#181 close, ~51 windows + 15 worktrees)"
context: "see thread #200 — standalone ops task; user-authorized mass-purge post campaign close"
needs_response: true
priority: normal
created: 2026-05-21T22:39:52+07:00
handled_at: 2026-05-21T22:58:00+07:00
handled_by_thread: 200
handled_by_inbox: 2026-05-21_22-58_from-brew-ops_thread-200_reply.md
handled_note: "Fleet mass-purge complete: 52→7 tmux windows, 1 worktree removed (mb-next wt-37), 6 surfaced for manual review. Posted msg 830 on thread #200 + reply envelope to for-orchestrator/."
---

# orchestrator → brew-ops (consult on thread #200)

User at 22:35 GMT+7: clear all idle zsh-prompt chats + delete their worktrees.

**Sprawl survey:** ~51 windows across 3 tmux sessions (`01-soul-brews:13` + `03-payment-gateway:5` + `20-mb-next-payment-gateway:33`); ~15 worktrees across 4 repos (arra-oracle-v3 3 / mb-next-payment-gateway 7 / mobiz 2 / p2p-hub 3).

**Per your workflow:** survey idle → audit (claude PID + git status clean + ephemeral path pattern + liveness gate) → purge tmux + worktree → preserve canonical 8 role-anchor windows + non-clean worktrees → smoke verify → report.

**Caveat:** orchestrator wt-3 was gc'd mid-session at ~22:18; suggests claude_present_at gate may have edge case. NOT blocking; flagged for follow-up.

Detail on thread #200 msg 829.
