---
title: #drift — mobiz KTB payout stale-claim triage: latent double-spend defect, code-e
tags: [drift, money-safety, double-spend, mobiz, ktb, payout, withdrawal-queue, latent-defect]
created: 2026-05-16
source: pg-writer thread #129 assessment
project: github.com/kokarat/mobiz-payment-gateway
---

# #drift — mobiz KTB payout stale-claim triage: latent double-spend defect, code-e

#drift — mobiz KTB payout stale-claim triage: latent double-spend defect, code-exposed but ZERO realized loss in production (assessed 2026-05-16, thread #129)

## The defect (confirmed present in current mobiz)
KTB single-transfer is single-signer: the OTP-confirm click is the irreversible execute; the KTB transaction reference exists only on the post-execution success page. `scheduler/withdrawal_dispatcher.go:790-828` triages stale `processing` queue items (>10 min):
- `item.BankTransactionID != ""` → `MarkWaitingToReview` (safe, no refund)
- `item.BankTransactionID == ""` → `services.MarkFailed` → `processPostCompletion(item,"failed")` → auto-refunds amount+fee to client wallet (`services/withdrawalQueue.go:1435-1471`, op `payout_refund`).

The triage's safety hinges entirely on `bank_transaction_id`. For KTB single-transfer that field CANNOT be set before OTP-confirm (no txn ref exists pre-execute; `/bot/queue/:id/set-txn-id` is a maker-checker/SCB concept — "called by maker after submitting transfer"). So a KTB bot dying between OTP-confirm and success-page scrape leaves `bank_transaction_id=""` → triage hits the MarkFailed branch → auto-refund while money already left = double-spend. The bot's own `/bot/queue/:id/failed` path reaches the same `MarkFailed` refund. THE CODE IS GENUINELY EXPOSED.

## Recovery net (also confirmed in code) — why it self-heals
KTB embeds the request_id in the transfer description ("...TR to <acct> <name> PAY1776... <ref>..."). `services/transactionMatcher.go matchPayout` Priority-1 matches statements by that request_id against queue items in status [processing,success,failed]; `finalizePayout` then calls `ReconcileFailedPayoutToCompleted` (failed→completed, re-deducts wallet, op `payout_confirm_completed`). `tryReconcileAfterMarkFailed` does the same right after MarkFailed. So a genuine KTB double-spend auto-corrects once the bank statement is scraped+matched by request_id. Permanent loss requires the compound condition: crash in the OTP→scrape window AND the KTB statement is never scraped (account abandoned / scraper dead).

### Addendum (orchestrator, thread #129, 2026-05-16) — the recovery net is a deliberate workaround with client-visible churn
`ReconcileFailedPayoutToCompleted` is not an incidental "self-heal" — it is mobiz's **deliberate workaround** for this exact defect. Frame it as a recovery mechanism that leaks churn to the client, not a clean design:
- **Two callbacks** reach the client — `failed` first (`processPostCompletion(item,"failed")` → `EventPayoutFailed`), then `succeeded` when the statement match flips `failed → completed` (`EventPayoutCompleted`).
- The client wallet `balance` **flip-flops**: original debit (at payout create) → credited-back on the auto-fail refund (`payout_refund`) → re-debited on the reconcile. Three writes for one transfer.

Contrast: the next system (spec under thread #132) routes a stuck claim to `review` with callback held and freeze held — resolution emits exactly one callback and settles the wallet once, no churn.

## Production data — defect has NOT fired (dpay MCP, 2026-05-16)
- Definitive test: every KTB outgoing bank_statement whose DESCRIPTION embeds a PAY request_id (proof the bot executed that transfer) → 67,367 map to `completed` payouts, 10 to `cancelled` (bulk test-data cleanup, one test client, ฿10-194), **0 to `failed`**. No executed KTB transfer ended `failed`.
- The 11 KTB payouts auto-failed by the exact stale-triage message ("bot may have crashed before submit", ฿26,681): all 11 verified — NO outgoing debit in fully-covered statement history (8,477 rows, continuous); bot-down gaps in the timeline align. Triage's auto-fail+refund was CORRECT.
- 1,067 other "timeout" KTB failures: sampled 100 — all Playwright `locator.click: Timeout` at PRE-execute stages (add-recipient button, "ถัดไป"/Next button). Money never moved.
- 38 "failed payout w/ matched statement" + a similar cancelled set = matcher amount+account MIS-matches (statement's description request_id ≠ matched_request_id; the described id is a `completed` payout). Secondary matcher data-quality issue, not money loss.

## Disposition
Severity: latent HIGH (money-safety) in code; realized exposure = ฿0. NOT a live-loss emergency — no funds recovery needed. SHOULD be escalated for a code fix before it fires: the stale-triage MarkFailed branch and the bot `/failed` path should route KTB (any single-signer) source to `waiting_to_review` rather than auto-refunding, OR require a positive "transfer not submitted" proof before refunding. Same defect class theoretically applies to SCB after approver-confirm — out of this assessment's scope, worth a separate check. Code fix is outside pg-writer remit (assess+document only).

---
*Added via Oracle Learn*
