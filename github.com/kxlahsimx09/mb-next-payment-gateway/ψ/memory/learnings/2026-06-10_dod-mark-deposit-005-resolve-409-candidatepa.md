---
title: #dod-mark — DEPOSIT-005 resolve → 409 CANDIDATE_PAST_DEADLINE defined-error ADDE
tags: [dod-mark, deposit, deposit-005, in-slice-done, depmatch-b3, candidate-past-deadline, defined-error, nextteam, next-pm, simlive]
created: 2026-06-10
source: next-pm (campaign simlive) — DoD-mark
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# #dod-mark — DEPOSIT-005 resolve → 409 CANDIDATE_PAST_DEADLINE defined-error ADDE

#dod-mark — DEPOSIT-005 resolve → 409 CANDIDATE_PAST_DEADLINE defined-error ADDED — IN-SLICE-DONE (campaign simlive, marked by next-pm 2026-06-10 GMT+7).

Marked gate-to-artifact, FROM ARTIFACTS ONLY (merged-PR + review; never claims). Scope = the depmatch B3 defined-error addition (a past-deadline picked candidate now returns a clean 409 CANDIDATE_PAST_DEADLINE instead of a misleading "race"); NOT epic-done — the §ADR-21 LIVE gate + owner ACCEPT for epic-deposit is a separate per-EPIC step.

GATE BOARD (gate → artifact → result):
- AUTHORITY: next-architect_depmatch_proposal.md §6 B3 (+ §2); owner GO Option B 2026-06-10. PASS.
- CONFIRM-FINDING (dev-depmatch-B3-report.txt): traced in code, NOT assumed — a raw-pending past-deadline picked candidate today passes the deposit_not_pending gate, then finalize_deposit's deadline guard (expires_at > v_now) fails → NULL → outcome finalize_declined → EF 409 {error:finalize_declined, "race"} with NO guidance. That confusing non-result is what B3 fixes.
- BUILD: PR #373 MERGED to main — gh: state=MERGED, mergeCommit 469034546ec3fc14ac9963969fbd48f26b5f8d66, mergedAt 2026-06-10T11:38:08Z. Branch fix/deposit005-candidate-past-deadline-error, +151/-2, 4 surfaces: NEW migration 20260610000002 (CREATE OR REPLACE admin_resolve_multi_candidate, SAME 5-arg sig → no overload; read-only pre-check on the §ADR-20 app_now() clock AFTER the not_pending gate, BEFORE finalize → RETURN 'candidate_past_deadline'), admin-deposit-resolve/index.ts maps it → 409 CANDIDATE_PAST_DEADLINE (distinct from ALREADY_FINALIZED) with next_action:"deposit-007-approve", spec §5b, ADR EW1 wire-pin. Shipped 20260519000008 + finalize_deposit guard confirmed UNTOUCHED. Migration orders cleanly after #371's 20260610000001, no collision. PASS.
- REVIEW: reviewer-373-report.txt — next-code-reviewer VERDICT APPROVE, no blockers; pre-check placement CORRECT, migration discipline CLEAN (function-only CREATE OR REPLACE, no schema change, safe on a deployed stack). PASS.
- CONSTRAINTS HONORED: NO bypass param on finalize_deposit (single-guard kept); §ADR-4b match guards + finalize deadline clause UNTOUCHED (Option B affirms them); new outcome DISTINCT from ALREADY_FINALIZED; detection in a thin RPC outcome, not by weakening the finalize guard.

DEFINED-ERROR ADDED: the admin's legitimate pick of a past-deadline candidate now yields a clean, actionable 409 CANDIDATE_PAST_DEADLINE (next_action deposit-007-approve), and finalize_declined now means a genuine concurrent race only.

DOCUMENTED IN-SLICE FOLLOW-UPS (named, NOT defects, do not block this mark):
- B3 path PROBE is next-tester's lane (seed a review-parked statement, picked candidate raw-pending past expires_at → assert 409 CANDIDATE_PAST_DEADLINE, distinct from ALREADY_FINALIZED, no finalize, no credit) — flagged in PR #373, NOT yet authored.
- B1 §ADR-4c §Amendment 2026-06-10 is next-architect's lane, not yet landed; PR #373 forward-references it (surgical EW1 edit, disjoint, low conflict).
- Pre-existing (out of B3 scope, flagged for next-architect): ALREADY_FINALIZED (picked candidate concurrently went paid/matched) still surfaces as 500 admin_resolve_failed (finalize P0001 raise), not a clean 409.

SCOPE DISCIPLINE: claimed "DEPOSIT-005 B3 defined-error: code-landed + reviewer-APPROVE (in-slice-done)" — NOT "epic done", and NOT "probe-verified" (the B3 path probe is a documented next-tester follow-up). The §ADR-21 LIVE gate + owner ACCEPT remain the separate per-EPIC step.

---
*Added via Oracle Learn*
