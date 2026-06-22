---
from: orchestrator (campaign o-business-gap-2)
to: [next-live-tester]
date: 2026-06-22T (GMT+7)
topic: LIVE test-cases to author for GW-SCH-02 (system-wide maintenance lockdown sweep) — addendum to the 3-fix handoff
status: code merged (ADR #709 + build #711); NOT deployed anywhere — author now, run after a staging deploy (owner-gated)
tags: [#repo:mb-next-payment-gateway, #live-tester, #o-business-gap-2, #gw-sch-02, #maintenance, #sweep, #test-authoring, #handoff]
---

# Handoff → next-live-tester: GW-SCH-02 system-wide maintenance lockdown sweep — test-cases

**Companion to** `ψ/inbox/handoff/2026-06-21_21-59_livetest-cases-o-business-gap-2-gwrec01-botd02-gwx02.md` (GW-X-02 / GW-REC-01 / BOT-D-02). This adds the 4th fix: GW-SCH-02.
**Deploy status:** code merged, **NOT deployed** (no staging, no prod). Author now; run after a staging deploy lands (owner-gated). Same owner constraint as the rest: bankbot↔portal contract (incl. mock) == current — this fix is gateway-side only, doesn't touch it.

## What it does
**Source:** §ADR-4a §Amendment 2026-06-21 "System-Wide Maintenance-Window Lockdown Sweep" (SW1–SW9); spec `docs/spec/system-wide-maintenance-sweep-slice.md` (AC-1..10); build PR #711 (`82e12f4`, migration `20260624000100`).
A pg_cron tick (~1m) that, **only while the global `app_settings.maintenance_window` is active** (HH:MM-HH:MM Bangkok, evaluated on the `app_now()` virtual clock), atomically cleans up ALREADY-pending items: cancel ALL pending payouts→refund + expire ALL pending deposits. It's the SYSTEM-WIDE sibling of the per-bank sweep (PA7), and complements the deposit front-door 503 gate (which blocks NEW). Ported from current `scheduler/maintenance_cancel.go`.

## Journey to author (end-to-end)
Operator declares a system-wide maintenance window → the platform **drains atomically** (every pending payout refunded, every pending deposit expired) → during the window NEW deposits are refused (503) → after the window the system resumes clean. Prove the operator regains the "atomic global lockdown" current had.

## Concrete cases (from SW1–SW9 / AC)
- **Payout leg — cancel ALL pending → refund (SW3):** with the window active, EVERY `pending` payout is cancelled with failure code **`system_maintenance`**, the wallet is unfrozen (`frozen -= amount+fee`, balance untouched), and exactly **one** `payout.cancelled` callback fires per item. **Include an UNROUTED / pool-pending payout** (`required_bank_account_id IS NULL`) — it MUST be cancelled here (the key contrast with PA7, which skips unrouted).
- **Deposit leg — expire ALL pending (SW4):** with the window active, EVERY `pending` deposit is expired (one `deposit.expired` callback), **including a slip-bearing pending deposit** — and **no wallet move / no refund** (pending = pre-credit). Confirm a slip-bearing pending deposit IS expired (the build made the slip-guard bypassable for exactly this).
- **Window INACTIVE ⇒ total no-op:** outside the window, nothing is cancelled/expired — pending payouts & deposits sit untouched.
- **Pending-only / never-auto-X:** a `claimed`/`processing`/`review`/terminal payout and a non-`pending` deposit are NEVER touched, even with the window active.
- **Idempotent / re-run safe:** run the tick twice over the same data → no double-cancel, no double-refund, no duplicate callback (per-item CAS → `race_lost` skip).
- **Independence + orthogonality:** the per-bank PA7 sweep still runs every tick regardless of the global window; the deposit front-door **D1-11 503 `DEPOSIT_MAINTENANCE`** gate still blocks NEW deposit creation during maintenance — both UNCHANGED.
- **Money-safety:** LO1 lock order (`withdrawal_queue → ts_payouts → wallet`) preserved; AM5 (`balance ≥ frozen`) holds after unfreeze; each item is one all-or-nothing transaction (no cancelled-payout-with-funds-still-frozen).
- **Clock:** drive the window boundary with `clock_set`/`clock_advance` (`app_now()`), not real wall-clock — the gate is test-drivable.

## Config note (OQ-1, resolved)
The trigger is the **port-faithful scheduled global `maintenance_window`** (owner-resolved 2026-06-21 → option a; no manual master-switch, no converge onto `deposit_maintenance`). Set/clear it via `app_settings.maintenance_window = "HH:MM-HH:MM"` for the test.

## Evidence pointers
ADR §Amendment 2026-06-21 (SW1–SW9) in `docs/adr.md`; spec `docs/spec/system-wide-maintenance-sweep-slice.md`; build PR #711 (`migration 20260624000100`, 50/50 pgTAP `gwsch02_system_maintenance_sweep_test.sql`); parity `GW-SCH-02`. Ground truth (current): `scheduler/maintenance_cancel.go` `process()`:88-103 / `cancelPendingPayouts`:178 / `expirePendingDeposits`:302.
