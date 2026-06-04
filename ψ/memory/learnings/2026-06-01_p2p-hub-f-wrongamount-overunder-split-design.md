---
title: p2p-hub §F `wrong_amount` over/under split (design PR #19, Oracle thread #7, RAT
tags: [p2p-hub, system-architect, dispute, wrong-amount, over-under-split, matched-overpaid, matched-incomplete, close-outcome-contract, settle-gate, non-custodial, release-reserve, customer-books, ratification-pending, thread-7, p-004, p-001, cross-repo-caveat]
created: 2026-06-01
source: system-architect — design PR #19, thread #7
project: github.com/kxlahsimx09/p2p-hub
---

# p2p-hub §F `wrong_amount` over/under split (design PR #19, Oracle thread #7, RAT

p2p-hub §F `wrong_amount` over/under split (design PR #19, Oracle thread #7, RATIFICATION_PENDING) — refines the ratified §F (P-001 evolve, not delete).

CORE FINDING (grounded in the money model P-004, docs/design/p2p-hub-design-exploration.md): the `matched_incomplete` "match passes at the real-but-short amount / no money moves / each reconciles with own customer" language is a CUSTOMER-BOOKS statement, NOT a hub settle-at-actual. The hub does NOT settle a wrong-amount match — it FAILS the §G6 settle gate (which requires `actual == M`). The only settle RPC (`settle_p2p_match`, §D4) debits exactly `M` on the B2B float; there is NO settle-at-actual wallet path. So ANY `actual ≠ M` (over OR under) fails the gate → match does not reach SETTLED → the still-reserved `M` on the payout side is RELEASED (`release_reserve`, §D2). This makes under and over STRUCTURALLY SYMMETRIC at the hub: both release `M`, both leave the discrepancy as a customer-books matter, neither is an inter-provider debit. This corrects a likely misread that `matched_incomplete` settles at actual via the wallet.

THE TWO DIRECTIONS:
- under (`actual < M`) → `matched_incomplete` (kept). Shortfall is a DSP↔its-depositor matter. The whole reserved `M` is released (no partial-settle op).
- over (`actual > M`) → `matched_overpaid` (NEW live outcome). Depositor's customer sent `M + X` bank-to-bank to the destination (PSP customer's account); obligation is only `M`. Excess `X` is a DEPOSIT-SIDE-CUSTOMER matter — the PSP customer (windfall recipient) returns `X` to its counterpart; hub CANNOT claw back (§A7 non-custodial / §B1.2 "over-pay is an unrecoverable gift") so `X` is NOT hub-settled and NOT an inter-provider debit.

CONTRACT IMPACT (§F.3): live close_outcome count 6 → 7 (`matched_overpaid` added); reserved stays 5; total 11 → 12. `matched_incomplete` KEPT not renamed (P-001 — already live in PRD DISPUTE-002/003 + PR-#18 catalogue).

IMPL-PASS: no new wallet op needed for the split — `release_reserve` (reserved -= M) covers both directions. A future partial-settle-at-actual would need a new op; flagged not built. (Separate from §G7b `fee_refund_charged` post-charge fee question.)

EDITS MADE (design doc): §F.1 row split + RATIFICATION_PENDING:#7 note; §F.3 live-count bump + note; §G8 predicate row split (`actual < M` / `actual > M`); aligned §F.0 / §G5 mock-emit table / §G6 Gap #2.

CROSS-DB CAVEAT: this learning is filed under github.com/kxlahsimx09/p2p-hub; prior p2p-hub §F/§S5 learnings live under github.com/kxlahsimx09/mb-next-payment-gateway (cross-repo split — search BOTH projects for §F / close_outcome history).

NEXT-WRITER FOLLOW-UPS (do NOT auto-author): docs/requirements/epic-dispute-liability.md DISPUTE-002 (L112) + DISPUTE-003 (L155); docs/requirements/fault-class-catalogue.md (PR #18) wrong_amount row (L49) + live-set line (L67) — all carry the single under-paid row and need the over/under split + `matched_overpaid` once thread #7 ratifies.

Refs: §F.1 / §F.3 / §G8 / §G6 / §D2 / §D4 / §A7 / §B1.2; Oracle thread #7; PR #19.

---
*Added via Oracle Learn*
