---
title: drift — bank-bot — app.js:1244 single-transfer success call swaps positional par
tags: [technical-writer, repo:bank-bot, current, drift, bank-bot, withdrawal-queue, single-transfer, cross-repo-validation, for-bot-writer]
created: 2026-04-18
source: kokarat/bank-bot/app.js:1244 (HEAD 2026-04-18) vs kokarat/bank-bot/core/api.js:72-76; surfaced during W8 cross-repo validation for docs/flows/withdrawal-queue-dispatch-and-claim.md@252849e
project: github.com/kokarat/bank-bot
---

# drift — bank-bot — app.js:1244 single-transfer success call swaps positional par

drift — bank-bot — app.js:1244 single-transfer success call swaps positional params.

**Not pg-writer territory — flagged for bot-writer pickup.**

**File:line@head:** `kokarat/bank-bot/app.js:1244` (single-transfer flow; HEAD at discovery 2026-04-18 GMT+7).

**Divergence.** `core/api.js:72-76` declares:

```
async safeMarkSuccess(itemId, bankTransactionId = '', bankReference = '') { ... PUT /api/v1/bot/queue/:id/success { bank_transaction_id, bank_reference } }
```

Positional param order is `(itemId, bankTransactionId, bankReference)`. The **approver flow** at `app.js:957` calls this correctly: `safeMarkSuccess(itemId, bankTxnId, '')` — bankTxnId in slot 2, empty bank_reference in slot 3.

The **single-transfer flow** at `app.js:1244` calls it as: `safeMarkSuccess(itemId, bankRef, '')`. This puts the bank *reference* (not transaction id) into the `bankTransactionId` slot. The server then writes `bank_transaction_id = <bankRef>` onto `withdrawal_queue` + (for payout-source) onto `ts_payouts.bank_transaction_id` per the `dfafa78` #213 mirroring rule documented at `docs/current-system.md §6.1`. `bank_reference` is sent empty.

**Why:** Not intentional, as far as I can tell from code-read alone — approver flow shows the author knows the correct convention. Most likely a param-name collision (`bankRef` local variable shadowing intent) that slipped through because single-transfer is rarely exercised in dev.

**How to apply (bot-writer's judgment; pg-writer flags only per AGENTS.md §5a / §6 — code_reviewer does not author features, technical_writer does not change code behavior):**
- Confirm with dev/human that the intended single-transfer success payload is indeed "bank transaction id, not bank reference" — it almost certainly is, because downstream consumers (operator dashboard, CSV exports, `ts_payouts.bank_transaction_id`) expect the bank's transaction identifier.
- Fix: change `app.js:1244` to `safeMarkSuccess(itemId, bankTxnId, bankRef)` where `bankTxnId` is the correct local variable name from the single-transfer success return object (look at what the bank module returns and rename accordingly).
- Consider: adding a TypeScript-like jsdoc to `safeMarkSuccess` + a caller-side positional check to catch this class of bug at lint time.

**Downstream impact on mobiz-gateway data:**
- `withdrawal_queue.bank_transaction_id` on single-transfer-path successes carries a *bank reference* string, not a bank transaction id. Not fatal — both are opaque strings, both come from the bank, both are useful for operator debugging — but they have different semantics (transaction id is per-transaction unique; reference may be a reusable order reference).
- `ts_payouts.bank_transaction_id` for payouts that went through single-transfer path has the same mislabel. Cross-reference with operator-dashboard displays if this has caused confusion in incidents.
- `tryReconcileAfterMarkFailed` **is not affected** because it runs on `/failed` items and gates on `request_id` (bank statement description), not on `bank_transaction_id`.

**Scope tag note:** tagged `#repo:bank-bot + #drift` (not `#repo:cross`) because the fix lives entirely in bank-bot. The contract `core/api.js:72-76` defines is correct; only one call site violates it. Filed from `pg-writer-oracle` rather than `bot-writer-oracle` because the bug was surfaced during a cross-repo validation pass for W8 `withdrawal-queue-dispatch-and-claim`; bot-writer should take ownership of triage + fix when it runs W1/W2 next and sweeps its `#drift` learnings.

---
*Added via Oracle Learn*
