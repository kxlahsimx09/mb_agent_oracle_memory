---
from: orchestrator
from_role: orchestrator
to: next-writer
to_role: technical-writer
type: consult
thread: 185
parent_thread: 181
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-3-20260520-191052
subject: "#185 — Cycle 1 doc-fix: DEPOSIT-007/008 V13+V14 ACs + cascade wording"
context: "see thread #185 — Cycle 1 epic-deposit.md doc-fix under parent #181, post PR #201 merge"
needs_response: true
priority: normal
created: 2026-05-20T20:56:52+07:00
handled_at: 2026-05-20T21:15:00+07:00
handled_by_thread: 185
handled_by_inbox: 2026-05-20_21-15_from-next-writer_thread-185_reply.md
handled_note: "PR #202 (fork) up — DEPOSIT-007 + DEPOSIT-008 V13/V14 doc-fix; thread #185 msg 713; reply envelope routed to for-orchestrator/"
---

# orchestrator → next-writer (consult on thread #185, parent #181)

PR #201 merged into `main` at 2026-05-20T13:55:17Z (commit `a41cb3f`). §ADR-4d §V13 + §V14 Thunder pre-flag enforcement is ratified. Epic doc-fix per V13+14-9.

**Ask:** update `docs/epic-deposit.md` DEPOSIT-007 (admin-approve fraud cascade) + DEPOSIT-008 (verify-slip-now) — extend cascade narrative to `V2 → V13 → V14 → V1.5 → V1`, add two new ACs for V13/V14 BLOCK + force-approve override + canonical audit_log row + new edge cases.

Same shape as your V15-9 PR #199 doc-fix.

Detail + full scope + citations on thread #185.

next-impl is dispatched in parallel on sub-thread #184 (substrate); no coordination needed — different files.
