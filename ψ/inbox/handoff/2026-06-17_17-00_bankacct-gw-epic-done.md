# Handoff: Gateway Beneficiary Bank-Account requirement epic — DONE (campaign doc-bankacct-gwepic)

**From:** next-writer (technical-writer, #next) · **To:** orchestrator (campaign owner slug `doc`)
**Date:** 2026-06-17 (GMT+7) · **Status:** COMPLETE, DOCUMENTS ONLY, NOT MERGED (owner-gated)

## Deliverable
- **File:** `docs/requirements/epic-beneficiary-bank-account.md` in `mb-next-payment-gateway` — Epic ID **BENE**, stories **BENE-001..007**, **249 lines** (≤250 cap). L1 requirement layer above §ADR-22; frames the value stream, does NOT duplicate the ADR's column-level detail; cross-references portal WUI-201..205 (does not restate them).
- **Also updated:** `docs/requirements/INDEX.md` (new BENE section) + `docs/requirements/README.md` (new Epic-index row, trust = dominant = **S2**).

## PR
- **PR #560** — https://github.com/kxlahsimx09/mb-next-payment-gateway/pull/560 (base `main`, branch `docs/bank-account-epic`). **DO NOT MERGE.**
- **NOTE — deviation from brief (forced by reality, P-004):** the brief said extend PR #557 on `arch/bank-account-ui-spec`, but **#557 ALREADY MERGED** (2026-06-17T09:40Z) — §ADR-22 is now on `main` and that branch is fully folded in. A merged PR cannot be reopened by pushing, so I branched off **current `origin/main`** (§3d) in an isolated worktree (§3c) and opened a **NEW** docs-only PR (#560) instead. Same content/scope; only the PR target changed. team-lead was notified at the start.

## Trust-label summary (per §ADR-22 — NOT re-graded)
- **BENE-001..006 = [S2 ratified]** — port-fidelity of a running production surface onto ratified §ADR-13 + §ADR-2 invariants (`#decision` class (a)), under owner "parity with current".
- **BENE-007 = [S3 provisional]** — the ENFORCED payout-destination linkage (§ADR-22 (b1)), `[RATIFICATION_PENDING:owner]` + `[ESCALATE_TO_HUMAN]`.
- **CONFIRMED: b1 was NOT upgraded to S2.** It stays S3 provisional with the escalate marker; current production has ZERO server-side registry↔payout linkage (free-form inline dest; GetApprovedBankAccounts is picker-only).

## Grounding (no invention, P-004)
Every story Sources block cites §ADR-22 + the current Go @ `03d6383` the ADR already cites (`models/bank_accounts.go`, `controllers/BankAccountController.go`, `routes/bankaccount.go`, `helpers/tenant_filters.go`) + the portal epic.

## Open owner items carried (from §ADR-22)
b1 (enforced payout linkage — material, BENE-007) · b3 (admin create-on-behalf, parity=self-only) · b4 (24h cooldown, backend unverified) · b5 (single-approver, parity).

## Hygiene
Isolated worktree removed; primary `mb-next-payment-gateway` never touched. arra_learn filed (#repo:mb-next-payment-gateway #vault #technical-writer #next #bank-account). Sidenote: the gateway primary is currently parked on `chore/wf7-migfix-v-system-banks-ff1725b` (not `main`) — pre-existing, not caused by me; I branched off `origin/main` so my base was correct regardless (§3d defense-in-depth).
