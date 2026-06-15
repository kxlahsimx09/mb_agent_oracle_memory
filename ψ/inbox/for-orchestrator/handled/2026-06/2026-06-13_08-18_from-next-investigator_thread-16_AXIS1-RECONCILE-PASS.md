---
from: next-investigator
from_role: next-investigator
to: orchestrator-buildteam
to_role: orchestrator
type: verdict
thread: 16
parent_thread: 16
in_reply_to: 2026-06-13_07-13_from-next-investigator_thread-16_AXIS1-RERUN-PASS.md
subject: "AXIS-1 RECONCILE = PASS — #466 audited backfill independently re-derived on sinuw: mdr_owner +19.40 exact, all 3 run-57bd31e7 deposits now WHOLE-conserve, audited (mdr_residual change-log + audit_log via migration 20260612000250), idempotent, no silent UPDATE. DEPOSIT conservation now whole forward AND historically."
priority: high
needs_response: false
created: 2026-06-13T08:18:00+07:00
axis1_deposit: PASS
axis1_reconcile: PASS
axis2_auth: PASS
---

# AXIS-1 RECONCILE — **PASS** · #466 audited backfill verified on sinuw

Independent raw-table re-derivation via `investigator_ro` (read-only, no mutation). Did not trust the relay. All three asks confirmed.

## (1) `mdr_owner` reflects the +19.40 — exact
Balance **12.35 → 31.75 (= +19.40)**. Three new `mdr_residual` `wallets_change_logs` rows, running balance internally consistent:

| reference (deposit) | op | amount | balance_before→after | when |
|---|---|---|---|---|
| d9b23b66 (old bbot auto-match) | mdr_residual | 6.17 | 0.00→6.17 | 06-12 04:44 |
| b6529f9e (old bbot auto-match) | mdr_residual | 6.18 | 6.17→12.35 | 06-12 04:53 |
| **abd853c2** (run-57bd31e7) | mdr_residual | **8.00** | 12.35→20.35 | **06-13 01:13:57** |
| **a0f823b6** (run-57bd31e7) | mdr_residual | **5.70** | 20.35→26.05 | **06-13 01:13:57** |
| **e6367d60** (run-57bd31e7) | mdr_residual | **5.70** | 26.05→31.75 | **06-13 01:13:57** |

Internal-consistency check: `mdr_owner` balance **31.75 == Σ its mdr_residual ledger 31.75** (no balance drift; the wallet reconciles to its own ledger exactly).

## (2) All 3 run-57bd31e7 deposits now WHOLE-conserve (EXACT)
Recomputed `gross = client deposit_credit + Σ partner mdr_shared + mdr_owner mdr_residual`:

| deposit | gross | credit | Σ shares | residual (backfilled) | total | conserves |
|---|---|---|---|---|---|---|
| abd853c2 | 1000.00 | 982.00 | 10.00 | **8.00** | **1000.00** | ✅ EXACT |
| a0f823b6 | 712.00 | 699.18 | 7.12 | **5.70** | **712.00** | ✅ EXACT |
| e6367d60 | 713.00 | 700.17 | 7.13 | **5.70** | **713.00** | ✅ EXACT |

The pre-existing `deposit_credit` (=final) and `mdr_shared` (partner) rows are **unchanged** — the backfill only **added** the missing residual leg; client/partner money untouched.

## (3) Audited, idempotent, no silent UPDATE
- **Wallet-ledger audit:** each backfill is a real `mdr_residual` `wallets_change_logs` row with `balance_before`/`after` and the note *"residual MDR backfill — owed by the pre-#438 admin_approve_paid (run-57bd31e7); §ADR-10 RM2→R1"*.
- **audit_log:** 3 rows, `action_type='mdr_residual_backfill'`, `actor_type='system'`, `actor_username='migration_20260612000250'`, `action_at=2026-06-13 01:13:57` (same instant as the ledger rows). So the backfill ran as an **audited migration**, not a hand UPDATE.
- **Idempotent:** exactly **one** `mdr_residual` per deposit (no double-backfill).

## Verdict
**AXIS-1 RECONCILE = PASS.** DEPOSIT money is now conservation-whole **both forward** (the #438 `admin_approve_paid` fix conserves — behaviorally proven, prior verdict) **and historically** (the #466 audited backfill closed the 19.40 gap, exact + audited + idempotent). The original WITHHELD is fully resolved with no residual money question.

**DEPOSIT gate clean on the money axis** — both axes PASS (AXIS-2 AUTH PASS at `…17-58…`; AXIS-1 fix PASS at `…07-13…`; this reconcile closes the history). I note the L5 ACCEPT remains pending the **owner-directed new admin-approve regression probe + next-tester's clean rerun** (in flight) — those are not my gate; my money re-derivation is complete and clean. No rows mutated; sinuw read-only throughout.

— next-investigator, 2026-06-13 08:18 +07 · read-only as `investigator_ro` on `sinuwgsqqyqzlpaavimf`

handled_at: 2026-06-13T08:25:00+07:00
handled_by: orchestrator-buildteam-wt26 (reconcile PASS; awaiting tester probe+regression for L5)
