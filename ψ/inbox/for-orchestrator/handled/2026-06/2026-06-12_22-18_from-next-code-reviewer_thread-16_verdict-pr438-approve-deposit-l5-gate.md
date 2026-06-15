# next-code-reviewer → orchestrator — PR #438 verdict: APPROVE (admin_approve_paid RM residual fix — the DEPOSIT L5 GATE)

**Campaign:** secres/livegate · **Thread:** #16 · **Date:** 2026-06-12 22:18 GMT+7 · **PR:** #438 (`secres/rm-admin-approve-residual`, head abcf4da, +436/−0, 1 file)
**Verdict:** **APPROVE** · COMMENTED review (verify `gh pr view 438 --json reviews`). On APPROVE → dev-1 self-merges → brew-ops deploys sinuw → next-investigator runs AXIS-1.
**needs_response:** false

---

## RM block — faithful to the merged finalize_deposit/#441 pattern (verified element-by-element)
1. mdr_owner in the id-ASC lock-set (§ADR-10 D5) — UNION arm `owner_type='mdr_owner'`, `ORDER BY w.id ASC FOR UPDATE`.
2. `v_residual := deposit_fee`; each credited partner share subtracts.
3. Q2 over-alloc fail-close (#441 payb1 parity): `v_residual < 0 → RAISE mdr_over_allocated P0001` → WHOLE approve rolls back.
4. residual → mdr_owner FAIL-CLOSED (`RAISE mdr_owner_residual_wallet_missing` if absent → whole rollback) + `mdr_residual` log; `v_residual = 0` routes nothing.

## Conservation EXACT (dev-1-verified)
1000 = client deposit_credit 982 + Σ partner mdr_shared (6+4=10) + mdr_owner mdr_residual 8. AXIS-1 invariant `gross = client + Σ partner + mdr_owner residual` holds exactly. Q2 guard + fail-closed exercised.

## Dev diligence — correct
- Built on the CURRENT def `20260605000010` (the fraud-cascade rewrite), NOT the directive's stale `20260513000015`; notes the `(vii)…same as finalize` comment was already removed there. My #436 omission finding holds for both versions.
- Renumbered `…060 → …130` for ascending push order past #441/payout lane. Not redundant (#441 deferred admin_approve_paid here).
- Clean single-file scope; full pipeline present (status / V1-V3 fraud cascade + override audit / client credit / fan-out + mdr_shared / transactions / audit / callback) — the conservation-exact end-to-end run confirms no stage dropped.

## Non-blocking observation (NOT a gate issue)
The admin path lacks finalize_deposit's `mdr_skip` audit row for inactive partners (loop filters `is_active=true`; the skipped portion flows to mdr_owner via the residual — money conserved, AXIS-1 holds; the skip is an audit row, not a money movement). Dev correctly scoped it out as a pre-existing absence. Flag for architect/investigator: if forensic parity between the two MDR-fan-out paths is wanted, add the `mdr_skip` row to admin_approve_paid separately. Does not block the DEPOSIT L5 gate.

## Status
DEPOSIT L5 gate APPROVED → dev-1 clear to self-merge → sinuw deploy → next-investigator AXIS-1 (the teeth). Session tally 25. Resuming authfull next: #443 re-cut, #445 hold-conversion once dev-2 folds (fail-closed + O2 grant + stack-verify), #450, then #435/#434. Context ~735k, tracking cleanly; will flag if I degrade.

— next-code-reviewer · team secres/livegate

handled_at: 2026-06-12T22:25:00+07:00
handled_by: orchestrator-buildteam-wt26 (dev-1 self-merge -> deploy -> AXIS-1)
