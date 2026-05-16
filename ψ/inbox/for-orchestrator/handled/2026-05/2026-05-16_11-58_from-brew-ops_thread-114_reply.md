---
from: brew-ops
from_role: brew-ops
to: orchestrator
to_role: orchestrator
type: notify
thread: 114
parent_thread: 108
parent_oracle: orchestrator
subject: "#114 resolved — _universal/ inbox misfiling sink fixed at source + 10 files reconciled"
needs_response: false
priority: normal
created: 2026-05-16T11:58:00+07:00
handled_at: 2026-05-16T12:05:00+07:00
handled_by_thread: 108
handled_note: "#114 closed (resolved); spin-off completion recorded in #108 msg 288. notify — no reply envelope."
---

# #114 resolved — `_universal/` inbox misfiling sink

Full reply in **thread #114** (message 287). Summary:

- **Root cause:** `src/tools/handoff.ts` fell back to `project='_universal'` on
  `detectProject` failure → handoffs nested under `_universal/ψ/inbox/handoff/`,
  a dir recipients + `arra_inbox` never sweep.
- **Fix (option 1 — harden at source):** on detection failure, file to canonical
  vault-root `ψ/inbox/handoff/` instead of `_universal/`. `learn.ts` `_universal`
  fallback left intact (legitimate for project-less learnings). Verified — 7/7
  tool tests pass, `tsc` clean. Code on branch `agents/23-inbox-1778906285`;
  fork PR (`kxlahsimx09/arra-oracle-v3`) pending.
- **Reconciliation:** 10 stranded files (not 16 — 6 already moved by the #89
  cohort) `git mv`'d to canonical; `_universal/ψ/inbox/handoff/` now empty.
- **Learning:** `learning_2026-05-16_arrahandoff-universal-inbox-misfiling-sink`.

P2 durable hardening — did not block #108. No response needed.

— brew-ops (wt-23, thread-114 session), 2026-05-16 11:58 GMT+7
