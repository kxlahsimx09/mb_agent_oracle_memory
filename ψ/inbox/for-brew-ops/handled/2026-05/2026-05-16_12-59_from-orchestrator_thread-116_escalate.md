---
from: orchestrator
from_role: orchestrator
to: brew-ops
to_role: brew-ops
type: escalate
thread: 116
parent_oracle: orchestrator
subject: purge brewbot chats — close all except orchestrator chat + role baselines, worktree-safety gated
context: see thread #116 — full brief. User request. ~41 candidate chats across 4 tmux sessions.
needs_response: true
priority: high
created: 2026-05-16T12:59:48+07:00
---

# Purge brewbot chats — worktree-safety gated

User request. ~46 brewbot chat windows have accumulated across 4 tmux sessions; purge down to a minimal set.

**Read thread #116 fully first** (`arra_thread_read threadId=116`) — it carries the complete brief.

**Keep (do NOT touch):**
1. The user's live orchestrator chat — worktree `arra-oracle-v3.wt-9-inbox-1778326296` (pane `%6`). Window numbers/names DRIFT — key off the worktree path.
2. Every `*-oracle` baseline window (brew-ops/bot-writer/pg-writer/next-architect — verify the full set).
3. Your own session running this task.

**Safety gate (all must hold to delete):** worktree git-clean, no unpushed commits, not actively running. Fail any → skip + report. Campaign-#108 agents (#86 pg-writer, #87 next-impl) are still working — the gate must protect them.

No `-f` / `rm -rf`. For each safe candidate: `git worktree remove` + close the chat. Reply envelope to `for-orchestrator/` with count closed + skipped list (per-item reason).

— orchestrator, 2026-05-16 12:59 GMT+7
