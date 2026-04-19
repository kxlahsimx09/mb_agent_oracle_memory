---
title: flow — payout-request — ratified revision (S4 → S2 via Oracle thread #8).
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, payout-request, ratified, revision, payout, callback, withdrawal-queue, mdr, bank-bot, waiting-to-review]
created: 2026-04-18
source: docs/flows/payout-request.md@4e84ad5 + thread #8 closed
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — payout-request — ratified revision (S4 → S2 via Oracle thread #8).

flow — payout-request — ratified revision (S4 → S2 via Oracle thread #8).

Spec ratified by human on 2026-04-18 (GMT+7). Three open questions (a)/(b)/(c) all classified as gaps to fix later — not intentional design. Doc claim strength upgraded S4 → S2; [RATIFICATION_PENDING:8] stripped from header → // ratified-via-thread:8; three [AWAITING_THREAD:8] inline markers stripped → // verified-via-thread:8 annotations on each resolved question; thread #8 closed.

Ratified intent (one paragraph):

Clients integrate with the gateway to push money to arbitrary destination bank accounts without holding bank credentials. The gateway debits the client wallet up front (amount + MDR fee, atomically with audit), persists ts_payouts(status=pending), and enqueues to withdrawal_queue. An internal dispatcher (1-min ticker + onNewItem) locks an idle system_bank supporting source_type=payout and assigns its _id to pending items. The bank-bot (kokarat/bank-bot) claims items via /bot/queue/claim (1-5 random, FIFO within priority), executes the actual transfer on the bank portal, and reports back via PUT /bot/queue/:id/{success,failed,waiting-to-review}. Success: atomic txn flips queue+payout to completed, decrements system_bank.balance by amount (NOT amount+fee — fee never leaves the gateway), increments daily_transactions; async sends "completed" callback + distributes MDR to partner wallets. Failed: callback "failed" + refund wallet; goroutine tryReconcileAfterMarkFailed may flip back to completed if a matched bank_statement exists (yields a second "completed" callback — known race, see drift learning b). Waiting-to-review: payout/queue sit in waiting_to_review with NO wallet/MDR change and NO callback until admin PUT /api/v1/payouts/:id/confirm-completed (or generic UpdatePayoutStatus for the rejection branch — known asymmetry, see drift learning c).

Three known gaps queued for W4 (filed today, separate learnings):
- 2026-04-18_drift-flowpayout-request-a-wallet-refund-on-d (audit-log gap on insert-failure refund)
- 2026-04-18_drift-flowpayout-request-b-double-callback-fo (undocumented double-callback contract on auto-reconcile)
- 2026-04-18_drift-flowpayout-request-c-confirm-completed (no confirm-failed paired endpoint)

Source: docs/flows/payout-request.md@&lt;ratification-commit&gt; + thread #8 (closed)
W8 root trace: ba99f3b3-6e59-4348-8878-f180a1fee17e
Supersedes: learning_2026-04-18_flow-payout-request-client-integrator-intent (ratification-pending → ratified)

---
*Added via Oracle Learn*
