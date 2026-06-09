# next-dev — dep34fix findings (C-1 / C-2 / verify_jwt follow-ups)

**PR:** [#324](https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/324) → `main` (**NOT merged**)
**Branch:** `dep34fix/c1-c2-verifyjwt-cleanups`
**Code commit:** `9b08f14`
**Scope:** owner-approved cleanups on the merged DEPOSIT-003/004 cluster (PRs #320/#321). None changes the 27/27 verified behavior — a re-verify must reproduce identically.

---

## What landed in the PR

### C-1 — drop dead `p_now` from `run_slip_verify`
`supabase/migrations/20260604000002_dep34_c1_drop_run_slip_verify_p_now.sql` (forward-only; landed mig …41 not edited).
- `run_slip_verify` collapses `(uuid, text, timestamptz)` → `(uuid, text)`. `p_now` was accepted but never threaded into `record_slip_verify_attempt` (stamps `attempted_at` via column `DEFAULT now()`). Owner: CUT, don't thread. Body does no time read.
- Sole in-DB caller `escalate_slip_deposit` recreated → calls `run_slip_verify(id, 'sweep_auto')`; KEEPS its own `p_now` for the CAS clock. Re-grants `service_role`.

### C-2 — sweep error observability
`supabase/migrations/20260604000003_dep34_c2_sweep_error_observability.sql` (forward-only; …40/…41 not edited).
- DROP+CREATE `sweep_expired_deposits` + `sweep_slip_escalation`. Each per-row `EXCEPTION WHEN OTHERS` now `RAISE WARNING`s (sweep name + deposit id + `SQLERRM`) BEFORE `CONTINUE`. Resilience preserved (still continues). Privilege surface unchanged (only re-applies the explicit `service_role` grant `sweep_slip_escalation` had in mig …41; `sweep_expired_deposits` keeps PUBLIC default — no grant added).

### verify_jwt
`supabase/config.toml` — added `[functions.deposits-upload-slip] verify_jwt = false` (aligned with `deposits-create`). SPEC §D-1 already documents OFF (lines 49/64/323) → confirmed matching, NOT changed.

---

## ⚠ Test-harness follow-up for next-tester (OUT-OF-SCOPE here)
C-1 changes the RPC arg list. `tests/integration/probes/d34/_flow34.ts:72` calls `run_slip_verify` via PostgREST with a named `p_now: null` arg → after the migration that arg no longer resolves (PGRST202). **next-tester must remove `p_now: null` from that helper call** (and update the `_spec34.ts:41` signature comment) before/at re-verify. Assertion logic unchanged. I did not touch `tests/` per scope.

---

## Deploy artifacts (brew-ops — SUPABASE_ACCESS_TOKEN provisioned + verified working)

1. **`brew-ops db-push` → BOTH `tester` + `seal`** of:
   - `supabase/migrations/20260604000002_dep34_c1_drop_run_slip_verify_p_now.sql`
   - `supabase/migrations/20260604000003_dep34_c2_sweep_error_observability.sql`
2. **`brew-ops functions deploy` of `deposits-upload-slip`** — applies the config.toml `verify_jwt = false` gate.

Cross-stack deploy is brew-ops per the updated workflow; I did not deploy. next-tester re-verifies the 27/27 after deploy.

## Why non-behavior-change (27/27 reproduces)
- C-1 removes an unused param (recorder stamps `attempted_at` identically).
- C-2 only logs on an error path the happy path never enters.
- verify_jwt-off relaxes an auth requirement the tester already satisfies (sends both headers).
