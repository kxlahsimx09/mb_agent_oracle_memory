---
title: drift — DRIFT-19 deposit slip-fraud hardening + late-statement auto-confirm (fraud/financial)
tags:
  - technical-writer
  - repo:mobiz-payment-gateway
  - current
  - deposit
  - fraud
  - drift
created: 2026-06-17
source: controllers/DepositController.go:896-918,994-1009 + services/slipFraudCheck.go:190-217 + services/transactionMatcher.go finalizeCheckingDeposit @ 03d6383
related:
  - 2026-05-22_drift-thunder-deferred-happy-path-slip-fraud
  - 2026-06-17_decision-range-a011daf-03d6383-w1-sized-escalate
project: github.com/kokarat/mobiz-payment-gateway
---

# DRIFT-19 — Deposit slip-fraud hardening + late-statement auto-confirm, undocumented

Three related 2026-06 commits on the deposit/matcher surface, recorded as deferred drift (current-system.md §9 DRIFT-19). Fraud/financial-adjacent — **CC `security_auditor` + `code_reviewer`**. Tightens the DRIFT-15 happy-path slip-fraud gap.

Evidence (post-change @ 03d6383):
- **`8f29c29` #528 — duplicate-slip force-approve gate.** `UpdateDepositStatus` rejects status→`paid` with **`409 DUPLICATE_SLIP`** (original deposit id in body) when `slip_duplicate_of` is non-empty, UNLESS `input.Notes` contains the literal token `[force-approve]` (detected by `isAdminWithForceApprove(c, input.Notes)`, `controllers/DepositController.go:994-1009`). `slip_duplicate_of` is persisted by `ProcessSlipVerification` (`services/slipVerifyService.go:127`). Prevents admin double-credit on an already-matched slip.
- **`b88eccb` #529 — persisted external-destination warning.** Two new deposit fields `slip_dest_status` (`ok`/`mismatch`/`unverified`) + `slip_dest_account`, set at verify time by new `services/slipFraudCheck.go:190-217 EvaluateSlipDestination` (mask-aware last-4 for PromptPay, visible-digit substring for masked bank transfers, compared vs the deposit's PromptPay + system bank). Approve→paid hard-blocks only on `mismatch` (`controllers/DepositController.go:896-918`); `unverified` surfaces in UI but does not block (avoids false rejection of legit masked slips). Persisted so the warning survives every view. Production scan cited ~905 cases / ~1.07M THB over 90 days.
- **`e1964b8` #530 — late-statement auto-confirm of `checking` deposits.** New `services/transactionMatcher.go finalizeCheckingDeposit` flips a `checking`-status deposit (escalated because no statement landed within `slip_review_timeout_minutes`) to `paid` when a late statement matches, via atomic CAS requiring: `status="checking"` AND `is_matched!=true` AND no `slip_duplicate_of` (#528) AND `slip_dest_status!="mismatch"` (#529) AND exactly one candidate (`len(pool)==1`). Multi-candidate stays link-only for admin review. Shares `finalizeDepositFrom()` (wallet credit + MDR distribution + callback + transaction record). This was the dominant Thunder cost driver (matched-but-checking deposits previously still entered paid Thunder review).

Resolution path: folds into the W1-sized backlog; the §6.7 slip-fraud section + §3.2 deposit status machine need a W1 rewrite to cover these guards.
