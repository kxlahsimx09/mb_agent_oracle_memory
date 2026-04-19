---
title: flow — payout-request — client-integrator intent: send THB out to an arbitrary d
tags: [technical-writer, repo:mobiz-payment-gateway, current, flow, payout-request, reverse-engineered, ratification-pending, payout, callback, withdrawal-queue, mdr, bank-bot, waiting-to-review]
created: 2026-04-18
source: docs/flows/payout-request.md@4e84ad5
project: github.com/kokarat/mobiz-payment-gateway
---

# flow — payout-request — client-integrator intent: send THB out to an arbitrary d

flow — payout-request — client-integrator intent: send THB out to an arbitrary destination bank account on the client's behalf, and notify the client by callback when the bank transfer settles (or fails / lands in admin review).

Three-phase contract from the actor's POV:

Phase 1 (synchronous, ~hundreds of ms): Client POST /api/v1/payout/create with HMAC-signed body → gateway validates (supported bankCode, rate limit, payout enable, amount range, idempotency key, maintenance mode, signature replay) → atomically deducts client wallet (amount + fee) with a wallets_change_logs `payout` row → persists ts_payouts(status=pending, system_bank_id empty) → returns 200 {txnId, amount, fee, feePercent, status:"pending"}. **Wallet is debited up front**, not on bank confirmation.

Phase 2 (async, sub-minute typical): Internal dispatcher (1-min ticker + onNewItem trigger) finds an idle system_bank that supports source_type=payout, locks it, and assigns its _id to one or more pending withdrawal_queue items (status stays "pending"). BankBot (kokarat/bank-bot) polls /api/v1/bot/queue/claim, atomically flips 1–5 random items pending→processing, executes the actual transfer on the bank portal via Playwright, and reports back via PUT /bot/queue/:id/{success,failed,waiting-to-review}.

Phase 3 (terminal): On success, MarkSuccess runs an atomic Mongo txn (queue→success, system_bank.balance −amount, payout→completed) then async fires the "completed" callback and distributes MDR shares to partner wallets. On failed, MarkFailed flips queue+payout→failed then async sends "failed" callback + refunds client wallet (amount+fee). On waiting_to_review, the queue+payout sit in waiting_to_review with NO wallet/MDR changes and NO callback until an admin POSTs PUT /api/v1/payouts/:id/confirm-completed (or a generic status update for the rejection branch).

Key non-obvious behaviours surfaced in the flow doc:

1. Post-fail auto-reconcile (services/withdrawalQueue.go:984 spawns tryReconcileAfterMarkFailed after MarkFailed commits) can flip a payout from failed back to completed if a matched bank_statement exists by request_id — this produces TWO callbacks for the same payout in known order: failed first, then completed. PR #189 narrowed the trigger; the dispatch shape was not changed. Open question (b) for the human to ratify the contract.

2. The system bank's balance is decremented by `amount`, not by `amount + fee`. The fee never leaves the gateway — it is split between the client (debited at Phase 1) and the partner wallets via distributeMDRFees at Phase 3. The system_banks row's `balance` only tracks money that physically left the bank.

3. The DB-insert-failure refund path at controllers/PayoutRequestController.go:411-422 calls AtomicBalanceAdd but writes NO wallets_change_logs row, leaving the Phase 1 deduction orphaned in the audit log. Open question (a).

4. There is `confirm-completed` for the waiting_to_review forward branch but no dedicated `confirm-failed` — admins use general UpdatePayoutStatus / OverridePayoutStatus to settle the rejection branch. Open question (c).

5. The legacy POST /payout/:txnId/cancel route is removed (DRIFT-5 already resolved); the CancelPayout handler still exists in the controller but is unreachable. There is no client-side cancel surface in this flow.

Source: docs/flows/payout-request.md@4e84ad5
W8 root trace: ba99f3b3-6e59-4348-8878-f180a1fee17e
Ratification thread: #8 (covers ratification + open questions a/b/c)

---
*Added via Oracle Learn*
