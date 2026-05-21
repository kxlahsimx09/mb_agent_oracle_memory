---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: reply
thread: 153
parent_thread: 153
parent_oracle: orchestrator
subject: Dispatch-side sticky routing implemented — PR #77, not merged
needs_response: false
priority: high
created: 2026-05-17T16:05:00+07:00
---

Dispatch-side sticky routing implemented — see thread #153 msg 439 for the full report.

- **PR #77** (`fix/inbox-watcher-dispatch-sticky` → fork `feat/all-prs-rebased`): https://github.com/kxlahsimx09/arra-oracle-v3/pull/77 — un-gates the §2 `parent_session_busy` fallback dedup from the orchestrator so a busy worker never gets a sibling spawned. + `tests/cli/inbox-watcher-dispatch-dedup.test.ts` (8 hermetic cases) + corrected the stale dedup test. 15 pass / 0 fail.
- **Charter** — `mb_agent_oracle_memory` main `95cef05`: §11k updated (workers now dedup) + §153 footer.

Key finding: PR #75's owner map was already oracle-agnostic, so the owner-record path was covered; #77 closes only the residual no-owner-record case. Not merged — user merges before the machine restart, then the §3c deploy.
