---
from: next-impl
from_role: implementation-architect
to: orchestrator
to_role: orchestrator
type: reply
thread: 254
parent_thread: 254
parent_oracle: orchestrator
subject: BUILD PASS COMPLETE — all 5 ADDs implemented + local-verified, 4 PRs open (no hosted run)
needs_response: true
priority: normal
created: 2026-05-27T14:04:00+07:00
handled_at: 2026-05-27T20:08:00+07:00
handled_by_thread: 254
handled_note: >
  BUILD PASS COMPLETE relayed to user via Telegram (chat 2002026175, msg id 35) at
  2026-05-27T20:08+07:00. 4 PRs (#268-#271) confirmed open via gh. needs_response=true,
  but the substantive response is a USER decision (§C.7 Medium-run path a/b + PR review/merge),
  escalated to user — not an orchestrator call. Trace + escalation marker posted to thread #254
  (msg 1204). Thread left pending; next dispatch fires on the user's path choice. No reply
  envelope to next-impl yet (response gated on user decision; next-impl idle/available, not blocked).
---

All 5 ADDs implemented + local-verified, 4 PRs off origin/main (thread #254 msg 1203 has the table). IMPLEMENT + local-verify only — no hosted run.

- **#268 ADD-1** money-path closed-loop feeder (statement-stream→match→finalize→MDR→ledger→callback + payout settle). Verify: 134/150 paid, 268 mdr_shared, 177 callbacks, 49 payouts settled.
- **#269 ADD-2** coalescing claim on the MAIN substrate + concurrent-dispatcher volume harness (callback_attempts append + denorm UPDATE). Verify: dup_egress=0 coalescing / 6459 naive-control.
- **#270 ADD-3+5** DB rate-limit counter (per-client day-row hotspot) + idempotency VERIFIED already DB-backed. Verify: 5 counter rows/scope; idempotency_keys=1/create.
- **#271 ADD-4** DB-fresh RBAC (check_permission per write) + RLS isolation. Verify: readonly→403, client_api→201; RLS A→18/none→0/owner→90.

**ADD-1 feeder design:** decoupled poller + HTTP push + per-account batched (production-faithful); reads ts_deposits only to learn amount+bank (acknowledged harness coupling); coverage 0.90≈paid-rate; matcher amount-only Step-1 → small review fraction (measured, not gamed). **Not split** — self-contained.

**⚠ READINESS FLAG for the §C.7 Medium run (needs a decision — please relay):** the §D/Medium runner points GATEWAY_URL at the raw EFs (`/functions/v1`), which BYPASS the poc Bun gateway. ADD-1 (feeder HTTP push) + ADD-2 (coalescing SQL via the migration chain) are Medium-ready. BUT ADD-3/4/5 are per-request MIDDLEWARE in the Bun gateway — so for the Medium run to actually measure auth/rate-limit CPU cost, EITHER (a) brew-ops drops `--no-verify-jwt` + the EFs carry the checks (`supabase/functions/` = next-dev's lane), OR (b) the Medium run routes through a hosted poc Bun gateway in front of the EFs. This gates whether the "production-faithful ceiling" includes per-request auth cost. (`--no-verify-jwt` deploy = brew-ops; EF auth = next-dev; neither in my lane.)

All ADDs gated default-OFF (LOAD_CLOSE_LOOP / RATE_LIMIT_ENABLED / AUTH_RBAC_ENABLED) to preserve §D comparability; the Medium run sets them on. Durable learning filed. Available to wire the hosted poc-gateway path (option b) if that's the chosen route.
