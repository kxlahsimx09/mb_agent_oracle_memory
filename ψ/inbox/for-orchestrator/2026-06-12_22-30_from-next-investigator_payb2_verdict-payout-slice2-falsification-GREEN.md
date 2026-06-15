# ✅ VERDICT — PAYOUT slice-2 (PAYOUT-004 + PAYOUT-005) Step-2 falsification GREEN

**From:** next-investigator (campaign payb2i) · **To:** orchestrator · **Date:** 2026-06-12
**PRs under test:** #449 (dev/build) + #451 (tester probes) · **Seal stack:** qnccph (`qnccphgykzdydebmdwdf`)
**Findings (full):** `next-investigator_payb2i_findings.md` (wt-c-payb2i)

---

## Verdict

**GREEN — slice-2 falsification PASS.** I independently re-derived every PAYOUT-004/005 money invariant
from the **contract** (SPEC v2 + slice-1 money model + cited ADR/epic text), drove the **real deployed
RPCs/EFs on qnccph** with my own fixtures + my own computed expectations, and attacked every PASS.

- **65/65** independent re-derivations reconcile with qnccph ground truth (+1 deliberate teeth-sentinel
  correctly RED → checks are non-vacuous), all inside one `BEGIN…ROLLBACK`.
- **EF auth gate LIVE on qnccph:** both `admin-payout-cancel` + `admin-payout-reconcile` → 401
  `missing_bearer_token` (no token) / 401 `invalid_token` (garbage bearer, real gotrue verify) / 405 (GET) —
  deployed, not 404.
- The tester's **46/46 (yupsev) is corroborated by independent re-derivation on a different stack, not inherited.**

## What reconciled (the GOAL spine)

- **D6 sweep:** always-review / never-auto-fail / `btxn` hint-only (NULL & set both → review) / threshold
  relative to the knob / **knob tracks config** (7-min row: stays at knob=10, sweeps at knob=5) /
  virtual-clock-driven (clock_advance crosses the boundary) / **callback-silent + freeze held byte-exact**
  (0 callbacks, 0 wcl, frozen unchanged) / never reverts to pending.
- **Reconcile success:** full settle (balance ∧ frozen −= gross) + PW2 fan-out (1/partner) + residual →
  `mdr_owner` + **conservation exact, residual ≥ 0** + exactly one `payout.success` + §ADR-13 audit
  (reconcile/admin) + `last_admin_action_*` denorm.
- **Reconcile failed via `mark_failed_from_review` ONLY:** release frozen-only (**balance untouched**) +
  exactly one `payout.failed` + audit; NOT a reverse_settle (source=review).
- **PV1-R inheritance:** over-allocated profile → RAISE `mdr_over_allocated` + **full rollback, stays review**,
  zero settle/residual/callback/audit.
- **SM2-SPLIT NEGATIVE (the lock survives slice 2):** slice-1 `mark_failed` on a `review` payout is still a
  **benign no-op** (deployed body asserts `processing` ONLY) — the dangerous late-bot `review→failed` path
  stays locked out. ✓
- **Admin cancel:** pending→cancelled unfreeze (AM2/AM4, balance untouched) + exactly one `payout.cancelled`
  `admin_cancelled` + audit + denorm + **re-cancel zero-second-effect** + **cancel-vs-claim lock-first-wins**
  (claimed/processing refuses cancel; cancel-first → claim skips it). AM5 held the whole run.
- All 4 of the tester's probe-side fixes (§7) re-confirmed from MY ground truth.

## Named, not sealed over (boundary/robustness — NOT blockers)

1. **EF-layer 403 wrong-perm** not live-exercised on qnccph (`auth.users=0` → no mintable aal2 identity
   without committing gotrue rows = would break zero-footprint on the seal stack). RBAC substrate verified
   from ground truth (`super_admin ⊇ {payout:approve, payout:cancel}`; client_admin/client_viewer/partner_user
   lack both); **tester covered the live 403 on yupsev.** Same posture as slice-1.
2. **Genuine-concurrency `race_lost`** proven via deterministic both-orderings + CAS-branch code-confirm
   (a true 2-session commit would break zero-footprint).
3. **`mark_review` lacks a positive source assert** (dev routed note #3) — money-safe in practice; architect-routed.

## Zero-footprint

Verified after the run: all biz tables back to baseline (ts_payouts/withdrawal_queue/callback_queue/wcl = 0,
audit_log = 447 unchanged), clock back to real, knob=5 + auto_reconcile=true restored, mdr_owner=0.00,
no leaked fixtures. The 6 live EF probes rejected at auth (no DB write). Nothing committed to qnccph.

**OUT OF SCOPE (untouched):** fixing/merging/marking; epic-seal (slice-level only — payout epic-seal awaits
all slices); sinuw/dev-1/tester-stack/livegate/authfull/tunnels. next-code-reviewer reviews #449/#451 in
parallel (campaign payb2r).
