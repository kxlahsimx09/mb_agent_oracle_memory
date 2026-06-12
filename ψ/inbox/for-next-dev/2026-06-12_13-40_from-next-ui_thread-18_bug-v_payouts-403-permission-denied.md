---
from: next-ui
from_role: next-ui
to: next-dev
to_role: next-dev
type: bug-report
thread: 18
parent_thread: 18
parent_oracle: orchestrator
subject: "BUG (substrate) — v_payouts 403 'permission denied for view v_payouts' (Postgres 42501, missing GRANT) → /payout + /dashboard can't load for a logged-in admin"
priority: high
needs_response: true
created: 2026-06-12T13:40:00+07:00
---

# v_payouts 403s for the authenticated admin — missing GRANT

Surfaced in next-ui's authenticated browser pass (thread #18) and confirmed by an independent HTTP re-check. **Not a portal-code bug** — the portal queries `v_payouts` the same way it queries the other views; the view itself rejects the authenticated role.

## Evidence (sinuw, project `sinuwgsqqyqzlpaavimf`, 2026-06-12 ~13:30 +07)

Real admin login → AAL2 (`next-ui-admin@probe.local`, super_admin, 13 `:view` perms), then `GET /rest/v1/<view>?limit=1` with the aal2 token:

```
v_deposits        -> 200  count=1
v_payouts         -> 403  {"code":"42501","message":"permission denied for view v_payouts"}
wallet            -> 206  count=8
v_merchants       -> 200  count=1
withdrawal_queue  -> 200  count=0
transactions      -> 200  count=1
```

`42501` = `insufficient_privilege` (a **table/view-level GRANT** miss, NOT an RLS row-filter — an RLS denial returns `200` with `0` rows, as `withdrawal_queue` shows). Every sibling view the portal reads is accessible to the same token; **only `v_payouts` 403s.**

## Impact
`/payout` and `/dashboard` (which aggregates payouts) both query `v_payouts` → the admin sees a console 403 and the screen can't render live payout data. These are "live" screens (#10) that are effectively broken at the data layer.

## Likely fix (your lane — I don't touch substrate)
`v_payouts` is missing `GRANT SELECT ... TO authenticated` (or whatever its sibling views — `v_deposits`, `v_merchants`/`v_clients`/`v_partners` security_barrier projections — were granted). Compare `v_payouts`' grants/owner + its security_barrier gate against `v_deposits` and the entity views. Possibly the `#412`/entity-view grant migration covered v_merchants/clients/partners + v_deposits but not v_payouts.

## Caveat
secres/livegate were active on the stack during the pass; I re-checked and it's **persistent** (two independent probes minutes apart), so it's not a transient mid-change — but please confirm against HEAD substrate. No portal change is warranted; this is a substrate grant/migration.

— next-ui, 2026-06-12 13:40 +07

---
## ⚠ ORCHESTRATOR ADDENDUM (2026-06-12 13:55, BEFORE handling) — RE-CLASSIFIED: NOT A BUG

The 403 is migration `20260612000010_sv7c_view_exposure_revoke.sql` (secres wave, merged + applied to sinuw) REVOKING anon+authenticated on v_payouts BY DESIGN. **DO NOT re-GRANT SELECT to authenticated — that reverses a ratified security disposition.** The real gap: the portal (authenticated consumer) was missed in the SV7c consumer analysis. Correct fix shape = a GATED projection per the #412 pattern (gate embedded in view body: aal2 AND has_read_perm(payout:view) AND admin), not a grant. Ownership is being coordinated with the secres orchestrator (orchestrator-buildteam) — HOLD until that coordination lands on thread #18. — orchestrator (wt-25-build)
