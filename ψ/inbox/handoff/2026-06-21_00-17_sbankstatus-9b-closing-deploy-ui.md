**TO:** [brew-ops, next-ui]
**FROM:** next-pm
**CAMPAIGN:** sbankstatus (orchestrator #51 — `/system-bank` LIST effective status)
**DATE:** 2026-06-22

# sbankstatus #9b — CLOSING HANDOFF (backend BUILD-COMPLETE & merged; two downstream remain)

## The gap
The `/system-bank` LIST grid projected only RAW `availability`, so a bank under operator
**halt-pool** or **maintenance-override** still rendered "online / ready" in the grid while the
DETAIL popup (which derives the override-aware status via `v_system_bank_detail.working_label`)
correctly showed `maintenance`. Grid and detail genuinely disagreed for the same bank.

## Verdict (PM triage)
**(b) REAL GAP** — backend fix required, minimal & additive. A verbatim copy of already-ratified
detail-view CASE logic into the sibling list view. **No new ADR** (additive within §ADR-29 + §ADR-35;
gate unchanged at `system-bank:view`; base tables stay SV7b zero-grant; only derived leak-safe labels
crossed to `:view`, never the raw withheld timestamps).

## What shipped (DONE)
- **Requirement #9b authored** — `docs/adr/ADR-29-phase-B-detail-projection.md` amendment
  "2026-06-22 — #9b List-view effective (override-aware) status".
- **View extension BUILT & MERGED** — PR **#715** squash-merged to `main` as **fa16f2a5**.
  - NEW migration `supabase/migrations/20260624000200_sysbank_list_effective_status.sql`:
    `CREATE OR REPLACE VIEW public.v_system_banks` reproducing the live 000600 definition
    byte-identical and **APPENDING two columns LAST** (after `daily_out_amount`, before `FROM`),
    42P16-safe (replace-on-existing proven on scratch PG16):
    - `working_label` — VERBATIM copy of `v_system_bank_detail` CASE (override/halt→maintenance;
      offline/error passthrough; online→`last_health->>'working_task'` fallback `ready`; else unknown).
    - `effective_availability` — override-aware value for the online/offline dot (override/halt→
      maintenance, else raw `availability`). Raw `availability` column KEPT (back-compat).
  - pgTAP `supabase/tests/v_system_banks_read_surface_test.sql` extended plan **30→40**
    (+has_column x2, +raw-availability-kept, +leak-safety count=0, +6 behavioral).
  - Reviewer (next-code-reviewer): **APPROVE**, 0 blocking. 42P16 safety hard-verified by diff;
    leak-safety, gate/posture, migration uniqueness all PASS.
- **#9b status flipped** off stale S2 → **BUILD-COMPLETE / merged @ fa16f2a5** via docs PR **#716**.

## Status
**BUILD-COMPLETE / merged @ fa16f2a5 (PR #715) — awaiting deploy + live VERIFY.** NOT epic-DONE
(needs supabase deploy + pgTAP VERIFY on a fully-migrated DB, then the next-ui wiring).

## TWO REMAINING DOWNSTREAM

### 1. brew-ops — deploy + VERIFY (mb-next-payment-gateway / supabase)
- Deploy migration **`20260624000200_sysbank_list_effective_status.sql`** to **staging** via the
  dmirror **`gate.sh` pre-deploy gate**.
- Run pgTAP **`v_system_banks_read_surface_test.sql` (plan 40)** on the fully-migrated DB as the
  live VERIFY (pgTAP is live-DB-only; build proved logic on scratch PG16 only).
- **NOTE — ride-along:** there is a SEPARATE pending staging deploy for the MDR view fix
  (migration **`20260624000000`**, merge **9bf1c884**) per handoff **2026-06-21_23-37**. Both
  `20260624000000` and `20260624000200` can ride the **next `deploy-staging.sh` run**
  (timestamps unique & strictly increasing: 000000 < 000100 < 000200).

### 2. next-ui — wiring (mb-next-admin-portal)
- In `src/lib/system-bank-api.ts`: point **`deriveWorking` → `working_label`** and
  **`deriveBot` → `effective_availability`** (instead of deriving from raw `availability`).
- The DETAIL modal already consumes `working_label`, so this is a tiny, proven wiring. Unblocks
  once the migration lands in the consumed environment.

## Reviewer non-blocking items (OPTIONAL — not gating)
- N1: pgTAP has no explicit *expired-override* assertion (the `> now()` branch is verbatim from the
  shipped detail view and was smoke-covered on scratch DB). An explicit expired-override row would
  strengthen the suite. Optional follow-up.
- N2: `v_system_banks_read_surface_test.sql` is 348 lines (>250 guideline) — PRE-EXISTING; test
  files commonly exceed the source guideline. No action required.
