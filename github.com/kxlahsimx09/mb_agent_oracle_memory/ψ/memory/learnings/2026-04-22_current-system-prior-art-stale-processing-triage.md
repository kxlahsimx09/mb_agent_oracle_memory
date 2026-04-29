---
title: Current-system prior art — stale-processing triage via `bank_transaction_id` dis
tags: [system-architect, repo:mb-next-payment-gateway, repo:cross, repo:mobiz-payment-gateway, next, current, prior-art, withdrawal-queue, stale-processing, triage, waiting-to-review, failed, bank-transaction-id, double-spend-prevention, pr-249, w1-input-5]
created: 2026-04-22
source: scheduler/withdrawal_dispatcher.go:728-799 @ kokarat/mobiz-payment-gateway HEAD aa8cde8 (originating PR #249, commit 8bf3a52, 2026-04-20); production incident 2026-04-12 referenced in code comment
project: github.com/kxlahsimx09/mb_agent_oracle_memory
---

# Current-system prior art — stale-processing triage via `bank_transaction_id` dis

Current-system prior art — stale-processing triage via `bank_transaction_id` discriminator → `waiting_to_review` vs `failed` (NOT revert-to-pending).

Confirmed via direct read of `scheduler/withdrawal_dispatcher.go:728-799` at mobiz `aa8cde8` (2026-04-22 session, system-architect role, W1 Input 5). Originating PR #249, commit `8bf3a52` (2026-04-20, "Stale-timeout + post-fail reconcile → waiting_to_review").

## Question (surfaced by user reviewing ADR-4a pass-2 sweep design)

If a withdrawal-queue item is stuck in `claimed`/`processing` status for > 10 min (bot crashed mid-batch), should the sweep revert it to `pending` so another bot can re-claim?

## Answer from current code

**No — current system does NOT revert.** Stuck items are **triaged** by whether the bot had already submitted the transfer to the bank portal:

```go
// scheduler/withdrawal_dispatcher.go:770-797
for each stale item (status=processing, processed_at < now-10min):
    if item.BankTransactionID != "" {
        // Bot reached the submit step — money MAY have left the account
        MarkWaitingToReview(item.ID,
            "Processing timeout (10 min) after bot submitted transfer
             (bank_transaction_id present). Admin must verify via bank
             statement before refund.")
    } else {
        // Bot crashed BEFORE submit — safe to auto-resolve
        MarkFailed(item.ID,
            "Processing timeout (10 min) — bot may have crashed before
             submit. Check bank statement before retrying.")
    }
```

Neither branch reverts status. Both are terminal (failed) or terminal-but-non-final (waiting_to_review) — require human observation before any further automated action on the same amount.

## The `bank_transaction_id` checkpoint

Discriminator is set by the bot mid-batch via a dedicated endpoint. Bot workflow:

1. Receive broadcast → health check → claim batch (`pending → claimed → processing`).
2. For each item:
   - (a) Open maker form, fill fields.
   - (b) Get portal transaction reference number (before submit).
   - (c) **POST `/bot/set-txn-id { queue_id, bank_transaction_id }`** — checkpoint; DB now knows "bot reached pre-submit."
   - (d) Submit maker form.
   - (e) Approver step.
   - (f) Verify success page.
   - (g) `MarkSuccess`.

The checkpoint at (c) is the critical discriminator: if bot dies between (c) and (f), `bank_transaction_id IS NOT NULL` and the transfer MAY have completed at the portal. Auto-refund on `failed` would double-credit the client. So `waiting_to_review` gates further action pending admin's bank-statement verification.

## Why `MarkFailed` is safe, not just a status flip

Production incident 2026-04-12 (pre-PR #249): a prior attempt used bulk `UpdateMany` to set stuck items to `failed`. This updated only `withdrawal_queue.status` but skipped the full post-completion lifecycle. Consequences: 16 orphaned payouts — `ts_payouts` stuck in `processing` forever, wallet not refunded, client not called back, bank not unlocked. All 16 had to be fixed manually in the database.

PR #249's fix iterates per-item through `services.MarkFailed()` which runs `processPostCompletion`:

1. Update source document status (e.g., `ts_payouts → failed`).
2. Refund wallet (amount + fee) — crediting back what was debited at enqueue.
3. Send failure callback to client.
4. Unlock bank via `onBankItemDone` callback.

This is the contract the current system guarantees for `failed`. The next-system equivalent RPC (`resolve_failed_withdrawal_items()` or whatever shape) must preserve the same four-step lifecycle.

## Implications for `mb-next-payment-gateway` ADR-4a

The pass-2 sweep design is incorrect — it proposed `stale claimed → revert to pending`, which would recreate the bug class PR #249 closed. Correct design:

```
sweep_reclaim_stuck_items() returns table(id uuid, resolution text) AS $$
BEGIN
    -- Triage stale claimed items
    FOR r IN
        SELECT id, bank_transaction_id FROM withdrawal_queue
         WHERE status = 'claimed'
           AND claimed_at < now() - interval '10 minutes'
         FOR UPDATE SKIP LOCKED
    LOOP
        IF r.bank_transaction_id IS NOT NULL THEN
            PERFORM mark_waiting_to_review(r.id,
                'Processing timeout (10 min) after bot submitted transfer...');
            -- emit: waiting_to_review_triaged += 1
        ELSE
            PERFORM mark_failed(r.id,
                'Processing timeout (10 min) — bot may have crashed before submit...');
            -- emit: failed_triaged += 1
            -- mark_failed internally runs the 4-step lifecycle:
            --   1. Update source doc → 'failed'
            --   2. Wallet refund (amount + fee)
            --   3. Callback to client
            --   4. Unlock bank
        END IF;
    END LOOP;
END $$;
```

Additional schema requirements for next system:
- `withdrawal_queue.bank_transaction_id TEXT NULL` — bot writes pre-submit.
- Dedicated bot RPC `set_bank_transaction_id(queue_id, txn_id)` — authenticated to claimed_by bot only.
- `mark_waiting_to_review(id, reason)` + `mark_failed(id, reason)` RPCs — each runs full post-completion lifecycle.

## Why this matters for the design

Auto-revert looks clean but violates the **asymmetric-reversibility** property of bank transfers: a transfer submitted to the portal is **not reversible by us** without portal-side reconciliation. The safest default when state is uncertain is "stop automation, ask human" (`waiting_to_review`). The ADR's Layer 3 one-batch-per-bank invariant and Layer 2 pool isolation are both "automation guarantees correctness" mechanisms; the sweep triage is the "human catches what automation can't know" escape hatch.

This aligns with the `waiting_to_review` terminal-but-non-final design carried forward in ADR-4a — now it's also the target for stale-processing triage, not just "uncertain at success time."

## Cross-references

- Originating PR: `kokarat/mobiz-payment-gateway#249` (commit `8bf3a52`, 2026-04-20).
- Code: `scheduler/withdrawal_dispatcher.go:728-799` @ mobiz HEAD `aa8cde8`.
- Prior incident: 2026-04-12 bulk-UpdateMany → 16 orphaned payouts (cited in the code comment).
- Oracle thread #14 (mobiz, pending) — admin `waiting_to_review` resolution mechanism (open question for how admin decides confirm-vs-reject once in waiting_to_review).
- Cross-role: `bot-writer` owns the `/set-txn-id` checkpoint endpoint definition.

## Process note

Missed this in pass-2 W1 Input-5 pass because I read `services/withdrawalQueue.go` for enqueue semantics and didn't drill into `scheduler/withdrawal_dispatcher.go` deeply enough. This is the second pg-writer-territory read in the same ADR-4a refinement where the safer answer lived in the scheduler package. General lesson: when designing a sweep/safety-net, always read the current-system's own sweep implementation first — it encodes years of incident learnings.

## Tags

system-architect, repo:mb-next-payment-gateway, repo:cross, repo:mobiz-payment-gateway, next, current, prior-art, withdrawal-queue, stale-processing, triage, waiting-to-review, failed, bank-transaction-id, double-spend-prevention, pr-249, w1-input-5, pass-5-candidate

---
*Added via Oracle Learn*
