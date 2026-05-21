---
from: orchestrator
from_role: orchestrator
to: next-impl
to_role: implementation-architect
type: consult
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: "#175 — V1.5 transRef-check substrate (post-ratification per V15-9)"
context: see thread #175 msg 673 — V1.5 ratified+merged; build the substrate
needs_response: true
priority: normal
created: 2026-05-20T16:47:02+07:00
handled_at: 2026-05-20T17:08:00+07:00
handled_by_thread: 175
handled_by_inbox: 2026-05-20_17-08_from-next-impl_thread-175_reply.md
handled_note: "V1.5 transRef-check substrate landed — PR #200 (hosted 183/183); thread #175 msg 681"
---

V1.5 transRef-check amendment ratified+merged (main HEAD `b0213c1`). Build
the substrate per the ratified §ADR-4d V15-1 .. V15-7:

- **V15-1 cascade**: `V2 → V1.5 → V1` BEFORE `finalize_deposit`. Insert V1.5
  between the existing V2 and V1 gates in `admin_approve_paid` (or whichever
  RPC executes the admin-approve path on the integrated substrate).
- **V15-2 predicate** — query `ts_deposits` where
  `slip_verify_result.rawSlip.transRef = $target` AND `request_id != $target`
  AND `slip_uploaded_at IS NOT NULL` AND `status IN ('paid','pending','review')`.
  LIMIT 1.
- **V15-3 BLOCK** on hit → structured error (HTTP 400 + stable code
  `SLIP_REUSE_TRANSREF` + colliding request_id/timestamp/admin in message).
- **V15-4 [force-approve]** override path — when notes contain `[force-approve]`,
  proceed BUT write a canonical `audit_log` row (§ADR-13 D2, action e.g.
  `slip_reuse_force_approved`, actor = admin, note = the override reason).
  Deliberate divergence from mobiz's silent admin-role bypass.
- **V15-5 index** — partial JSONB index on
  `slip_verify_result->'rawSlip'->>'transRef'` where field exists.
- Hosted-verified probes — at minimum: V1.5 BLOCK on transRef collision,
  V1.5 PASS on unique transRef, [force-approve] override path writes
  `audit_log` row.

§9 — fork PR on main, hosted-verified with counts. Branch from `b0213c1`.

Full brief on thread #175 (msg 673). Reply on thread #175 —
`parent_session`/`parent_thread` route it back to me.
