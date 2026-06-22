---
title: Gateway requirement epic for the Beneficiary Bank-Account Registry — authored as
tags: [repo:mb-next-payment-gateway, vault, technical-writer, next, bank-account, requirements, ADR-22, trust-labels, merged-PR-adaptation]
created: 2026-06-17
source: next-writer (technical-writer), campaign doc-bankacct-gwepic
project: github.com/kxlahsimx09/mb-next-payment-gateway
---

# Gateway requirement epic for the Beneficiary Bank-Account Registry — authored as

Gateway requirement epic for the Beneficiary Bank-Account Registry — authored as docs/requirements/epic-beneficiary-bank-account.md (Epic ID BENE, BENE-001..007), the L1 requirement layer above §ADR-22.

Tags: #repo:mb-next-payment-gateway #vault #technical-writer #next #bank-account

WHAT: Ported §ADR-22 (P1–P4) into a readable L1 epic framing the backend value stream (clients/partners self-register destination settlement/topup accounts → admin approve/reject → owner set-default; advisory-only, no enforced payout linkage = parity with current). Stories: BENE-001 self-service submit (admin REFUSED at create), BENE-002 admin approve/reject (one bank-account:approve perm), BENE-003 set-default (approved-only), BENE-004 owner edit/delete own-pending + super_admin bypass, BENE-005 owner-isolation RLS read + admin cross-tenant leak-safe read, BENE-006 new §ADR-13 F3 `bank-account` RBAC resource, BENE-007 payout-destination linkage fork. Updated INDEX.md (new BENE section) + README.md (Epic-index row). 249 lines (≤250 cap). Every story Sources block cites §ADR-22 + current Go @ 03d6383 (models/bank_accounts.go, controllers/BankAccountController.go, routes/bankaccount.go, helpers/tenant_filters.go) + portal epic.

TRUST DISCIPLINE (per §ADR-22, NOT re-graded): BENE-001..006 = S2 ratified (port-fidelity class (a)); BENE-007 ENFORCED payout-destination linkage = S3 provisional, [RATIFICATION_PENDING:owner] + [ESCALATE_TO_HUMAN] — current has ZERO server-side registry↔payout linkage (ts_payouts.dest_* free-form, GetApprovedBankAccounts is picker-only). b1 was NOT upgraded to S2.

ADAPTATION (reality-first, P-004): the brief said extend PR #557 on branch arch/bank-account-ui-spec, but #557 had ALREADY MERGED (2026-06-17T09:40Z) — §ADR-22 is on origin/main and the branch is fully folded in. Pushing to a merged PR's branch does NOT reopen it. Correct move: branch off CURRENT origin/main (§3d) in an isolated worktree (§3c), open a NEW docs-only PR = PR #560 (base main, DO NOT MERGE, owner-gated). Lesson: before adding to a named PR, verify gh pr view <n> --json state — a brief written earlier may assume an open PR that has since merged.

---
*Added via Oracle Learn*
