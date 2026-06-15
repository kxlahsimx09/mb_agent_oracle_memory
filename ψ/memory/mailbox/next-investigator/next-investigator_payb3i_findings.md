# ✅ next-investigator — PAYOUT slice-3 (PAYOUT-008 + PAYOUT-010) Step-2 FALSIFICATION — **GREEN**

**Campaign:** payb3i · **Branch:** `campaign/payb3i` (wt-c-payb3i) · **Seal stack:** qnccph (`qnccphgykzdydebmdwdf`, `stack_role='test'`) · **Date:** 2026-06-13
**Under test:** PR #457 (dev/build `build/payout-slice3` @ `3899f10`) + PR #458 (tester probes `test/payb3-probes`)
**Tester claim falsified:** next-tester **39/39 GREEN** (yupsev) — `next-tester_payb3t_findings.md`
**SPEC (contract, read via git):** `origin/build/payout-slice3 : docs/spec/payout-cancel-sweeps-slice.md` v1 (2026-06-13)

---

## 0. Verdict

**GREEN — slice-3 falsification PASS.** I independently re-derived every PAYOUT-008 / PAYOUT-010 behaviour
and money invariant from the **deployed substrate ground truth on qnccph** (the real function bodies, not
the dev/tester code or findings), drove the **real deployed RPCs** with **my own fixtures + my own recomputed
expectations**, attacked every PASS, and reconciled.

- **27/27 independent re-derivations reconcile** with qnccph ground truth **+ 1 deliberate teeth-sentinel
  correctly RED** (proves the checks are non-vacuous), **0 unexpected failures**.
- Method: ONE `BEGIN…ROLLBACK`, virtual clock injected **both** ways (explicit `p_now` *and*
  `clock_set`/`clock_advance`), own banks/clients/pools/payouts, every PASS attacked.
- The tester's **39/39 (yupsev) is corroborated by independent re-derivation on a different stack (qnccph),
  not inherited** — I never read the tester's probe code; I drove the RPCs and recomputed from the schema.
- **Zero-footprint verified** after the run: flag ends **`false`**, knob `15`, clock `real`, all biz tables
  back to `0`, the 3 real banks pristine (NULL windows — I seeded my **own** banks), `net` queue `0`,
  migrations `000160/000170` + both crons intact.

Evidence harness: `/tmp/falsify_payb3i.sql` (one txn, self-contained, recomputes its own expectations).

---

## 1. Substrate ground truth (what I verified the tester *against* — read from `pg_get_functiondef`)

| Object | Deployed shape on qnccph — confirmed | Matches SPEC |
|---|---|---|
| migrations | `…000160` + `…000170` recorded; `…000150` absent (secres hole, brew-ops-noted, irrelevant to 008/010) | ✓ |
| `sweep_stale_payouts(int,timestamptz)` | single overload (old `(int)` **dropped**); `SECURITY DEFINER`; `service_role` EXECUTE; `v_now := COALESCE(p_now, app_now())`; **FIRST stmt** `IF NOT _payout_auto_cancel_enabled() THEN RETURN`; candidate `created_at + make_interval(mins => v_timeout) <= v_now` (at-or-past, **inclusive**); `ORDER BY created_at ASC LIMIT`; per-row `cancel_stale_payout(id)` (default code) in `BEGIN…EXCEPTION WHEN OTHERS CONTINUE` | ✓ |
| `sweep_payouts_bank_maintenance(int,timestamptz)` | NEW; `SECURITY DEFINER`; `service_role` EXECUTE; **NO flag check** (always-ON); `v_now_bkk := (COALESCE(p_now,app_now()) AT TIME ZONE 'Asia/Bangkok')::time`; predicate = `p.status='pending'` ∧ `EXISTS(wq q JOIN bank_account ba ON ba.id=q.required_bank_account_id WHERE q.source_id=p.id AND q.source_type='payout' AND q.status='pending' AND q.required_bank_account_id IS NOT NULL AND ba.is_active AND _bank_in_maintenance(...))`; cancel via `cancel_stale_payout(id,'bank_maintenance')` | ✓ |
| `cancel_stale_payout(uuid,text)` | LO1: `withdrawal_queue … FOR UPDATE` **first**; CAS `UPDATE ts_payouts SET status='cancelled', completed_at=now() WHERE id=… AND status='pending'`, else `race_lost`; AM2 `wallet.frozen -= amount+payout_fee` (balance untouched) keyed `owner_type='client' AND owner_id=client_id`; one `wallets_change_logs` `payout_unfreeze` (4-field snapshot); queue → `cancelled` (status NOT IN success/failed); **one** `callback_queue payout.cancelled` payload `{request_id, amount, failure_code=p_failure_code}` | ✓ (reused, unchanged) |
| `_bank_in_maintenance(time,time,time)` | NULL/zero-length ⇒ false; `start<end` ⇒ `now>=start AND now<end`; else (wrap) `now>=start OR now<end` | ✓ |
| `_payout_auto_cancel_enabled()` | `coalesce(lower(value)='true', false)` — fail-closed | ✓ |
| `_payout_pending_timeout_minutes()` | `coalesce(value::int, 15)` | ✓ |
| seeds / crons | `app_settings` flag `false`, knob `15`; crons `sweep-stale-payouts`→`sweep_stale_payouts(500)` and **new** `sweep-payouts-bank-maintenance`→`sweep_payouts_bank_maintenance(500)`, both `* * * * *` active | ✓ |
| table guards (independently confirmed) | `withdrawal_queue.two_mode_shape` CHECK = `(rba NOT NULL) OR (rba NULL AND pool_id NOT NULL)`; `wallet.wallet_balance_gte_frozen` CHECK enforces **AM5 at the table level** | — |

**Keying confirmed from the body, then proven empirically (FZ15):** the maintenance sweep keys on
`withdrawal_queue.required_bank_account_id`, **never** `ts_payouts.system_bank_id`.

---

## 2. Re-derivation ledger — 27 PASS + 1 sentinel RED (0 unexpected), one `BEGIN…ROLLBACK`

Each row recomputed its own expectation from the schema and **attacked** the PASS. Concrete observed values in `[]`.

### PAYOUT-008 (per-age, flag-gated)
- **FZ1 — flag-OFF structural no-op (ATTACKED 3 ways).** Ancient pending (age 10000 m ≫ knob), flag `false`; swept with `p_now=v_t0`, with `p_now=+1e6 min`, and with `batch=1` → **all empty**, payout `pending`, frozen held, 0 callbacks. `[rows=0; status=pending; frozen=527.25; callbacks=0]` — *the sweep cannot cancel anything with the flag off.*
- **FZ2 — flag-ON cancels the SAME-shaped fixture; full money invariant.** `[cancelled; completed_at set; qstatus=cancelled; code=auto_cancelled; callbacks=1; dedup=payout:<id>:payout.cancelled]`; money `[balance 100430.75→100430.75 UNTOUCHED; frozen 430.75→0.00; wcl=1; AM5 true]`; unfreeze log `[balance_before==balance_after; frozen Δ==gross; amount==gross]`; **conservation** `[only 1 wcl row for the wallet — no settle/fan-out]`; payload amount `[412.55 == payout.amount]`. The flag is the *only* difference vs FZ1.
- **FZ3 — knob boundary, INCLUSIVE.** age==knob(15m) **cancels** (`created_at+15m <= v_now`); age 14:59 **survives**; age 14m **survives**. `[at=cancelled; just=pending; young=pending]`.
- **FZ4 — cutoff TRACKS the knob (config, not constant).** age 20m: `knob=30 ⇒ survives`, then `knob=10 ⇒ cancels` (same fixture, only the knob moved). `[knob30=pending; knob10=cancelled]`.
- **FZ5 — virtual-clock-drivable via `clock_set`/`clock_advance` (p_now NULL → `app_now()`).** fresh-at-anchor survives; cancels only after `clock_advance(16m)` — no real wait. `[t0=pending; advanced=cancelled]`.
- **FZ6 — pending-only / never-auto-X.** ancient + flag ON: `processing/review/success/failed` **never swept**, no callback. `[proc/rev/succ/fail unchanged; cb=0]`.
- **FZ18a — idempotent re-tick.** re-sweep of the cancelled fixture = zero 2nd effect. `[in2nd=0; cb=1; unfreeze=1]`.

### PAYOUT-010 (per-bank maintenance, always-ON)
- **FZ7 — in-window cancels with the 008 flag OFF (always-ON proof).** `[cancelled; code=bank_maintenance; cb=1; frozen=0.00; AM5 true]` — *the flag does NOT gate 010.*
- **FZ8 — flag ON ⇒ code STILL `bank_maintenance`** (not `auto_cancelled`) — codes never crossed. `[code=bank_maintenance]`.
- **FZ9 — NOT-in-window survives, 3 shapes:** NULL window / outside-time (10–11 @ BKK12) / zero-length (09=09) all stay `pending`, 0 cb.
- **FZ10 — unrouted SKIP (§3.2).** `rba IS NULL (+pool)` Mode-1 payout **survives** while a window-open **routed sibling cancels on the same tick** (proves the sweep is live and the skip deliberate). `[routed=cancelled; unrouted=pending]`.
- **FZ11 — per-bank isolation.** A(in-window) cancels, B(no-window) survives, same tick. `[a=cancelled; b=pending]`.
- **FZ12 — inactive-bank SKIP.** `is_active=false` bank with an OPEN window ⇒ payout **survives** (the `ba.is_active=true` filter). `[pending; cb=0]`.
- **FZ13 — overnight wrap (20:00→08:00).** cancel @ BKK02 (inside), survive @ BKK12 (outside) — clock driven to **both sides of midnight BKK**. `[in=cancelled; out=pending]`.
- **FZ14 — window `[start,end)`.** cancel @ BKK==start (10:00 inclusive), survive @ BKK==end (11:00 exclusive). `[start=cancelled; end=pending]`.
- **FZ15 — KEY PROOF (two-way).** (a) queue→in-window bank but `ts_payouts.system_bank_id`→no-window bank ⇒ **CANCELS**; (b) queue→no-window bank but `system_bank_id`→in-window bank ⇒ **SURVIVES**. `[a=cancelled; b=pending]` — *keys on `withdrawal_queue.required_bank_account_id`, ignores `system_bank_id`.*
- **FZ16 — pending-only for 010 too.** a `processing` payout is skipped, **and** a `pending` payout whose **queue** row is `claimed` is skipped (predicate needs `p.status='pending' AND q.status='pending'`). `[proc=processing; qclaim=pending; cb=0]`.
- **FZ18b — idempotent re-tick (010).** already-cancelled fixture not re-selected. `[in2nd=0; cb=1; unfreeze=1]`.

### Shared bundle / cross-cutting
- **FZ19 — 3-code matrix never crossed.** 008 sweep ⇒ `auto_cancelled`, 010 sweep ⇒ `bank_maintenance`, direct `cancel_stale_payout(id,'admin_cancelled')` ⇒ `admin_cancelled` — **3 distinct, each once.**
- **FZ20 — cancel-vs-claim lock-first-wins** (deterministic ordering per SPEC §4.3). A just-claimed (`processing`) payout ⇒ `cancel_stale_payout` returns `race_lost`, **no unfreeze, no callback**, stays `processing`.
- **FZ21 — bundle idempotency.** 1st cancel `cancelled`, 2nd `race_lost`; exactly 1 callback & 1 unfreeze (CAS + the deterministic `dedup_key` UNIQUE both backstop it).
- **FZ22a/b — tester staging-RED reconfirmed from ground truth.** (a) nulling `required_bank_account_id` **without** a pool ⇒ `two_mode_shape` **check_violation fires** `[raised=true]`; (b) null `rba` **+ pool in one statement** succeeds ⇒ genuinely unrouted `[rba=NULL; pool set]`, which FZ10 shows the sweep SKIPs. *The tester's first-run RED was a fixture omission (no `pool_id`), exactly as they reported — the substrate is correct.*
- **FZ-SENTINEL (deliberate RED).** asserts a flag-OFF sweep *cancels* an ancient payout — it must not. Harness reported **FAIL** `[actual status=pending]`, proving the suite is non-vacuous.

> **AM5** (`balance ≥ frozen`) held after every unfreeze — and is additionally enforced by the
> `wallet_balance_gte_frozen` table CHECK (a violating unfreeze would have been rejected). **Conservation:**
> every cancel moved **zero balance** (frozen-release only; exactly one `payout_unfreeze` log; no settle, no
> fan-out rows).

---

## 3. Named — boundary/robustness observations (NOT blockers; consistent with prior routings)

1. **`ts_payouts_failure_code_check` does NOT list `'bank_maintenance'`** (it allows `auto_cancelled`,
   `admin_cancelled`, and the post-claim codes). This is **safe today**: the shared bundle writes the
   failure code **only** into `callback_queue.payload`, never onto `ts_payouts.failure_code`, so no
   constraint is touched. It is a **latent asymmetry** — any future change that tried to persist
   `failure_code='bank_maintenance'` on `ts_payouts` would be rejected. → note for the slice owner / next-architect.
2. **`cancel_stale_payout` stamps `completed_at = now()` (wall clock)** on the CAS + queue-cancel — a §ADR-20
   T1 residue, but it lives in the **slice-2 bundle (reused unchanged)** and is a timestamp, not a gating
   predicate. Not a slice-3 concern (already through the slice-2 seal); noted for completeness.
3. **DRIFT-V** (`v_payouts`/`v_payouts_read`/`v_deposits` `effective_status` wall-clock `now()`) — read-side
   view family, **out of slice**, already routed to next-architect by dev/tester. I did **not** probe it
   (per SPEC §0/§7). Production behaviour unaffected (`now()==app_now()` on the real clock).
4. **Genuine-concurrency `race_lost`** proven via deterministic ordering + CAS-branch confirm (a true
   2-session commit would break zero-footprint on the seal stack) — same accepted posture as slices 1/2.

---

## 4. Zero-footprint (verified post-rollback over the wire)

`payout_auto_cancel_enabled='false'` ✓ (the critical one) · `payout_pending_timeout_minutes='15'` ✓ ·
`sys_clock mode='real' speed=1` ✓ · `ts_payouts/withdrawal_queue/wallets_change_logs/callback_queue = 0` ✓ ·
no leaked FZ banks/clients/pools/wallets ✓ · the 3 real banks (scb/ktb/kbank) **active, windows NULL —
untouched** (I seeded my own `FZ*` banks, never the real ones) ✓ · `net.http_request_queue = 0` (the
dispatch/fair-router triggers' `net.http_post` rolled back transactionally — no external side effect) ✓ ·
migrations `000160`/`000170` present + both crons active ✓. **Nothing committed to qnccph.**

> The whole run is one connection / one transaction, so the flag/knob/window/clock writes are **all
> transactional** with the `ROLLBACK` (the GOAL's separate-connection hazard never applies); the explicit
> post-run re-verification above is belt-and-suspenders.

---

## 5. Out of scope (untouched, per GOAL)

Fixing / merging / marking / epic-seal (this is a **slice-level** falsification; the payout epic-seal awaits
all slices). sinuw / dev-1 / tester-stack / livegate / authfull. next-code-reviewer reviews **#457/#458** in
parallel (campaign payb3r).
