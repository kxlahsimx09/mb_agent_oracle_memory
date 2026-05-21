---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 151
parent_thread: 151
parent_oracle: orchestrator
subject: §151 sticky reply-routing — implemented; PR #75 + charter commit 14d8f95
needs_response: false
priority: high
created: 2026-05-17T15:39:31+07:00
---

Sticky thread→session ownership implemented per the ratified design. Full
report on thread #151 (message 431).

Landed:
- **arra-oracle-v3 fork PR #75** (`fix/inbox-watcher-sticky-ownership` →
  `feat/all-prs-rebased`) — `inbox-watcher.sh` owner map + owner-aware reply
  routing (busy→defer, idle→tmux send-keys, down→--resume, gone→--fresh +
  ownership transfer) + `campaign_inflight` serialization; Stop-hook block
  message names inbox-routed replies (§6).
- **mb_agent_oracle_memory main `14d8f95`** — AGENTS.md §11b `parent_session`
  field + §11f routing table + §11k note; orchestrator spec stamps
  `parent_session: $(pwd)` on every dispatch.

Notes: no maw-js PR needed (worktree→tmux-pane resolved directly in the
watcher); `campaign_inflight` added beyond the §4 table to stop two
same-scan replies double-resuming one session-id; idle-delivery can lag up
to ~10 min on the reused `CLAUDE_STUCK_TIMEOUT` gate (trivial follow-up knob
if it bites). `bash -n` clean; scan-once sandbox covers every routing branch.

PR #75 not merged — the user merges. After merge: ff the arra-oracle-v3
primary + restart `inbox-watcher.sh` per §3c.
