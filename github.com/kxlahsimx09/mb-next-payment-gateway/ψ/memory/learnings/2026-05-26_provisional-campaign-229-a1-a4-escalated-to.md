---
title: provisional — Campaign #229: A1 + A4 escalated to user for human ratification (p
tags: [system-architect, repo:mb-next-payment-gateway, next, provisional, adr, payout, deposit, withdrawal-queue, slip, maintenance, campaign-229, ratification-pending]
created: 2026-05-26
source: docs/adr.md §ADR-4a PA7 [RATIFICATION_PENDING:229] (A1) + §ADR-4c §Escalation 2026-05-26 [RATIFICATION_PENDING:229] (A4); thread #229 / campaign #228
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# provisional — Campaign #229: A1 + A4 escalated to user for human ratification (p

provisional — Campaign #229: A1 + A4 escalated to user for human ratification (product / money-safety material).

Sub-task 1 of parent campaign #228. Two of the four in-epic divergences pg-writer found (campaign #225, thread #227 msg 1017) carry product / money-safety / client-experience implications, so they exceed architect authority and are escalated to the user with a recorded architect recommendation. Marked [RATIFICATION_PENDING:229] in docs/adr.md. Companion #decision learning covers the within-authority A2+A3. These become #decision only after human GO.

## A1 — Per-bank maintenance-window payout cancel (§ADR-4a PA7 [RATIFICATION_PENDING:229])
RECOMMENDATION: KEEP the per-bank variant.
- Current MaintenanceCancelScheduler (scheduler/maintenance_cancel.go:79-303@0424cdc #417; learning 2026-05-07_maintenancecancelscheduler-gains-per-bank-cancella) runs TWO flavours sharing one cancel body: (i) system-wide — cancels all pending payouts only while the global maintenance window is open; (ii) per-bank — runs EVERY tick, cancels pending payouts assigned to any active bank whose OWN maintenance_time (e.g. 20:00-08:00) covers now, refunds amount+fee → so a client's money isn't frozen ~12h overnight when one bank sleeps.
- next-system: the system-wide "maintenance-window bulk-cancel" is flagged a separate/unratified question (§ADR-4a §Amendment 2026-05-15 PA-section, thread #105; §ADR-4c Decision #9; epic-deposit.md:204). The PER-BANK flavour (the money-safety workhorse) is unmentioned anywhere. PAYOUT-008 (epic-payout) is the per-AGE auto-cancel (flag-gated, OFF in Phase-1) — a different mechanism.
- Why KEEP: PA6 dropped the "flag-off frozen-funds" alert precisely BECAUSE the maintenance-window backstop bounds frozen-funds duration; PA6 says re-evaluate "only if next-system decides NOT to carry maintenance-window bulk-cancel." So the maintenance cancel is already load-bearing for shipping PAYOUT-008 OFF-by-default. Dropping it → PAYOUT-008 becomes the sole cancel path AND client funds can freeze overnight.
- Why escalate (not architect-ratify): determines whether client funds sit frozen overnight = product / money-safety / client-experience material.
- On GO: §ADR-4a §Amendment — per-bank every-tick sweep over banks whose maintenance_time covers now; reuse cancel_stale_payout body + §ADR-10 AM2/AM4 unfreeze + §ADR-9 payout.cancelled with a distinct failureCode (e.g. bank_maintenance); admin-UX still deferred to admin-API ADR.

## A4 — Slip-bearing deposit deadline-expiry (§ADR-4c §Escalation 2026-05-26 [RATIFICATION_PENDING:229])
RECOMMENDATION: ALIGN with current #460 (exclude slip-bearing pending deposits from deadline-expiry → escalate to review/checking).
- OPPOSITE outcomes, no recorded decision. Current #460 (9aebabb, 2026-05-22; scheduler/deposit_expiry.go:73-267; learnings 2026-05-22_defer-thunder-slip-verification-until-admin-review + 2026-05-22_w9-pass-2026-05-22-range-2f353569aebabb-pr-46) changed processExpiredDeposits to EXCLUDE pending deposits carrying a slip ($or:[{slip_image:""},{slip_image:{$exists:false}}]) → they escalate to admin review (processSlipEscalation → checking → lazy Thunder), NOT expire.
- next-system DEPOSIT-004 three-timer model (epic-deposit.md:256): if the deposit's own deadline falls before auto-match / the Thunder-verify threshold, the §ADR-4c expire sweep flips it to terminal `expired` + fires deposit.expired callback even though a slip was uploaded. Model predates #460; divergence never flagged deliberate.
- Why ALIGN: an end-user who uploaded proof-of-payment but whose bank statement is merely slow should not be told "expired/no payment" — that is a false-negative on real money and is exactly the customer-money-safety case #460 was shipped to fix. Per-client deadlines are 5-45 min (median 10), Thunder threshold 15 min → for short-deadline clients the deposit IS still pending at deadline and currently auto-expires.
- Why escalate: changes a client-facing terminal outcome + callback contract + adds admin-review load = product / money-safety material.
- On GO: §ADR-4c Decision #2 sweep filter gains a slip-absent predicate (mirror current); DEPOSIT-003/004 AC updates (next-writer); reconcile with §ADR-4d Thunder-verify sweep so a slip-bearing deposit deterministically lands in checking/review not expired.

Verified against source per P-004 (next docs + current-system vault). Links: [[feedback_poc_load_bearing_realism]], [[feedback_adr_amendment_supersession]].

---
*Added via Oracle Learn*
