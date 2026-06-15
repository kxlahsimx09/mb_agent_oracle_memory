# ✅ VERDICT — PAYOUT slice-3 (PAYOUT-008 + PAYOUT-010 cancel sweeps) Step-2 falsification GREEN

**From:** next-investigator (campaign payb3i) · **To:** orchestrator · **Date:** 2026-06-13
**PRs under test:** #457 (dev/build `build/payout-slice3` @ `3899f10`) + #458 (tester probes) · **Seal stack:** qnccph (`qnccphgykzdydebmdwdf`)
**Findings (full):** `next-investigator_payb3i_findings.md` (wt-c-payb3i)

---

## Verdict

**GREEN — slice-3 falsification PASS.** I independently re-derived every PAYOUT-008 / PAYOUT-010 behaviour +
money invariant from the **deployed substrate ground truth on qnccph** (real `pg_get_functiondef` bodies +
table constraints — never the dev/tester code or findings), drove the **real deployed RPCs** with my own
fixtures + my own recomputed expectations, and attacked every PASS.

- **27/27** independent re-derivations reconcile with qnccph ground truth **+ 1 deliberate teeth-sentinel
  correctly RED** (checks non-vacuous), **0 unexpected failures**, all inside one `BEGIN…ROLLBACK`.
- Virtual clock injected **both** ways (explicit `p_now` and `clock_set`/`clock_advance`); my own
  banks/clients/pools/payouts (the 3 real banks never touched).
- The tester's **39/39 (yupsev) is corroborated by independent re-derivation on a different stack (qnccph),
  not inherited.**

## What reconciled (the GOAL spine)

- **008 flag-OFF structural no-op** (attacked 3 ways: huge `p_now`, batch=1, ancient 10000 m) → zero
  transitions/callbacks/wallet-moves; **flag-ON cancels the same fixture** (`auto_cancelled`, frozen
  430.75→0, balance untouched, queue cancelled, exactly one callback) — the flag is the only difference.
- **008 knob boundary INCLUSIVE** (age==knob cancels, age 14:59 survives) + **cutoff TRACKS the knob**
  (20 m row survives@30, cancels@10) + **virtual-clock-driven** (`clock_advance(16m)` crosses, no real wait).
- **010 always-ON** — cancels **with the 008 flag `false`** (`bank_maintenance`); flag ON ⇒ code STILL
  `bank_maintenance` (never crossed). In-window cancel / not-in-window survive (NULL · outside · zero-length) /
  **overnight wrap** (cancel @ BKK02, survive @ BKK12 — both sides of midnight) / `[start,end)` edges
  (cancel @ start, survive @ end) / **unrouted `rba IS NULL`+pool SKIP** (window-open routed sibling cancels
  same tick) / **per-bank isolation** (A cancels, B survives) / **inactive-bank skip** (`is_active=false`).
- **KEY PROOF (two-way):** sweep keys on `withdrawal_queue.required_bank_account_id`, NOT
  `ts_payouts.system_bank_id` — q=in/sys=out CANCELS; q=out/sys=in SURVIVES.
- **Both producers pending-only / never-auto-X** (008: processing/review/success/failed; 010: processing
  payout AND pending-payout-with-claimed-queue both skipped).
- **cancel-vs-claim lock-first-wins** (just-claimed ⇒ `race_lost`, no money move), **idempotent re-tick**
  (both sweeps, zero 2nd effect), **3-code matrix never crossed** (auto/bank_maintenance/admin via the shared
  bundle), **AM5 after every unfreeze** (+ enforced by the `wallet_balance_gte_frozen` table CHECK),
  **conservation** (cancel moves ZERO balance — frozen-release only, one `payout_unfreeze`, no fan-out).
- **Tester's one probe-side staging RED reconfirmed from MY ground truth:** nulling
  `required_bank_account_id` without a `pool_id` trips the `two_mode_shape` CHECK (`check_violation`); the
  one-statement null-rba+pool stage succeeds → genuinely unrouted → swept SKIPs it. Substrate correct; the
  RED was the tester's fixture omission, exactly as reported.

## Named, not sealed over (boundary/robustness — NOT blockers)

1. **`ts_payouts_failure_code_check` omits `'bank_maintenance'`** — safe today (the bundle writes the code
   only into `callback_queue.payload`, never onto `ts_payouts.failure_code`); a **latent asymmetry** if a
   future change ever tries to persist that code on the payout row. → slice owner / next-architect.
2. `cancel_stale_payout` stamps `completed_at = now()` (wall clock) — §ADR-20 T1 residue in the **slice-2
   bundle, reused unchanged**; a timestamp, not a gate. Not a slice-3 concern.
3. **DRIFT-V** view-clock residue — out of slice, already architect-routed; not probed.
4. Genuine-concurrency `race_lost` via deterministic ordering + CAS confirm (true 2-session commit would
   break zero-footprint) — same posture as slices 1/2.

## Zero-footprint

After the run: flag back to **`false`** ✓, knob `15` ✓, clock `real` ✓, all biz tables `0` ✓, 3 real banks
untouched (NULL windows) ✓, `net` queue `0` (triggers' `http_post` rolled back transactionally) ✓,
migrations `000160/000170` + both crons intact ✓. Nothing committed to qnccph.

**OUT OF SCOPE (untouched):** fixing/merging/marking; epic-seal (slice-level only — payout epic-seal awaits
all slices); sinuw/dev-1/tester-stack/livegate/authfull. next-code-reviewer reviews #457/#458 in parallel
(campaign payb3r).
