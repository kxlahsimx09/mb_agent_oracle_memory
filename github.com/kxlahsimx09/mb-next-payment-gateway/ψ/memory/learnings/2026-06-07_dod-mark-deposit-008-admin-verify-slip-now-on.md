---
title: DoD-MARK — DEPOSIT-008 (admin verify-slip-now / on-demand Thunder re-verify) — D
tags: [dod-mark, deposit-008, nextteam, dep8pm, verify-slip-now, adr-4d, adr-13]
created: 2026-06-07
source: next-pm dep8pm DoD-mark
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — DEPOSIT-008 (admin verify-slip-now / on-demand Thunder re-verify) — D

DoD-MARK — DEPOSIT-008 (admin verify-slip-now / on-demand Thunder re-verify) — DoD-DONE (in-slice, all 9 ACs). NOT epic-done (§ADR-21 LIVE gate + owner ACCEPT are separate, owner-only).

Marked by next-pm (campaign dep8pm) from ARTIFACTS ONLY; each of the 5 gates independently re-verified gate-to-artifact, never on agent word.

GATE 1 — SPEC ✅ docs/spec/deposit-008-verify-now-slice.md present on origin/main (status: published). Self-contained test-facing contract: POST /functions/v1/admin-deposit-verify-now, slip_verify_attempts append-only + ts_deposits denorm surface, 9 AC→probe mapping, RBAC perm = deposit:verify-slip (ADR-13 F3 flat). Binding to ADR-4d D4/D5/D8/D9 + 2026-05-20 verdict-only-flip amendment.

GATE 2 — BUILD ✅ PR #334 MERGED (squash 02a6dfc), git merge-base --is-ancestor 02a6dfc origin/main = TRUE. Delta byte-verified on origin/main:
  - RBAC rename deposit:verify-slip-now → deposit:verify-slip in EF index.ts (requirePermission L76), _shared/admin-auth.ts super_admin grant (L57), poc middleware admin-auth-core.ts (L51).
  - supabase/config.toml [functions.admin-deposit-verify-now] verify_jwt = false (L340-341).
  - Step-0 SPEC committed.
  - Residual old "deposit:verify-slip-now" string exists ONLY in frozen historical evidence JSON (2026-05-20/21 hosted runs), not in any active grant map/source.

GATE 3 — REVIEW ✅ next-code-reviewer posted "## VERDICT: APPROVE" in PR #334 body (the gate per build-workflow Step 3; gh review-state COMMENTED/empty by design). next-code-reviewer_dep8review_findings.md: Dim1 MEETS REQ+ADR ✅, Dim2 CODE CLEAN ✅ (2 cosmetic comment-drift nits, non-blocking), Dim3 PERF ✅ — APPROVE.

GATE 4 — VERIFY ✅ next-tester PR #335 [NOT FOR MERGE] on campaign/dep8test, head commit 553881f (RE-RUN). Evidence evidence/integration-deposit-8-1780803286883-d0a283ae.json: summary {total:16, passed:16, failed:0} = 16/16 GREEN; bijection {ac_clauses:9, expected:9}; spec8_unbound=false; pending_bindings=[]; git_sha d0a283ae; stack yupsevcrubgprsbujbpu. De-bias workflow caught 2 real pre-prod gaps, both fixed pre-merge: (1) AC8 perm-rename not yet deployed to stack; (2) Supabase platform verify_jwt gate ON 401ing the ADR-13 stub bearer (config.toml lacked verify_jwt=false).

GATE 5 — SEAL ✅ next-investigator EPIC SEALED on isolated seal stack qnccphgykzdydebmdwdf. next-investigator_dep8seal_findings.md: verdict SEALED, 74 PASS / 0 FAIL / 0 RECORD; all 9 ACs + 4 mandated load-bearing claims (verdict-only-flip; append-only one-row-per-outcome; RBAC deposit:verify-slip 403; admin-owns-terminal no-auto-reject) independently raw-derived GREEN from the truth DB.

DoD BOARD: SPEC ✅ | BUILD ✅ | REVIEW ✅ | VERIFY ✅ | SEAL ✅ → DEPOSIT-008 DoD-DONE (all 9 ACs in-slice). Epic-done deferred to §ADR-21 LIVE gate + owner ACCEPT.

---
*Added via Oracle Learn*
