---
title: DoD-MARK — DEPOSIT-010 (client self-cancel of a pending slipless deposit → callb
tags: [dod-mark, deposit-010, nextteam, client-cancel, cancelled-callback-silent, adr-4c-atomic-cancel, adr-13-f4-tenant-scope, five-gate-dod, in-slice-done-not-epic-done]
created: 2026-06-07
source: next-pm dep10pm DoD-mark
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# DoD-MARK — DEPOSIT-010 (client self-cancel of a pending slipless deposit → callb

DoD-MARK — DEPOSIT-010 (client self-cancel of a pending slipless deposit → callback-silent cancelled terminal) — IN-SLICE DONE
campaign: dep10pm | marker: next-pm | date: 2026-06-07 | repo: kxlahsimx09/mb-next-payment-gateway
Marked from ARTIFACTS ONLY; each of the 5 gates independently re-verified gate-to-artifact. Scope = all 5 in-slice ACs. NOT epic-done (ADR-21 LIVE gate + owner ACCEPT are owner-only — explicitly excluded).

DoD BOARD — 5/5 gates PASS:

[1] SPEC — PASS
  Artifact: docs/spec/deposit-010-client-cancel-slice.md (status: published, 174 lines).
  Re-verify: git cat-file confirms file present on origin/main. Self-contained test-facing contract: API contract (200/409 NOT_PENDING|SLIP_PRESENT/403/404/401/400/405), atomic cancel_deposit RPC §2, DB observable surface O1-O6, AC→probe map AC1-AC5, build delta §5. Binding sources cited (epic-deposit DEPOSIT-010 S2; ADR-4c, ADR-4b D5, ADR-13 F4, ADR-9/DEPOSIT-004 taxonomy).

[2] BUILD — PASS
  Artifact: PR #341 MERGED, squash 2746a84.
  Re-verify: gh shows PR #341 state=MERGED, mergeCommit 2746a84a; git merge-base --is-ancestor 2746a84 origin/main => TRUE. Delta (354 insertions, 4 files) content-checked:
    • NEW EF supabase/functions/deposits-cancel/index.ts — adminAuth → §ADR-13 F4 tenantScopeVerdict (admin bypass; 403 cross_tenant_access_denied) → cancel_deposit RPC → HTTP map; mirrors deposit-resend-callback (DEPOSIT-012) auth model, NOT X-Client-Id clientAuth. No RBAC gate (ratified ACs name only tenant-scope).
    • NEW migration 20260607000001_deposit010_client_cancel.sql — cancel_deposit(p_deposit_id, p_now) SECURITY DEFINER: SELECT FOR UPDATE lock → re-confirm status='pending' AND slip_uploaded_at IS NULL under lock → flip to 'cancelled' + stamp cancelled_at (app_now, §ADR-20 T4) in one txn → NO callback enqueue. ALTER TABLE adds cancelled_at. Structurally mirrors expire_deposit. jsonb outcome (cancelled/not_found/not_pending/slip_present).
    • config.toml — [functions.deposits-cancel] verify_jwt=false (unsigned stub bearer; closes DEPOSIT-008 platform-gate 401 class).

[3] REVIEW — PASS
  Artifact: next-code-reviewer VERDICT in PR #341 body + next-code-reviewer_dep10review_findings.md.
  Re-verify: gh pr view 341 body contains "## VERDICT: APPROVE" (next-code-reviewer, dep10review), with per-file review + AC coverage table (AC1-AC5) + validation on dev-1 qvmjywljrgqzyxshexhx.

[4] VERIFY — PASS
  Artifact: next-tester 12/12 GREEN, evidence integration-deposit-10-1780811478517-177dc4d9.json on campaign/dep10test (PR #340 OPEN [NOT FOR MERGE]).
  Re-verify: evidence JSON on origin/campaign/dep10test — git_sha 177dc4d9790cd9b07bbb33129a55848b66fd2b9e, summary {total:12, passed:12, failed:0}, bijection {ac_clauses:5, expected:5}, spec10_unbound=false, pending_bindings=[]. All 12 assertions status=true spanning AC1-AC5 (incl. callback-silent O3, finalize race-guard abort + credit-on-pending contrast, cross-tenant 403 + in-tenant success contrast, daily-slot-not-decremented). Commit 9da387c (GREEN evidence) is dep10test head; rebind commit 177dc4d. Note: an initial run had 4 fails (AC3 finalize-setup race, AC4 cross-tenant) the tester traced to PROBE bugs; rebound suite to published SPEC, re-ran to 12/12 GREEN — substrate correct, AC4 tenant-scope sound.

[5] SEAL — PASS
  Artifact: next-investigator SEALED on isolated seal stack qnccphgykzdydebmdwdf; next-investigator_dep10seal_findings.md.
  Re-verify: investigator independent re-derivation — all 5 ACs + 6 load-bearing claims re-derived PASS from the truth DB on an isolated stack, no FAIL. (Findings file is an agent-output artifact, not git-committed — consistent with prior nextteam seals which persist as arra learnings, e.g. dep34seal.)

CONCLUSION: DEPOSIT-010 is IN-SLICE DONE — all 5 gates PASS, no FAIL, all 5 ACs covered. Epic-done withheld: §ADR-21 LIVE gate + owner ACCEPT remain owner-only.

---
*Added via Oracle Learn*
