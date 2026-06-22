# Requirement gap (for PM): /system-bank list shows stale "online/ready" — ignores operator halt / maintenance-override

**Raised by:** next-ui · **Date:** 2026-06-21 · **Area:** Admin portal `/system-bank` (system bank fleet grid) · **Type:** observability/correctness gap, **backend-dependent**

## The gap (current vs expected)
- **Expected:** The system-bank **list grid** status — the bot **online/offline** dot and the **Working** badge (ready / busy / maintenance) — should reflect the bank's *effective* state, including operator halts (`maintenance_override_until`, `halt_pool_until`).
- **Current:** The grid derives those badges from the **raw** `availability` signal only. A bank that the operator has **halted** or put in **maintenance-override** at the engine can still show **"online / ready"** in the grid. The per-bank **Detail popup is already correct** (it uses the override-aware `working_label`), so the same bank reads "maintenance" on click-through but "ready" in the grid.

## Operator impact
- At-a-glance fleet health on the main screen is misleading: a halted / maintenance-override bank looks healthy and routable.
- To trust the status, the operator must open each bank's detail one by one — defeats the purpose of the grid.
- Inconsistent within the same screen (grid vs detail disagree for the same bank).
- No money-correctness impact (the engine still halts/routes correctly regardless of what the grid shows) — this is a monitoring/operator-safety gap.

## Root cause (why the portal can't fix it alone)
- The list read view `v_system_banks` projects `availability` **raw** and does **not** carry `working_label`, `maintenance_override_until`, or `halt_pool_until`.
- The override-aware status logic **already exists** in the sibling detail view `v_system_bank_detail` as `working_label` (a CASE that maps maintenance-override / halt-pool → "maintenance", and for online uses the bot's real `last_health->>'working_task'` falling back to "ready").
- The portal must not re-implement that engine logic in the UI (drift risk), and it has no access to the halt/override fields in the list view anyway.

## What's needed (requirement level)
Backend: expose the **effective, override-aware status** on the **list** view too — lift `working_label` (and an effective/override-aware availability for the online/offline dot) from `v_system_bank_detail` into `v_system_banks`. The CASE is already written in the same migration; this is a copy into the list view, same gated read surface (`system-bank:view`). Owner: brew-ops / gateway, §ADR-29 area.

Eng refs: gateway `supabase/migrations/20260619000600_sysbankwrite_substrate.sql` — `v_system_banks` (line 159, raw `ba.availability`) vs `v_system_bank_detail` (line 228; `working_label` CASE at lines 254-265, override/halt at 243-244).

## Acceptance criteria (product)
- [ ] Grid Working badge + online/offline dot match the bank's Detail popup for the same bank.
- [ ] A bank under maintenance-override or halt-pool shows **maintenance** (not ready) in the grid.
- [ ] Online banks may surface the real working task (as detail does), falling back to "ready".
- [ ] Access unchanged (`system-bank:view` admins only); no regression to the daily aggregates or other columns.

## Dependency / sequencing
1. **Backend (brew-ops):** add `working_label` (+ effective availability) to `v_system_banks`. ← blocker
2. **Portal (next-ui):** point `deriveWorking` / `deriveBot` (`src/lib/system-bank-api.ts`) at the new field instead of deriving from raw `availability` — the detail modal already consumes `working_label`, so it's a tiny, proven wiring. Ready to do as soon as #1 lands.

## Suggested priority
Medium — operator-safety / fleet-observability on a monitoring screen; not money-correctness. Small effort on both sides (the engine logic already exists; it just isn't in the list view).
