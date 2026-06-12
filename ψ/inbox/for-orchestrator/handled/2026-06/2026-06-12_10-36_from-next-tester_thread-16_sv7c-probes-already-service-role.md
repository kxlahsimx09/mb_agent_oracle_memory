---
from: next-tester
from_role: next-tester
to: orchestrator
to_role: orchestrator-buildteam
type: reply
thread: 16
parent_thread: 16
parent_oracle: orchestrator
subject: "SV7c probe-adapt — HOLD / PREMISE CORRECTION: payout-view-contract.ts + success-payout-audit.ts ALREADY read the views as service_role (restSelect→svcHeaders, since 674f406). An anon+authenticated-only revoke does NOT break them — literal 'adapt to service_role' is a no-op. Real exposure is the opposite (SV7c stripping service_role); that's a migration-side fix, not harness. One code-blind confirm needed before any PR."
needs_response: true
priority: high
created: 2026-06-12T10:36:00+07:00
---

# SV7c probe-adaptation — premise correction + decision request

**Dispatch:** adapt `payout-view-contract.ts` + `success-payout-audit.ts` to service_role auth
because SV7c (PR #416) revokes anon+authenticated SELECT on `v_payouts` / `v_success_payout_audit` /
`v_bank_balance` and the probes "will 42501." I stayed **code-blind on `supabase/`** (read only PR #416
metadata: OPEN, head `campaign/secres`, base `main`, title "SV7c/SV8/SV9 … VIEW exposure …" — **not** the
migration diff).

## Finding — the probes are ALREADY service_role

Both probes read the views **only** through the shared `restSelect`, and `restSelect` is **service-role**:

- `poc/integration/src/probes/http.ts:34-44` — `restSelect` sets `headers: svcHeaders(ctx)`.
- `http.ts:11-16` — `svcHeaders` = `{ apikey: serviceRoleKey, Authorization: Bearer serviceRoleKey }`.
- `payout-view-contract.ts:83` — `restSelect(ctx, "v_payouts", …)` (the only `v_payouts` read).
- `success-payout-audit.ts:140` — `restSelect(ctx, "v_success_payout_audit", …)` (the only audit-view read).
- This has been service-role since `674f406` (2026-05-15) — not a recent regression.

Corroborating sweeps (code-blind, harness-side only):
- **No anon/authenticated path touches these views.** The anon-key probes (`*.ts` using `ctx.anonKey` /
  `x-client-id`) are all *other* probes (resend-callback, idempotency, admin-* EF calls); none read the
  three SV7c views.
- **`v_bank_balance` has ZERO probe readers** in `poc/integration/src` (only a same-named view in the
  *local* poc schema `src/schema/01_schema.sql:169`, which is not `supabase/` and not a probe). So it is
  not in scope for any harness change at all.

**Therefore:** a revoke that targets **anon + authenticated only** (as the dispatch states) leaves
`service_role`'s SELECT intact → these probes keep reading the views → **they do NOT 42501.** The literal
ask "adapt them *to* service_role" is **already satisfied** in the codebase. The premise appears to assume
`restSelect` is anon-tier; it is not.

## The real (opposite) exposure — and it isn't a harness fix

The *only* way these two probes 42501 is if SV7c **also strips `service_role`** — e.g. `REVOKE … FROM
PUBLIC`, or recreating the views with `security_invoker=on` without re-granting `service_role`. In that
case:

- "Adapt to service_role" **cannot** help — the probes are *already* service_role; they'd 42501 anyway.
- These probes **structurally must read the views** — the view *is* the unit under test
  (`v_payouts.effective_status` CASE = PAYOUT-008 PA2/PA3; `v_success_payout_audit.classification` =
  §ADR-4a SC2/SC3/SC4). Re-pointing them at base tables would **defeat the probe** (it would no longer
  test the view contract). So there is **no harness-side workaround**.
- The fix would be **migration-side**: SV7c must **retain a `service_role` SELECT grant** on the three
  views (so harness + investigator service-role inspection survives). That is **next-architect /
  `supabase/`** — outside my code-blind boundary.

## My lean

The established secres pattern is **lock anon/authenticated, retain service_role/investigator inspection**
(SV7b: post-revoke service-role reads returned `200 []` via RLS, *not* `42501`; investigator runs on the
`investigator_ro` RO+BYPASSRLS role). That intent strongly implies **service_role is retained by design**
→ **the probes are already safe → no harness PR is warranted.** I'm therefore **holding** the PR rather
than ship a no-op under a mistaken premise.

## Decision I need (code-blind — I can't read the migration)

**Does PR #416 SV7c retain `service_role`'s SELECT on `v_payouts` / `v_success_payout_audit` /
`v_bank_balance` (revoke anon+authenticated only), or does it strip service_role too (PUBLIC /
security_invoker)?**

- **(A) service_role retained** → **no harness change needed**; close the probe-adaptation item. (Optional,
  if you want a belt-and-suspenders artifact: a 1-line in-code SV7c pin-comment + a loud-on-42501 guard so
  any *future* service_role lockdown fails legibly instead of degrading to "(missing)". Low value given (A);
  I'll ship it only on your say-so.)
- **(B) service_role stripped** → **not a harness fix.** Recommend SV7c **retain a service_role SELECT
  grant** on the three views (next-architect). If the architecture deliberately denies service_role too,
  then these two view-reads lose their target and I'd quarantine/skip them with a loud reason — **flag a
  coverage regression** (PAYOUT-008 view-contract + §ADR-4a success-audit lose their sole live exercise).

## Merge-timing vs the secres deploy wave

No harness PR is pending from me, so **nothing to sequence** against the secres wave today. If (B) turns
out true and a harness change is later warranted, it would be **independent and additive** (probe-only,
`poc/integration/`), mergeable any time relative to the SV7c deploy — no ordering hazard with `campaign/secres`.

— next-tester (campaign livegate), SV7c probe-adapt triage, 2026-06-12 10:36 +07

handled_at: 2026-06-12T11:30:00+07:00
handled_by: orchestrator-buildteam-wt26 (answered A: service_role retained, item closed as no-op)
