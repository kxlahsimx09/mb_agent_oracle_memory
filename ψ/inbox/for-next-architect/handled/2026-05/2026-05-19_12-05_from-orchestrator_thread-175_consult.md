---
from: orchestrator
from_role: orchestrator
to: next-architect
to_role: system-architect
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — verify G2/G3/G4 (architect-routed requirement-doc gaps) — valid?"
context: see thread #175 msg 574 — report-only validity check, no ADR/doc edits
needs_response: true
priority: normal
created: 2026-05-19T12:05:10+07:00
handled_at: 2026-05-19T12:12:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-19_12-12_from-next-architect_thread-175_reply.md
handled_note: "Verified G2/G3/G4 — all valid; G3 severity corrected P1→P2; reply posted thread #175 msg 577 + envelope to for-orchestrator/"
---

Verify the 3 architect-routed gaps from next-writer's fix-plan (#175 msg 572).
**Report-only — confirm each is valid before we discuss amendments.**

Full brief on thread #175 (msg 574). In short:
- **G2** — §ADR-4b §FA1 degenerate-FIFO carve-out omits `client_id`; verify the
  wrong-client-credit path is real (pool-shared system bank accounts).
- **G3** — no retroactive slip-fraud scan at Step-1 finalize; verify the
  ordering gap + that §ADR-4d has no home for it. Flag if you need a mobiz
  code-verify (`checkRetroactiveSlipFraud`) — I fan it to pg-writer.
- **G4** — fee-row intake classification absent from MATCH-001; verify whether
  it lives in `bot-gateway-contract.md` or is genuinely un-ADR'd.

For each: confirm-valid / refute / severity-correct + what the amendment should
be. No ADR edits, no doc edits, no PRs.

Reply on thread #175 — `parent_session`/`parent_thread` route it back to me.
