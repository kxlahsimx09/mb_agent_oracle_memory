---
title: EPIC-SEAL — SETTLEMENT destination-registry enforcement (PR #579, §ADR-22 §Amend
tags: [next-investigator, repo:mb-next-payment-gateway, next, epic-seal, seal, verify, settlement, beneficiary-bank-account, dest-registry-enforcement, adr-22, pr-579, falsify, wallet, provenance]
created: 2026-06-17
source: next-investigator_settleenfseal_findings.md @ seal-env qnccphgykzdydebmdwdf; create_settlement md5 0dfa56682ce03006d10a9c47481b72ab
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# EPIC-SEAL — SETTLEMENT destination-registry enforcement (PR #579, §ADR-22 §Amend

EPIC-SEAL — SETTLEMENT destination-registry enforcement (PR #579, §ADR-22 §Amendment 2026-06-18 BENE-007 refined). next-investigator (de-bias layer 2) SEALED the VERIFY-by-falsification gate on its OWN seal stack qnccphgykzdydebmdwdf, grounding EVERY probe-PASS in RAW COMMITTED tables (never the harness flag / tester word / dev code).

VERDICT: SEAL (Step-2 VERIFY layer). Tester@settleenfbuildt claimed 11 PASS / 0 FAIL; all independently reproduced from raw seal-DB; ZERO contradiction.

Method (faithful + independent): each create_settlement / create_payout ran as its OWN psql transaction (autocommit) = a production EF call; on RAISE only that statement's tx aborts; then read COMMITTED raw rows. Stronger than the tester's single BEGIN..ROLLBACK-with-savepoints. De-bias improvement: counted negative rows by request_id (precise) + a GLOBAL settlements-count invariant — closing the tester's entity_id-filter blind spot.

Raw-data confirmations:
- 6 NEGATIVES (free-form/pending/rejected/wrong-owner/topup-only/cross-tenant) → P0001 dest_not_registered; 0 rows by request_id; owner wallet frozen=0 (balance intact); 0 wallets_change_logs; 0 audit_log. Global settlements stayed baseline+positives (15→17 = +2 positives only).
- NO-LEAK: 6 tokens normalize to 1 string (only variable = caller's OWN id); leaks_target_state=false. Caller cannot tell "no account" from "pending/rejected/not-yours/wrong-purpose".
- 2 POSITIVES (client {topup,settlement}; partner {settlement}) → 1 row each by request_id, pending, total_frozen 50000, beneficiary_bank_account_id FK = matched APPROVED registry row, owner wallet frozen 0→50000 (partner wallet for partner case), exactly 1 settlement_freeze log each.
- ORDERING: no-wallet owner + bad dest → dest_not_registered (NOT entity_wallet_missing/P0002) ⇒ gate fires BEFORE wallet FOR UPDATE; null dest → missing_dest_bank (gate AFTER null-check).
- PAYOUT UNTOUCHED: free-form create_payout → SUCCESS, ts_payouts row, NO dest_not_registered, 0 settlement rows; gate did not bleed into payout.
- ADVERSARIAL (beyond tester): uppercase bank_code, trailing-space account_number, retried-pending all REJECT (exact match, no loosening); determinism re-run identical; post-everything global count still 17, namespace rows still 2 (no leaked/dup row).

Deployed artifact fingerprint: create_settlement md5(pg_get_functiondef)=0dfa56682ce03006d10a9c47481b72ab; §5 FK settlements.beneficiary_bank_account_id → beneficiary_bank_account(id) live.

PROVENANCE CARVE-OUT (gates DONE, NOT the seal): PR #579 is OPEN/unmerged (pre-merge VERIFY deploy — VERIFY precedes MERGE). origin/main has docs/SPEC/ADR only, not the supabase function source. Seal stack schema_migrations has NO settle-dest-registry-enforcement ledger row (independently confirms the tester's flag) → stack-freshness.sh blind to it. So V4 run-sha==merged-HEAD cannot be literally met (unmerged by design). Open item → brew-ops/merge: land the ledgered migration on merge. This seal certifies the deployed PR-#579 artifact; it does NOT mark DONE — only next-pm marks (merged PR + reviewer APPROVE + this seal + LIVE gate §ADR-21).

Footprint: cleanup of positive money-ledger rows correctly BLOCKED by append-only guard _block_mutation_append_only on wallets_change_logs (P-001 money-ledger immutability) — not forced; 2 settlements + 1 ts_payouts + 3 freeze-logs retained under namespace 5ea1xxxx (harmless; negatives left nothing immutable).

---
*Added via Oracle Learn*
