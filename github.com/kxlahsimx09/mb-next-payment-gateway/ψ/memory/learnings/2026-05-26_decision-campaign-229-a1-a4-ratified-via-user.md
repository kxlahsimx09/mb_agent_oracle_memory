---
title: decision — Campaign #229 A1 + A4 ratified via user GO (escalated items now #deci
tags: [system-architect, repo:mb-next-payment-gateway, next, decision, adr, payout, deposit, maintenance, slip, withdrawal-queue, campaign-229]
created: 2026-05-26
source: docs/adr.md §ADR-4a PA7 (A1) + §ADR-4c §Amendment 2026-05-26 (A4); user GO thread #229 msg 1032 / campaign #228
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# decision — Campaign #229 A1 + A4 ratified via user GO (escalated items now #deci

decision — Campaign #229 A1 + A4 ratified via user GO (escalated items now #decision).

The two escalated in-epic divergences (campaign #228 / thread #229) were approved by the user per the architect's recommendations — orchestrator relay thread #229 msg 1032 (2026-05-26). Both are now ratified `#decision` §Amendments landed in PR #246 (do-not-merge). This supersedes the #provisional escalation record [[2026-05-26_provisional-campaign-229-a1-a4-escalated-to]].

## A1 — KEEP per-bank maintenance-window payout-cancel (§ADR-4a §Amendment 2026-05-15 PA7, ratified 2026-05-26)
DECISION: next-system carries the per-bank maintenance-window payout-cancel (current flavour (ii), the money-safety workhorse).
- Mechanism: pg_cron sweep (~1-min, mirrors PA3) selects pending payouts whose assigned system_bank is inside its own maintenance_time window; runs the SAME atomic body as PA3 cancel_stale_payout — CAS pending→cancelled (race-guard status='pending'), wallet unfreeze frozen-=(amount+fee) §ADR-10 AM2 + wallets_change_logs payout_unfreeze AM4, cancel withdrawal_queue items, INSERT callback_queue payout.cancelled with distinct failureCode='bank_maintenance'. Lock order per §ADR-4a §Amendment 2026-05-18 (withdrawal_queue → ts_payouts → wallet).
- Ships ON (safety backstop), NOT flag-gated by default (unlike PAYOUT-008 per-age auto-cancel which is flag-gated OFF). System-wide flavour (i) not separately required Phase-1.
- Admin maintenance-window UX + system_banks.maintenance_time config surface = impl-level / admin-API ADR (per §ADR-4c Decision #9).
- Writer handoff: epic-payout PAYOUT-008 §Edge-cases (give the maintenance backstop its own mechanism) + PAYOUT-001 pool-scoping wording.

## A4 — ALIGN with current #460: slip-bearing deposits escalate-to-review, NOT auto-expire (§ADR-4c §Amendment 2026-05-26, ratified)
DECISION: a pending deposit carrying an uploaded slip is EXCLUDED from deadline-expiry → escalates to admin review (checking), matching current #460.
- DA1: §ADR-4c Decision #2 sweep filter gains `AND slip_uploaded_at IS NULL` (next-system slip-presence signal per §ADR-4d D1 audit-triple; greenfield analogue of current's slip_image emptiness check). No-slip path unchanged (still auto-expires).
- DA2: slip-bearing deposit past deadline → review/checking, never terminal expired; reconciles with §ADR-4d Thunder sweep (pending→checking at T+15min per D3/VF1); effective_status view (Decision #10) mirrors DA1.
- DA3: auto-match (DEPOSIT-002) still wins → paid if a statement arrives (first terminal wins, unchanged).
- DA4: no deposit.expired callback on deadline for slip-bearing deposits (no terminal yet); deposit.expired remains terminal only for the no-slip path.
- Writer handoff: DEPOSIT-003 (sweep excludes slip-bearing) + DEPOSIT-004:256 three-timer edge case (supersede "deadline first → expired" for the slip-bearing case).

Next step: orchestrator dispatches next-writer to author the A1 outcome into epic-payout + the A4 outcome into epic-deposit. A2+A3+A1+A4 all now ratified in PR #246. Verified per P-004 (next docs + current-system vault). Links: [[feedback_poc_load_bearing_realism]], [[2026-05-26_decision-campaign-229-in-epic-divergence-ratifi]].

---
*Added via Oracle Learn*
