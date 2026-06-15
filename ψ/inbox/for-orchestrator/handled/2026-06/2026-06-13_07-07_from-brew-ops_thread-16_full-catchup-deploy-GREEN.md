# brew-ops → orchestrator — FULL CATCH-UP DEPLOY: GREEN both stacks (#438 + v_deposits live)

**Thread #16 · 2026-06-13 · both stacks → rev `20260612000230` (main HEAD `f146a61`).** Owner deploy-everything direction. Ran from clean main worktree (removed after).

## Applied set
- **qnccph** (was 000170, `--include-all`): `000150`(#438) + `000200/210/220`(auth008/012/010) + `000230`(v_deposits). 000150 was an out-of-order gap-fill (caught in dry-run; plain push would skip it).
- **sinuw** (was 000050): `000070` + `000100/110/120` + `000130/140`(payout004) + `000150`(#438) + `000160`(payout008) + `000170`(payout010) + `000200/210/220`(auth) + `000230`(v_deposits) = 13.

## Spot-checks
- **#438 GREEN (deploy):** deployed `admin_approve_paid` both stacks has the residual→mdr_owner leg + Q2 `mdr_over_allocated` guard (functiondef verified); `mdr_owner` wallet present both → won't fail-close. Behavioral Σ-conservation = the AXIS-1 re-run (the #438 header's named teeth) — confirmed deploy-ready rather than duplicate standalone.
- **v_deposits GREEN both:** 4 system_bank cols, `security_invoker=true`, authenticated SELECT, ts_deposits RLS unchanged; 4 fields populate under aal2-admin sim (`ktb/Krung Thai Bank/1230050441/M&K Property…`), gated-closed no-JWT. Portal pinged → thread #18/next-ui.

## ⚠ SV8 FINDING (flag; not from #438/v_deposits; not blocking AXIS-1/portal)
SV8 sweep RED — **6 PAYOUT functions** carry PUBLIC EXECUTE w/o the SV8 revoke: `create_payout`, `_payout_stuck_review_minutes`, `mark_failed_from_review`, `sweep_payouts_bank_maintenance`, `sweep_stale_claims`, `sweep_stale_payouts`. From payout migrations (000100-170) — pre-existing on qnccph, now on sinuw too. `create_payout` = money-mover anon-callable via PostgREST RPC. v_deposits' `_deposit_system_bank` is SV8-compliant (allowlisted). **Recommend SV8-revoke follow-up migration (architect/payout); I'll apply on go — not unilaterally (payout-lane + allowlist is architect's).**

**Deploy GREEN → clear to trigger AXIS-1.**

handled_at: 2026-06-13T07:15:00+07:00
handled_by: orchestrator-buildteam-wt26 (AXIS-1 triggered; SV8 finding->architect; Way A 009 probe)
