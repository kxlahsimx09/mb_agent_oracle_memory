---
title: EPIC-SEAL: DEPOSIT-005 (multi-candidate review parking — DEPOSIT-002 safety bran
tags: [epic-seal, deposit-005, multi-candidate-review, fifo-fix, independent-verification, money-invariants]
created: 2026-06-04
source: next-investigator (campaign dep5seal)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# EPIC-SEAL: DEPOSIT-005 (multi-candidate review parking — DEPOSIT-002 safety bran

EPIC-SEAL: DEPOSIT-005 (multi-candidate review parking — DEPOSIT-002 safety branch) — SEALED 2026-06-04 by next-investigator with INDEPENDENT raw-table re-derivation on isolated seal stack qnccphgykzdydebmdwdf (NOT the tester stack yupsevcrubgprsbujbpu). Migration 20260604000010_deposit005_multi_candidate_review_fifo verified live.

ALL 7 ACs / 14 assertions re-derived from RAW ground-truth tables (ts_deposits, wallets_change_logs, bank_statements, callback_queue, mdr_shared) by request_id lookups with unique per-run keys (no cross-run collision) — harness booleans NOT trusted.

LOAD-BEARING AC-2 (LIFO→FIFO fix) CONFIRMED FIXED on my stack: degenerate full-key collision (same client_id+source_account+source_bank) auto-picks FIFO-OLDEST. Re-derived twice off ts_deposits.created_at: oldest-created deposit is credited+paid+matched (matched_request_id=oldest, matched_link_step=1); newer stays pending with zero wallet movement. The latent LIFO bug (ordered by abs(transaction_date_bkk−created_at), which ranks the NEWEST closest to a late statement) is genuinely corrected to created_at ASC.

MONEY INVARIANTS hold (raw): ≤1 deposit_credit across the candidate set; conservation (net credit = gross − fee; fee = sum of mdr_distribute + mdr_residual; §ADR-19 gross base); exactly-one delivered deposit.paid callback (winner=1, loser=0).

AC-1 diff-source→review+match_note+8-field match_candidates+NO finalize; AC-3 same-source cross-client (≥2 distinct client_id)→review NOT carve-out, both clients zero credit (cross-client wrong-credit path §Amendment 2026-05-19 closed); AC-4 review excluded from sweep_unmatched_statements; AC-5 candidate list non-empty 8 fields name_score numeric; AC-6 admin_resolve_multi_candidate→review→matched (link_step=admin_multi_candidate_resolve), chosen finalized (1 credit+1 callback), other pending; AC-7 +7d clock+both sweeps→statement never auto-resolves (deposits may expire). V1 bijection (7↔7) + V5 completeness: no claimed-green-but-unprobed clause.

DISCREPANCY (resolved, NOT a defect): my harness run scored 13/14 — the one RED (AC-1 dep_status=[undefined,pending]) was a deposit-create id-capture TRANSPORT flake (row created but id not returned client-side → finalizeFootprint read undefined; orphan row had zero wallet logs = behavior correct). The create EF also intermittently failed whole runs on the seal stack. This is DEPOSIT-001 create-EF/harness reliability, ORTHOGONAL to DEPOSIT-005 matcher/cascade/resolve logic — does not block the seal. Flagged for harness owners. Findings: next-investigator_dep5seal_findings.md.

---
*Added via Oracle Learn*
