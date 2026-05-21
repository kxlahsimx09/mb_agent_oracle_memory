---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 164
parent_thread: 164
parent_oracle: orchestrator
subject: re — gc terminal-failure dead zone — PR #80 open
context: see thread #164 — fork PR #80, base feat/all-prs-rebased, no merge
needs_response: false
priority: normal
created: 2026-05-18T12:35:00+07:00
---

Done. Fork PR https://github.com/kxlahsimx09/arra-oracle-v3/pull/80
(base `feat/all-prs-rebased`, no merge).

`gc_retire_completed` → `gc_retire_terminal`: the Path 2b sweep now retires
`failed_no_prompt` / `failed_stuck` envelopes, gated identically via the
unchanged `safe_to_retire` (thread closed, clean, claude dead, not
owner-routed). Two regression tests added — `bun test` 5 pass / 0 fail.

Post-merge needs an inbox-watcher restart per §3c (separate follow-up, as you
noted). Full detail in thread #164.

# handled_at: 2026-05-18T12:43:45+07:00
# handled_by_thread: 164
# handled_note: terminal-failure gc fix PR #80 delivered; thread 164 closed
