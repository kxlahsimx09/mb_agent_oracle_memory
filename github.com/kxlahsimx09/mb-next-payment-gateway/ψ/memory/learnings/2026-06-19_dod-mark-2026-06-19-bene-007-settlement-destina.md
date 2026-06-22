---
title: DoD-MARK 2026-06-19 — BENE-007 (settlement destination-registry enforcement) = I
tags: [dod-mark, in-slice-done, BENE-007, settlement, destination-registry, buildepic2, ADR-22, seal, verify]
created: 2026-06-19
source: next-pm campaign buildepic2
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK 2026-06-19 — BENE-007 (settlement destination-registry enforcement) = I

DoD-MARK 2026-06-19 — BENE-007 (settlement destination-registry enforcement) = IN-SLICE-DONE (gates 1–4 GREEN). epic-DONE WITHHELD.

Story: BENE-007 SETTLEMENT-enforced half (split: PAYOUT advisory / SETTLEMENT enforced, owner-refined 2026-06-18, §ADR-22 §Amendment). The `create_settlement` Layer-1 destination-registry gate.

Gate chain (labels NOT trusted as state; verified against the migration on main + raw gate evidence):
- BUILD: PR #579 MERGED (9abf6fb) — mig 20260618000100_settle_dest_registry_enforcement.sql. Gate predicate = owner-match ∧ status='approved' ∧ 'settlement'=ANY(purpose), else dest_not_registered (P0001 → HTTP 400) + optional §5 forensic FK settlements.beneficiary_bank_account_id. Fires AFTER missing_dest_bank null-check and BEFORE the wallet FOR UPDATE money-lock. 18/18 ROLLBACK self-test on dev-1; staging PR #583. SPEC docs/spec/settlement-destination-registry-enforcement-slice.md.
- REVIEW: at #579 merge (self-authored-PR COMMENTED posture per §9a).
- VERIFY (gate 3): next-tester GREEN 62/0 — campaign bene7test, tester stack yupsevcrubgprsbujbpu. Black-box probe off SPEC only (migration body + EF never read), scripts/verify-bene7-dest-registry-tester.sh (62 assertions). Refused settlement = dest_not_registered/400 with ZERO wallet movement (no settlements row, balance+frozen unchanged, 0 change-logs); null dest → distinct missing_dest_bank. TEETH proven (in-suite no-movement assertion + out-of-band gate-bypass sim both fired RED). Evidence: next-tester_bene7test_findings.md.
- SEAL (gate 4): next-investigator SLICE SEAL — VERDICT GREEN — campaign bene7seal, isolated seal stack qnccphgykzdydebmdwdf. All 13 ACs CONFIRMED from raw TRUTH-DB re-derivation (psql-as-postgres + service-role rpc/create_settlement, independent be7e0007-… fixtures), ZERO contradictions. Evidence: next-investigator_bene7seal_findings.md.

epic-DONE WITHHELD — settlement is a MONEY surface, so the §ADR-21 money LIVE journey applies (distinct from the BENE-001..006 non-money LIVE-N/A path). The PAYOUT-advisory half = parity (nothing to enforce/verify).

Recorded in: docs/requirements/epic-beneficiary-bank-account.md (Build status DoD §, 🟢 evidence table), docs/requirements/INDEX.md (BENE epic-intro + BENE-007 row), next-pm_reconcile_findings.md. Doc PR #621 (OPEN, owner-merge, DO NOT MERGE, NOT self-merged) — commit b60b908.

---
*Added via Oracle Learn*
