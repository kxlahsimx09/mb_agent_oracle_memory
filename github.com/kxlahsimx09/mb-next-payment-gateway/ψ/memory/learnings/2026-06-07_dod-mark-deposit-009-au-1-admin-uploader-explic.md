---
title: DoD-MARK — DEPOSIT-009 §AU-1 admin-uploader explicit-override policy at slip-upl
tags: [dod-mark, deposit-009, nextteam, au-1, admin-upload-gate, slice-dod]
created: 2026-06-07
source: next-pm dep9pm DoD-mark
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — DEPOSIT-009 §AU-1 admin-uploader explicit-override policy at slip-upl

DoD-MARK — DEPOSIT-009 §AU-1 admin-uploader explicit-override policy at slip-upload — DONE (slice-DoD, all 10 ACs in-slice). NOT epic-done: §ADR-21 LIVE gate + owner ACCEPT remain owner-only.

Marked by next-pm (campaign dep9pm) from ARTIFACTS ONLY — each of the 5 gates independently re-verified gate-to-artifact, never on any agent word.

DoD BOARD (5/5 gates PASS):

1. SPEC — PASS. docs/spec/deposit-009-admin-upload-gate-slice.md present on origin/main (landed via PR #336). Test-facing Step-0 contract; 10 ACs (AC1–AC10) enumerated with explicit AC→probe mapping (§3) + response matrix + bilingual AU1_REFUSED payload. Verified by git show origin/main.

2. BUILD — PASS. PR #336 MERGED (squash) → merge commit 2cb3e35; git merge-base --is-ancestor 2cb3e35 origin/main = YES. Delta = exactly 3 files: docs/spec doc; supabase/config.toml [functions.admin-deposit] verify_jwt=false (line 350); supabase/functions/admin-deposit/index.ts upload-slip case wired to check_admin_slip_upload_gate (line 114), RBAC deposit:upload-slip. NO migration touched (git show --name-only on 2cb3e35 shows zero migrations/ files). §AU-1 substrate pre-applied in mig 20260521000003_adr4d_v3_au1_bundled.sql (wrapper RPC + audit_log.admin_upload_override_audit_id cross-link + upload_slip 6-arg + admin_approve_paid most-recent-wins) — confirmed on origin/main.

3. REVIEW — PASS. PR #336 body opens ## VERDICT: APPROVE (next-code-reviewer; body verdict is merge gate — shared bot acct cannot self-approve). All 3 SPEC §0 reconciliation flags ruled: (a) EF placement in admin-deposit (adminAuth carries trusted user_type=admin; deposits-upload-slip clientAuth cannot, AC7) = PASS; (b) AC1/AC3 flip→deferred-sweep ADR-consistent (§ADR-4d D4 verdict-only-flip + §ADR-4b deferred-Thunder) = PASS; (c) AC6 400 V<n>_FRAUD vs AC7 409 AU1_REFUSED = PASS. next-code-reviewer_dep9review_findings.md corroborates: VERDICT APPROVE, all 10 ACs PASS, all 3 flags PASS. Two non-blocking concerns (pre-existing substrate edge; verify_jwt also unblocks pre-existing approve/reject) — out of slice scope.

4. VERIFY — PASS. Evidence evidence/integration-deposit-9-1780808079572-2a69d1c7.json on origin/campaign/dep9test (PR #337, NOT FOR MERGE): story=DEPOSIT-009, git_sha=2a69d1c72c2b... (matches 2a69d1c), summary {total:23, passed:23, failed:0}, bijection {ac_clauses:10, expected:10}, spec9_unbound=false, pending_bindings=[] (fully bound). Tester CAUGHT+fixed an AC10 probe bug (most-recent-wins ground-truth) — probe-side, not substrate.

5. SEAL — PASS. next-investigator_dep9seal_findings.md: Verdict SEALED on isolated seal stack qnccphgykzdydebmdwdf (independent of tester stack yupsevcrubgprsbujbpu). Tester d9 suite re-run by investigator → 23/23 PASS; investigator own raw re-derivation off truth-DB rows → 8/8 PASS. Every load-bearing claim re-derived from truth DB agrees with spec/ACs; no FAILs, no RECORDs. Code-under-test = origin/campaign/dep9dev @ 7c3efd7 (= squash-equivalent of merged 2cb3e35); substrate 20260521000003.

TRANSPARENCY NOTE (benign, documented): seal evidence file stamps git_sha=02a6dfc (harness rev-parse of seal worktree HEAD); actual deployed code-under-test is 7c3efd7 (dep9dev tip). Investigator explicitly recorded this harness-artifact ambiguity. Not a discrepancy in code under test — squash-merge of dep9dev (7c3efd7) is 2cb3e35 on main; tester evidence stamps 2a69d1c. All trace to the same EF wiring.

CONCLUSION: DEPOSIT-009 slice-DoD satisfied — SPEC + BUILD + REVIEW + VERIFY + SEAL all independently artifact-verified PASS across all 10 in-slice ACs.

---
*Added via Oracle Learn*
