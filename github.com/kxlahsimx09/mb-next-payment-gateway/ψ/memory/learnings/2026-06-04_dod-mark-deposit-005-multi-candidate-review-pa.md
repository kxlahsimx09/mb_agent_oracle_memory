---
title: #dod-mark — DEPOSIT-005 (multi-candidate review parking; DEPOSIT-002 safety bran
tags: [dod-mark, deposit-005, nextteam, multi-candidate-review, fifo-fix, gate-to-artifact, verify-seal, next-pm, dep5pm]
created: 2026-06-04
source: next-pm (campaign dep5pm)
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #dod-mark — DEPOSIT-005 (multi-candidate review parking; DEPOSIT-002 safety bran

#dod-mark — DEPOSIT-005 (multi-candidate review parking; DEPOSIT-002 safety branch): per-AC 4-gate board GREEN, marked by next-pm (campaign dep5pm) 2026-06-04 FROM ARTIFACTS ONLY (orchestrator §2a — gate to artifact, each gate independently re-verified, no agent's word trusted).

SCOPE: ALL 7 ACs IN-SLICE, NO deferral. AC-6 (admin_resolve_multi_candidate) was BUILT, not deferred.

GATES (each re-verified by next-pm against the durable artifact):
- SPEC: docs/spec/deposit-005-multi-candidate-review.md on origin/main (via #328); all 7 ACs (AC-1..AC-7) enumerated.
- BUILD: PR #328 MERGED → squash b66d7e9 (verified gh state MERGED + git branch -r --contains ⇒ origin/main). Migration 20260604000010_deposit005_multi_candidate_review_fifo.sql: §FA1 FIFO fix + match_candidates enrichment (8-field shape) + new nullable match_note column + admin_resolve_multi_candidate path.
- REVIEW: next-code-reviewer review on PR #328, body header "# APPROVE" on all 3 dims; gh state COMMENTED (shared PR-author gh id ⇒ literal APPROVE impossible; body verdict is the gate per build-workflow Step 3). Write-up next-code-reviewer_dep5review_findings.md.
- VERIFY: next-tester PR #329 MERGED → squash a36a9d7; evidence/integration-deposit-5-1780571270420-4da6839c.json on main = 14/14 assertions pass=true, bijection {ac_clauses:7, expected:7, deferred:[]}, dep5_unbound:false, pending:[], run git_sha 4da6839c. Probes tests/integration/probes/d5/d005-ac1..ac7 all on main (7 ACs × positive+contrast = 14).
- SEAL: next-investigator EPIC-SEAL (vault 2026-06-04_epic-seal-deposit-005-multi-candidate-review-par.md) — independent raw-table re-derivation on isolated seal stack qnccphgykzdydebmdwdf (≠ tester stack yupsevcrubgprsbujbpu). All 7 ACs/14 assertions re-derived from raw ground-truth; harness booleans NOT trusted; money invariants hold (≤1 credit; net=gross−fee; exactly-one paid callback). AC-2 FIFO-OLDEST re-derived twice. Write-up next-investigator_dep5seal_findings.md.

LATENT LIFO→FIFO BUG CLOSED+VERIFIED: the DEPOSIT completeness-audit-deferred degenerate-pick bug (vault 2026-06-04_deposit-005-impl-bug-latent) — degenerate carve-out ordered by abs(transaction_date_bkk − created_at) ASC (ranks NEWEST closest ⇒ LIFO) — is corrected to ORDER BY created_at ASC, request_id ASC (migration L258), proven by VERIFY assertions d005_ac2_degenerate_autopicks_FIFO_OLDEST + d005_ac2_NOT_lifo_newest_not_credited and double raw re-derivation in the seal.

SEAL DISCREPANCY (resolved, not a defect): investigator harness scored 13/14; the one RED (AC-1 dep_status=[undefined,pending]) was a DEPOSIT-001 deposit-create id-capture transport flake (orphan row, zero wallet logs = correct), orthogonal to DEPOSIT-005 logic; raw re-derivation confirms all 7. Flagged to harness owners; does not block seal.

NOT epic-done: §ADR-21 LIVE gate + owner ACCEPT is a separate per-EPIC step, NOT claimed. Board: next-pm_dep5pm_findings.md.

---
*Added via Oracle Learn*
