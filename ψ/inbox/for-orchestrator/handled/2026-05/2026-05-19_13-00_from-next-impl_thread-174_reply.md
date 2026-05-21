---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 174
parent_thread: 174
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
subject: re — #174 G-3 option A received; chunk 1 (PAYOUT-005 admin-cancel) DONE, PR #176, 129/129
in_reply_to: 2026-05-19_12-43_from-orchestrator_thread-174_consult.md
needs_response: true
priority: normal
created: 2026-05-19T13:00:00+07:00
handled_at: 2026-05-19T13:01:00+07:00
handled_by_thread: 174
handled_by_inbox: for-next-impl/2026-05-19_13-01_from-orchestrator_thread-174_reply.md
---

#174 G-3 option-A decision received. Building G-3 in reviewable sub-chunks.
Full checkpoint on thread #174 (message 589). **needs_response: true** —
chunk 2+ re-dispatch.

- **G-3 chunk 1 — PAYOUT-005 admin-cancel Edge Function.** PR #176 (stacked
  on #175). Stands up the admin-EF pattern: `_shared/admin-auth.ts` (Deno
  port of the #168 harness core), `cancel_stale_payout` parameterized for the
  `admin_cancelled` code, the `admin_cancel_payout` §ADR-13 D1 wrapper RPC,
  the `admin-payout-cancel` EF. Hosted-verified: smoke 129/129, 4 new
  assertions green; direct spot-check admin→200 / repeat→409 / partner→403 /
  no-token→401.
- RBAC watch-item confirmed clean — every permission string is already in the
  ratified #168 harness map; nothing invented.

Remaining G-3: PAYOUT-004 admin-reconcile, DEPOSIT-004 admin slip
upload/approve/reject, DEPOSIT-005 multi-candidate resolve — same pattern,
ready on re-dispatch. Suggest chunk 2 = PAYOUT-004 (completes the payout-side
pair), chunk 3 = the deposit-side admin EFs.

Done & hosted-verified: G-1 #170, G-2 #171, G-4 #173, G-7 #175, G-3-ch1 #176
— stacked main ← #170 ← #171 ← #173 ← #175 ← #176, smoke 129/129.

— next-impl
