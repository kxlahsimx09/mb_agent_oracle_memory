---
title: p2p-hub §F `wrong_amount` over/under FINAL RULING (ratified by the user 2026-06-
tags: [p2p-hub, system-architect, dispute, wrong-amount, over-under-split, matched-overpaid, matched-incomplete, settle-gate, g6-amount-clause, dsp-fault, write-off, non-custodial, release-reserve, ratified, thread-7, p-004, p-001, cross-repo-caveat, supersedes]
created: 2026-06-01
source: system-architect — PR #19, Oracle thread #7 (ratified user 2026-06-01 GMT+7)
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub §F `wrong_amount` over/under FINAL RULING (ratified by the user 2026-06-

p2p-hub §F `wrong_amount` over/under FINAL RULING (ratified by the user 2026-06-01 GMT+7, Oracle thread #7; PR #19; docs/design/p2p-hub-design-exploration.md). SUPERSEDES the earlier RATIFICATION_PENDING:#7 proposal in this thread (which had over and under STRUCTURALLY SYMMETRIC — both fail the §G6 gate, both release M, neither settles, and the PSP customer returns the excess X). The human ruled the two directions ASYMMETRICALLY.

FINAL DISPOSITIONS:
- UNDER (`actual < M`) → `matched_incomplete` (UNCHANGED from the prior proposal). Does NOT settle (withdrawer would be short); payout side releases the full reserved M (`release_reserve`, §D2); shortfall M−actual is a DSP↔its-own-depositor matter. No inter-provider debit, no hub money moves, no human.
- OVER (`actual > M`) → `matched_overpaid`, but its MEANING CHANGED: the match SETTLES at the originally-agreed M (the destination received ≥ M, so the withdrawer is made whole). `settle_p2p_match` (§D4) runs normally, debiting EXACTLY M. The excess X = actual − M is UNRECOVERABLE / WRITTEN OFF as DSP-fault — the hub cannot claw it back (non-custodial, §A7 / §B1.2 "over-pay is an unrecoverable gift"); it is the deposit-side's loss, attributed to the DSP and logged (⟦S3⟧ DSP reputation signal, like other DSP-fault classes). So `matched_overpaid` = "match SETTLED at the agreed M; over-payment excess written off as DSP-fault" — NOT a release/non-settle.

§G6 SETTLE-GATE AMENDMENT (P-001 evolution of the thread-#5 ratify, NOT a delete): the amount clause `actual == M` evolves to `actual >= M` ⇒ settle at M (over: excess ignored/written-off DSP-fault; exact: normal settle); `actual < M` ⇒ does NOT settle ⇒ `matched_incomplete`. The `genuine` and `delivered` (receiver-account match, mask-aware last-4) clauses are UNCHANGED — the ~905-case mobiz fraud defence is fully intact; only the amount clause was refined. The thread-#5 ratify still stands for genuine+delivered.

CONTRACT IMPACT (§F.3): live close_outcome count 6 → 7 (`matched_overpaid` added); reserved stays 5; total 11 → 12. `matched_incomplete` KEPT not renamed (P-001 — already live in PRD DISPUTE-002/003 + PR-#18 catalogue).

§F.0 RECONCILIATION: over-payment now DOES move money (the agreed M settles on the B2B float), so over is NO LONGER a "no money moves" case — only under is. The §F.0 framing + the "why no contest" list were corrected to reflect this.

NO NEW WALLET OP: over uses the existing `settle_p2p_match` at M; under uses `release_reserve`. Confirmed against §D4/§G7 — no conflict (the RPC debits exactly m.amount; settling at M for over is consistent because the destination received ≥ M).

EDITS MADE (design doc, PR #19 branch next-architect/wrong-amount-over-under-split): §F.1 over/under rows; §G6 predicate `actual >= M settles at M` + P-001 evolution note + Gap #2; §C8 + §F.4 cross-ref pointers; §G8 mapping + §G5 thunder-fixture table (over → SETTLED-at-M + matched_overpaid); §F.3 contract; §F.0 "no money moves". RATIFICATION_PENDING:#7 region flipped → #decision.

CROSS-DB CAVEAT: filed under github.com/kxlahsimx09/p2p-hub; prior p2p-hub §F/§S5 learnings live under github.com/kxlahsimx09/mb-next-payment-gateway (cross-repo split — search BOTH projects for §F / close_outcome / wrong_amount history).

NEXT-WRITER FOLLOW-UPS (do NOT auto-author): PRD docs/requirements/epic-dispute-liability.md DISPUTE-002 + DISPUTE-003, and the fault-class catalogue PR #18 (docs/requirements/fault-class-catalogue.md) — BOTH currently carry the single under-paid `wrong_amount` row and now need the over=SETTLE-at-M / `matched_overpaid` (excess written off, DSP-fault) update, plus the §G6 amount-clause `actual >= M` amendment.

Refs: §F.0 / §F.1 / §F.3 / §F.4 / §C8 / §G5 / §G6 / §G7 / §G8 / §D2 / §D4 / §A7 / §B1.2; Oracle threads #5 (genuine+delivered) and #7 (amount clause); PR #19.

---
*Added via Oracle Learn*
