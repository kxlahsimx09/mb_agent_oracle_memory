---
title: drift — bank-bot — bankRef in wrong positional slot (corrected framing).
tags: [technical-writer, repo:bank-bot, current, drift, bank-bot, withdrawal-queue, single-transfer, corrected-framing, for-bot-writer, bankref-slot]
created: 2026-04-18
source: kokarat/bank-bot/app.js:1629,1695 + core/api.js:72 (HEAD bbd1616); supersedes 2026-04-18_drift-bank-bot-appjs1244-single-transfer-suc
project: github.com/kokarat/bank-bot
---

# drift — bank-bot — bankRef in wrong positional slot (corrected framing).

drift — bank-bot — bankRef in wrong positional slot (corrected framing).

**Revises `2026-04-18_drift-bank-bot-appjs1244-single-transfer-suc` — original framing was slightly off. This is the corrected version.**

**Not pg-writer territory — flagged for bot-writer pickup.**

**File:lines@head:** `kokarat/bank-bot/app.js:1629` (batch-transfer branch, KTB) and `:1695` (single-item branch) at HEAD `bbd1616`.

**Divergence.** `core/api.js:72` declares the signature:

```js
async markSuccess(itemId, bankTransactionId = '', bankReference = '') { ... }
```

Positional params: `(itemId, bankTransactionId, bankReference)`. The **approver flow** at `app.js:957` calls it correctly for dual-control: `safeMarkSuccess(batchItem.id, batchItem.bankTxnId, '')` — dual-control *has* a distinct `bankTxnId` captured at maker's `set-txn-id` call, and passes it in slot 2. Bank reference is empty because SCB's dual-control doesn't surface a separate reference string.

The **single-transfer flow** calls it as:

```js
// app.js:1629 (batch) and :1695 (single)
await safeMarkSuccess(itemId, result.bankRef || '', '');
```

Single-transfer captures only **one** identifier from the bank's success page (`bankRef`, scraped at `banks/ktb/transfer.js:55,105-106`); there is no separate bank-transaction-id. Passing `bankRef` in slot 2 means gateway receives `bank_transaction_id = <bankRef>` and `bank_reference = ""`.

**Correction vs original filing.** My earlier `…-appjs1244-single-transfer-suc` learning claimed the fix was `safeMarkSuccess(itemId, bankTxnId, bankRef)` — implying a `bankTxnId` also existed and just needed to be added. That was wrong. Single-transfer has no `bankTxnId` at all. Correct fix:

```js
await safeMarkSuccess(itemId, '', result.bankRef || '');  // empty slot 2, bankRef slot 3
```

**Why it happened (speculation):** the `bankRef` local variable name suggested "bank reference" but the positional-param convention put it in the "transaction id" slot because slot 2 came first — easy to miss when writing, easy to miss when reviewing if you don't have the `markSuccess` signature open. Approver flow got it right because the dual-control data model separates maker's-txn-id and any reference.

**Downstream impact on mobiz-gateway data (unchanged from original filing, but clearer framing):**
- `withdrawal_queue.bank_transaction_id` for single-transfer successes carries the bank reference (KTB receipt number), not a transaction identifier.
- `ts_payouts.bank_transaction_id` (mirrored from queue per PR #213 / commit `dfafa78`) for KTB-completed payouts carries the same.
- Operator dashboards / CSV exports that label this column as "Bank Txn ID" are semantically wrong for KTB-completed rows. Not fatal; both values are opaque-bank-strings that operators use for debugging. But a query that tries to match `bank_transaction_id` against a bank-side transaction-id system will never hit for KTB rows.
- `tryReconcileAfterMarkFailed` **is not affected** (it gates on `request_id` in the bank statement description, not on `bank_transaction_id`).

**How to apply (bot-writer's judgment):**
- Option A (minimal): change `app.js:1629,1695` to `safeMarkSuccess(itemId, '', result.bankRef || '')`. Two-line fix.
- Option B (defensive): add a TypeScript-like JSDoc to `safeMarkSuccess` + a runtime assertion that slot 2 looks like a bank-transaction-id (format validation) — catches this class of bug at lint or runtime.
- Migration concern: existing queue rows + payout rows for KTB-completed items have bankRef in the `bank_transaction_id` field. A one-off data backfill (`UPDATE` to move value from `bank_transaction_id` to `bank_reference` for KTB-completed rows) is possible but unnecessary — the string is still useful for debugging even in the wrong column, and operator ops team already know KTB behaviour.

**Scope tag note:** tagged `#repo:bank-bot + #drift + #corrected-framing`. Supersedes the earlier filing. Filed from `pg-writer-oracle` during W8 authoring of `docs/flows/withdrawal-queue-single-bot-transfer.md`.

---
*Added via Oracle Learn*
