# next-code-reviewer — PAYOUT slice 3 review (campaign payb3r)

**Date:** 2026-06-13 · **Reviewer slot:** next-code-reviewer (wt-c-payb3r, branch `campaign/payb3r`)
**Scope:** Step-3 three-dimension review (requirement / clean-code / perf) of the two slice-3 PRs.
**House rules honored:** DO NOT MERGE (reviewed only); verdicts routed to the orchestrator; self-merge
happens only after this APPROVE **and** the investigator's GREEN seal (falsifying in parallel).

| PR | Title | Verdict |
|----|-------|---------|
| **#457** | build(payout-slice3): PAYOUT-008 + PAYOUT-010 pending→cancelled cancel sweeps | **✅ APPROVE** (2 LOW non-blocking clean-code nits) |
| **#458** | test(payb3t): PAYOUT slice-3 cancel-sweep probes | **✅ APPROVE** |

Both verdicts are posted as COMMENTED reviews on the PRs (verdict in the body header).

---

## Substrate verified (the reuse claims are real — not taken on trust)

Read the LATEST deployed bodies of every "reused, not forked" dependency and confirmed each claim:

- **`cancel_stale_payout(p_payout_id uuid, p_failure_code text DEFAULT 'auto_cancelled')`** — migration
  `…000005` (slice 2), on main. LO1 lock order is exactly `withdrawal_queue` (FOR UPDATE, ordered by id)
  → `ts_payouts` CAS `WHERE status='pending'` (else `race_lost`) → `wallet` FOR UPDATE; AM2 unfreeze
  (`frozen -= amount+fee`, balance untouched) + one `payout_unfreeze` WCL; queue cancel
  (`status NOT IN ('success','failed')`); one `callback_queue` `payout.cancelled` with `failure_code` in
  the payload. **arg2 is the failure code, default `auto_cancelled`.** ✓ Both slice-3 producers ride this
  verbatim — no fork.
- **`_bank_in_maintenance(p_start time, p_end time, p_now time)`** — migration `…000010`, generic (not
  deposit-specific). NULL/zero-length ⇒ false; `start<end` ⇒ `[start,end)` (start-inclusive,
  end-exclusive); `start>end` ⇒ overnight wrap (`now>=start OR now<end`). ✓ Reused verbatim by 010.
- **Old `sweep_stale_payouts(int DEFAULT 100)`** — migration `…000003`. Confirmed it read **wall-clock
  `now()`** on the age predicate, had **no `p_now`**, and **no `service_role` grant** (the D8 drift 160
  closes). ✓
- **`_payout_auto_cancel_enabled()`** (fail-closed: missing/non-`'true'` ⇒ false) and
  **`_payout_pending_timeout_minutes()`** (fail-safe default 15) — `…000003`. Seeds
  `payout_auto_cancel_enabled='false'`, `payout_pending_timeout_minutes='15'`. ✓ Untouched by this slice.
- **Schema:** `bank_account.maintenance_window_start/_end` (`time`, nullable) present; `withdrawal_queue`
  has `source_id`, `source_type`, `required_bank_account_id`, `status`, `pool_id`. ✓
- **SV precedent:** the sibling sweep `sweep_stale_claims(int,timestamptz)` already carries
  `GRANT EXECUTE … TO service_role` on main (`…000140`, commit 9a9fcfc, reg-cert reg28 GREEN). The two new
  slice-3 sweeps follow that **already-SV-cleared** grant pattern → **no over-grant / SV8 concern.**

---

## PR #457 — migrations (RPC-only, no EFs) — **APPROVE**

### Requirement dimension — all GOAL checks pass

**Migration `…000160` — `sweep_stale_payouts` rewrite (closes D8):**
- ✅ **PA1 flag-gate preserved** as the first procedural statement (`IF NOT _payout_auto_cancel_enabled()
  THEN RETURN`). Flag OFF (shipped default) or unreadable ⇒ structural no-op, no `cancel_stale_payout`
  call regardless of payout age. Money-safety fail-closed intact (see clean-code nit #2 for a precision
  caveat on the DECLARE-order).
- ✅ **`COALESCE(p_now, app_now())` clock** (§ADR-20 T1/T4); **no wall-clock `now()` on the predicate.**
  Predicate `created_at + make_interval(mins => v_timeout) <= v_now` (inclusive `<=` = "age at or past",
  matches SPEC §2.1). `make_interval` replaces the old `(v_timeout||' minutes')::interval` text-cast — a
  clean improvement.
- ✅ Knob read via `_payout_pending_timeout_minutes()`; pending-only predicate `status='pending'`,
  `ORDER BY created_at ASC LIMIT p_batch_size`.
- ✅ Per-row delegation `cancel_stale_payout(v_row.id)` → default `auto_cancelled`; **no bundle fork.**
  Per-row `BEGIN…EXCEPTION WHEN OTHERS THEN CONTINUE` isolates a row failure from the tick.
- ✅ **Old `(int)` overload DROPPED** (`DROP FUNCTION IF EXISTS sweep_stale_payouts(int)`) — necessary:
  with both overloads present the single-int cron call `sweep_stale_payouts(500)` would be ambiguous
  ("function is not unique"). New `(int, timestamptz)` is the single canonical def.
- ✅ **Cron re-point idempotent** — guarded by `pg_extension` existence, `unschedule` only `IF EXISTS`,
  re-`schedule` to `sweep_stale_payouts(500)` (now unambiguous). Cadence unchanged `* * * * *`.
- ✅ `SECURITY DEFINER` + `GRANT EXECUTE … TO service_role` (probe-callable; matches the SV-cleared
  `sweep_stale_claims` pattern).

**Migration `…000170` — `sweep_payouts_bank_maintenance` NEW (closes D10):**
- ✅ **Always-ON — verified NO `_payout_auto_cancel_enabled()` (or any flag) reference anywhere in the
  body.** It is the unconditional fund-safety backstop.
- ✅ Candidate predicate matches SPEC §3.1 **exactly**: `p.status='pending'` AND EXISTS a
  `withdrawal_queue q` with `q.source_id=p.id AND q.source_type='payout' AND q.status='pending' AND
  q.required_bank_account_id IS NOT NULL`, joined `bank_account ba ON ba.id=q.required_bank_account_id`
  with `ba.is_active=true` AND `_bank_in_maintenance(ba.maintenance_window_start,
  ba.maintenance_window_end, v_now_bkk)`. Keys on the **assigned bank**
  (`withdrawal_queue.required_bank_account_id`), **not** `ts_payouts.system_bank_id`. ✓
- ✅ **Unrouted SKIP** enforced by `required_bank_account_id IS NOT NULL` (also implied by the inner JOIN,
  but kept explicit so probes bind the §3.2 boundary — good, not redundant noise).
- ✅ **`_bank_in_maintenance` reused verbatim** (no second predicate); wrap/NULL/zero-length semantics
  delegate to the predicate.
- ✅ BKK conversion `(… AT TIME ZONE 'Asia/Bangkok')::time` — the same derivation the deposit create-path
  uses; computed once per tick (frozen instant for the whole batch — correct).
- ✅ Passes **`'bank_maintenance'` explicitly** to `cancel_stale_payout` — distinct code, never crossed.
- ✅ Batch bound `LIMIT p_batch_size` (default 500), `ORDER BY p.created_at ASC`; per-row exception
  isolation; `SECURITY DEFINER` + service_role grant; idempotent cron registration.

**LO1 / CAS race posture (GOAL focus 3):** ✅ Neither sweep locks candidate rows itself — both use a
**plain `SELECT`** to pick candidate ids; all `FOR UPDATE` locking is deferred to `cancel_stale_payout`'s
canonical `queue → payout → wallet` order, per row. The sweeps therefore **cannot invert LO1**. A
candidate claimed/cancelled between select and per-row cancel is handled by the bundle CAS (`race_lost`),
no second money move. Adversarially checked: multi-queue-row payouts, mid-tick claims, cursor-vs-modify —
all benign.

**Migration safety (GOAL focus 4):** ✅ Forward-only, idempotent — `DROP … IF EXISTS`, `CREATE OR
REPLACE`, idempotent `GRANT`, `pg_cron`-guarded `DO` blocks that unschedule-if-exists then schedule.

**No sealed-lane/deposit/_shared/EF files (GOAL focus 5):** ✅ #457 touches only `SPEC-BROADCAST.md`
(pointer bump), the new spec, dev findings, and the 2 migrations. No `supabase/functions/*`, no
`_shared/*`, no deposit/auth migrations.

### Clean-code dimension — 2 LOW, non-blocking

1. **[LOW] `…000170` — dead `v_now` variable + a redundant clock read.** `v_now timestamptz :=
   COALESCE(p_now, app_now())` is declared and initialized but **never referenced** in the body (the
   maintenance sweep has no age predicate; only `v_now_bkk` is used). Separately, `v_now_bkk` recomputes
   `COALESCE(p_now, app_now())` from scratch. One line fixes both:
   `v_now_bkk time := (v_now AT TIME ZONE 'Asia/Bangkok')::time;` — reuses `v_now` (so it's no longer
   dead) and drops the duplicate `app_now()` evaluation. Cosmetic — `app_now()` is a cheap STABLE read.
2. **[LOW] `…000160` — knob/clock reads in DECLARE precede the PA1 gate.** The header states "the FIRST
   statement is the flag gate." That's true for the procedural BEGIN body, but `v_now :=
   COALESCE(p_now, app_now())` and `v_timeout := _payout_pending_timeout_minutes()` evaluate in the
   DECLARE section *before* the gate. The pre-160 body read the knob **after** the gate, so a flag-OFF
   tick was a pure no-op with zero settings reads. **Money-safety fail-closed is intact** (no cancel runs
   unless the flag is `true`; both reads are side-effect-free), but a corrupt non-integer
   `payout_pending_timeout_minutes` would now RAISE during DECLARE even with the flag OFF (the cron tick
   errors; no money moves) where the old order no-op'd cleanly. If the strict "structural no-op even if
   everything else is broken" reading is wanted, move both initializers below the gate. Not a defect.

### Perf dimension — clean

Both sweeps are batch-bounded (`LIMIT 500`) and `ORDER BY created_at ASC`. The maintenance candidate is a
correlated `EXISTS` over `withdrawal_queue ⋈ bank_account` — relies on the existing
`withdrawal_queue(source_id, source_type, status)` and `ts_payouts(status, created_at)` access paths; no
N+1 beyond the intended per-row cancel delegation. No lock is held across the candidate scan (locks taken
per-row inside the bundle) → minimal contention. The redundant double `app_now()` (nit #1) is negligible.

---

## PR #458 — test probe suite (`_cs` modules + `run-payout-cs.ts`) — **APPROVE**

### Requirement — SPEC-not-impl binding, faithful

- ✅ Every `_cs` module binds to `_spec-cs.ts` constants derived from the broadcast SPEC; **RPC param
  names match §5.7 exactly** (`p_batch_size`, `p_now`, `p_payout_id`, `p_failure_code`, `p_start/p_end/
  p_now`). `SPEC_CS_UNBOUND=false`; the only defensive bindings (window-column spelling, callback
  source-linkage) are surfaced in `SPEC_CS_PENDING_BINDINGS`, read defensively, never silently invented.
- ✅ De-bias maintained: no `supabase/` source import anywhere; assertions read ground-truth tables +
  RPC responses only.
- ✅ Pure predicates in `_assert-cs.ts` mirror the substrate: `agePastTimeout` uses inclusive `<=`
  (matches the migration's `<=`); `bankInMaintenance` reproduces NULL/zero/`[start,end)`/wrap exactly;
  `autoCancelTarget`/`maintenanceCancelTarget` encode flag-OFF no-op, pending-only, unrouted-SKIP.
- ✅ Probe→AC bijection via the `C.quote.*` detail tails (each assertion cites its SPEC clause).

### Clean-code / additivity / hygiene

- ✅ **Additive `_cs` siblings only.** The sole mutations to existing files are the **named**
  `payout-selfcheck.ts` extension (+112, a self-contained block, **each load-bearing predicate proven RED
  by a deliberate violation** — flag-OFF-still-cancels, wrong-code-cross, unrouted-cancelled,
  claimed-swept, window NULL/zero/wrap/boundary, dup-callback re-sweep) and `docs/test-index.md` (+31,
  additive). No slice-1/2 logic touched.
- ✅ **Fixture restoration in `finally` across every probe**: cleanup all staged payouts, restore
  `priorFlag` (captured pre-run), restore `priorKnob` (p008), clear bank windows (p010/cs-bundle/am5),
  `clockReset`. **Flag ends `false`** — each body's last flag write is `'false'`, and the restore targets
  the prior value (which is `'false'` on the seeded stack); defensive even if the flag row was absent.
- ✅ **Fail-loud, never a false pass.** `readiness-cs` (Lane-0) on a bare stack ⇒ `deployed=false` ⇒
  money lanes report `BLOCKED-ON-DEPLOY`, are never run, never counted green; runner exits non-zero on
  blocked/unbound/any-fail. The two fixture-dependent legs (M010-d unrouted needs a pool; M010-e
  isolation needs ≥2 active banks) emit `ok(…, false, "BLOCKED: …")` → recorded as a failure → lane RED,
  surfaced as a fixture stack-need rather than faked.
- ✅ **No secrets.** Service-role key + GW4 signing key come from `process.env`; nothing hardcoded
  (scan clean). The committed evidence JSON carries only the public stack URL
  (`yupsevcrubgprsbujbpu.supabase.co`) + assertion records — **no key material.**
- ✅ Evidence JSON well-formed: GREEN 39/39, all six lanes GREEN, `summary {total:39, passed:39,
  failed:0}` on the yupsev tester stack. All sibling imports resolve (`probes/_context.ts`,
  `_spec-payout`, `_spec-rc`, `_assert-payout`, `_assert-rc`, `_flow-payout`, `_flow-rc`,
  `_stage-payout`). No committed binaries (all diffs text).

### Perf — N/A (tests)

Push-button, zero-footprint (per-leg `cleanupPayout` + `reset_for_test` + clock reset); p010 cleans each
leg before the next to prevent batch cross-talk. Good hygiene.

---

## Boundary notes (not gate items)

- The money-correctness GREEN seal is the **investigator's** job (re-deriving invariants from
  ground-truth, falsifying in parallel). This review is the three-dimension **code** gate only.
- DRIFT-V (the `v_payouts`/`v_payouts_read`/`v_deposits` `effective_status` 0-lag view-clock `now()`
  residue) is correctly **routed to next-architect**, NOT patched in this producer slice — agreed: it's a
  coherent cross-cutting view-clock change, not a partial fix here. Production behavior is unaffected
  (real-clock `now()==app_now()`); only virtual-clock test coherence of the 0-lag ACs.
- `cancel_stale_payout` sets `completed_at = now()` (wall-clock) inside the reused bundle — an inherited
  slice-2 behavior, out of this slice and not introduced here; same §ADR-20 family as DRIFT-V.

## Disposition

Both PRs **APPROVE**. The two #457 nits are LOW / non-blocking (no correctness or money-safety impact)
and can be folded opportunistically or carried as routed cleanups — they do not gate merge. Per house
rules: **not merged**; verdict routed to the orchestrator; self-merge awaits this APPROVE **+** investigator
GREEN.
