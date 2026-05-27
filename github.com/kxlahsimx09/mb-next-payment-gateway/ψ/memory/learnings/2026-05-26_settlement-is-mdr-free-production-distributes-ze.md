---
title: Settlement is MDR-free — production distributes ZERO settlement MDR (contradicti
tags: [system-architect, repo:mb-next-payment-gateway, next, migration-map, settlement, mdr, decision, adr-12, thread-236, production-drift-flag, wallet]
created: 2026-05-26
source: dpay prod (wallets_change_logs mdr_distribution: settlement=0 of ~1.6M; mdr_wallet_log + mdr_wallets empty; settlements mdr_field_count=0) + tester learning 2026-04-22 + pg-writer 2026-05-04 + thread #236/#233
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Settlement is MDR-free — production distributes ZERO settlement MDR (contradicti

Settlement is MDR-free — production distributes ZERO settlement MDR (contradiction resolved by P-004, thread #236 / #233).

§ADR-12 settlement flow — MDR-on-approve contradiction RESOLVED. next-writer #233 flagged a conflict: tester learning '2026-04-22 settlement confirm-review success branch skips MDR' vs pg-writer Bucket B 'approve → MDR distribute' (and the pg-writer note 'ApproveSettlement is the only MDR-distributing settlement path').

RESOLUTION (factual, P-004 — dpay prod 2026-05-26; NOT assumption): settlement distributes ZERO MDR across full history.
- wallets_change_logs mdr_distribution ops by source: deposit ~1.6M, topup 563, payout 1,242, SETTLEMENT 0.
- mdr_wallet_log + mdr_wallets collections both EMPTY (0 docs) — all MDR flows through wallets_change_logs mdr_distribution.
- settlements docs carry NO MDR field (mdr_field_count = 0 across all 2,986 docs).
→ The 'ApproveSettlement is the only MDR-distributing path' code branch NEVER FIRES in production. The Bucket B 'approve→MDR' expectation is FALSIFIED by data. The tester's hypothesis (skip is intentional to avoid double-pay) is confirmed by the zero-count.

ARCHITECT RECOMMENDATION (next-system): settlement is MDR-free. Rationale: MDR is charged ONCE at inflow (deposit/topup per §ADR-16) + on payout; settlement is a merchant withdrawing its already-settled balance (MDR was already taken at deposit time) — charging again at settlement would double-charge. The mobiz ApproveSettlement MDR branch is a #current dead-path NOT inherited (production-drift-flag pattern: a #current code path next-system declines to carry forward).

MONEY-MATERIAL ESCALATION: whether the next-gen gateway charges any settlement fee is a product/revenue call → flagged to user for confirmation before binding #decision (charter §9). A future settlement processing fee (distinct from MDR) would be a separate product decision, out of scope here. Marked RATIFICATION_PENDING (user money sign-off); the factual contradiction-resolution itself is firm.

Story impact (next-writer): SETTLE-002 approve AC already has NO MDR fan-out clause → keep as-is. The [AWAITING_THREAD:233] edge-case 'Does approve distribute MDR?' closes with: 'No — settlement is MDR-free; MDR is charged once at inflow + payout; the mobiz ApproveSettlement MDR branch never fires in prod and is not inherited.'

---
*Added via Oracle Learn*
