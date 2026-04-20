---
title: Flow `payout-confirm-completed` — admin-initiated reversal path from `failed` / 
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, payout-confirm-completed, reverse-engineered, ratification-pending, w8, payout, admin-action, waiting-to-review, callback, withdrawal-queue, mdr]
created: 2026-04-19
source: docs/flows/payout-confirm-completed.md@0d968fa + controllers/PayoutController.go:1735-2039@0d968fa + thread #22 + W8 trace a7dd9b6d-fea6-4123-a423-897b15950a51
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow `payout-confirm-completed` — admin-initiated reversal path from `failed` / 

Flow `payout-confirm-completed` — admin-initiated reversal path from `failed` / `waiting_to_review` back to `completed` on the payout rail. Endpoint `PUT /api/v1/payouts/:id/confirm-completed` (JWT, `payout:approve`). Entire ledger update lives inside a single Mongo session transaction: (1) atomic CAS on `ts_payouts` `{failed|waiting_to_review} → completed` with confirm-audit field stamping, (2) conditional wallet adjustment — re-deduct `amount+fee` with balance guard when previous was `failed`, skip deduction entirely when previous was `waiting_to_review` (the original Step-3 deduction from `POST /payout/create` still stands), (3) MDR fan-out inlined for transaction atomicity (skip-on-fail per partner, not the non-transactional `services.distributeMDRFees` helper), (4) `mdr_shared` row insert + `ts_payouts.mdr_distributions` mirror, (5) `withdrawal_queue` row flipped to `success` with `failed_at`/`error_message` unset. Async fan-out after commit: `completed` callback + SSE `confirmed_completed`. The `completed` callback is the first-and-only for `waiting_to_review` entry but the second for `failed` entry (preceded by `failed` callback from `MarkFailed`'s `processPostCompletion`). Claim strength S4 pending ratification via Oracle thread #22 (folds ratification + three open questions: (a) fail-closed on spent refund, (b) queue row rewrite loses failed history, (c) inline MDR vs `distributeMDRFees` helper divergence).

---
*Added via Oracle Learn*
