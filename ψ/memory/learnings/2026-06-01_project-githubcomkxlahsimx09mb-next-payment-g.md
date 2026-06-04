---
title: [project: github.com/kxlahsimx09/mb-next-payment-gateway] depfix campaign — epic
tags: [epic-deposit, depfix, adr-reconciliation, deposit.paid, customer_bank_bank_code, status-taxonomy-TS1-R, cancelled-callback-silent, port-fidelity, next-architect, repo:mb-next-payment-gateway]
created: 2026-06-01
source: next-architect depfix pass 2026-06-01
---

# [project: github.com/kxlahsimx09/mb-next-payment-gateway] depfix campaign — epic

[project: github.com/kxlahsimx09/mb-next-payment-gateway] depfix campaign — epic-deposit pre-dev FIX pass, architect adr.md reconciliations (3) on branch arch/depfix-adr, PR #299 (NOT merged).

Three port-fidelity consistency fixes to canonical docs/adr.md (no new decisions):

1. `deposit.completed` → `deposit.paid` at §ADR-4b D5 (finalize_deposit outbox), §ADR-4d D5 (admin status=paid), §ADR-9 §Context flows. `deposit.paid` = ratified §ADR-9 §TS5 canonical wire name (641,801 production callback_logs). Stale `.completed` strings re-seeded the epic taxonomy bug each pass.

2. `custom_bank_code` → `customer_bank_bank_code` throughout §ADR-4d V3 (slip-sender bank-mismatch) amendment. V3 prose (ratified thread #194, AFTER §ADR-4b §CB1's 2026-05-13 rename) used the pre-CB1 misnomer. Verified NOT distinct: deployed migration 20260521000003_adr4d_v3_au1_bundled.sql:436 reads upper(v_dep.customer_bank_bank_code); custom_bank_code survived only as a stale code-comment. Footnote added at §V3-5.

3. §ADR-9 §TS1 — TS1-R note + AM5 fix. Locked deployed ts_deposits.status CHECK enum (canonical: 20260521000001_adr4d_adr4b_cr_canonical_review_rename.sql:87-88) = (pending,paid,rejected,expired,cancelled,checking,failed) as a strict SUPERSET of callback-terminal set {paid,rejected,expired,failed}. Facts: (a) cancelled IS a sanctioned deposit terminal (admin/maintenance-cancel) but CALLBACK-SILENT — no deposit.cancelled event Phase-1 (0 of 888,871 production callback_logs); (b) processing is NOT a deposit status (payout-only ts_payouts.status); deposit holding state is checking. §ADR-9 AM5 corrected to drop bogus deposit processing.

Durable methodology notes (future deposit passes):
- The depreview architect-reviewer's claim that adr.md lacks §ADR-19 was STALE/WRONG — §ADR-19 is at docs/adr.md:3801, intact.
- Retroactive at-match slip-fraud DETECTION is ALREADY deployed (20260513000013_adr4b_check_retroactive_slip_fraud.sql, pg_cron 1-min sweep, port of mobiz transactionMatcher.go checkRetroactiveSlipFraud) — flags both colliding paid deposits via failure_code='slip_invalid', keeps paid, refund=DEPOSIT-011 deferred. Only undocumented in the epic, not dropped.
- Current mobiz create math = math.Floor(amount), reject <1 THB (DepositRequestController.go:229); NO fractional disambiguator.
- Current expiry = per-client expired_deposit_time default 10 min, request timeout override only if 1..60; NO 5-15/5-45 fixed band (epic fabrications; 5-15 is only a production sample).
- V1 slip-fraud is binary hash-equality — NO match-score; score only belongs to multi-candidate name-match (DEPOSIT-005).
- Narrow gap surfaced (HIGH-6, needs user decision): slip-bearing past-deadline on persistent Thunder no-verdict has NO producer to reach checking (expire sweep skips slip-bearing per DA1; only a Thunder verdict flips pending→checking; admin queue is checking-only) → sits invisibly at pending. §ADR-4c DA2's "deterministically lands in checking" is unbacked on the no-verdict path.

---
*Added via Oracle Learn*
