---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 175
parent_thread: 175
parent_oracle: orchestrator
parent_session: /Users/dev01/Code/github.com/Soul-Brews-Studio/arra-oracle-v3.wt-1-20260519-105119
in_reply_to: 2026-05-20_16-47_from-orchestrator_thread-175_consult.md
subject: "#175 — V1.5 transRef-check substrate landed (PR #200, hosted-verified 183/183)"
context: thread #175 msg 681 — substrate port of ratified §ADR-4d V15-1..V15-7
needs_response: false
priority: normal
created: 2026-05-20T17:08:00+07:00
---

Substrate port of the ratified §ADR-4d §Amendment 2026-05-20 V1.5 transRef-
check landed as fork PR #200 (branch `next-impl/thread175-v15-transref-substrate`)
on main HEAD `b0213c1`. **Hosted-verified 183/183 PASS** (baseline 180/180
from main + 3 new V1.5 assertions).

**Migration `20260520000009_adr4d_v15_transref_check.sql`:**
- Schema: `ts_deposits.slip_verify_result` widened text → jsonb (existing
  text → `{"verdict": <text>}`). `v_deposits` view dropped + recreated
  around the ALTER (its `SELECT *` rule blocked the type change).
- `record_slip_verify_attempt` writer updated to store the JSONB form
  `{verdict, rawSlip:…}` from `p_thunder_response_raw`. §VF1
  verdict-only-flip preserved verbatim.
- **V15-1** cascade — `admin_approve_paid` extended V2 → V1.5 → V1.
- **V15-2** predicate — transRef equality, exclude self, slip_uploaded_at
  IS NOT NULL, `status IN ('paid','pending','checking')`. **Substrate
  translation flagged:** the architect's `'review'` has no deposit-lane
  equivalent; `'checking'` is the slip-bearing admin-in-loop holding
  state. Documented in migration header.
- **V15-3** BLOCK — `RAISE EXCEPTION 'V1.5_FRAUD %'` with structured
  `{check, code:'SLIP_REUSE_TRANSREF', colliding_request_id,
  target_transRef, target_request_id, override_hint}` payload. `V<n>_FRAUD`
  prefix shape preserved across V1 / V1.5 / V2.
- **V15-4** override — two-gate (`[force-approve]` + `user_type='admin'`)
  writes a canonical audit_log row with `action_type='slip_reuse_v15_override'`,
  metadata={colliding_request_id, target_transRef, target_request_id,
  admin_notes, force_approve_marker_position, actor_user_type}. The
  completed-approve row carries a `v15_override_audit_id` cross-link.
  **Deliberate divergence from mobiz's silent admin-role bypass**.
- **V15-5** partial JSONB index per the architect's exact spec.

**Probe `slip-reuse-v15.ts`** — 3 named assertions (BLOCK / PASS /
force-approve audit) seeded post-quiescence on Client A; cleans up on exit.

**Discipline:** §9 honoured; no merge. Branched from `b0213c1`. No
unratified config touched. Status-enum translation `'review'` → `'checking'`
is documented; no other deviation from the ratified spec.

PR: https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/200
Thread reply: #175 msg 681
Evidence: `poc/integration/evidence/integration-hosted-run-2026-05-20T10-00-52-159-hosted-tiny.json`

Awaiting orchestrator/user disposition.
