---
title: Flow `payout-auto-reconcile-from-statement` authored at HEAD 4aaec2c, 2026-04-22
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, flow:payout-auto-reconcile-from-statement, workflow-8, reverse-engineered, ratification-pending, payout, matcher, auto-reconcile, request-id-gate]
created: 2026-04-22
source: docs/flows/payout-auto-reconcile-from-statement.md@4aaec2c
project: github.com/kokarat/mobiz-payment-gateway
---

# Flow `payout-auto-reconcile-from-statement` authored at HEAD 4aaec2c, 2026-04-22

Flow `payout-auto-reconcile-from-statement` authored at HEAD 4aaec2c, 2026-04-22. The actor-visible intent: a payout the merchant saw as `failed` is corrected to `completed` in a later callback (zero additional client API calls between the two), when a subsequently-arriving bank-statement debit row carries the payout's `request_id` in the bank description — the `request_id` is the only disambiguator that proves the debit is for this specific payout. Scoped to the bank-statement-arrival trigger class via the 1-minute `direction="out"` matcher ticker, plus its two synchronous-ish and admin-manual variants; the parallel post-MarkFailed goroutine `tryReconcileAfterMarkFailed` is a different trigger class (queue event, not statement arrival) and remains owned by `payout-request.md` Step 10 / `withdrawal-queue-single-bot-transfer.md`. Auto-reconcile arms only on P1 (request_id) matches in `finalizePayout` (`byReqID=true`); P2 (full account) and P3 (last4 + bank code) link the statement but leave the payout failed for admin review — a deliberate safety cut that mirrors the sibling deposit flow's Q4c/Q4d answers (non-request-id matches on financial state transitions are too risky to auto-fire). Inside the reconcile helper, client wallet is re-deducted by amount+fee (undoing the MarkFailed refund), MDR is fanned out, queue flips to success, `confirm_completed_reason` serves both as the double-confirm guard and the canonical auto-reconcile signal. Idempotency honoured via `ErrPayoutAlreadyReconciled` so concurrent matcher + post-MarkFailed callers never double-commit.

---
*Added via Oracle Learn*
